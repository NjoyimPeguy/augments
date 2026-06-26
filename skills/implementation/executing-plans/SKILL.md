---
name: executing-plans
description: Use when you have a plan directory from writing-plans (a 00-index map plus per-task contract files) and need to execute it to done. Works one task at a time, gates each task on its Evaluator, and keeps the index as the live record. Skip for a single task — just do it.
---

# Executing Plans

Run a plan to done one task at a time. The index is the source of truth: a task is done only when its Evaluator passes, and the plan is done only when the plan-level Acceptance passes.

## Before you start

1. **Confirm the user has seen the plan.** If you arrived here straight from writing it, present the index and stop for the go — the user steers at the plan/execution seam. A "go ahead" given *before* the plan existed approved the work, not the unseen plan; a non-interactive session means end the turn with the plan presented, not skip the pause. Proceed unpaused only on an explicit straight-through order or an explicitly requested unattended run.
2. **Confirm you are not on the main branch.** For a plan of 3+ tasks, set up an isolated worktree *now* (see `using-git-worktrees`) — don't rationalize "it's quick" into skipping this. Silent commits to main are the failure this prevents.
3. **Load the index (`00-index.md`)** and read it critically: raise any concern (missing dependency, unclear or contradictory task, design conflict) *before* writing code, and confirm the task contracts together actually deliver the Acceptance. Gaps are cheap to fix now and expensive ten tasks in.

## The loop

Work tasks in order, honoring each task's `Depends-on`. For each:

1. **Load only that task's contract file** — don't re-read completed tasks; keep context small.
2. **Note the current commit**, so a review (if any) can scope to this task's diff.
3. **Build the change** at the task's suggested tier. A fully-specified mechanical task (create a file, a rename, a config change) runs inline with just the self-check. When your context is filling on a long run, or a task is large and self-contained, offload it to a fresh-context subagent — see `subagent-dispatch.md`.
4. **Self-check before done:** every requirement met, behavior covered by a real test, existing patterns followed, no scope you weren't asked for.
5. **Run the task's Evaluator.** Only when it passes, tick `[x]` for that task in the index.
6. If you learned something that affects later tasks, append a line to a `## Learnings` section in the index — and carry it into any later subagent dispatch.

**Sequential is the default, not a rule.** "One task at a time" is the *gate cadence* — verify each task's Evaluator before the next — not a ban on concurrency. Tasks with no `Depends-on` between them and disjoint files and state may be fanned out with `dispatching-parallel-agents`; each still gates on its own Evaluator, and the combined check waits for the plan's Acceptance.

## Name the outcome

Don't let "done" hide doubt: **done** (Evaluator green, self-check clean) · **done with concerns** (it works but something nags — record it in the index, don't bury it) · **blocked** (missing dependency, an Evaluator you can't pass, a contradictory task — stop and surface it) · **needs context** (reading file after file without progress — get the missing information, don't guess).

Bad work is worse than no work — escalate rather than guess.

## Long runs

Context grows as you go. Every few tasks, or after a task with large output, it's safe to reset to a fresh session and resume — the index is the durable record. To resume: load `00-index.md`, announce the position (done vs left), find the first unticked task, and continue.

## When reality differs from the plan

If a task is wrong or outdated, update the task file and the index before continuing — the plan stays the source of truth. Don't silently drift.

## Finishing

When every task is `[x]`, run the plan-level **Acceptance** from the index. Only then is the plan done; merging or opening a PR is your next decision.

## Common mistakes

- Executing on main, or holding the whole plan in context at once.
- Ticking `[x]` before the Evaluator is green.
- A subagent committing to the wrong branch — a gitignored worktree makes `git status` look empty; pass absolute git paths (see `subagent-dispatch.md`).
- Forcing heavy review on a trivial task, or guessing past a blocker instead of surfacing it.
