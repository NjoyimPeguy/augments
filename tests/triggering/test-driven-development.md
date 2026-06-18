# Triggering test: test-driven-development

First activation record — backfilled so every skill carries one (see `../README.md`; `coverage.sh` flagged this skill as record-less). Confirms the shipped `description` routes "implement a feature with logic" and stays off content with no logic.

**Method.** Routing proxy via `tests/triggering-harness.sh`: fresh subagents see only the live `name :: description` catalogue (no skill bodies) and route an opening to one skill or NONE. Backfill pass — 3 fresh general-purpose routers from Claude Code, large-tier judge, 2026-06-18. Caveat: to backfill twelve records in one pass each router judged a batch of independent openings in one context (instructed to treat each in isolation), rather than one fresh router per scenario as `prompt` emits — a known deviation, disclosed; treat as directional. LLM-judge proxy, not a deterministic gate.

## Scenarios

- **Fire:** "Let's implement the discount-calculation feature for the shopping cart."
- **Skip:** "Update the copyright year in the LICENSE file."

## Pass criteria

- **Fire:** routes to `test-driven-development`.
- **Skip:** does **not** route to `test-driven-development` — content with no logic has nothing to test-drive.

## Last result (2026-06-18)

- **Fire:** 3/3 `test-driven-development`.
- **Skip:** 3/3 `NONE` — the trigger stays quiet on a no-logic content edit.
