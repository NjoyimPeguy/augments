#!/usr/bin/env bash
# Stop-hook done-boundary re-nudge for harnesses that provide the Claude-style
# Stop payload fields this script reads. The detection policy is shared with
# the Kimi wrapper in hooks/stop-nudge-detect.sh; this script only adapts the
# payload (last_assistant_message inline) and the block format (JSON envelope).
set -euo pipefail
command -v jq >/dev/null 2>&1 || exit 0
input="$(cat)"
get() { printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null; }

# Never loop: if our own block is what resumed the agent, let this stop stand.
[ "$(get '.stop_hook_active')" = "true" ] && exit 0

reason="$(get '.last_assistant_message' | bash "$(dirname "${BASH_SOURCE[0]}")/stop-nudge-detect.sh")" || exit 0

esc="$reason"; esc="${esc//\\/\\\\}"; esc="${esc//\"/\\\"}"; esc="${esc//$'\n'/\\n}"
printf '{"decision":"block","reason":"%s"}\n' "$esc"
