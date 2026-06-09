# Triggering test: writing-plans

Activation depends solely on the `description` (see `skills/common/writing-skills/reference.md`). Baseline record for an unchanged description — it measures the trigger as shipped, so there is no RED arm; re-run whenever the description changes.

**Method.** Fresh subagents see only the skill catalogue (descriptions, no bodies) and one opening message (`tests/triggering-harness.sh prompt`), and answer `CHOICE:/WHY:`. LLM-judge proxy, not a deterministic gate. Three fresh trials, plus a shared stay-quiet trial.

## Scenario

> "Here's the approved requirements spec for the feedback API. Break the work into an implementation plan the team can pick up and execute task by task."

Nearest competing triggers: `executing-plans` (no plan exists yet), `spec-it` (already satisfied in the opening). The question is whether spec-in-hand routes to plan *authoring*, not plan execution.

## Pass criteria

- Routes to `writing-plans` over its neighbours on a spec-approved, plan-needed opening.
- Stays quiet on the shared trivial change.

## Last result (2026-06-09)

- **3/3** routed to `writing-plans`, each quoting "an alignment brief or a clear multi-step task … an executable plan before implementing." None confused it with `executing-plans`.
- **Stay-quiet (shared trial for the wing):** "Bump the lodash dependency to the latest patch version" → `NONE` **3/3** (one router explicitly noted it was "too trivial for writing-plans").
