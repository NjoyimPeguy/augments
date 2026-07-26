#!/usr/bin/env bash
# UserPromptSubmit implementation reminder for harnesses whose PreToolUse event
# does not fire on file writes (measured on codex exec: the pre-tool event never
# fires, so a blocking guard is impossible there). This is the honest fallback:
# the pairing rule is re-injected on EVERY prompt, not once at session start.
# It is advisory by construction — where a blockable PreToolUse exists, the
# implementation guards are the enforcement; this is the floor, not the gate.
printf '%s\n' 'If this turn involves writing implementation code: invoke `test-driven-development` and `yagni` BEFORE the first line — the pair comes first, the code after. Skip only if the user waived them or the task has no logic (spike, pure config).'
