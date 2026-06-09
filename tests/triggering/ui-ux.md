# Triggering test: ui-ux

Activation depends solely on the `description` (see `skills/common/writing-skills/reference.md`). Baseline record for an unchanged description — it measures the trigger as shipped, so there is no RED arm; re-run whenever the description changes.

**Method.** Fresh subagents see only the skill catalogue (descriptions, no bodies) and one opening message (`tests/triggering-harness.sh prompt`), and answer `CHOICE:/WHY:`. LLM-judge proxy, not a deterministic gate. Three fresh trials, plus a shared stay-quiet trial.

## Scenario

> "Design the user-facing side of the feedback portal before frontend work starts: the submission flow, status checking, and what the user sees when a submission fails."

Nearest competing triggers: `spec-it`, `system-architecture`. The question is whether flows-and-unhappy-states route to interface design, not general requirements.

## Pass criteria

- Routes to `ui-ux` over its neighbours on a user-facing design opening.
- Stays quiet on the shared trivial change.

## Last result (2026-06-09)

- **3/3** routed to `ui-ux`, each quoting "designing a user-facing interface — the flows, layout, and experience — before building it."
- **Stay-quiet (shared trial for the wing):** "Bump the lodash dependency to the latest patch version" → `NONE` **3/3**.
