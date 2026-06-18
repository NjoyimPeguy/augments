# Triggering test: executing-plans

First activation record — backfilled so every skill carries one (see `../README.md`; `coverage.sh` flagged this skill as record-less). Confirms the shipped `description` routes "I have a plan directory, execute it" and stays off a single task.

**Method.** Routing proxy via `tests/triggering-harness.sh`: fresh subagents see only the live `name :: description` catalogue (no skill bodies) and route an opening to one skill or NONE. Backfill pass — 3 fresh general-purpose routers from Claude Code, large-tier judge, 2026-06-18. Caveat: to backfill twelve records in one pass each router judged a batch of independent openings in one context (instructed to treat each in isolation), rather than one fresh router per scenario as `prompt` emits — a known deviation, disclosed; treat as directional. LLM-judge proxy, not a deterministic gate.

## Scenarios

- **Fire:** "I've got the plan directory from writing-plans — the 00-index and the per-task files. Let's execute it."
- **Skip:** "Fix the off-by-one in the pagination helper."

## Pass criteria

- **Fire:** routes to `executing-plans`.
- **Skip:** does **not** route to `executing-plans` — a single task is just done, not run through a plan.

## Last result (2026-06-18)

- **Fire:** 3/3 `executing-plans`.
- **Skip:** 3/3 `debugging` — off-target, so the executing-plans skip holds; a single off-by-one routes to the bug-hunt, not the plan runner.
