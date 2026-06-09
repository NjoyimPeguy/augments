# Triggering test: define-goals

Activation depends solely on the `description` (see `skills/common/writing-skills/reference.md`). Baseline record for an unchanged description — it measures the trigger as shipped, so there is no RED arm; re-run whenever the description changes.

**Method.** Fresh subagents see only the skill catalogue (descriptions, no bodies) and one opening message (`tests/triggering-harness.sh prompt`), and answer `CHOICE:/WHY:`. LLM-judge proxy, not a deterministic gate. Three fresh trials, plus a shared stay-quiet trial.

## Scenario

> "Leadership just approved building a customer-feedback portal next quarter. It's a brand-new project — nothing exists yet. Kick it off with me."

Nearest competing triggers: `scope-it`, `feasibility-check`, `interview-me`. The question is whether a bare project kickoff routes to pinning goals first, before boundary or risk work.

## Pass criteria

- Routes to `define-goals` over its planning neighbours on a kickoff opening.
- Stays quiet on the shared trivial change.

## Last result (2026-06-09)

- **3/3** routed to `define-goals`, each quoting "at the start of a new project or initiative — before scoping or building — to pin down what success means."
- **Stay-quiet (shared trial for the wing):** "Bump the lodash dependency to the latest patch version" → `NONE` **3/3**; no planning, analysis, or design skill fired.
