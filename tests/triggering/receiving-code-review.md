# Triggering test: receiving-code-review

First activation record — backfilled so every skill carries one (see `../README.md`; `coverage.sh` flagged this skill as record-less). Confirms the shipped `description` routes "review feedback arrived, responding" and stays off requesting/giving a review.

**Method.** Routing proxy via `tests/triggering-harness.sh`: fresh subagents see only the live `name :: description` catalogue (no skill bodies) and route an opening to one skill or NONE. Backfill pass — 3 fresh general-purpose routers from Claude Code, large-tier judge, 2026-06-18. Caveat: to backfill twelve records in one pass each router judged a batch of independent openings in one context (instructed to treat each in isolation), rather than one fresh router per scenario as `prompt` emits — a known deviation, disclosed; treat as directional. LLM-judge proxy, not a deterministic gate.

## Scenarios

- **Fire:** "The reviewer left a bunch of comments on my PR — here they are. Help me work through responding to them."
- **Skip:** "Review this diff for me and tell me what's wrong with it."

## Pass criteria

- **Fire:** routes to `receiving-code-review`.
- **Skip:** does **not** route to `receiving-code-review` — being asked to perform a review is the requesting side, not the receiving side.

## Last result (2026-06-18)

- **Fire:** 3/3 `receiving-code-review`.
- **Skip:** 3/3 `requesting-code-review` — off-target, so the skip holds; the routers cleanly separated the two sides of review.
