---
name: post-mortem
description: "Use after a production escape, late defect, data loss, outage, security incident, or badly failed work cycle when the immediate technical cause and containment are known and the question is why safeguards failed or impact grew. Missing escape-path evidence is gathered here, not routed back to debugging. Use debugging first only when the technical cause itself remains unknown; skip ordinary bugs."
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

1. **Protect the evidence.** Draft under the identity, trust, access/storage/
   egress, redaction, retention, cleanup-authority, and legal/operational
   controls in `references/post-mortem-template.md`.
2. **Reconstruct impact and timeline.** From artifacts—not memory—record what was
   affected, magnitude/duration, introduction, detection, response,
   containment, recovery, and evidence gaps. Separate observed timestamps from
   estimates.
3. **State cause and contributing conditions.** Consume debugging's root cause,
   then identify technical, organizational, environmental, detection, and
   recovery conditions that made introduction or impact more likely. Avoid both
   individual blame and a fictional single-cause story.
4. **Audit the escape path.** Freeze the stable expected gate/surface inventory
   and source digest. Compare expected protection with what actually ran:
   `missing / too weak / skipped / stale / failed but ignored / held`; any
   omission needs its accountable disposition.
5. **Define an honest risk-reduction claim.** Say whether each action should
   prevent, detect earlier, limit blast radius, or accelerate recovery, plus
   residual risk and uncertainty. Never claim recurrence is impossible.
6. **Propose stable corrective actions.** Each maps to a structural cause and
   binds owner/approver rule, dates, artifact/gate, rollout/reversal, dependency,
   and effectiveness. It stays `proposed` until complete trusted receipts accept
   exact scope/dates. Record rejection/cancellation/supersession with residual
   risk/replacement. The record grants no authority.
7. **Require falsification for every implemented corrective gate.** Against the
   captured incident or a representative controlled case, preserve raw evidence
   that the pre-fix/bypassed gate failed to protect, then that the implemented
   gate fails on the bad case and passes on the good control.
8. **Track terminal receipts into enforcement.** Owning workflows execute and
   produce identity-bound, quiescent receipts; this record never infers success
   from summaries. A control completes only in its real CI/runtime/review/release/
   alert/recovery surface. Battery changes update `verification-strategy`, not
   an unowned duplicate gate.
9. **Review effectiveness later.** At the predeclared date/window, compare
   baseline and target: recurrence/near misses, detection time, coverage,
   false-positive/operational cost, response/recovery, and whether the gate
   actually ran. Mark effective, ineffective, or inconclusive. The latter two
   reopen unless the exact approver rule accepts residual-risk closure.
10. **Issue and store deliberately.** Return the immutable analysis plus external
    lifecycle ledger. Write the user-set path (or the template's default) only
    under current repository/storage authority; an in-repository record is a new
    candidate. Never mutate an issued analysis to record later state.

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
