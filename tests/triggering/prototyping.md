# Triggering test: prototyping

First activation record — backfilled so every skill carries one (see `../README.md`; `coverage.sh` flagged this skill as record-less). Confirms the shipped `description` routes a genuinely-uncertain feasibility question and stays off a known, certain change.

**Method.** Routing proxy via `tests/triggering-harness.sh`: fresh subagents see only the live `name :: description` catalogue (no skill bodies) and route an opening to one skill or NONE. Backfill pass — 3 fresh general-purpose routers from Claude Code, large-tier judge, 2026-06-18. Caveat: to backfill twelve records in one pass each router judged a batch of independent openings in one context (instructed to treat each in isolation), rather than one fresh router per scenario as `prompt` emits — a known deviation, disclosed; treat as directional. LLM-judge proxy, not a deterministic gate.

## Scenarios

- **Fire:** "I'm not sure whether this charting library can render 100k points smoothly. Cheaper to just try it than argue about it?"
- **Skip:** "Add a created_at timestamp column to the users table."

## Pass criteria

- **Fire:** routes to `prototyping`.
- **Skip:** does **not** route to `prototyping` — a known, certain change needs no throwaway spike.

## Last result (2026-06-18)

- **Fire:** 3/3 `prototyping`.
- **Skip:** 3/3 `data-model` — off-target, so the prototyping skip holds. (Aside, out of scope here: `data-model` firing unanimously on a one-column add is a mild over-trigger worth a future look — its own record should test that boundary.)
