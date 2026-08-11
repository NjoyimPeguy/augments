---
name: using-task-branches
description: "Use before starting repo edits or implementation, or when work needs isolation from the current checkout, so a meaningful task branch, harness workspace, or git worktree exists according to user or project preference. Fires on start on this ticket and let's build X inside a repository, even if nobody says branch or worktree. Skip read-only work, and skip when the current branch or workspace is already dedicated to this task."
---

<EXTREMELY-IMPORTANT>
NEVER START REPO EDITS ON `main`/`master`, `dev`/`develop`, A RELEASE BRANCH, OR
AN UNRELATED TASK BRANCH. Create or enter a meaningful branch or workspace
*before* the first edit, unless the user explicitly okayed the current checkout.
</EXTREMELY-IMPORTANT>

# Using Task Branches

## When to use

- You are about to edit files, implement a feature/fix/refactor, execute a plan, or dispatch agents.
- Runtime or review isolation matters: parallel agents, risky changes, separate ports, databases, fixtures, or long-running app state.
- **Skip** for read-only investigation, when the user explicitly says to stay in the current checkout, or when the current branch/workspace is already dedicated to this task with known ownership, base, and baseline.

## Procedure

Each step fills the matching section of `assets/workspace-record.md`. Open it
now and write as you go — the fields it asks for are the ones a later step, and
whatever finishes the branch, cannot re-derive from the repository alone.

### Understand what you are already in

1. **Detect the real checkout** — repository root, status, branch or detached
   HEAD, `git-dir` and `common-dir`, registered worktrees, a submodule
   superproject, and any harness-native workspace metadata.

   A detached or host-owned checkout may already be isolated. Until you know its
   owner and permitted lifecycle, do not nest inside it, attach to it, switch it,
   or clean it.

2. **Classify ownership** of every resource and dirty change: created by this
   task, or pre-existing, user-owned, shared, or host-owned. Unknown provenance
   counts as the latter, and blocks switching or cleanup.

3. **Separate planning state from implementation state.** Planning may stay in
   an approved planning or native workspace. Before the first product edit,
   re-run this check and bind implementation to its own branch or workspace and
   its own exact base. Plan approval says nothing about code isolation.

### Establish the base

4. **Prove the intended base** from direct user or project guidance, and record
   its revision and remote freshness. Gate inputs that live outside the source
   tree — ignored, generated, external — belong in the record too; the revision
   does not capture them.

   Any install or baseline command runs under the contract in
   `references/baseline-contract.md`. Read it before running anything, not
   after: it decides whether the command may run in the current checkout at all.

### Create the workspace

5. **Choose isolation without nesting.** User instruction wins, then project
   guidance, then an existing native workspace. Failing those, a normal branch
   suits one task; reach for a worktree when there are parallel writers,
   separate runtime state, or a dirty checkout that must stay untouched.

6. **Validate the name and its collisions.** Follow project naming, or use
   `feature/{{short-task}}`, `fix/{{short-task}}`, or `docs/{{short-task}}`.
   Validate the ref, then check local branches, remote-tracking refs, and
   attached worktrees. Never overwrite or silently reuse a collision.

7. **Create only from the proven base.** Keep a worktree outside scanned paths,
   or gitignored. A submodule needs an owned branch and an explicit plan for the
   parent gitlink.

### Baseline it

8. **Isolate runtime state, then run the real baseline in the chosen
   workspace.** `references/baseline-contract.md` owns what "real" requires
   here: the pre-run inspection, the distinct runtime identities, the pre/post
   capture, and how each red cell is bound before work continues.

   The rule that survives without the reference: a red cell you cannot attribute
   blocks work. So do uncontained effects.

9. **Report the record.** Hand over the completed
   `assets/workspace-record.md` — identity, inventory, external gate inputs,
   baseline evidence and side effects, runtime identities, and the task-owned
   resources that may later be cleaned up.

## Pressure points

| The thought | The reality |
| --- | --- |
| "I'll just inspect first" | For edit requests, branch/status is the first inspection. |
| "It's only a small change" | Small changes still land on the wrong branch. Create the branch first. |
| "Worktrees are safer, so always use one" | User/project preference wins; a plain branch is correct for normal single-task work. |
| "The harness made a detached checkout, so I'll add my own worktree" | First determine whether the host already owns isolation and cleanup. |
| "I'll make the branch after the first edit" | After the edit, you may already have mixed unrelated state. |

## Checkpoint while you work

<EXTREMELY-IMPORTANT>
COMMIT LOCALLY AS YOU GO — after each independently testable piece, not once at
the end. The authority is already granted; do not ask again for each checkpoint.
A checkpoint never grants push, publication, or integration authority.
</EXTREMELY-IMPORTANT>

Committing is not the last step of the task. It is a step you owe after each
independently testable piece, and the authority for it already exists: local
task-branch commits are authorized repository edits unless higher-priority user
or project policy withholds them or requires approval not yet given.

10. **After each coherent piece a reviewer could accept or reject separately**,
    invoke `verifying-completion`, run its smallest real gate, and commit
    locally. Do not wait for the final candidate, and do not ask again for each
    checkpoint.
11. **Stop there.** A checkpoint is neither reviewed nor done and grants no
    push, publication, or integration authority. `finishing-a-branch` may
    rewrite its history only with authority established there. Hand it the
    recorded workspace, base, and ownership; do not integrate, discard, delete,
    or clean here.

| The thought | The reality |
| --- | --- |
| "I'll commit once it all works" | One terminal commit cannot be reviewed or reverted in pieces, and every good intermediate state is gone. |
| "Nothing is finished, so there is nothing to commit" | The unit is an independently testable change, not a finished feature. If a gate can accept it, it can be a checkpoint. |
| "I should ask before each commit" | The authority is already granted. Asking again per checkpoint spends the user's turn re-deciding what they decided. |
| "The gate is slow — I'll run it once at the end" | Then a red gate at the end leaves every change a suspect. The smallest gate per checkpoint is what keeps that cheap. |
| "It passes locally, so committing can wait" | An uncommitted passing state is one crash, wrong checkout, or overwrite away from not existing. |
| "A mid-task commit looks unfinished" | It claims nothing. Nothing reads a checkpoint as done until `finishing-a-branch` runs. |
