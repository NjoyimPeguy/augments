# Triggering test: scope-it

Activation depends solely on the `description` (see `skills/common/writing-skills/reference.md`). Baseline record for an unchanged description — it measures the trigger as shipped, so there is no RED arm; re-run whenever the description changes.

**Method.** Fresh subagents see only the skill catalogue (descriptions, no bodies) and one opening message (`tests/triggering-harness.sh prompt`), and answer `CHOICE:/WHY:`. LLM-judge proxy, not a deterministic gate. Three fresh trials, plus a shared stay-quiet trial.

## Scenario

> "We agreed the goal: cut support-ticket volume 20% with a self-serve feedback portal, measured over a quarter. There's far more we could build than the quarter allows. Help me decide what makes the first cut and what explicitly doesn't."

Nearest competing triggers: `define-goals` (already satisfied in the opening), `spec-it`, `interview-me`. The question is whether goals-set-but-unbounded routes to the boundary, not back to goals or forward to requirements.

## Pass criteria

- Routes to `scope-it` over its neighbours on a goals-agreed, boundary-undrawn opening.
- Stays quiet on the shared trivial change.

## Last result (2026-06-09)

- **3/3** routed to `scope-it`, each quoting "after the goals are set and before design — to draw the boundary … what is in, what is explicitly out, and the smallest cut that still meets the goal."
- **Stay-quiet (shared trial for the wing):** "Bump the lodash dependency to the latest patch version" → `NONE` **3/3**.
