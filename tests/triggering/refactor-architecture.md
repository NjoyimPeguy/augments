# Triggering test: refactor-architecture

First activation record — backfilled so every skill carries one (see `../README.md`; `coverage.sh` flagged this skill as record-less). Confirms the shipped `description` routes existing-codebase friction and stays off new-system design.

**Method.** Routing proxy via `tests/triggering-harness.sh`: fresh subagents see only the live `name :: description` catalogue (no skill bodies) and route an opening to one skill or NONE. Backfill pass — 3 fresh general-purpose routers from Claude Code, large-tier judge, 2026-06-18. Caveat: to backfill twelve records in one pass each router judged a batch of independent openings in one context (instructed to treat each in isolation), rather than one fresh router per scenario as `prompt` emits — a known deviation, disclosed; treat as directional. LLM-judge proxy, not a deterministic gate.

## Scenarios

- **Fire:** "Every change to the orders module ends up touching ten files and the seams leak everywhere — help me improve the structure."
- **Skip:** "Design the architecture for a brand-new notifications service from scratch."

## Pass criteria

- **Fire:** routes to `refactor-architecture`.
- **Skip:** does **not** route to `refactor-architecture` — new design belongs to `system-architecture`, per this skill's own skip clause.

## Last result (2026-06-18)

- **Fire:** 3/3 `refactor-architecture`.
- **Skip:** 3/3 `system-architecture` — off-target, so the skip holds; the routers landed on exactly the sibling the description names for new design.
