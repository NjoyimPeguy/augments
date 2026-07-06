#!/usr/bin/env bash
# Stop-hook done-boundary re-nudge for harnesses that provide the Claude-style
# Stop payload fields this script reads.
set -euo pipefail
command -v jq >/dev/null 2>&1 || exit 0
input="$(cat)"
get() { printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null; }

# Never loop: if our own block is what resumed the agent, let this stop stand.
[ "$(get '.stop_hook_active')" = "true" ] && exit 0

last="$(get '.last_assistant_message' | tr '[:upper:]' '[:lower:]')"

# In-progress reports ("not done yet", "still failing") are not a done boundary.
printf '%s' "$last" | grep -Eq \
  'not (yet )?(done|complete|finished)|still (failing|broken|debugging)|not yet' && exit 0

# Only re-nudge on an actual completion claim.
printf '%s' "$last" | grep -Eq \
  '(^|[^a-z])(done|complete|completed|finished|fixed|passing|passes|works now|ready to (merge|ship)|good to go)([^a-z]|$)' \
  || exit 0

reason="$(cat <<'EOF'
You are wrapping up as if this task is done. Before it stands as done, re-orient with `using-augments` and invoke the done-boundary skill(s) it routes to: at minimum `verifying-completion` (run the real check, read its output, and claim only what that output supports), and at a feature boundary `requesting-code-review` and `finishing-a-branch`. If you have already verified with real evidence, state the exact command and its output here, then stop.
EOF
)"
esc="$reason"; esc="${esc//\\/\\\\}"; esc="${esc//\"/\\\"}"; esc="${esc//$'\n'/\\n}"
printf '{"decision":"block","reason":"%s"}\n' "$esc"
