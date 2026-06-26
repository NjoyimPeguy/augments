#!/usr/bin/env bash
# Emit the augments routing bootstrap as a SessionStart context injection, in the
# JSON envelope Claude Code consumes. Claude-Code-only by design (it lives under
# hooks/claude-code/); other harnesses get their own adapter when added.
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

if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
    # Claude Code sets CLAUDE_PLUGIN_ROOT
    printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$esc"
fi
