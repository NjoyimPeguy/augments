#!/usr/bin/env bash
# Offline contract for the scoped implementation-entry hook.
#
# This is not a universal file-mutation boundary. It covers the structured
# edit-class actions declared by the supported adapters and verifies that they
# cannot write a code path before both implementation disciplines have loaded.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

case "${1-}" in
  -h|--help)
    cat <<'EOF'
tests/run-implementation-guard.sh — check the scoped pre-edit hook contract.

Takes no arguments. Exercises Claude transcript evidence, Kimi native-skill
evidence, and Codex skill-file-read evidence without calling a model.

Exit codes: 0 every check passed · 1 at least one failed · 2 bad repository state
EOF
    exit 0;;
esac

guard=scripts/sh/implementation-guard.sh
[ -f "$guard" ] || { echo "FAIL: missing $guard"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "needs jq" >&2; exit 2; }

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
transcript="$tmpdir/transcript.jsonl"
fails=0

ok() { echo "  ok    $1"; }
bad() { echo "  FAIL  $1"; fails=1; }

if jq -e 'any(.hooks.PreToolUse[]?.hooks[]?; .command | contains("implementation-guard.sh"))' \
     hooks/hooks.json >/dev/null; then
  ok "Claude: PreToolUse installs the guard"
else
  bad "Claude: PreToolUse does not install the guard"
fi
if jq -e '
     any(.hooks.PreToolUse[]?.hooks[]?; .command | contains("implementation-guard.sh")) and
     any(.hooks.PostToolUse[]?.hooks[]?; .command | contains("implementation-guard.sh"))
   ' plugins/sdlc-skills/hooks/hooks.json >/dev/null; then
  ok "Codex: PreToolUse and PostToolUse install the guard"
else
  bad "Codex: guard lifecycle hooks are incomplete"
fi
if jq -e '
     any(.hooks[]?; .event == "PreToolUse" and (.command | contains("implementation-guard.sh"))) and
     any(.hooks[]?; .event == "PostToolUse" and (.command | contains("implementation-guard.sh")))
   ' .kimi-plugin/plugin.json >/dev/null; then
  ok "Kimi: PreToolUse and PostToolUse install the guard"
else
  bad "Kimi: guard lifecycle hooks are incomplete"
fi

claude_check() { # description expected payload
  local desc="$1" expected="$2" payload="$3" out actual=allow
  out="$(printf '%s' "$payload" | bash "$guard" 2>/dev/null)"
  printf '%s' "$out" | jq -e '.hookSpecificOutput.permissionDecision == "deny"' >/dev/null 2>&1 && actual=deny
  [ "$actual" = "$expected" ] && ok "$desc" || bad "$desc (expected $expected, got $actual)"
}

printf '%s\n' \
  '{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"sdlc-skills:test-driven-development"}}]}}' \
  > "$transcript"
claude_check "Claude: one discipline is insufficient" deny \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/w/src/a.py\"},\"transcript_path\":\"$transcript\"}"

printf '%s\n' \
  '{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"sdlc-skills:yagni"}}]}}' \
  >> "$transcript"
claude_check "Claude: both disciplines allow a code edit" allow \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"/w/src/a.py\"},\"transcript_path\":\"$transcript\"}"
claude_check "Claude: non-code writes stay outside the scoped boundary" allow \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"/w/README.md\"},\"transcript_path\":\"$transcript\"}"
claude_check "Claude: Bash is explicitly outside the Write/Edit-class boundary" allow \
  "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"touch src/a.py\"},\"transcript_path\":\"$transcript\"}"

kimi_payload() {
  printf '{"hook_event_name":"%s","session_id":"guard-test","tool_name":"%s","tool_input":%s}' "$1" "$2" "$3"
}
kimi_check() { # description expected payload
  local desc="$1" expected="$2" payload="$3" rc=0 actual=allow
  printf '%s' "$payload" | TMPDIR="$tmpdir" bash "$guard" >/dev/null 2>&1 || rc=$?
  [ "$rc" -eq 2 ] && actual=deny
  [ "$actual" = "$expected" ] && ok "$desc" || bad "$desc (expected $expected, got $actual; rc=$rc)"
}

kimi_check "Kimi: no discipline evidence denies a code edit" deny \
  "$(kimi_payload PreToolUse Write '{"file_path":"/w/src/a.rs"}')"
printf '%s' "$(kimi_payload PostToolUse Skill '{"skill":"sdlc-skills:test-driven-development"}')" \
  | TMPDIR="$tmpdir" bash "$guard" >/dev/null 2>&1
kimi_check "Kimi: one discipline is insufficient" deny \
  "$(kimi_payload PreToolUse Edit '{"file_path":"/w/src/a.rs"}')"
printf '%s' "$(kimi_payload PostToolUse Skill '{"skill":"sdlc-skills:yagni"}')" \
  | TMPDIR="$tmpdir" bash "$guard" >/dev/null 2>&1
kimi_check "Kimi: both disciplines allow a code edit" allow \
  "$(kimi_payload PreToolUse Edit '{"file_path":"/w/src/a.rs"}')"

codex_payload() {
  printf '{"hook_event_name":"%s","session_id":"codex-guard-test","tool_name":"%s","tool_input":%s}' "$1" "$2" "$3"
}
codex_check() { # description expected payload
  local desc="$1" expected="$2" payload="$3" out actual=allow
  out="$(printf '%s' "$payload" | TMPDIR="$tmpdir" bash "$guard" 2>/dev/null)"
  printf '%s' "$out" | jq -e '.hookSpecificOutput.permissionDecision == "deny"' >/dev/null 2>&1 && actual=deny
  [ "$actual" = "$expected" ] && ok "$desc" || bad "$desc (expected $expected, got $actual)"
}

patch_input='{"patch":"*** Begin Patch\n*** Update File: /w/src/a.py\n@@\n-old\n+new\n*** End Patch"}'
printf '%s' "$(codex_payload PostToolUse exec '{"cmd":"printf test-driven-development/SKILL.md"}')" \
  | TMPDIR="$tmpdir" bash "$guard" >/dev/null 2>&1
codex_check "Codex: mentioning a skill path is not loading it" deny \
  "$(codex_payload PreToolUse apply_patch "$patch_input")"
printf '%s' "$(codex_payload PostToolUse exec '{"cmd":"sed -n 1,200p /plugin/skills/test-driven-development/SKILL.md"}')" \
  | TMPDIR="$tmpdir" bash "$guard" >/dev/null 2>&1
codex_check "Codex: one read discipline is insufficient" deny \
  "$(codex_payload PreToolUse apply_patch "$patch_input")"
printf '%s' "$(codex_payload PostToolUse exec '{"cmd":"sed -n 1,200p /plugin/skills/yagni/SKILL.md"}')" \
  | TMPDIR="$tmpdir" bash "$guard" >/dev/null 2>&1
codex_check "Codex: both read disciplines allow apply_patch" allow \
  "$(codex_payload PreToolUse apply_patch "$patch_input")"
codex_check "Codex: non-code patches stay outside the scoped boundary" allow \
  "$(codex_payload PreToolUse apply_patch '{"patch":"*** Begin Patch\n*** Update File: /w/README.md\n@@\n-old\n+new\n*** End Patch"}')"

[ "$fails" -eq 0 ] && { echo "implementation guard: PASS"; exit 0; }
echo "implementation guard: FAIL"
exit 1
