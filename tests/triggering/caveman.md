# Triggering test: caveman

First activation record — backfilled so every skill carries one (see `../README.md`; `coverage.sh` flagged this skill as record-less). Confirms the shipped `description` routes its intended opening and stays quiet on an adjacent one.

**Method.** Routing proxy via `tests/triggering-harness.sh`: fresh subagents see only the live `name :: description` catalogue (no skill bodies) and route an opening to one skill or NONE. Backfill pass — 3 fresh general-purpose routers from Claude Code, large-tier judge, 2026-06-18. Caveat: to backfill twelve records in one pass each router judged a batch of independent openings in one context (instructed to treat each in isolation), rather than one fresh router per scenario as `prompt` emits — a known deviation, disclosed; treat as directional. LLM-judge proxy, not a deterministic gate.

## Scenarios

- **Fire:** "Caveman mode from now on — keep it terse, stop burning my tokens on filler."
- **Skip:** "Can you explain in depth how our retry/backoff logic handles partial failures? I want the full reasoning, take your time."

## Pass criteria

- **Fire:** routes to `caveman`.
- **Skip:** does **not** route to `caveman` — an explicit request for depth must not trigger terse mode.

## Last result (2026-06-18)

- **Fire:** 3/3 `caveman`.
- **Skip:** 3/3 `NONE` — the trigger stays quiet; the brevity request is the discriminator, not the topic.
