---
name: verifying-completion
description: "ALWAYS use before any claim that work is complete, fixed, passing, done, or satisfactory, and before any commit or PR. Also use when evidence may be stale, partial, or bound to another state. No exception; unavailable required gates make the claim pending."
---

# Verifying Completion

Evidence before claims. A green result proves only the exact state, gate,
environment, and transition it actually checked. Confidence, summaries, and a
nearby run do not widen that evidence.

## When to use

- Before any claim that work is complete, fixed, passing, done, merge-ready, or
  otherwise satisfactory.
- Before committing or opening a PR.
- This discipline never scales down; only the required gate set does.

## The gate

1. **Name the exact claim and transition.** Task green, integrated acceptance,
   reviewed candidate, and releasable artifact are different states.
2. **Resolve the required gate set.** Use the task/plan Evaluators and applicable
   assurance-matrix cadence. Missing, planned, blocked, or unjustifiably omitted
   gates make the claim pending.
3. **Capture state identity.** Record repository/workspace, base and HEAD, a
   source/working-tree digest covering staged, unstaged, untracked, and relevant
   ignored paths, plus generated/external gate-input identities, artifact digest,
   cwd, configuration, environment, platform, build mode, gate version, and
   controlled data/process/external-effect pre-state.
4. **Contain and run each required action.** Bind attempt ID, exact environment/
   data/effects, authority, resources, timeout/kill, cleanup/recovery, and
   evaluator identity. Sequence overlapping gates; parallelize only disjoint
   effect boundaries. Run fresh. Timeout/failure is cancellation-requested until
   process/effect quiescence; quarantine partials. A rerun is a linked successor
   attempt and rejects predecessor late output. Capture
   post-state; any unintended mutation invalidates the evidence and must be
   restored/re-run or surfaced pending. Cache counts only under its gate contract.
5. **Read and protect raw output.** Record command/action, timestamp, exit
   status, pass/fail counts, threshold comparison, output/artifact location, and
   operator. Classify sensitivity and set access, integrity/digest,
   retention/expiry, exact cleanup targets/effects/recoverability, cleanup
   authority, and disposition; redact only the presented copy.
6. **Audit execution completeness.** Reconcile required suites, shards,
   attempt/lease histories, source-change and live-state queues, platform/build
   cells, TDD RED/falsification/restoration and unchanged judge, plan
   done-with-concerns/cancelled/superseded dispositions, and changed/skipped/
   quarantined/deleted tests/corpora. Aggregate green is red when required work
   did not run or reconcile.
7. **Return evidence without changing the candidate.** Use
   `references/evidence-ledger.md`, but never copy it into a frozen candidate or
   review workspace. Store it outside that identity or return it directly; keep
   failures and inconclusive results rather than green-washing them.
8. **Make only the supported claim.** State what passed, on which identity, and
   what remains pending. If any required row failed or did not run, do not say
   complete.

Any relevant source, test, configuration, dependency, environment, generated
artifact, integration, or threshold change invalidates affected evidence. A
commit with the identical source tree may retain content-check evidence, but
commit/CI/review gates still bind to their own revision. An authorized checkpoint
banks work; it does not make it reviewed, merge-ready, or releasable.

## Manual acceptance

When a requirement genuinely needs human judgment, use
`references/manual-acceptance.md`. Bind every observation to the same candidate
and environment. An unrun row is pending; the agent cannot self-certify a
human-owned judgment.

## Hard stops

- Never claim a test passes without seeing it pass for the recorded state.
- Never claim a bug fixed without a reproduction that failed before and passes
  after, with exact restoration/control evidence.
- Never turn a worker's “success” report into evidence; inspect its diff/state
  and raw output.
- Never mutate a candidate with the bookkeeping meant to prove that candidate.
- A never-falsified gate is suspect—see `references/hollow-verification.md`.
- A flaky green is unexplained nondeterminism; route it through `debugging`.
- Verified is not reviewed. A non-trivial candidate at a completion or
  integration boundary requires `requesting-code-review`; task-local evaluator
  status is not that boundary unless its plan says so.

## When tempted to skip

| Thought | Reality |
| --- | --- |
| "It should work" | Run the gate and make it a fact. |
| "I ran it earlier" | Earlier state or evidence age may not support this transition. |
| "The types pass" | Types, build, behavior, requirements, and release are distinct claims. |
| "The agent said green" | A report is a claim; inspect raw state and output. |
| "The summary says all passed" | Reconcile skipped tests, shards, and matrix cells. |
| "I committed it, so evidence is banked" | A checkpoint is neither review nor integration proof. |
| "All checks are green, so done" | Green supports only the checks; independent review challenges completeness. |

## Relationship to plans

Evaluators and assurance matrices define what must run and which promotion each
gate protects. This skill binds those runs to exact evidence; it does not design
the battery, review the change, integrate the branch, or decide release.
