---
name: executing-plans
description: "Use when asked to execute or resume a multi-task plan directory, including when its claimed approval, version, mode, or entry state must first be verified. High-risk target work remains blocked until approved current migration and assurance contracts plus passed entry gates exist; directly authorized gate-enabling tasks may consume their exact proposed gate contract but cannot edit target shards. Skip a single task."
---

# Executing Plans

Advance only through real state transitions; nothing is done until its evaluator is green on the exact result.

## Before you start

1. **Verify authority and lineage.** Match exact plan/mode and complete approver
   rule to a current user-role answer or scoped standing receipt. Confirm every
   predecessor consumer is reconciled; the plan cannot authenticate itself.
2. **Refresh the workspace.** Confirm branch/workspace ownership, HEAD, intended
   base, status, baseline, and runtime identities through
   `using-task-branches`. Never infer them from the plan.
3. **Audit executability.** Check stable task IDs/delta, current bound inputs,
   dependencies, Consumes/Produces, exclusive files/effects, evaluator identity/
   edit authority and RED/falsification, trace, review, concerns rule, and
   Acceptance. Stop on a contradiction before changing code.
4. **Select the execution form.** Bounded tasks use the loop below. A plan with
   phases or machine-derived shards also loads `references/phase-queues.md`;
   never flatten a queue into copied tasks. Directly authorized gate prerequisites
   may consume their exact proposal before phase entry but cannot modify target
   shards, approve the contract, or satisfy target entry. Target tasks require
   approved current migration and assurance contracts plus passed entry gates.

## Bounded task loop

Honor `Depends on` and the directly approved execution mode. Changing between
inline and delegated execution requires a direct mode decision; independence
alone does not override it.

1. Load the task, exact referenced inputs/interfaces/evaluator, and relevant
   identity-bound learnings from the external execution ledger.
2. Record stable task/attempt ID, allowed prior state, exact pre-task revision/
   effects, external task state, evaluator identity, and expected observable.
3. Execute under every discipline that governs the action now. For delegated
   work use `references/subagent-dispatch.md`; for approved parallel work,
   `dispatching-parallel-agents` owns isolation and reconciliation.
4. Inspect the result against the task's file/scope contract. For an offload,
   inspect its raw diff, authorized checkpoints (or none), result revision, and
   evaluator output rather than accepting a summary.
5. Invoke `verifying-completion` to run the task Evaluator in the authoritative
   workspace and bind its output to the exact state. That skill owns the
   evidence ledger; this skill owns the task-state transition.
6. Append `done` only after the evaluator passes on the accepted state. A concern
   cannot count toward any gate until proved non-blocking or accepted under its
   exact owning deviation/exclusion and compensating gate.
7. Re-run a combined gate after integrating parallel results.

## Outcomes and circuit breaker

The append-only ledger uses **done**, **done with concerns**, **blocked**,
**needs context**, **cancelled**, or **superseded**; cancellation/supersession
needs its owning approved plan decision and never means done.

Every attempt has identity and terminal evidence. Failure/deadline enters
**cancellation requested** until worker, descendants, and effects are quiescent;
quarantine partials; linked retries reject late results/mutations. Classify
repeated failures under a stable class ID and raw evidence.

Task `done` means evaluator-accepted inside the plan, not integrated or merge-ready; required task review and final-candidate review remain separate gates.

Three non-converging terminal attempts in one stable class stop the task. High-
risk contracts own thresholds/pause scope; never patch shard symptoms separately.

## Resume and plan changes

On resume, refresh plan/decision state, workspace/base/HEAD/dirty state, ledgers/
queues, contract versions, and evidence freshness; never infer progress by order.

When reality differs, update its owner. Every normative scope, interface,
evaluator, phase, ownership, cutover, rollback, decommission, or mode change
requires a successor and direct reapproval.
Runtime attempts, leases, and outcomes update only their external ledgers.

Run plan Acceptance on the exact integrated revision, then re-route; review,
branch integration, and release retain their own gates and decisions.
