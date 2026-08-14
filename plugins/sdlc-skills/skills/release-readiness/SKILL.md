---
name: release-readiness
description: "Use after integration and before each release promotion verdict — initial canary or stage, expansion, full deployment, publication, or distribution — for services, applications, libraries, packages, CLIs, and artifacts. Fires on is this safe to ship, are we ready to release, and can we deploy this, even if nobody says readiness. Skip only work with no releasable or running artifact."
---

# Release Readiness

Merged is not releasable. Judge the exact artifact or artifact set that will be
deployed or distributed, under the release gates and recovery conditions that
protect its real consumers. This skill decides readiness and puts the promotion
decision to the user; it does not perform the deployment or publication itself.

## When to use

- An integrated candidate is approaching an initial or later release promotion.
- **Skip** internal work with no release surface. A library/package release is
  not a skip merely because it has no running production service.

## The readiness gate

Work the rows in `assets/release-candidate.md`. Each ends as **evidenced**,
**not applicable with a rationale**, or **blocking**. When a row needs more than
a yes, `references/gate-details.md` gives its concrete check and the way it
silently fails; the row numbers below point into it.

### Fix what is being released

1. **Issue one immutable release-input descriptor.** Name the exact promotion,
   the source and contracts it comes from, the artifacts and gate cells you
   expect, and who may approve.

   Attempts and their evidence stay *outside* the descriptor. That is what keeps
   it a fixed target rather than a record that drifts toward whatever the results
   turned out to be. Never put secret values in it.

2. **Freeze the artifact set.** Accept one terminal successful build per required
   platform or package member, from the recorded source, and preserve its
   identity (gate row 10).

   Everything downstream tests and promotes *that* set — never a later rebuild,
   however equivalent it looks.

### Judge it

3. **Verify the artifacts themselves.** Install, start, or load each required
   member through the paths a real consumer uses. A green source tree is not
   artifact evidence.

4. **Run every gate protecting this promotion** through `verifying-completion`,
   over its stable expected inventory, and reconcile that inventory against what
   actually ran (row 11).

5. **Exercise cutover and recovery** by observation rather than design intent —
   including the RPO/RTO you claim (rows 3 and 13).

6. **Prove the target is ready:** configuration, secrets, capacity,
   dependencies, and step ordering (row 6). Verify shape and presence without
   printing values.

7. **Bind rollout control** to the owning assurance, migration, or release
   policy (rows 5 and 12).

   A missing policy blocks. Readiness does not invent one and does not lower
   one. Expansion and full release additionally require observed evidence from
   the prior stage.

8. **Account for consumers** (rows 7, 8, 15). For a library or package, install
   the packed artifact into a clean representative consumer — publishing is the
   first place an unusable package becomes visible, and by then it is public.

### Decide

9. **Disposition every deviation** (row 14). Lowering a gate so the candidate
   passes is a new assurance decision, not a release fix.

10. **Issue a promotion-bound verdict.** Bind it to the release-input,
    artifact-set, terminal-evidence, approval, and freshness identities, and
    recompute every one immediately before any decision or action — drift
    invalidates the verdict and reopens the decision.

11. **Present the release decision.** Readiness is evidence; shipping is the
    user's call. State the exact artifact set and target, verdict, gate count,
    owned deviations, and rollback state. Ask one conversational question
    offering promote this exact set, hold, or cancel. Recommend promote only
    when the verdict is `ready`; otherwise recommend hold, with one sentence of
    reasoning, then stop.

    Nothing is promoted until the user names one. A `ready` verdict, a green
    board, and an accepted deviation are all *inputs* to that choice, never the
    choice itself. This skill records the decision; the promotion then runs
    under its own authorized action contract, never on the strength of a
    verdict.

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
