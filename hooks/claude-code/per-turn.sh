#!/usr/bin/env bash
# Emit the augments per-turn routing reminder as a UserPromptSubmit context
# injection, in the JSON envelope Claude Code consumes. One short line per user
# turn so the routing check never decays over a long session — see
# docs/augments/activation.md for the rationale and how to disable it.
# Claude-Code-only by design (it lives under hooks/claude-code/).
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
line="$(cat "${here}/per-turn.md")"

# JSON-escape, in order: backslash, double-quote, then the control characters.
esc="$line"
esc="${esc//\\/\\\\}"
esc="${esc//\"/\\\"}"
esc="${esc//$'\n'/\\n}"
esc="${esc//$'\r'/\\r}"
esc="${esc//$'\t'/\\t}"

printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "UserPromptSubmit",\n    "additionalContext": "%s"\n  }\n}\n' "$esc"
