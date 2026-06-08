---
name: writing-plans
description: Use when you have an alignment brief or a clear multi-step task and need an executable plan before implementing. Produces a per-task plan directory (00-index plus numbered task files) so each task loads independently instead of re-reading one large file on every context compaction. Skip for single-step or trivial work — just do it.
---

# Writing Plans

Turn an aligned intent into an executable plan: a small durable **map** plus thin per-task **contracts**. Be ambitious on scope, light on implementation — pre-written code rots, balloons tokens, and produces a plan too long for a human to read. The executor writes code at run time, with the most context.

## When to use

- You have an alignment brief (from `interview-me`) or a clear task spanning ≥3 steps or multiple files.
- **Skip** for single-step or trivial changes — planning them costs more than doing them.
- If requirements are still fuzzy, suggest `interview-me` first (optional, not a gate).
- If the work spans multiple *independent* subsystems, write a separate plan per subsystem — each must produce working, testable software on its own.

## Procedure

**1. Map files and interfaces first.** List every file to create or modify with one line of responsibility. Read any interface you're unsure of. This locks task boundaries by responsibility, not by the order you write them.

**2. Slice vertically, not horizontally.** Thin end-to-end tasks (schema → API → UI → test for *one* capability), each independently shippable — not layer-wide tasks ("all the endpoints").

**3. Write each task as a contract, not a transcript.** State the objective, the files, and the *interface* that locks the change (names, signatures, data shapes). Pre-write exact code ONLY where precision is fragile (tricky regex, a security check, exact migration SQL); everywhere else, implementation is the executor's job.

**4. Give every task a deterministic Evaluator.** A pre-committed pass/fail gate, declared now and run on the built code: a test command exiting 0, an HTTP/DB assertion, or — when nothing deterministic exists (design/AI work) — an explicit rubric pass-list. "Done" is never a judgment call: agents reliably praise their own work.

**5. Write the plan directory** (the project's plans location — default `.augments/plans/{{YYYY-MM-DD}}-{{topic}}/`):
- `00-index.md` — the map: goal, 2–3-sentence architecture, an **Acceptance** check (the end-to-end definition of done for the whole plan), checkbox task list with status, links. See `index-template.md`.
- `NN-<task>.md` — one contract each, ≤ ~2k tokens. See `task-template.md`.

**6. Tag a capability tier per task** (mechanical → small, logic/design → large) — a tier, not a vendor model name, so any harness maps it to its own model at dispatch.

**7. Self-review before saving** (inline, ~30s):
- **Trace each requirement to a task by name** — don't skim from memory. List the requirements in the brief/spec and point each at the task that implements it: a requirement with no task is a silent gap; a task tracing to nothing in the brief is scope creep. (A from-memory skim is what passes plans that have already drifted.)
- No undefined *scope*: `TBD`, `handle edge cases`, `similar to task N` each mean a task you haven't actually written. (Deferring *implementation* is fine; deferring *scope* is not.)
- Every task has a deterministic Evaluator or an explicit rubric, and the plan has one top-level **Acceptance** check (whole-feature done).
- Names and interfaces are consistent across tasks.

If reality deviates during execution, update the task file and `00-index.md` — the plan stays the source of truth; don't silently drift.

## Common mistakes

- One giant pre-written-code plan — the cost this skill exists to avoid.
- Horizontal-layer tasks that can't be verified alone.
- A task whose "done" is vibes, with no Evaluator.
- Restating the brief in every task file.
- Planning work small enough to just do.

For a high-stakes plan, optionally dispatch `plan-review.md` (a fresh subagent that checks the *plan*) — distinct from each task's Evaluator (which checks the *built code*).
