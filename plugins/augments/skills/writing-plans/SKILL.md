---
name: writing-plans
description: Use when requirements are agreed (a brief from interview-me or spec-it) or the task is clearly multi-step, and you need an executable plan before implementing — a per-task plan directory each task loads independently. Skip for single-step or trivial work — just do it.
---

# Writing Plans

Turn an aligned intent into an executable plan: a small durable **map** plus thin per-task **contracts**. Be ambitious on scope, light on implementation — pre-written code rots, balloons tokens, and produces a plan too long for a human to read. The executor writes code at run time, with the most context.

## When to use

- Requirements are agreed (a brief from `interview-me`/`spec-it`) or the task spans ≥3 steps or multiple files.
- **Skip** for single-step or trivial changes — planning them costs more than doing them.
- If requirements are still fuzzy, suggest `interview-me` first (optional, not a gate).
- If the work spans multiple *independent* subsystems, write a separate plan per subsystem — each must produce working, testable software alone.

## Procedure

### Decompose the work

**1. Map files and interfaces first.** List every file to create or modify with one line of responsibility. Read any interface you're unsure of. This locks task boundaries by responsibility, not by the order you write them.

**2. Slice vertically, and size each task to the reviewer's gate.** Thin end-to-end tasks (schema → API → UI → test for *one* capability), each independently shippable — not layer-wide tasks ("all the endpoints"). A task is the *smallest unit that carries its own Evaluator and is worth a fresh reviewer's gate*: fold setup, config, scaffolding, and docs into the task whose deliverable needs them, and split only where a reviewer could reject one task while approving its neighbour.

### Write each task as a contract

**3. Contract, not transcript.** State the objective and the files, then lock the *interface* by splitting it in two: what the task **Consumes** (names, signatures, data shapes it takes from earlier tasks) and what it **Produces** (the exact names and types later tasks will rely on). Because each task loads on its own, this Consumes/Produces pair is how independent tasks stay interface-consistent *by construction* — not by hoping the executor recalls task 3 while writing task 7. Pre-write exact code ONLY where precision is fragile (tricky regex, a security check, exact migration SQL); everywhere else, implementation is the executor's job.

**4. Give every task a deterministic Evaluator.** A pre-committed pass/fail gate, declared now and run on the built code: a test command exiting 0, an HTTP/DB assertion, or — when nothing deterministic exists (design/AI work) — an explicit rubric pass-list. "Done" is never a judgment call: agents reliably praise their own work.

### Assemble the plan directory

**5. Write it** to `.augments/plans/{{YYYY-MM-DD}}-{{topic}}/` (the standard plans location; another path only if the user says otherwise). Write the files one at a time — index, then each task file — never one monolithic dump: a long write can stall or truncate, and a half-written plan reads as done. It contains:
- `00-index.md` — the map: goal, 2–3-sentence architecture, a **Constraints** block (project-wide rules — version floors, dependency limits, naming, security, platform — copied verbatim; every task's contract implicitly includes them), an **Acceptance** check (the end-to-end definition of done for the whole plan), checkbox task list with status, links. See `index-template.md`.
- `NN-<task>.md` — one contract each, ≤ ~2k tokens. See `task-template.md`.

**6. Tag a capability tier per task** (mechanical → small, logic/design → large) — a tier, not a vendor model name; each harness maps tier → model at dispatch.

### Self-review before saving (inline, ~30s)

- **Trace each requirement to a task by name** — don't skim from memory. List the requirements in the brief/spec and point each at the task that implements it: a requirement with no task is a silent gap; a task tracing to nothing in the brief is scope creep. (A from-memory skim is what passes plans that have already drifted.)
- No undefined *scope*: `TBD`, `handle edge cases`, `similar to task N` each mean a task you haven't written. (Deferring *implementation* is fine; deferring *scope* is not.)
- Every task has a deterministic Evaluator or an explicit rubric, and the plan has one top-level **Acceptance** check (whole-feature done).
- **Every Consumes resolves to a Produces** under the *same* name and type — a `clearLayers()` consumed but only `clearFullLayers()` produced is a build-time break — and no task violates a rule in the index's Constraints block.

### Present, then stop — the plan/execution handoff

Only the user can confirm the plan's *direction*, and this is the cheapest moment to redirect. A hard gate, not a formality:

- **Show the index** — goal, architecture, Constraints, Acceptance, the task list.
- **End your turn with one question that both approves and chooses how to run it:** *"Ready to execute this as written, or want changes? If it's a go — run it **inline** here (you watch each task land) or **subagent-driven** (a fresh subagent per task, reviewed between tasks — better for long plans and context isolation)?"* Then wait.
- **Presenting and executing are two separate turns**, with the user's "go" between them — do not invoke `executing-plans`, create a task branch/workspace, or write a line of code in the same turn you present the plan.
- **What does *not* count as a go:** a green light given *before* the plan existed ("go ahead", "over to you" — that approved the work, not the unseen plan); a non-interactive session (end the turn with the plan presented — don't skip the pause because nobody can answer).
- **Proceed unpaused only** when the user explicitly ordered a straight-through run ("plan it and build it, don't stop for approval") or requested an unattended run.

If reality deviates during execution, update the task file and `00-index.md` — the plan stays the source of truth.

## Common mistakes

- One giant pre-written-code plan — the cost this skill exists to avoid.
- Horizontal-layer tasks that can't be verified alone.
- A task whose "done" is vibes, with no Evaluator.
- Restating the brief in every task file.
- Planning work small enough to just do.
