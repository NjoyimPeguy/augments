#!/usr/bin/env bash
# Deterministic, offline test for the Kimi Stop-hook re-nudge.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
repo="$(cd "$here/../.." && pwd)"
hook="$repo/hooks/stop-nudge-kimi.sh"
command -v jq >/dev/null 2>&1 || { echo "test needs jq" >&2; exit 3; }
[ -f "$hook" ] || { echo "missing hook: $hook" >&2; exit 3; }
fail=0

fakehome="$(mktemp -d)"
trap 'rm -rf "$fakehome"' EXIT
session="session_test"
wiredir="$fakehome/sessions/wd_fixture/$session/agents/main"
mkdir -p "$wiredir"

write_wire() { # $1 = last assistant text
  jq -cn --arg m "$1" '
    {type:"turn.prompt", input:{text:"fixture"}},
    {type:"context.append_loop_event", event:{type:"content.part", part:{type:"think", think:"reasoning is not the message"}},
     },
    {type:"context.append_loop_event", event:{type:"content.part", part:{type:"text", text:$m}}}
  ' > "$wiredir/wire.jsonl"
}

run() { # $1 = stop_hook_active (true|false)
  jq -cn --argjson a "$1" --arg s "$session" \
    '{hook_event_name:"Stop", session_id:$s, cwd:"/tmp", stop_hook_active:$a}' |
    KIMI_CODE_HOME="$fakehome" bash "$hook"
}

expect_block() {
  local out rc
  write_wire "$2"
  out="$(run "${3:-false}" 2>&1)"; rc=$?
  if [ "$rc" -eq 2 ] && printf '%s' "$out" | grep -q 'verifying-completion'; then
    printf 'ok    %-22s re-nudges (exit 2)\n' "$1"
  else
    printf 'FAIL  %-22s expected exit 2 + reason, got rc=%s out=%s\n' "$1" "$rc" "${out:-<empty>}"
    fail=1
  fi
}

expect_allow() {
  local out rc
  write_wire "$2"
  out="$(run "${3:-false}" 2>&1)"; rc=$?
  if [ "$rc" -eq 0 ]; then
    printf 'ok    %-22s lets turn end\n' "$1"
  else
    printf 'FAIL  %-22s expected allow, got rc=%s out=%s\n' "$1" "$rc" "$out"
    fail=1
  fi
}

echo "== kimi stop-nudge detection (offline, payload + wire fixture) =="
expect_block "done-claim"    "Done. The rate limiter is implemented and the tests pass. Ready to merge."
expect_block "fixed-claim"   "Fixed - the null-pointer crash no longer reproduces."
expect_allow "in-progress"   "The tests are still failing - not done yet, I need to keep debugging."
expect_allow "no-claim"      "Here is how the module works. Want me to change the greeting format?"
expect_allow "loop-guard"    "Done. Everything passes." true

# Fail-open: no wire log for the session at all.
rm -f "$wiredir/wire.jsonl"
out="$(run false 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && [ -z "$out" ]; then
  printf 'ok    %-22s lets turn end\n' "missing-wire"
else
  printf 'FAIL  %-22s expected silent allow, got rc=%s out=%s\n' "missing-wire" "$rc" "$out"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS - Kimi stop-nudge blocks done-claims and fails open"
else
  echo "FAILED"
  exit 1
fi
