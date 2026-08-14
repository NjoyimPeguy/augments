---
name: post-mortem
description: "Use after a production escape, late defect, data loss, outage, security incident, or badly failed work cycle, once the immediate technical cause and containment are known and the open question is why the safeguards missed it or why the impact grew. Fires on how did this reach production, why didn't we catch this, and what do we change so it doesn't happen again, even if nobody says post-mortem. Skip while the technical cause is itself still unknown, and skip ordinary bugs."
---

# Post-Mortem

`debugging` explains why the system failed. This explains why the failure
escaped or grew, then measures whether corrective action reduces recurrence,
detection, or impact risk. Reflection is not the gate; deployed and falsified
controls are.

## When to use

- A failure reached users/production, escaped far downstream, caused material
  loss, or exposed a process failure worth correcting.
- **Skip** an ordinary reproduced bug. Begin after the code-level cause and
  immediate containment are known.

## Procedure

1. **Protect the evidence before writing any of it down.** Fill the control and
   evidence header of `assets/post-mortem-template.md` first — an incident
   record concentrates logs, traces, and user data, so who may read it and how
   long it survives are decisions to make before it exists.

2. **Reconstruct impact and timeline from artifacts, not memory.** Mark every
   time as observed or estimated. A reconstructed timestamp that reads as a
   measured one is how a timeline quietly becomes fiction.

3. **State the cause and the conditions around it.** Take the code-level root
   cause from `debugging`, then fill in what made introduction or impact more
   likely.

   Two opposite failure modes here: naming a *person* where a condition belongs,
   and collapsing several real conditions into one tidy single cause.

4. **Audit the escape path.** Freeze the expected gate and surface inventory
   with its source digest, then compare what should have protected this against
   what actually ran. Each entry lands as
   `missing / too weak / skipped / stale / failed but ignored / held`, and every
   omission needs an accountable disposition.

5. **Define an honest risk-reduction claim.** For each action, say which it
   buys — prevent, detect earlier, limit blast radius, or recover faster — and
   state the residual risk. Never claim recurrence is impossible.

6. **Propose corrective actions, then present them.** Each maps to a structural
   cause and carries the fields the template's action rows require.

   Every action stays `proposed`; writing one down authorizes nobody. State the
   analysis path, impact, structural cause, escaped gate, and each corrective
   action with owner and date. Ask one conversational question offering accept
   the actions, request changes, reject the analysis, or cancel. Recommend the
   answer supported by the evidence and action ownership, with one sentence of
   reasoning, then stop.

   Only complete trusted receipts accepting the exact scope and dates move an
   action out of `proposed`. Record rejection, cancellation, or supersession
   with its residual risk and replacement.
7. **Falsify every corrective gate you implement.** Against the captured
   incident or a representative controlled case, preserve raw evidence that the
   gate fails on the bad case and passes on the good control — and that the
   pre-fix version did *not* catch it.

8. **Track terminal receipts into enforcement.** A control is complete only in
   the surface that will really enforce it — CI, runtime, review, release,
   alerting, or recovery — and only on an identity-bound receipt from the
   workflow that owns it. Never infer success from a summary. Changes to the
   battery itself belong to `verification-strategy`, not to a duplicate gate
   nobody owns.

9. **Review effectiveness at the date you predeclared.** Compare baseline
   against target, and check whether the gate ever actually ran. Mark it
   effective, ineffective, or inconclusive; the last two reopen the action
   unless the exact approver rule accepts closure with residual risk.

10. **Issue and store deliberately.** Return the immutable analysis alongside
    its external lifecycle ledger, writing to the user-set path (or the
    template's default) only under current storage authority. An in-repository
    record is itself a new candidate. Never mutate an issued analysis to record
    something that happened later.

## Action states

The external ledger records `proposed → {owner-accepted | rejected | cancelled |
superseded}`. Accepted:
`implemented → falsified → deployed/enforced → effectiveness reviewed → effective → closed`.
Ineffective/inconclusive reopens or needs direct residual-risk closure; no prose, merge, or local green skips a state.

## Common mistakes

- A tidy memory-based story with missing raw evidence.
- “Human error” or “reviewer missed it” instead of the conditions and absent
  gate that allowed the action to escape.
- A training/promise action with no observable enforcement or effectiveness
  measure.
- A regression test that was never shown to fail on the incident case.
- Closing when code merges rather than when the control is enforced and reviewed.
- Publishing sensitive incident artifacts without access and retention controls.
