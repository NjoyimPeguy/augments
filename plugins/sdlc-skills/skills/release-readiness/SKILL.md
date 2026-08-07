---
name: release-readiness
description: "Use after integration and before each release promotion verdict—initial canary/stage, expansion, full deployment, publication, or distribution—for services, applications, libraries, packages, CLIs, and artifacts. Skip only work with no releasable or running artifact."
---

# Release Readiness

Merged is not releasable. Judge the exact artifact or artifact set that will be
deployed or distributed, under the release gates and recovery conditions that
protect its real consumers. This skill decides readiness; it does not perform
deployment or publication.

## When to use

- An integrated candidate is approaching an initial or later release promotion.
- **Skip** internal work with no release surface. A library/package release is
  not a skip merely because it has no running production service.

## The readiness gate

Use `references/release-candidate.md` and `references/gate-details.md`. Every
required row is evidenced, not-applicable with rationale, or blocking.

1. **Issue one immutable release-input descriptor.** Bind the exact promotion,
   source/contracts, expected artifacts and gate cells, review/security inputs,
   source/live queues, deviations/prior-stage inputs, target/consumer state,
   effect contracts, and approver rule. Keep later attempts and evidence outside
   it; never expose secret values.
2. **Freeze the artifact set.** Through controlled attempts, accept one terminal
   successful build per required platform/package member from the recorded
   source; preserve every identity/digest, contents, dependencies, build inputs,
   provenance, and storage location. Test/promote that set—not a later rebuild.
3. **Verify the artifacts themselves.** Install/start/load each required member
   through representative consumer paths and inspect packaging, configuration,
   migrations, and generated content. Source-tree green cannot substitute for
   artifact green.
4. **Run every gate protecting this promotion.** Execute its stable expected
   inventory through `verifying-completion`; require current differential/
   acceptance, static/dynamic safety, security, performance/resource,
   test-inventory, and platform/build-mode evidence. Reconcile migration shards,
   source/live changes, and every approved omission within the matrix's lag bound.
5. **Exercise cutover and recovery.** Prove snapshot/high-water catch-up,
   ordering/idempotency, reconciliation/lag, mixed-version data integrity,
   retained artifacts, rollback/restoration, and RPO/RTO by observed evidence.
6. **Prove target readiness.** Verify configuration and secret presence/shape,
   permissions, capacity, dependency availability, observability, and deploy or
   publication ordering without exposing secret values.
7. **Bind rollout control.** Require telemetry, cohorts, thresholds, soak,
   abort, rollback, and in-flight behavior from the owning assurance,
   migration, or release policy. Missing policy blocks; readiness does not
   invent or lower it. Expansion/full release requires observed prior-stage
   evidence.
8. **Account for consumers.** Verify compatibility and required communication,
   release/operator notes, and downstream certification. For libraries/packages,
   install the packed artifact in a clean representative consumer and verify
   public API/ABI/schema/runtime/metadata obligations.
9. **Disposition every deviation.** Record impact, owner, compensating gate,
   expiry, rollback trigger, and exact approval receipts. Lowering a gate to make
   the candidate pass creates a new assurance decision; it is not a release fix.
10. **Issue a promotion-bound verdict.** Bind status to release-input,
    artifact-set, terminal-evidence, approval, and freshness identities. Recompute
    every bound input before a decision/action; any drift invalidates both.

## Hard stops

- Release tests ran on source or a different/incomplete artifact set.
- Release-input, artifact-set, terminal-evidence, or verdict identity is missing,
  stale, incomplete, or changed.
- Any required cell/evidence/change is missing, duplicated, generically skipped/
  rejected, unresolved, unowned, misordered, or beyond its bound.
- Decommission is partial, failed, awaiting/failed validation, or unresolved.
- Rollback names only source, not a restorable artifact and data/config state.
- The fixer, builder, or deployer self-accepts an unapproved deviation.
- “Ready” is treated as authority to deploy or publish.

## Common mistakes

- Rebuilding after tests and assuming the bytes are equivalent.
- Treating local/pre-merge green as release evidence, or skipping package gates.
- Calling a bare flag a rollout plan, or an unbounded recovery promise rollback.
