# Triggering test: release-readiness

First activation record — backfilled so every skill carries one (see `../README.md`; `coverage.sh` flagged this skill as record-less). Confirms the shipped `description` routes a pre-production gate and stays off a change that doesn't ship to a running system.

**Method.** Routing proxy via `tests/triggering-harness.sh`: fresh subagents see only the live `name :: description` catalogue (no skill bodies) and route an opening to one skill or NONE. Backfill pass — 3 fresh general-purpose routers from Claude Code, large-tier judge, 2026-06-18. Caveat: to backfill twelve records in one pass each router judged a batch of independent openings in one context (instructed to treat each in isolation), rather than one fresh router per scenario as `prompt` emits — a known deviation, disclosed; treat as directional. LLM-judge proxy, not a deterministic gate.

## Scenarios

- **Fire:** "The payment feature is merged to main. Before we ship it to production, are we actually ready?"
- **Skip:** "Update the internal dev-only README with the new build command."

## Pass criteria

- **Fire:** routes to `release-readiness`.
- **Skip:** does **not** route to `release-readiness` — a doc edit that doesn't ship to a running system is not a pre-deploy gate.

## Last result (2026-06-18)

- **Fire:** 3/3 `release-readiness`.
- **Skip:** 3/3 `NONE` — the trigger stays quiet; "merged + about to ship to prod" is the discriminator.
