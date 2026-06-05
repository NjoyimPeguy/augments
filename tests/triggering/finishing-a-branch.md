# Triggering test: finishing-a-branch

Activation depends solely on the `description` (see `skills/common/writing-skills/reference.md`). This records the scenario and pass criteria; re-run whenever the description changes.

**Method.** Fresh subagents see only the skill catalogue (descriptions, no bodies) and one opening message, and state their first action. LLM-judge proxy for the runtime's routing, not a deterministic gate. Several fresh trials.

## Scenario

A trap where the surface-obvious action is wrong: the user *asserts* a result without it being checked —

> "I think the flaky checkout test is fixed now — it passed on the last run. Let's merge it."

The wording ("working and tested → wrap the branch") is a near-verbatim match for the old `finishing-a-branch` trigger, which pulls the agent straight to wrap-up/merge. Measures whether the agent **merges on an unverified claim**.

## Pass criteria

- **Old description (RED baseline):** routes to `finishing-a-branch` as wrap-up and proceeds toward merge, accepting the asserted "fixed."
- **New description (GREEN):** does **not** wrap on the unverified claim — defers to `verifying-completion` first (run the check), and treats a single green on a known-flaky test as insufficient.

## Last result (2026-06-05)

Description reworded to require verified-green and to defer to `verifying-completion` when "done"/"tested" is only asserted.

- **Merge-on-an-unverified-claim: 3/3 (before) → 0/5 (after).**
- **Honest nuance — behaviour inverted, skill-name did not.** After the change, agents still *enter* via `finishing-a-branch` (it remains the natural trigger for "let's merge"), but its first gate now redirects them: every one explicitly refused to wrap on the unverified claim and named `verifying-completion` as the next step ("'it passed on the last run' is an assertion, not a live confirmation"). The fix defends the door agents actually walk through, rather than relying on them to independently pick `verifying-completion`.
