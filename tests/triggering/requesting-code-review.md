# Triggering test: requesting-code-review

First activation record for this skill — it shipped without one, and the gap showed: in a real session on a large codebase, an agent finished a multi-file change, saw every gate green, claimed done, and never reached review. The pre-edit `description` was *desire-conditioned* ("…and you want fresh eyes…"): it only fires if the agent already wants a review, and the agent that most needs one is the confident one. This record measures the edit to an *event-conditioned* trigger (done boundary, named boundary words, green-gates-don't-substitute rebuttal, sharper skip list) — and reports honestly that the edit did **not** change first-hop routing; the operative hole is elsewhere (see the honest note).

**Method.** Routing proxy via `tests/triggering-harness.sh`: fresh subagents see only the live `name :: description` catalogue plus one opening message and answer `CHOICE:`/`WHY:`. Four fresh verdicts per condition; old-description baselines were measured *before* the edit landed. LLM-judge proxy, not a deterministic gate; directional and model-dependent. Judged on a large-tier model via the harness's subagent dispatch, 2026-06-10.

## Scenarios

- **S1 — wrap/merge opening:** "I've finished the payment-retry refactor — six files changed, all evaluators are green, tests pass, lint is clean. Committing and merging this to dev now."
- **S2 — skip gate:** "I bumped the package version from 1.2.3 to 1.2.4 in the manifest for the release — one line changed, committing it now."
- **S3 — done-claim opening (the real-session miss):** "The retry-policy feature is implemented — I ran everything: all evaluators are green, tests pass, lint is clean. Marking the task complete and reporting it as done."

## Pass criteria

- **S1 / S3:** routes to `requesting-code-review` directly, **or** to a skill whose body hands off to it before the boundary is crossed. `finishing-a-branch` qualifies (its merge option gates on `requesting-code-review`); `verifying-completion` does **not** (its body contains no review handoff) — landing there with no onward edge is a miss for the chain.
- **S2:** does *not* route to `requesting-code-review` — the trivial-diff skip must hold.

## Last result (2026-06-10)

Description changed from desire-conditioned to event-conditioned (done-boundary wording, "green gates and passing tests don't substitute", skip list with concrete examples).

- **S1:** old **4/4 `finishing-a-branch`** → new **4/4 `finishing-a-branch`**. Unchanged. Acceptable-with-handoff: every judge quoted finishing-a-branch's near-verbatim match ("checks have been run and verified green and you're ready to wrap"), and its body dispatches `requesting-code-review` at the merge decision.
- **S2:** new **4/4 NONE** — the skip holds; two judges quoted the new skip clause ("trivial mechanical diff (rename, version bump, config one-liner) — self-review instead") verbatim. (Old description not separately measured here; it carried a skip clause too, so no claim is made that the edit improved S2.)
- **S3:** old **4/4 `verifying-completion`** → new **4/4 `verifying-completion`**. Unchanged — and this is the miss path: `verifying-completion`'s body has **no handoff** to `requesting-code-review` or `finishing-a-branch`, so once its gate passes green at a feature-level boundary the chain ends with the work unreviewed. That, not the trigger wording, is what the real session hit.

**Honest note.** The edit did not change first-hop routing in any scenario: at a done boundary the single-choice first hop is always captured by `verifying-completion` (the claim moment) or `finishing-a-branch` (the wrap moment), whose triggers name those moments verbatim — `requesting-code-review` is structurally a *second hop*, reached by handoff. The edit is kept on its merits for what this proxy cannot measure: when an agent weighs this skill's description directly (a "does a skill fit?" nudge check, or choosing whether to invoke it by name), the old wording licensed skipping unless the agent already wanted review, and the new wording conditions on the event and pre-counters the exact "evaluators are green" rationalization — at no cost elsewhere (S2 confirms no over-firing). **Follow-up owed:** the structural fix is a handoff edge in `verifying-completion`'s body (gate passes green at a feature boundary → hand off to `requesting-code-review` / `finishing-a-branch` rather than stopping at "verified"). That is an always-loaded discipline-body edit and owes its own pressure-test re-run under `tests/behavioral/` before it lands; it is deliberately not bundled into this change. The hypothesized `executing-plans` "optional review" bleed was not measured here — the missing handoff explains the miss more directly; revisit only if a miss persists after the handoff lands.
