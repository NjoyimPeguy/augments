#!/usr/bin/env bash
# Shared done-boundary detection for the Stop re-nudge wrappers.
#
# Reads the last assistant message on stdin. Exits 1 (no output) when the turn
# may end — in-progress reports and turns with no completion claim. On a real
# completion claim, prints the re-nudge reason on stdout and exits 0; the
# calling wrapper emits it in its harness's blocking format
# (stop-nudge.sh: JSON envelope; stop-nudge-kimi.sh: stderr + exit 2).
set -uo pipefail

last="$(tr '[:upper:]' '[:lower:]')"

# In-progress reports ("not done yet", "still failing") are not a done boundary.
printf '%s' "$last" | grep -Eq \
  'not (yet )?(done|complete|finished)|still (failing|broken|debugging)|not yet' && exit 1

# Only re-nudge on an actual completion claim.
printf '%s' "$last" | grep -Eq \
  '(^|[^a-z])(done|complete|completed|finished|fixed|passing|passes|works now|ready to (merge|ship)|good to go)([^a-z]|$)' \
  || exit 1

cat <<'EOF'
You are wrapping up as if this task is done. Before it stands as done, re-orient with `using-sdlc-skills` and invoke the done-boundary skill(s) it routes to. At minimum, use `verifying-completion`: run the real check, read its output, and claim only what that output supports. Invoke `requesting-code-review` followed by `finishing-a-branch` only at an actual feature or integration boundary. A private read-only diagnostic, audit, or report is evidence—not an integration candidate—and creating it alone does not establish that boundary; review or branch finishing applies only when the user separately intends to ship or integrate it. If you already verified with real evidence, state the exact command and its output here, then stop.
EOF
exit 0
