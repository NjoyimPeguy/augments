---
name: executing-plans
description: "Use when you have a plan directory from writing-plans (a 00-index map plus per-task contract files) and need to execute it to done, gating every task on its Evaluator. Per-task gating, not a concurrency ban: sequential by default, independent tasks can fan out. Skip for a single task — just do it."
---

# Executing Plans

Run a plan to done, gating every task on its Evaluator before building on it. The index is the source of truth: a task is done only when its Evaluator passes, and the plan only when the plan-level Acceptance passes.

## Before you start

1. **Confirm the plan was approved before you touch task 1.** If you just wrote it, `writing-plans` owns the present-and-pause — don't start executing in that turn. If you arrived here fresh (a resumed or handed-off session), present the index, end your turn with a go/no-go question, and wait.
2. **Confirm task-branch isolation.** Before task 1, create or enter the task branch/workspace (see `using-task-branches`). For a plan of 3+ tasks or any parallel/runtime-heavy work, decide whether a plain branch is enough or a worktree is needed. Silent commits to main are the failure this prevents.
3. **Load the index (`00-index.md`)** and read it critically: raise any concern (missing dependency, unclear or contradictory task, design conflict) *before* writing code, and confirm the task contracts together actually deliver the Acceptance. Gaps are cheap to fix now and expensive ten tasks in.

## The loop

Work tasks in order, honoring each task's `Depends-on`. For each:

1. **Load only that task's contract file** — don't re-read completed tasks; keep context small.
2. **Note the current commit**, so a review (if any) can scope to this task's diff.
3. **Build the change** at the task's suggested tier — pick the execution mode:
   - **Inline** — a fully-specified mechanical task (create a file, a rename, a config change): build it here, just the self-check.
   - **Sequential offload** — a large or self-contained task, or when your context is filling on a long run: hand it to a fresh-context subagent, one task at a time (`references/subagent-dispatch.md`).
   - **Parallel fan-out** — tasks independent *of each other* (disjoint files and state, no `Depends-on` between them): run them at once (`dispatching-parallel-agents`); each still gates on its own Evaluator, with the plan-level Acceptance as the combined check.
   If the user picked a posture at the plan handoff — **inline** vs **subagent-driven** — honour it as the default (still dropping to inline for trivial mechanical tasks, and fanning out genuinely independent ones). Whichever mode, the task is not done until its Evaluator passes (step 5).
4. **Self-check before done:** every requirement met, behavior covered by a real test, existing patterns followed, no scope you weren't asked for.
5. **Run the task's Evaluator.** Only when it passes, tick `[x]` for that task in the index.
6. If you learned something that affects later tasks, append a line to a `## Learnings` section in the index — and carry it into any later subagent dispatch.

## Name the outcome

Don't let "done" hide doubt: **done** (Evaluator green, self-check clean) · **done with concerns** (it works but something nags — record it in the index, don't bury it) · **blocked** (missing dependency, an Evaluator you can't pass, a contradictory task — stop and surface it) · **needs context** (reading file after file without progress — get the missing information, don't guess).

Bad work is worse than no work — escalate rather than guess.

## Circuit breaker

Three failed attempts at the same task — same failure class, no convergence — is a stop signal, not a prompt for attempt four (the same rule `debugging` applies to fixes). Mark the task **blocked**, record what was tried in the index, and escalate: re-plan the task, question the design, or ask the human. Repeated fix loops spend heavily without converging; proportionality is part of the gate.

## Long runs

Context grows as you go. Every few tasks, or after a task with large output, it's safe to reset to a fresh session and resume — the index is the durable record. To resume: load `00-index.md`, announce the position (done vs left), find the first unticked task, and continue.

## When reality differs from the plan

If a task is wrong or outdated, update the task file and the index before continuing — the plan stays the source of truth. Don't silently drift.

## Finishing

When every task is `[x]`, run the plan-level **Acceptance** from the index. Only then is the plan done — hand off to `finishing-a-branch` for the merge/PR decision.

## Common mistakes

- Executing on main, or holding the whole plan in context at once.
- Ticking `[x]` before the Evaluator is green.
- A subagent committing to the wrong branch or workspace — pass absolute git paths (see `references/subagent-dispatch.md`).
- Forcing heavy review on a trivial task, or guessing past a blocker instead of surfacing it.
