#!/usr/bin/env bash
# Deterministic, offline test for the Codex Stop-hook wrapper.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
repo="$(cd "$here/../../.." && pwd)"
hook="$repo/hooks/stop-nudge.sh"
command -v jq >/dev/null 2>&1 || { echo "test needs jq" >&2; exit 3; }
[ -f "$hook" ] || { echo "missing hook: $hook" >&2; exit 3; }
fail=0

run() { # $1 = stop_hook_active (true|false) ; $2 = last_assistant_message
  jq -cn --argjson a "$1" --arg m "$2" '{stop_hook_active:$a, last_assistant_message:$m}' | bash "$hook"
}

expect_block() {
  local out
  out="$(run "$2" "$3")"
  if printf '%s' "$out" | grep -q '"decision":"block"'; then
    printf 'ok    %-22s re-nudges\n' "$1"
  else
    printf 'FAIL  %-22s expected block, got: %s\n' "$1" "${out:-<empty>}"
    fail=1
  fi
}

expect_allow() {
  local out
  out="$(run "$2" "$3")"
  if [ -z "$out" ]; then
    printf 'ok    %-22s lets turn end\n' "$1"
  else
    printf 'FAIL  %-22s expected allow, got: %s\n' "$1" "$out"
    fail=1
  fi
}

echo "== codex stop-nudge detection (offline, payload-only) =="
expect_block "done-claim"    false "Done. The rate limiter is implemented and the tests pass. Ready to merge."
expect_block "fixed-claim"   false "Fixed - the null-pointer crash no longer reproduces."
expect_allow "in-progress"   false "The tests are still failing - not done yet, I need to keep debugging."
expect_allow "no-claim"      false "Here is how the module works. Want me to change the greeting format?"
expect_allow "loop-guard"    true  "Done. Everything passes."

if [ "$fail" -eq 0 ]; then
  echo "PASS - Codex wrapper delegates to the shared done-boundary detector"
else
  echo "FAILED"
  exit 1
fi
