#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2
G=scripts/sh/implementation-guard.sh
T=/tmp/guard-transcript.jsonl
fails=0
check() { # $1 desc  $2 expected(allow|deny)  $3 actual-output
  local kind=allow
  printf '%s' "$3" | grep -q '"permissionDecision":"deny"' && kind=deny
  if [ "$kind" = "$2" ]; then echo "  ok    $1"; else echo "  FAIL  $1 (expected $2, got $kind)"; fails=1; fi
}

# transcript with both skills fired
cat > "$T" <<'EOF'
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"augments:test-driven-development"}}]}}
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"augments:yagni"}}]}}
EOF
out=$(printf '{"tool_name":"Write","tool_input":{"file_path":"/w/src/a.js"},"transcript_path":"%s"}' "$T" | bash $G)
check "code file, both skills fired -> allow" allow "$out"

# transcript with only TDD
cat > "$T" <<'EOF'
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"augments:test-driven-development"}}]}}
EOF
out=$(printf '{"tool_name":"Edit","tool_input":{"file_path":"/w/src/a.py"},"transcript_path":"%s"}' "$T" | bash $G)
check "code file, yagni missing -> deny" deny "$out"

# transcript with neither
: > "$T"
out=$(printf '{"tool_name":"Write","tool_input":{"file_path":"/w/lib/b.go"},"transcript_path":"%s"}' "$T" | bash $G)
check "code file, neither fired -> deny" deny "$out"
out=$(printf '{"tool_name":"Write","tool_input":{"file_path":"/w/README.md"},"transcript_path":"%s"}' "$T" | bash $G)
check "markdown file, neither fired -> allow" allow "$out"
out=$(printf '{"tool_name":"Write","tool_input":{"file_path":"/w/config.toml"},"transcript_path":"%s"}' "$T" | bash $G)
check "config file, neither fired -> allow" allow "$out"
out=$(printf '{"tool_name":"Bash","tool_input":{"command":"ls"},"transcript_path":"%s"}' "$T" | bash $G)
check "non-edit tool -> allow" allow "$out"
out=$(printf '{"tool_name":"Write","tool_input":{"file_path":"/w/src/a.js"}}' | bash $G)
check "missing transcript_path -> allow (fail open)" allow "$out"
out=$(printf 'not json at all' | bash $G)
check "malformed payload -> allow (fail open)" allow "$out"
out=$(printf '{"tool_name":"Write","tool_input":{"file_path":"/w/AGENTS.md"},"transcript_path":"%s"}' "$T" | bash $G)
check "AGENTS.md instruction file -> allow" allow "$out"


echo "--- kimi variant (ledger-based)"
GK=scripts/sh/implementation-guard.sh
L="${TMPDIR:-/tmp}/augments-skill-ledger-test-guard"; rm -f "$L"
kcheck() { # $1 desc  $2 expected(allow|deny)  $3 payload
  local out rc kind=allow
  out=$(printf '%s' "$3" | bash $GK 2>/dev/null); rc=$?
  [ "$rc" -eq 2 ] && kind=deny
  if [ "$kind" = "$2" ]; then echo "  ok    $1"; else echo "  FAIL  $1 (expected $2, got $kind)"; fails=1; fi
}
kpay() { printf '{"hook_event_name":"%s","session_id":"test-guard","cwd":"/w",%s}' "$1" "$2"; }

kcheck "kimi: code edit, no ledger -> deny" deny "$(kpay PreToolUse '"tool_name":"Write","tool_input":{"file_path":"/w/src/a.js"}')"
printf '%s' "$(kpay PostToolUse '"tool_name":"Skill","tool_input":{"skill":"augments:test-driven-development"}')" | bash $GK >/dev/null 2>&1
kcheck "kimi: code edit, only TDD recorded -> deny" deny "$(kpay PreToolUse '"tool_name":"Write","tool_input":{"file_path":"/w/src/a.js"}')"
printf '%s' "$(kpay PostToolUse '"tool_name":"Skill","tool_input":{"skill":"augments:yagni"}')" | bash $GK >/dev/null 2>&1
kcheck "kimi: code edit, pair recorded -> allow" allow "$(kpay PreToolUse '"tool_name":"Write","tool_input":{"file_path":"/w/src/a.js"}')"
kcheck "kimi: docs edit, no ledger needed -> allow" allow "$(kpay PreToolUse '"tool_name":"Edit","tool_input":{"file_path":"/w/README.md"}')"
kcheck "kimi: non-edit tool -> allow" allow "$(kpay PreToolUse '"tool_name":"Bash","tool_input":{"command":"ls"}')"
rm -f "$L"
kcheck "kimi: code edit, fresh session ledger -> deny" deny "$(kpay PreToolUse '"tool_name":"Write","tool_input":{"file_path":"/w/src/a.js"}')"
kcheck "kimi: malformed payload -> allow (fail open)" allow 'not json'
rm -f "$L"


echo "--- review-fix cases"
check "path fallback (.tool_input.path) -> deny" deny "$(printf '{"tool_name":"Write","tool_input":{"path":"/w/src/a.js"},"transcript_path":"%s"}' "$T" | bash $G)"
check "case-insensitive extension (.PY) -> deny" deny "$(printf '{"tool_name":"Write","tool_input":{"file_path":"/w/src/a.PY"},"transcript_path":"%s"}' "$T" | bash $G)"
check "NotebookEdit no longer guarded -> allow" allow "$(printf '{"tool_name":"NotebookEdit","tool_input":{"notebook_path":"/w/n.ipynb"},"transcript_path":"%s"}' "$T" | bash $G)"
check "new extension (.ps1) -> deny" deny "$(printf '{"tool_name":"Write","tool_input":{"file_path":"/w/deploy.ps1"},"transcript_path":"%s"}' "$T" | bash $G)"
kcheck "kimi: missing session_id -> allow (no shared bucket)" allow "$(printf '{"hook_event_name":"PreToolUse","cwd":"/w","tool_name":"Write","tool_input":{"file_path":"/w/src/a.js"}}')"
rm -f "${TMPDIR:-/tmp}/augments-skill-ledger-test-guard"
kcheck "kimi: missing ledger (fresh session) -> deny" deny "$(kpay PreToolUse '"tool_name":"Write","tool_input":{"file_path":"/w/src/a.js"}')"
printf '%s' "$(kpay PostToolUse '"tool_name":"Skill","tool_input":{"skill":"augments:yagni"}')" | bash $GK >/dev/null 2>&1
[ -f "${TMPDIR:-/tmp}/augments-skill-ledger-test-guard" ] && perms=$(stat -c '%a' "${TMPDIR:-/tmp}/augments-skill-ledger-test-guard") || perms=missing
[ "$perms" = "600" ] && echo "  ok    kimi: ledger created owner-only (600)" || { echo "  FAIL  kimi: ledger perms $perms (expected 600)"; fails=1; }
rm -f "${TMPDIR:-/tmp}/augments-skill-ledger-test-guard"


echo "--- realistic claude payloads (hook_event_name AND transcript_path present)"
# Real claude PreToolUse payloads carry hook_event_name too; routing must still
# choose the transcript branch (a misroute to the ledger branch denies forever).
: > "$T"
check "claude-style with hook_event_name, pair missing -> deny (transcript branch)" deny \
  "$(printf '{"hook_event_name":"PreToolUse","session_id":"s1","tool_name":"Write","tool_input":{"file_path":"/w/src/a.js"},"transcript_path":"%s"}' "$T" | bash $G)"
cat > "$T" <<'EOF'
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"augments:test-driven-development"}}]}}
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"augments:yagni"}}]}}
EOF
check "claude-style with hook_event_name, pair fired -> allow" allow \
  "$(printf '{"hook_event_name":"PreToolUse","session_id":"s1","tool_name":"Write","tool_input":{"file_path":"/w/src/a.js"},"transcript_path":"%s"}' "$T" | bash $G)"

echo "---"; [ "$fails" -eq 0 ] && { echo "guard offline tests: PASS (claude + kimi + review fixes)"; exit 0; } || { echo "guard offline tests: FAIL"; exit 1; }
