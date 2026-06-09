# Triggering test: system-architecture

Activation depends solely on the `description` (see `skills/common/writing-skills/reference.md`). Baseline record for an unchanged description — it measures the trigger as shipped, so there is no RED arm; re-run whenever the description changes.

**Method.** Fresh subagents see only the skill catalogue (descriptions, no bodies) and one opening message (`tests/triggering-harness.sh prompt`), and answer `CHOICE:/WHY:`. LLM-judge proxy, not a deterministic gate. Three fresh trials, plus a shared stay-quiet trial.

## Scenario

> "Requirements are approved: web client, a public API, background email workers, and a CRM sync. Before anyone writes code, how should this system be structured?"

Nearest competing triggers: `writing-plans`, `data-model`, `architecture-decisions`. The question is whether a multi-component structuring ask routes to architecture, not straight to a plan.

## Pass criteria

- Routes to `system-architecture` over its design neighbours on a structure-before-build opening.
- Stays quiet on the shared trivial change.

## Last result (2026-06-09)

- **3/3** routed to `system-architecture`, each quoting "after the requirements are set, when a non-trivial system needs designing before it's built — components, boundaries, data flow."
- **Stay-quiet (shared trial for the wing):** "Bump the lodash dependency to the latest patch version" → `NONE` **3/3**.
