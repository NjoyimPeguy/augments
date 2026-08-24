#!/usr/bin/env bash
# Offline contract for the scoped implementation-entry hook.
#
# This is not a universal file-mutation boundary. It covers the structured
# edit-class actions declared by the Claude and Kimi adapters and verifies that they
# cannot write a code path before both implementation disciplines have loaded.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

case "${1-}" in
  -h|--help)
    cat <<'EOF'
tests/run-implementation-guard.sh — check the scoped pre-edit hook contract.

Takes no arguments. Exercises Claude transcript evidence and Kimi native-skill
evidence without calling a model, and keeps receipt-backed Codex enforcement
retired.

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
if jq -e '.hooks | has("PreToolUse") or has("PostToolUse")' \
     plugins/sdlc-skills/hooks/hooks.json >/dev/null; then
  bad "Codex: structured edit lifecycle hooks are still installed"
else
  ok "Codex: no structured edit lifecycle hooks are installed"
fi
if [ -e plugins/sdlc-skills/scripts/sh/implementation-guard.sh ]; then
  bad "Codex: unused implementation guard mirror is still shipped"
else
  ok "Codex: implementation guard mirror is not shipped"
fi

codex_err="$tmpdir/codex-guard.err"
codex_status=0
codex_out="$(printf '%s' \
  '{"hook_event_name":"PreToolUse","session_id":"codex-guard-test","tool_name":"apply_patch","tool_input":"*** Begin Patch\n*** Update File: src/a.rs\n@@\n-old\n+new\n*** End Patch"}' \
  | TMPDIR="$tmpdir" bash "$guard" 2>"$codex_err")" || codex_status=$?
codex_stderr="$(cat "$codex_err")"
if [ "$codex_status" -ne 0 ]; then
  bad "Codex: shared guard exited nonzero for a Codex-shaped structured edit"
elif printf '%s' "$codex_out" | jq -e '.hookSpecificOutput.permissionDecision == "deny"' \
       >/dev/null 2>&1 ||
     printf '%s' "$codex_stderr" | jq -e '.hookSpecificOutput.permissionDecision == "deny"' \
       >/dev/null 2>&1; then
  bad "Codex: shared guard still denies a Codex-shaped structured edit"
else
  ok "Codex: shared guard ignores Codex-shaped structured edits"
fi

sync_repo="$tmpdir/sync-repo"
mkdir -p "$sync_repo/scripts/sh" "$sync_repo/skills/common/router" \
  "$sync_repo/plugins/sdlc-skills/scripts/sh"
cp scripts/sh/sync-codex-plugin-skills.sh scripts/sh/session-start.sh \
  "$sync_repo/scripts/sh/"
: > "$sync_repo/skills/common/router/SKILL.md"
: > "$sync_repo/plugins/sdlc-skills/scripts/sh/implementation-guard.sh"
if (cd "$sync_repo" && bash scripts/sh/sync-codex-plugin-skills.sh) &&
   [ ! -e "$sync_repo/plugins/sdlc-skills/scripts/sh/implementation-guard.sh" ] &&
   [ -x "$sync_repo/plugins/sdlc-skills/scripts/sh/session-start.sh" ] &&
   cmp -s scripts/sh/session-start.sh \
     "$sync_repo/plugins/sdlc-skills/scripts/sh/session-start.sh"; then
  ok "Codex: sync removes a stale guard and refreshes the router script"
else
  bad "Codex: sync does not retire the stale guard lifecycle cleanly"
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

[ "$fails" -eq 0 ] && { echo "implementation guard: PASS"; exit 0; }
echo "implementation guard: FAIL"
exit 1
