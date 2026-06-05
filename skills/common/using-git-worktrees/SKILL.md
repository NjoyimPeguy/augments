---
name: using-git-worktrees
description: Use when work needs isolation from your current checkout — a multi-task plan, parallel agents, or a risky change you don't want touching the main working tree. Sets up a worktree (or your harness's native isolation) with its own branch, ports, and data, so commits never land on the wrong branch. Skip when isolation already exists or the change is a quick one-liner on the current branch.
---

# Using Git Worktrees

Isolate work so it can't collide with your main checkout or another agent's. A worktree is a second working directory on its own branch, sharing one repository — the cheap way to get isolation without a second clone.

## When to use

- A plan of several tasks, a risky refactor, or parallel agents that must not share a working tree.
- **Skip** when isolation already exists (you're already on a dedicated branch/worktree), or for a quick one-liner you'll commit on the current branch.

## Procedure

1. **Prefer existing isolation.** If your harness already gives each task an isolated workspace, use that — don't stack a git worktree inside it. Fall back to `git worktree` only for a plain shared checkout.
2. **Create it outside any scanned tree.** A sibling dir (`git worktree add ../{{repo}}-{{branch}} -b {{branch}}`), or a `.worktrees/{{branch}}` subdir that is gitignored. Never create one inside a path a docs generator or build scans.
3. **Confirm the .gitignore covers it.** If the worktree lives under the repo, that path MUST be gitignored — otherwise the worktree's own files get committed into the parent.
4. **Isolate the runtime, not just the code.** A worktree shares nothing automatically: a dev server, database, or migration from one worktree collides with another's if they share a port/DB/state. Give this worktree its own port, database name, and env — declare them up front, don't discover the clash mid-run.
5. **Install dependencies fresh.** A new worktree has no installed packages or build cache — install before the first build or test, then run the baseline check once to confirm a clean start.
6. **Name the path the user can see.** The IDE is open on the main checkout; a worktree file won't show in its diff panel. State the worktree path once, explicitly, in a form the user can open — or a review gate gets silently skipped.

## Finishing

When the work merges, remove the worktree **before** deleting its branch (`git worktree remove <path>`, then delete the branch) — never the reverse, or the removal fails. Clean up only worktrees you created; `finishing-a-branch` owns the merge/teardown decision.

## Common mistakes

- Stacking a git worktree inside a workspace the harness already isolated.
- A `.worktrees/` dir that isn't gitignored — its files get committed into the parent.
- Two worktrees sharing a port or database — one's migration corrupts the other's run.
- A worktree path the user can't find from their IDE, so the review never happens.
- Deleting the branch before removing the worktree that references it.
