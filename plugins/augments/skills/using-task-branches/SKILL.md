---
name: using-task-branches
description: Use before starting repo edits or implementation, or when work needs isolation from the current checkout - ensure a meaningful task branch, harness workspace, or git worktree exists according to user/project preference. Skip for read-only work or when the current branch/workspace is already dedicated to this task.
---

# Using Task Branches

Start implementation on a branch or workspace named for the task. The point is not worktrees; the point is preventing edits from landing on `main`, a release branch, or someone else's work.

**Never start repo edits on `main`/`master`, `dev`/`develop`, a release branch, or an unrelated task branch.** Create or enter a meaningful branch/workspace *before* the first edit, unless the user explicitly okayed working in the current checkout.

## When to use

- You are about to edit files, implement a feature/fix/refactor, execute a plan, or dispatch agents.
- Runtime or review isolation matters: parallel agents, risky changes, separate ports, databases, fixtures, or long-running app state.
- **Skip** for read-only investigation, when the user explicitly says to stay in the current checkout, or when the current branch/workspace is already dedicated to this task.

## Procedure

1. **Check where you are.** Read the current branch/workspace and `git status`. If it already names this task, use it. If there are uncommitted changes you didn't make, don't switch across them blindly; ask or create a separate worktree from a clean base.
2. **Choose the isolation mode by preference.** User instruction wins, then repo guidance, then harness-native isolation. If no preference is known, create a normal git branch in place for ordinary single-task work. Use a worktree only when the user/project prefers it, parallel work or runtime state needs separate files, or the current checkout is dirty and must stay untouched.
3. **Name the branch from the task.** Follow project convention if present. Otherwise use lowercase kebab-case, optionally grouped by kind: `feature/{{short-task}}`, `fix/{{short-task}}`, `docs/{{short-task}}`, or just `{{short-task}}`. Keep it short and descriptive; avoid spaces, dates, agent names, and vague names like `updates` or `fixes`. If unsure, validate with `git check-ref-format --branch {{branch}}`.
4. **Create or enter it before edits.** For a branch, use the project-equivalent of `git switch -c {{branch}}` from the intended base. For a worktree, use a sibling dir (`git worktree add ../{{repo}}-{{branch}} -b {{branch}}`) or a gitignored `.worktrees/{{branch}}` path.
5. **If using a worktree, keep it out of scans.** Never create one inside a path a docs generator or build scans. If it lives under the repo, that path MUST be gitignored or its files can be committed into the parent.
6. **Isolate runtime state when needed.** A branch or worktree does not isolate a dev server, database, migration, fixture, or cache by itself. Give parallel work its own port, database name, and env.
7. **Install and baseline new worktrees.** A new worktree has no installed packages or build cache; install dependencies and run the baseline check once before changing code.
8. **State the workspace.** Tell the user the branch name and, for a worktree, the path. The IDE may still be open on the original checkout.

## Pressure points

| The thought | The reality |
| --- | --- |
| "I'll just inspect first" | For edit requests, branch/status is the first inspection. |
| "It's only a small change" | Small changes still land on the wrong branch. Create the branch first. |
| "Worktrees are safer, so always use one" | User/project preference wins; a plain branch is correct for normal single-task work. |
| "I'll make the branch after the first edit" | After the edit, you may already have mixed unrelated state. |

## Finishing

When the work merges, `finishing-a-branch` owns cleanup. Remove a worktree **before** deleting its branch (`git worktree remove <path>`, then delete the branch). Never delete or discard a branch/workspace you did not create without explicit confirmation.

## Common mistakes

- Treating `main`, `dev`, or an unrelated feature branch as isolation for a new task.
- Ignoring the user's branch-vs-worktree preference.
- Stacking a git worktree inside a workspace the harness already isolated.
- Starting implementation before the branch/workspace exists.
- A `.worktrees/` dir that isn't gitignored — its files get committed into the parent.
- Two worktrees sharing a port or database — one's migration corrupts the other's run.
- A worktree path the user can't find from their IDE, so the review never happens.
- Deleting the branch before removing the worktree that references it.
