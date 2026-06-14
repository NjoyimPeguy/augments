#!/usr/bin/env bash
# Emit the augments proactive-use nudge as a SessionStart context injection,
# wrapped in the JSON envelope the running harness consumes. Emitting the
# envelope explicitly is more robust than printing raw text and relying on the
# harness to treat hook stdout as context — only some harnesses do that, and
# the rest silently drop it. An unrecognized harness gets the standard
# top-level field as a best effort.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
nudge="$(cat "${here}/context.md")"

# JSON-escape, in order: backslash, double-quote, then the control characters.
esc="$nudge"
esc="${esc//\\/\\\\}"
esc="${esc//\"/\\\"}"
esc="${esc//$'\n'/\\n}"
esc="${esc//$'\r'/\\r}"
esc="${esc//$'\t'/\\t}"

# This adapter is loaded only by its own harness, so the middle branch is the
# live one here; the others keep the script reusable when sibling adapters are
# wired with their own manifests.
if [ -n "${CURSOR_PLUGIN_ROOT:-}" ]; then
  printf '{\n  "additional_context": "%s"\n}\n' "$esc"
elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -z "${COPILOT_CLI:-}" ]; then
  printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$esc"
else
  printf '{\n  "additionalContext": "%s"\n}\n' "$esc"
fi
