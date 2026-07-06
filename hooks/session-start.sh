#!/usr/bin/env bash
# Emit the augments routing bootstrap as a SessionStart context injection.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
context="$(cat "${here}/context.md")"

# JSON-escape, in order: backslash, double-quote, then the control characters.
esc="$context"
esc="${esc//\\/\\\\}"
esc="${esc//\"/\\\"}"
esc="${esc//$'\n'/\\n}"
esc="${esc//$'\r'/\\r}"
esc="${esc//$'\t'/\\t}"

if [ -n "${CURSOR_PLUGIN_ROOT:-}" ]; then
    # Cursor-style hooks consume snake_case additional context.
    printf '{\n  "additional_context": "%s"\n}\n' "$esc"
elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -z "${COPILOT_CLI:-}" ]; then
    # Claude Code consumes the nested SessionStart envelope.
    printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$esc"
else
    # SDK-style hooks consume top-level camelCase additional context.
    printf '{\n  "additionalContext": "%s"\n}\n' "$esc"
fi
