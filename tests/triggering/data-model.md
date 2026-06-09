# Triggering test: data-model

Activation depends solely on the `description` (see `skills/common/writing-skills/reference.md`). Baseline record for an unchanged description — it measures the trigger as shipped, so there is no RED arm; re-run whenever the description changes.

**Method.** Fresh subagents see only the skill catalogue (descriptions, no bodies) and one opening message (`tests/triggering-harness.sh prompt`), and answer `CHOICE:/WHY:`. LLM-judge proxy, not a deterministic gate. Three fresh trials, plus a shared stay-quiet trial.

## Scenario

> "Before building the feedback service, pin down what we store: users, feedback items, statuses, audit history — and rules like 'a feedback item always has exactly one current status'."

Nearest competing triggers: `system-architecture`, `spec-it`. The question is whether an entities-and-invariants ask routes to the data model, not the broader architecture.

## Pass criteria

- Routes to `data-model` over its design neighbours on a storage-shape opening.
- Stays quiet on the shared trivial change.

## Last result (2026-06-09)

- **3/3** routed to `data-model`, each quoting "entities, attributes, relationships, and the invariants that keep it correct" — two explicitly citing the exactly-one-current-status rule as invariant language.
- **Stay-quiet (shared trial for the wing):** "Bump the lodash dependency to the latest patch version" → `NONE` **3/3**.
