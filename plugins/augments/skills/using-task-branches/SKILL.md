---
name: using-task-branches
description: Use before starting repo edits or implementation, or when work needs isolation from the current checkout - ensure a meaningful task branch, harness workspace, or git worktree exists according to user/project preference. Skip for read-only work or when the current branch/workspace is already dedicated to this task.
---

# Using Task Branches

**Never start repo edits on `main`/`master`, `dev`/`develop`, a release branch, or an unrelated task branch.** Create or enter a meaningful branch/workspace *before* the first edit, unless the user explicitly okayed working in the current checkout.

## When to use

- You are about to edit files, implement a feature/fix/refactor, execute a plan, or dispatch agents.
- Runtime or review isolation matters: parallel agents, risky changes, separate ports, databases, fixtures, or long-running app state.
- **Skip** for read-only investigation, when the user explicitly says to stay in the current checkout, or when the current branch/workspace is already dedicated to this task with known ownership, base, and baseline.

## Procedure

1. **Detect the real checkout.** Record repository root, status, branch or
   detached HEAD, `git-dir` and `common-dir`, registered worktrees, submodule
   superproject, and any harness-native workspace metadata. A detached or
   host-owned checkout may already be isolated: do not nest, attach, switch, or
   clean it until its owner and permitted lifecycle are known.
2. **Classify ownership.** Separate resources and dirty changes created by this
   task from pre-existing, user-owned, shared, or host-owned state. Unknown
   provenance blocks switching or cleanup.
3. **Separate planning from implementation state.** Planning may remain in an
   approved planning or native workspace. Before product edits, re-run this
   check and bind implementation to its own branch/workspace and exact base;
   plan approval does not prove code isolation.
4. **Prove the intended base.** Derive it from direct user/project guidance and
   record revision, remote freshness, relevant ignored/generated/external gate
   inputs. Before any install or baseline, inspect the command, scripts,
   dependencies, data/network boundary, expected effects, and containment. Run
   it in the current checkout only when that state is task-owned or the command
   is proved read-only and contained; otherwise defer it until isolation exists.
5. **Choose isolation without nesting.** User instruction wins, then project
   guidance, then an existing native workspace. Otherwise use a normal branch
   for one task and a worktree for parallel writers, separate runtime state, or
   a dirty checkout that must remain untouched.
6. **Validate identity and collisions.** Follow project naming or use
   `feature/{{short-task}}`, `fix/{{short-task}}`, or `docs/{{short-task}}`.
   Validate the ref and check local branches, remote-tracking refs, and attached
   worktrees before creating it; never overwrite or silently reuse a collision.
7. **Create only from the proven base.** Keep a worktree outside scanned paths or
   gitignored. A submodule needs an owned branch and explicit parent gitlink plan.
8. **Isolate and baseline runtime state.** Give parallel work distinct ports,
   databases, migrations, fixtures, caches, and environments. Capture pre-state.
   Install only when current authority covers the command, network, scripts, and
   effects; otherwise leave the baseline pending. Run the real baseline in the
   chosen workspace, capture post-state, and classify every side effect. Bind
   each red cell and raw output either to the task's accepted reproduction or
   to an exact approved pre-existing exclusion with evidence, owner, expiry/
   revisit rule, and compensating discriminator for new regressions. Generic
   “known failure,” an unexplained red, or uncontained effects block work.
9. **Record identity.** Report path, branch/HEAD, base, full relevant workspace
   inventory, external/generated gate inputs, pre/post baseline evidence and
   side effects, runtime identities, and task-owned cleanup resources.

## Pressure points

| The thought | The reality |
| --- | --- |
| "I'll just inspect first" | For edit requests, branch/status is the first inspection. |
| "It's only a small change" | Small changes still land on the wrong branch. Create the branch first. |
| "Worktrees are safer, so always use one" | User/project preference wins; a plain branch is correct for normal single-task work. |
| "The harness made a detached checkout, so I'll add my own worktree" | First determine whether the host already owns isolation and cleanup. |
| "I'll make the branch after the first edit" | After the edit, you may already have mixed unrelated state. |

## Checkpoint while you work

A branch or worktree isolates uncommitted work; durable checkpointing is a
separate decision. Create a checkpoint commit only when user/project policy
permits it and `verifying-completion` has run the checkpoint's real gate. A
checkpoint is neither reviewed nor done. `finishing-a-branch` may rewrite its
history only with authority established there. Hand recorded workspace/base/
ownership to that skill; do not integrate, discard, delete, or clean here.
