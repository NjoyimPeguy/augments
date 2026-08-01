---
name: migration-strategy
description: "Use before planning or implementing a high-risk rewrite, migration, generated conversion, or wide behavior-preserving transformation whose output is impractical to review line by line, spans ownership boundaries, or has platform, build, runtime, data, or cutover failure modes. Produces the preservation and change contract. Skip bounded changes and target architecture, executable proof, test writing, or migration execution."
---

# Migration Strategy

Define how a trusted source becomes the intended target without losing behavior, data, control, or recoverability. Make preservation and change reviewable first.

## When to use

- The transformation is too broad, partitioned, preservation-heavy, or operationally risky for ordinary feature planning and line-by-line review.
- **Skip** for a bounded change whose behavior and diff remain directly reviewable.
- This skill owns source facts and transition strategy; `system-architecture`
  owns target shape, `verification-strategy` proof, and planning/execution work.

## Procedure

1. **Bind versions and authority.** Name source/target revisions, scope, freshness,
   and one owner or required approvers plus conflict rule; route unsettled targets.
2. **Inventory implementation-independent facts.** Capture observable behavior,
   public contracts, durable data, consumers, platforms and build modes,
   operational obligations, and known deviations without treating source code
   structure as the specification.
3. **Classify every change.** Mark each fact as a preserved invariant,
   intentional deviation, or unresolved unknown. A deviation needs rationale
   and its owning approved requirement/decision; a newly discovered choice
   reopens that owner first. Every unknown has identity, evidence/state,
   validation, owner, expiry, failure response, and relevance disposition;
   unless proved irrelevant or approved with a compensating gate, it blocks.
4. **Choose the transition strategy.** State incremental, cutover, or hybrid
   approach; translation rules; intermediate and mixed-version states;
   compatibility direction; and how unmapped or invalid inputs behave.
5. **Design a representative trial slice.** Map a stable coverage inventory
   across facts, risks, platforms/modes, data shapes, and operations to selected
   and excluded cells. Cover the riskiest paths at useful scale; every exclusion
   needs its exact disposition. Define outcome, gate references, expansion
   decision, and failure response; assurance owns commands and thresholds.
6. **Partition exclusively.** Bind a stable shard inventory and define its state,
   evidence, lease, expiry, quiescence, quarantine, and reclaim rules. Put actual
   attempts, owners, heartbeats, transfers, and results in an append-only external
   ledger; runtime progress never rewrites the normative contract.
7. **Control source evolution.** Freeze the source or define one versioned
   change-intake contract and external queue. Every post-baseline change has
   identity, affected facts/shards, owner, lag, and an exact terminal disposition;
   none may disappear between revisions.
8. **Control live-state drift.** Define snapshot/high-water binding, post-snapshot
   capture or dual write, ordering, idempotency/deduplication, ownership, lag,
   reconciliation, and its external execution ledger.
9. **Define convergence and learning.** Reconcile external shard/change ledgers.
   Every skip needs an approved disposition. Repeated failure classes pause
   affected work, update shared rules, and re-audit every impacted shard.
10. **Make exit recoverable and retirement explicit.** Predeclare pause/abort,
   cutover authority, rollback target, point of no return, recovery timing, and
   retained-source identity, access, owner, period, and restore check.
   Decommission is a separate destructive state machine after retention, zero
   live use/work, its gate, exact targets, authority, and recovery are proved.
   Partial, failed, or validation-failed action blocks release and cleanup.
11. **Challenge independently.** Before approval, source/domain and operations/
   data roles challenge fact completeness, mappings/mixed states, intake paths,
   partitions, trial, and recovery. An omitted role needs an accountable skip.
   Bind exact attempts, access/artifact authority, deadlines, cancellation-
   requested quiescence, quarantine, linked retry, and late-result rejection.
   A required role without a current successful resolved report blocks.
12. **Write and decide the contract.** Fill
   `references/migration-contract.md` at
   `.augments/designs/{{YYYY-MM-DD}}-{{topic}}-migration.md`. Present the exact
   immutable version; record stable-ID delta, review, decision, and execution
   externally. Every normative change creates a proposed successor. Only an
   approved exact version with reconciled predecessor-bound consumers plans.

## Common mistakes

- Calling the current implementation the contract instead of observable facts.
- Hiding or approving behavior changes only inside the migration contract.
- Parallelizing files without exclusive ownership, stable inventory, or
  convergence accounting.
- Letting source fixes land outside a reconciled freeze or change-intake queue.
- Defining rollback after irreversible cutover, or treating cutover as decommission authority.
- Putting target architecture or test commands here instead of handing them off.
