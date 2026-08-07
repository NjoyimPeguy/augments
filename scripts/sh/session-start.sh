#!/usr/bin/env bash
# Emit the SDLC Skills routing bootstrap as a SessionStart context injection.
# The nudge text lives inline below (between the SDLC_SKILLS_NUDGE markers) so the
# hook is self-contained; token-budget.sh measures it from the same markers.
set -euo pipefail

context="$(cat <<'SDLC_SKILLS_NUDGE'
# SDLC Skills

SDLC Skills installs engineering skills for the whole lifecycle, listed with their triggers in your Skill tool. For every request, `using-sdlc-skills` must be the first skill you invoke, before another skill or any tool that begins the work. It routes from the current state and preconditions; then invoke only the skills whose triggers hold.
SDLC_SKILLS_NUDGE
)"

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
