---
name: migration-strategy
description: "Use before planning or implementing a high-risk rewrite, migration, generated conversion, or wide behavior-preserving transformation — one whose output is impractical to review line by line, crosses ownership boundaries, or can fail at the platform, build, runtime, data, or cutover layer. Fires on port this to X, move us off Y, and regenerate this from Z, even if nobody says migration. Skip bounded changes, and skip target architecture, executable proof, test writing, and running the migration itself."
---

# Migration Strategy

Define how a trusted source becomes the intended target without losing behavior, data, control, or recoverability. Make preservation and change reviewable first.

## When to use

- The transformation is too broad, partitioned, preservation-heavy, or operationally risky for ordinary feature planning and line-by-line review.
- **Skip** for a bounded change whose behavior and diff remain directly reviewable.
- This skill owns source facts and transition strategy; `system-architecture`
  owns target shape, `verification-strategy` proof, and planning/execution work.

## Procedure

Each step fills the matching section of `assets/migration-contract.md`. Read it
while you work rather than rebuilding its fields from memory.

### Establish the ground truth

1. **Bind versions and authority.** Name the source and target revisions, the
   scope, and one accountable owner or approval rule. An unsettled target routes
   back to its owner first.

2. **Inventory implementation-independent facts** — behavior, contracts, durable
   data, consumers, platforms and build modes, operational obligations, known
   deviations.

   The source's structure is not the specification. Treating it as one is how a
   migration faithfully preserves an accident and quietly drops a requirement.

3. **Classify every fact** as a preserved invariant, an intentional deviation, or
   an unresolved unknown. A deviation needs the approved requirement or decision
   that owns it, and a newly discovered choice reopens that owner rather than
   being settled here. An unknown blocks until it is proved irrelevant or
   approved with a compensating gate.

### Design the transition

4. **Choose the transition strategy** — incremental, cutover, or hybrid — with
   its translation rules, legal intermediate and mixed-version states,
   compatibility direction, and the behavior of unmapped or invalid input.

5. **Design a representative trial slice** that covers the riskiest paths at
   useful scale, mapped over a stable coverage inventory. Every excluded cell
   needs its exact disposition. Outcome, expansion decision, and failure response
   live here; assurance owns the commands and thresholds.

6. **Partition exclusively.** Bind a stable shard inventory and its ownership
   rules. Attempts, owners, heartbeats, transfers, and results go in an
   append-only external ledger — runtime progress never rewrites the normative
   contract.

### Control what moves underneath you

7. **Control source evolution.** Freeze the source, or run one versioned
   change-intake contract and external queue. Every post-baseline change gets an
   identity and an exact terminal disposition; none may disappear between
   revisions.

8. **Control live-state drift** wherever mutable data or work keeps moving while
   the migration runs. The contract's *Mutable live-state catch-up* section names
   every field this owes, from the boundary binding down to the maximum permitted
   lag and the gate that owns it.

   The judgement the template cannot make for you: every accepted write or work
   item after the snapshot has to land in exactly one terminal disposition.
   "Probably applied" is an unreconciled row, and an unreconciled row blocks
   cutover.

9. **Define convergence and learning.** Reconcile the external ledgers, and give
   every skip an approved disposition. A repeated failure *class* pauses the
   affected work, updates the shared rule, and re-audits every impacted shard —
   fixing its instances one at a time is how the class stays invisible.

10. **Make exit recoverable and retirement explicit.** Predeclare the whole exit
    path before anyone needs it: how work pauses and aborts, who authorizes
    cutover, what rollback returns to, where the point of no return sits, how long
    recovery takes, and what becomes of the retained source. The contract's exit
    and retention sections carry those fields.

    Decommission is a separate destructive state machine. Enter it only once
    retention has elapsed, live use is provably zero, its gate has passed, and its
    exact targets, authority, and recovery are established. A partial, failed, or
    validation-failed action there blocks release and cleanup.

### Challenge, then decide

11. **Challenge independently, before approval.** Two roles have to push back on
    this contract: someone who knows the source and its domain, and someone who
    owns operations and data. Between them they challenge whether the facts are
    complete, whether the mappings and mixed states hold, whether the intake path
    and the partitions work, and whether the trial slice and the recovery plan are
    real. A role you leave out needs an accountable, recorded skip.

    Bind each challenge to an exact attempt with a deadline, under the
    cancellation, quiescence, quarantine, linked-retry, and late-result rules the
    contract's challenge fields define — so that "in flight" can never pass for
    "returned". A required role with no current, successful, resolved report
    blocks approval.

12. **Write the contract** to
    `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}-migration.md`, keeping the
    stable-ID delta, review, and execution state external to it.

13. **Present the contract for decision.** Print exactly this, then stop:

    ```text
    Migration contract ready for your decision — {{contract-path}}

    Strategy:  {{incremental | cutover | hybrid}}
    Preserved: {{invariants}}
    Trial:     {{representative-slice}}
    Abort:     {{pause-abort-and-rollback}}
    Retire:    {{decommission-plan}}

    1. Approve — planning may consume this exact version
    2. Request changes — tell me what to revise
    3. Reject — wrong strategy
    4. Cancel — stop this work

    Which?
    ```

    Only an approved exact version, with predecessor-bound consumers reconciled,
    lets planning proceed; praise and silence decide nothing. Every normative
    change creates a proposed successor.

## Common mistakes

- Calling the current implementation the contract instead of observable facts.
- Hiding or approving behavior changes only inside the migration contract.
- Parallelizing files without exclusive ownership, stable inventory, or
  convergence accounting.
- Letting source fixes land outside a reconciled freeze or change-intake queue.
- Defining rollback after irreversible cutover, or treating cutover as decommission authority.
- Putting target architecture or test commands here instead of handing them off.
