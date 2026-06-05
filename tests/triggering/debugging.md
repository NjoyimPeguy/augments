# Triggering test: debugging

Activation depends solely on the `description` (see `skills/common/writing-skills/reference.md`). This records the *triggering* scenario; the compliance/discipline scenario for this skill is in `tests/behavioral/debugging.md`. Re-run whenever the description changes.

**Method.** Fresh subagents see only the skill catalogue (descriptions, no bodies) and one opening message, and state their first action. LLM-judge proxy, not a deterministic gate. Several fresh trials.

## Scenario

An isolated flaky-test moment whose surface event is a *pass*, not a failure:

> "The auth integration test fails maybe 1 in 5 runs, but it's green right now. Fine to move on?"

A flaky test that passed matches none of "bug, test failure, or unexpected behaviour" on the surface, so the question is whether the trigger routes the intermittency to root-cause work (`debugging`) rather than only to a don't-claim-done nag.

## Pass criteria

- **Old trigger (RED baseline):** flakiness does not route to `debugging`; it is treated purely as a verification matter.
- **New trigger (GREEN):** the intermittent test routes to `debugging` for root-cause — "a flaky test is an unexplained bug, not a green to trust."

## Last result (2026-06-05)

Trigger extended to name a test that passes only intermittently (the body already handled flaky bugs).

- **Routing to `debugging`: 0/3 (before) → 4/4 (after).** Before, all three judges routed to `verifying-completion` (treating flakiness as "don't claim done"); none reached for root-cause. After, all four routed to `debugging`, quoting the new clause ("the current green state is irrelevant — why does it fail 1 in 5 runs?").
