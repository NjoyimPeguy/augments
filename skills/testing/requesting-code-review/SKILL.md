---
name: requesting-code-review
description: "Use when an exact candidate reaches a done/integration boundary, or an explicit independent review is requested for one frozen state. At done, completion evidence precedes review and review precedes final claims or branch materialization, publication, and integration. Explicit keep/discard and PR-only close/reopen are branch-state actions, not readiness review. Non-trivial work needs independent review; proved mechanical work uses revision-bound self-review. Skip an unfinished reversible checkpoint unless review was explicitly requested."
---

# Requesting Code Review

Challenge the exact candidate independently. Legal sequence: `verified →
references read → identity frozen → nonempty dispatch receipt → poll receipt →
report → receiving-code-review`. Never announce/wait before a receipt exists.
Any candidate or bound review-input change voids the verdict.

## When to use

- Before an exact candidate is called complete or moves toward integration.
- On an explicit request to review one exact frozen state; that verdict does not
  call an unfinished checkpoint complete.
- `finishing-a-branch` consumes depth before source materialization,
  publication, or integration. Explicit keep/discard and PR-only close/reopen
  use its identity/authority gates without readiness review.
- A reversible checkpoint is not done merely because it was authorized.
- Only a proved no-surface-change mechanical diff uses self-review.
- A high-risk transformation uses `references/high-risk-review.md` unless its
  exact candidate has the direct recorded exception defined there; one final
  review of an unreadable aggregate diff is insufficient.

## Procedure

1. **Bring evidence first.** Invoke `verifying-completion`; run current required
   checks and bind exact state/output/failures. Review challenges, never replaces,
   completion evidence.
2. **Freeze the candidate.** Stop writers; read/apply
   `references/review-candidate.md`. Its one canonical result identity must equal
   completion's state byte-for-byte or return to verification. Use exactly one
   working-tree/checkpoint/integrated mode and full identity. Keep descriptor,
   reports, attempts, and controlled artifact/access/storage/egress/retention/
   cleanup state outside the candidate.
3. **Freeze depth and roles.** Give every required/omitted role a stable ID;
   omission needs evidence, owner, expiry, compensation, and approval.
   - **Shallow:** trivial mechanical self-review.
   - **Standard:** one independent breadth reviewer plus relevant specialists.
   - **Deep:** breadth, relevant specialists/security audit, and an independent adversarial pass.
   - **High-risk transformation:** separate implementer, equivalence specialist, at least two independent adversarial reviewers, and separate fixer.
4. **Run depth.** Shallow uses the self-review below with no dispatch. Otherwise
   read `references/code-reviewer.md` and send it plus raw evidence through a
   callable action without weakening read-only/full-identity/final-receipt rules.
   Only a returned nonempty ID means dispatched. Empty/refused/unavailable stays
   pending—never self-review or poll an empty target. A configured action grants
   no new disclosure boundary. Poll exact IDs to deadline; non-success waits for
   worker/descendant/effect quiescence, quarantines partials, and links retries
   while rejecting predecessor late results. Success needs one current report.
5. **Traverse by evidence.** Account for the complete inventory and every
   human-authored change. Generated/unreviewable ranges use source mapping,
   structural gates, and risk samples under the high-risk contract; follow
   callers/contracts/history/tests/failures only when evidence requires.
6. **Require bound findings.** Each names severity/disposition, violated
   requirement, project standard, or specialist invariant; reproduction/gate;
   evidence; and correction. Verdict and final structured receipt carry full
   candidate/context identities. Reconcile every
   role/attempt; missing, findings, inconclusive, non-success, or conditional
   ready blocks this candidate.
7. **Receive every report through `receiving-code-review`** before response,
   disposition, or conclusion—even `not ready` with no edit. Any fix or bound
   input change invalidates the verdict. Focused re-review is a fresh invocation
   with verification, references, identity, and receipt; never dispatch it ad hoc.

## Specialist passes

Use risk-required axes:
`references/silent-failures-reviewer.md`,
`references/type-design-reviewer.md`,
`references/test-coverage-reviewer.md`, and
`references/comment-accuracy-reviewer.md`. High-risk equivalence uses
`references/equivalence-reviewer.md`; trust changes invoke `security-audits`.
When a candidate adds or expands enduring owned surface, or an explicit
simplification review is requested, use `references/yagni-reviewer.md`. Broad
review owns unrequested scope; type review owns invariant-specific ceremony;
existing-code audits belong to `complexity-audit`. Assurance challenge belongs
to `verification-strategy`; generic review cannot replace a specialist verdict.

## Self-review for trivial diffs

- Bind `self-reviewed: ready / not ready` to the exact candidate digest and
  confirm its complete change does only what was requested.
- Are untracked/generated files and affected callers accounted for?
- Did a real structural gate run on the exact candidate?
- `not ready` never hands off: upgrade a false mechanical premise, or fix the defect and restart verification/review.

## Common mistakes

- Treating gates, workspace size, urgency, or completion pressure as an
  independent reviewer or downgrade permission.
- Inventing delegation authority, or treating an action as disclosure consent.
- Asking a reviewer to mutate the frozen candidate; destructive challenge runs
  only in a reviewer-owned copy or against retained evidence.
- Filling incompatible high-risk roles without a direct recorded exception.
- Applying fixes while review continues, so nobody reviewed one stable candidate.
- Writing receipts into the frozen candidate creates a new candidate and voids
  the verdict.
