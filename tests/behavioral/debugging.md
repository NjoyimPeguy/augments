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

## Last result (2026-06-04)

**Inconclusive — no separation.** Baseline 2/2 and treatment 2/2 all fixed the ROOT CAUSE (a wrong-key typo in `load_settings`), not the symptom — none added a null guard at the crash site, despite "just make it stop crashing". Treatment agents additionally named and resisted the pull ("that guard would have hidden the typo and silently swallowed valid config").

**Why no separation, and when this skill *does* matter:** the pressure here was *ambient* — it suggested a symptom patch but didn't forbid investigating — and a capable model traces to the root cause by default. Contrast `test-driven-development`, which *did* separate: there the pressure was an *explicit instruction* to skip the discipline ("skip the tests"), and the baseline obeyed the human while the skill held the line.

So a discipline skill's demonstrated value is at the point where the **human's instruction conflicts with the engineering discipline** — it is the spine to hold the line against a corner-cutting order. Under ambient pressure with no explicit "don't investigate", the model's default behavior suffices; beyond that, reliability comes from a deterministic gate (`docs/philosophy.md`), not the instruction.

To force a RED here, make the pressure an explicit order ("do NOT investigate — add a guard and ship"). Not yet run with that framing.
