# tests/harness/kimi-code/ - Kimi Code plugin adapter checks

This folder is the Kimi Code CLI adapter test layer. It has two scopes:

- `run-activation.sh selftest` is an offline detector check over fixture JSONL.
- `run-activation.sh --scenario-file scenarios/<phase>/<skill> --keep`
  drives a real `kimi -p --output-format stream-json` run and observes
  activation as a `Skill` tool call naming a canonical Augments skill.

`scenarios/` mirrors the shared per-phase scenario set (the same openings the
other adapters use — the filename is the expected skill). This runner is
single-scenario only: the flow/decay/momentum sequences are Claude-Code-only,
they need that harness's resumed-conversation flow engine. Negative scenarios
(a filename that is not a skill) are also Claude-Code-only — this runner
treats an empty `--expect` as "any activation passes", not "expect none".
- `test-stop-nudge.sh` is an offline payload+wire test for the Kimi Stop-hook
  re-nudge in `hooks/stop-nudge-kimi.sh` (declared in the plugin manifest's
  `hooks` array). Its detection policy is shared with the other harnesses in
  `hooks/stop-nudge-detect.sh`.

The adapter itself is `.kimi-plugin/plugin.json` at the repository root. It
points at the canonical phase directories (`skills/analysis/`,
`skills/common/`, ...) directly — Kimi accepts several `skills` paths and scans
each for `<name>/SKILL.md` one level deep, so no mirror or sync script is
needed. `tests/validate-kimi-plugin.sh` checks that the exposed set stays
identical to the canonical 30 skills.

The proactive-use nudge is the manifest's `sessionStart.skill: using-augments`,
which Kimi loads into the main agent at session start, and
`skillInstructions`, which Kimi appends whenever a plugin skill loads — it
binds the skills' harness-agnostic language to Kimi's real tool names
(`AskUserQuestion`, `TodoList`, `Agent` subagent types, the native `Skill`
tool).

## Run it

```bash
bash tests/validate-kimi-plugin.sh
bash tests/harness/kimi-code/run-activation.sh selftest
bash tests/harness/kimi-code/test-stop-nudge.sh
bash tests/harness/kimi-code/run-activation.sh \
  --scenario-file scenarios/maintenance/debugging --keep
```

The live probe always runs against an isolated temporary `KIMI_CODE_HOME`:
the runner copies the user's auth (`config.toml`, `credentials/`, `device_id`,
`oauth/`) into it and installs this checkout as a managed plugin
(`plugins/managed/augments/` plus a `plugins/installed.json` record — the same
layout `/plugins install` produces). The real home is never mutated.

The scenario goes in bare, with no prompt suffix: routing on the
`sessionStart.skill` nudge alone is part of what the probe proves. Detection is
a jq filter over assistant events for a `Skill` tool call
(`function.name == "Skill"`, skill name from `function.arguments`). The
detector cannot distinguish plugin skills from built-in ones by name — the
verdict compares against the expected canonical skill, which is what keeps the
probe honest. A run that hits its timeout after activation evidence was
captured still passes; the agent continues working the scenario after invoking
the skill.

These checks are adapter-specific. They do not replace the portable structural
gate in `tests/validate-skills.sh`.

## Honest status notes

- The session-start nudge fires on **new and resumed sessions only**. Mid-session compaction
  does not re-inject `using-augments` (Kimi's `PreCompact`/`PostCompact` hook
  events are observation-only; return values are ignored). On Claude Code the
  SessionStart matcher includes `compact`; Kimi has no equivalent, so after a
  compaction the routing nudge is whatever survived in the compacted summary.
- The **Stop re-nudge** ships in the manifest's `hooks` array and works (see
  `2026-07-19-stop-nudge-parity.md`), with one harness caveat: Kimi's Stop
  payload carries no transcript, so `hooks/stop-nudge-kimi.sh` recovers the
  last assistant message from the session wire log under
  `$KIMI_CODE_HOME/sessions/`. If that layout changes in a future CLI, the
  hook fails open (no nudge) rather than blocking turns.
- Plugins install per-user, not per-project (Kimi limitation), and
  `kimi -p "/plugins install ..."` does not execute slash commands — that is
  why the runner reproduces the managed-install layout directly.

## Result notes

2026-07-19: adapter added and exercised on Kimi Code CLI 0.27.0 — see
`2026-07-19-debugging-activation.md`. The managed-install layout was verified
against the CLI's own loader (`installed.json` record shape, `manifestKind:
"kimi-plugin-dir"`), all 30 canonical skills were discovered from the
multi-path `skills` array, and the wire log confirmed both
`sessionStart.skill` content and the `<kimi-plugin-instructions>` wrapper in
the system prompt.
