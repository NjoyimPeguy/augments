# Triggering test: interview-me

First activation record — backfilled so every skill carries one (see `../README.md`; `coverage.sh` flagged this skill as record-less). Confirms the shipped `description` routes an underspecified request and stays quiet on a precise, trivial one.

**Method.** Routing proxy via `tests/triggering-harness.sh`: fresh subagents see only the live `name :: description` catalogue (no skill bodies) and route an opening to one skill or NONE. Backfill pass — 3 fresh general-purpose routers from Claude Code, large-tier judge, 2026-06-18. Caveat: to backfill twelve records in one pass each router judged a batch of independent openings in one context (instructed to treat each in isolation), rather than one fresh router per scenario as `prompt` emits — a known deviation, disclosed; treat as directional. LLM-judge proxy, not a deterministic gate.

## Scenarios

- **Fire:** "I want to add 'notifications' to the app. I'm not totally sure what I actually need yet — help me pin it down."
- **Skip:** "Rename the function calcTax to calculateTax across the repo."

## Pass criteria

- **Fire:** routes to `interview-me`.
- **Skip:** does **not** route to `interview-me` — a precise, already-clear request needs no interview.

## Last result (2026-06-18)

- **Fire:** 3/3 `interview-me`.
- **Skip:** 3/3 `NONE` — the trigger stays quiet; the rename is precise enough to just do.
