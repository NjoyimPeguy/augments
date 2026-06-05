---
name: finishing-a-branch
description: Use when a change's checks have been run and verified green and you're ready to wrap the branch — clean commits, a real PR description, and a clear merge/keep/discard decision. If "done" or "tested" is only asserted and not yet confirmed by running the check, verify first (verifying-completion) — don't wrap on an unverified claim. Gates on green before anything destructive; never force-pushes or discards without explicit say-so. Skip mid-development — this is the wrap-up.
---

# Finishing a Branch

Take a working branch to a merge-ready state. The order is fixed — gate, tidy, describe, decide, clean up — and nothing destructive happens before the thing it depends on is confirmed.

## When to use

- A change is complete and its checks have been run and pass (not merely claimed), and you're ready to merge, open a PR, or set the branch aside.
- **Skip** mid-development — this is the wrap-up, not a checkpoint.

## Procedure

1. **Gate on green.** Run the tests and checks fresh; read the output. If anything fails, STOP and fix it before any step below. A merge-ready branch has passing checks, not "should be passing".
2. **Tidy the history.** One logical commit per coherent change. Imperative subject ≤ ~72 chars; the body says *why*, not *what* (the diff is the what). Squash fixup noise. Do **not** force-push a branch with shared history unless explicitly asked.
3. **Write the PR description** — two sections, no more:
   - `## Summary` — 2–3 bullets: what changed and why.
   - `## Test Plan` — how it was verified.
   A reader should grasp the change without opening the diff.
4. **Decide, explicitly** — surface the choice once; don't open-end it:
   - **Merge** it — only after review (`requesting-code-review`) and green checks.
   - **Open a PR** and leave the branch for review.
   - **Keep** it as-is, or **discard** it.
5. **Clean up only what you created**, and only after the merge is confirmed. Remove a workspace/worktree before deleting its branch, never the reverse (see `using-git-worktrees`). Never delete a branch or workspace you didn't create, and never discard without explicit confirmation.

## Common mistakes

- Presenting merge options while checks are red — the gate comes first.
- A force-push that rewrites shared history nobody asked you to rewrite.
- A PR body that restates the diff instead of explaining the why and the test plan.
- Deleting a branch before the worktree that references it (the delete fails), or cleaning up a workspace the harness owns.
