# Triggering test: writing-skills

First activation record — backfilled so every skill carries one (see `../README.md`; `coverage.sh` flagged this skill as record-less). Confirms the shipped `description` routes a skill-authoring request and stays off a request that merely *uses* a skill.

**Method.** Routing proxy via `tests/triggering-harness.sh`: fresh subagents see only the live `name :: description` catalogue (no skill bodies) and route an opening to one skill or NONE. Backfill pass — 3 fresh general-purpose routers from Claude Code, large-tier judge, 2026-06-18. Caveat: to backfill twelve records in one pass each router judged a batch of independent openings in one context (instructed to treat each in isolation), rather than one fresh router per scenario as `prompt` emits — a known deviation, disclosed; treat as directional. LLM-judge proxy, not a deterministic gate.

## Scenarios

- **Fire:** "I want to add a new skill to this augments library for handling database migrations."
- **Skip:** "Use the debugging skill to figure out why this test fails."

## Pass criteria

- **Fire:** routes to `writing-skills`.
- **Skip:** does **not** route to `writing-skills` — using a skill is not authoring one.

## Last result (2026-06-18)

- **Fire:** 3/3 `writing-skills`.
- **Skip:** 3/3 `debugging` — off-target, so the writing-skills skip holds; the routers followed the *work* (a failing test) rather than the word "skill".
