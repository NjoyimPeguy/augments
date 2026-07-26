#!/usr/bin/env bash
# Stop-hook done-boundary test — ONE runner for every harness. NO API call.
#
# The hook reads only the Stop payload (stop_hook_active + the last message), so
# the whole policy is testable offline over crafted payloads. It must:
#   - re-nudge exactly once when a turn claims the work is done
#   - stay silent when already looped (stop_hook_active), or the turn claims nothing
#   - fail OPEN: a malformed payload must never block the harness
#
# Usage: tests/run-stop-nudge.sh --harness claude-code|codex|kimi-code
set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"
cd "$scriptdir/.." || exit 2
repo="$PWD"

harness=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --harness) harness="$2"; shift 2;;
    *) echo "unknown argument: $1" >&2; exit 2;;
  esac
done
[ -n "$harness" ] || { echo "needs --harness claude-code|codex|kimi-code" >&2; exit 2; }
[ -f "$scriptdir/harnesses/$harness.sh" ] || { echo "no harness adapter: $harness" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "needs \`jq\`" >&2; exit 3; }
. "$scriptdir/harnesses/$harness.sh"

hook="$(adapter_stop_hook)"
[ -f "$hook" ] || { echo "missing hook: $hook" >&2; exit 3; }

# Some harnesses need state on disk before the hook can resolve anything (Kimi
# recovers the assistant text from a session wire log). Set it up in THIS shell.
command -v adapter_stop_setup >/dev/null 2>&1 && adapter_stop_setup

fails=0
# Harnesses differ in HOW a hook blocks: Claude Code emits JSON on stdout and
# exits 0; Kimi exits 2 with the reason on stderr. "Did it fire?" therefore means
# "did it emit anything on either stream", not "did it print to stdout".
run() { adapter_stop_payload "$1" "$2" | bash "$hook" 2>&1; }
check() { # $1 desc  $2 expect(fire|quiet)  $3 active  $4 message
  local out; out="$(run "$3" "$4")"
  local fired=quiet; printf '%s' "$out" | grep -q . && fired=fire
  if [ "$fired" = "$2" ]; then printf '  ok    %s\n' "$1"
  else printf '  FAIL  %s (expected %s, got %s)\n' "$1" "$2" "$fired"; fails=1; fi
}

echo "harness: $harness"
check "re-nudges on a done claim"        fire  false "All tests pass. The feature is complete and working."
check "silent when already looped"       quiet true  "All tests pass. The feature is complete."
check "silent on a non-completion turn"  quiet false "Here are three options for the cache layout."
# Fail-open: garbage in must not block the harness.
if printf 'not json' | bash "$hook" >/dev/null 2>&1; then printf '  ok    fails open on malformed payload\n'
else printf '  FAIL  fails open on malformed payload\n'; fails=1; fi

[ "$fails" -eq 0 ] && echo "stop-nudge: PASS" || echo "stop-nudge: FAIL"
exit "$fails"
