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

## Last result (2026-06-21 · Claude Code · large-tier judge) — firmed to an imperative trigger

The description was rewritten from the gentle "Use when…" to an imperative: "ALWAYS invoke before proposing or applying ANY fix … reaching for a fix without it is the mistake … The ONE exception: a one-line error you can fully explain." Rationale: relocate firing pressure into the **always-loaded catalogue**, which — unlike the SessionStart nudge — does not decay over a long session (the diagnosed cause of skills going silent in multi-hour sessions). Maintainer explicitly accepted the over-fire cost (firing > ceremony-avoidance).

- **Positive (real bug — 500 + failing auth test):** 3/3 → `debugging`. Routing intact.
- **Skip (one-line missing-paren — the description's own "ONE exception"):** firm **3/3 → `debugging` (over-fire)** vs gentle baseline **2/3 → NONE**. The "ALWAYS / by default / the mistake" framing overrides its own carve-out: judges explicitly noted the one-liner qualifies for the exception, then routed to `debugging` anyway ("the trigger still routes the fix here by default"). This over-fire is the **accepted** price of firmer firing, recorded honestly — not a regression to fix. The forced-choice harness also biases skip-cases toward the nearest skill, so read it as directional.
