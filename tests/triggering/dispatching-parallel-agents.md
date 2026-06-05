# Triggering test: dispatching-parallel-agents

Activation depends solely on the `description` (see `skills/common/writing-skills/reference.md`). A record, not an automated gate (`README.md`); re-run when the description changes.

**Method.** Fresh subagents see only the catalogue of `name :: description` (no bodies) and one opening message, and list every skill whose trigger matches. LLM-judge proxy. Several fresh trials.

## Scenario

- **Positive (independent work):** "Five tests are failing across five unrelated modules — auth, billing, search, email, logging. They don't share code. Fix them all as fast as possible."
- **Negative (dependent sequence — must NOT fire):** "Three tasks, each depends on the previous: create the DB schema, then the model on it, then the API that uses the model."

## Pass criteria

- **GREEN:** the independent set routes to `dispatching-parallel-agents`; the dependent sequence does **not** (it belongs to `executing-plans`).

## Last result (2026-06-05)

New skill. Independent failures → `dispatching-parallel-agents` **3/3** ("five failures in five modules with no shared code are textbook independent work units to fan out"). Dependent sequence → **0/2** for parallel dispatch; both routed to `writing-plans`/`executing-plans`, explicitly reasoning "each depends on the previous, so parallel dispatch is ruled out." The independence gate in the description holds — it does not fire on shared/ordered work.
