# Independent plan review

A fresh-context reviewer catches assumptions anchored into the author's plan.
This is mandatory before executing a high-risk transformation plan and optional
for bounded plans. The reviewer must not be the plan's sole author.

Before review, bind the exact plan version, reviewer identity, allowed artifact
access, current authority for its worker/provider/storage/egress, and report
location/lifecycle, including data class, retention/expiry, exact cleanup
targets/effects/recoverability, cleanup authority, and disposition. A dispatch exists only after
the callable action returns a nonempty reviewer/job identity; unavailable,
refused, or empty dispatch leaves review pending and cannot be replaced by
self-review. Declare a terminal deadline and timeout/cancel owner/action; poll
only the exact attempt identity. Failure/deadline enters cancellation-requested
until worker, descendants, and effects are quiescent; quarantine partial output.
Reassignment creates a linked successor and rejects predecessor late results or
mutations. The required role completes only with a current successful
version-bound report whose findings are dispositioned; retain every outcome.

Review the **plan**, approved requirements/design, current codebase, and—where
applicable—the exact migration contract and assurance matrix:

> Flag only issues that can cause incorrect, incomplete, unsafe, or
> non-executable work. For each finding give
> `severity — task/phase — source contract — evidence — required correction`.
>
> 1. **Traceability:** every requirement and accepted risk gate has one owning
>    task or phase; every task traces to a requirement, risk, or necessary gate.
> 2. **Correctness:** paths, interfaces, types, and commands match current
>    evidence and exact artifact revisions.
> 3. **Decomposition:** bounded tasks are independently evaluable; large
>    homogeneous work uses a stable inventory and exclusive shards.
> 4. **Consistency:** every Consumes resolves to a Produces under the same name
>    and type; dependencies and phase entries are acyclic and complete; files,
>    data, effects, evaluators, and external state are exclusive or ordered.
> 5. **Assurance:** Evaluators reference the accepted thresholds, environments,
>    cadence, and failure response without weakening them.
> 6. **Control:** trial, phase entry/exit, pause/abort, repeated-failure re-audit,
>    cutover, rollback, and ownership transfer are executable where required.
> 7. **Authorization:** the reviewed plan version and execution mode are pending
>    until directly approved.

Resolve every blocking finding and record its disposition. Every normative
correction creates a successor and requires focused re-review of affected and
dependent sections before direct approval.
