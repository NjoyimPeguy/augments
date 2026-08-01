#!/usr/bin/env bash
# Stop-hook done-boundary re-nudge for Kimi Code CLI — the Kimi adapter of
# scripts/sh/stop-nudge.sh. The detection policy is shared in
# scripts/sh/stop-nudge-detect.sh; this script only adapts the two harness
# differences: Kimi's Stop payload carries no last_assistant_message (the
# final assistant text is recovered from the session wire log), and Kimi's
# blocking contract is exit 2 with the reason on stderr, not a JSON envelope.
# Fail-open everywhere else.
set -uo pipefail
command -v jq >/dev/null 2>&1 || exit 0
input="$(cat)"
get() { printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null; }

# Never loop: if our own block is what resumed the agent, let this stop stand.
[ "$(get '.stop_hook_active')" = "true" ] && exit 0

session_id="$(get '.session_id')"
home="${KIMI_CODE_HOME:-${HOME:-}/.kimi-code}"
wire=""
for cand in "$home"/sessions/*/"$session_id"/agents/main/wire.jsonl; do
  [ -f "$cand" ] && { wire="$cand"; break; }
done
[ -n "$wire" ] || exit 0

# Last assistant text part in the wire log.
last="$(jq -rs '
  [ .[] | select(.type == "context.append_loop_event")
      | .event | select(.type == "content.part") | .part
      | select(.type == "text") | .text ] | last // empty
' "$wire" 2>/dev/null)"
[ -n "$last" ] || exit 0

reason="$(printf '%s' "$last" | bash "$(dirname "${BASH_SOURCE[0]}")/stop-nudge-detect.sh")" || exit 0
printf '%s\n' "$reason" >&2
exit 2
