# Triggering test: zoom-out

First activation record — backfilled so every skill carries one (see `../README.md`; `coverage.sh` flagged this skill as record-less). Confirms the shipped `description` routes "about to work in unfamiliar code" and stays quiet on a trivial change to known code.

**Method.** Routing proxy via `tests/triggering-harness.sh`: fresh subagents see only the live `name :: description` catalogue (no skill bodies) and route an opening to one skill or NONE. Backfill pass — 3 fresh general-purpose routers from Claude Code, large-tier judge, 2026-06-18. Caveat: to backfill twelve records in one pass each router judged a batch of independent openings in one context (instructed to treat each in isolation), rather than one fresh router per scenario as `prompt` emits — a known deviation, disclosed; treat as directional. LLM-judge proxy, not a deterministic gate. (If `zoom-out` ships `disable-model-invocation`, model routing is partly moot — it is reached by the nudge or by name; this proxy still shows the description does not mis-fire.)

## Scenarios

- **Fire:** "I need to change how the billing module charges customers, but I don't really know how that subsystem is laid out yet."
- **Skip:** "Bump the timeout in config.yaml from 30 to 60 seconds."

## Pass criteria

- **Fire:** routes to `zoom-out`.
- **Skip:** does **not** route to `zoom-out` — a trivial change to understood config needs no mapping pass.

## Last result (2026-06-18)

- **Fire:** 3/3 `zoom-out`.
- **Skip:** 3/3 `NONE` — the trigger stays quiet on the one-line config bump.
