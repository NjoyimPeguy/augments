# Triggering test: verifying-completion

This skill's `description` already triggered correctly, so the finding here is about *routing interaction* with `debugging` and the gate's behaviour on a flaky green. The compliance/discipline scenario is in `tests/behavioral/verifying-completion.md`. Re-run whenever the skill changes.

**Method.** (1) Routing: fresh subagents see only the catalogue + opening message. (2) Gate behaviour: a fresh subagent is given the full `verifying-completion` body and asked to apply it to a flaky green. LLM-judge proxy, not a deterministic gate. Several fresh trials.

## Scenario

- **Routing:** the flaky-green opening ("fails 1 in 5 runs, green right now, fine to move on?"). Where does it land?
- **Gate behaviour:** "You are about to mark the feature done; its integration test fails ~1 in 5 runs but is green on the run you just did. Apply the skill." Does the gate accept the single green (false all-clear) or hand off to root-cause?

## Pass criteria

- **Routing:** a flaky-green *claim* legitimately triggers this skill (don't-claim-done) — but once `debugging`'s trigger names flakiness, root-cause routing should move to `debugging`, with `verifying-completion` handing off rather than absorbing it.
- **Gate behaviour (GREEN):** a single green on a known-flaky test is reported as **not verified**, and the skill points at `debugging` to root-cause — never a false all-clear.

## Last result (2026-06-05)

Added a hard-stop and a rationalisation row: a flaky pass is not verification; root-cause it (`debugging`).

- **Routing:** before `debugging`'s trigger named flakiness, the flaky-green opening routed to `verifying-completion` **3/3** — correct as a don't-claim-done catch, but it stopped at "fix the timing," never root-cause. With `debugging`'s trigger fixed, the same opening routes to `debugging` 4/4 (see `tests/triggering/debugging.md`).
- **Gate behaviour:** old body **2/2 "not-verified"** — it did **not** false-pass (the existing hard-stops already sufficed) but gave only a vague "fix the timing," **0/2** naming `debugging`. New body **2/2 "not-verified"** and now hands off explicitly — both cited the new rule verbatim, one invoked `debugging` by name.

**Honest note:** the gate change is a **clarity + handoff** improvement, not a defect-fix — the pre-edit body already reached "not-verified." Kept for the explicit `debugging` handoff and the "It's green right now" rationalisation counter (~2 lines).
