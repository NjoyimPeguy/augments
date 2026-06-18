# Triggering test: handoff

First activation record — backfilled so every skill carries one (see `../README.md`; `coverage.sh` flagged this skill as record-less). Confirms the shipped `description` routes its intended opening and stays quiet on a finished, self-contained task.

**Method.** Routing proxy via `tests/triggering-harness.sh`: fresh subagents see only the live `name :: description` catalogue (no skill bodies) and route an opening to one skill or NONE. Backfill pass — 3 fresh general-purpose routers from Claude Code, large-tier judge, 2026-06-18. Caveat: to backfill twelve records in one pass each router judged a batch of independent openings in one context (instructed to treat each in isolation), rather than one fresh router per scenario as `prompt` emits — a known deviation, disclosed; treat as directional. LLM-judge proxy, not a deterministic gate.

## Scenarios

- **Fire:** "I'm out of time for today and someone else picks this up tomorrow — write up where things stand so they can continue without me."
- **Skip:** "I just fixed the typo in the README and pushed it. We're done here."

## Pass criteria

- **Fire:** routes to `handoff`.
- **Skip:** does **not** route to `handoff` — a finished, self-contained task needs no continuation.

## Last result (2026-06-18)

- **Fire:** 3/3 `handoff`.
- **Skip:** 3/3 `NONE` — the trigger stays quiet; "we're done here" is not a handoff to a next session.
