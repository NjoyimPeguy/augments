# Triggering test: security-audits

First activation record — backfilled so every skill carries one (see `../README.md`; `coverage.sh` flagged this skill as record-less). Confirms the shipped `description` routes a trust-boundary change and stays quiet on a change with no security surface.

**Method.** Routing proxy via `tests/triggering-harness.sh`: fresh subagents see only the live `name :: description` catalogue (no skill bodies) and route an opening to one skill or NONE. Backfill pass — 3 fresh general-purpose routers from Claude Code, large-tier judge, 2026-06-18. Caveat: to backfill twelve records in one pass each router judged a batch of independent openings in one context (instructed to treat each in isolation), rather than one fresh router per scenario as `prompt` emits — a known deviation, disclosed; treat as directional. LLM-judge proxy, not a deterministic gate.

## Scenarios

- **Fire:** "I added a login endpoint that takes a username and password from the request and builds a SQL query from them — can you check it for security holes before it ships?"
- **Skip:** "Tweak the CSS so the footer is centered."

## Pass criteria

- **Fire:** routes to `security-audits`.
- **Skip:** does **not** route to `security-audits` — a presentation tweak crosses no trust boundary.

## Last result (2026-06-18)

- **Fire:** 3/3 `security-audits`.
- **Skip:** 3/3 `NONE` — the trigger stays quiet; the trust boundary (attacker-controlled input → SQL) is the discriminator, not the word "endpoint".
