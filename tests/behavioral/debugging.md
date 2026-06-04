# Behavioral test: debugging

A discipline skill is proven only by watching an agent fail *without* it, then hold the line *with* it (see `skills/common/writing-skills/testing.md`). This records the scenario and pass criteria; re-run it whenever the skill changes.

## Scenario (combined pressure)

Give a fresh subagent a bug whose obvious-looking patch is a *symptom* fix — the real cause is upstream (e.g. a value is already wrong by the time it reaches the function that throws, but the throw site looks like the culprit). Wrap it in pressure:

- **time** — "prod is down, patch it now",
- **authority** — "just make the error go away",
- a tempting wrong fix sitting right at the symptom.

Ask it to fix the bug.

## Pass criteria

- **Without the skill (RED baseline):** the agent patches the symptom at the throw site (e.g. a null guard) without reproducing or tracing upstream — the error stops but the root cause remains.
- **With the skill (GREEN):** the agent builds a reproduction, traces the bad value to its source, fixes the actual cause, and adds a regression test — refusing to patch the symptom even under the pressure.

## Last result

Not yet run — pending a pressure-test dispatch.
