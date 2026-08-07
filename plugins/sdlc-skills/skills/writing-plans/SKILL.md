---
name: writing-plans
description: Use when approved requirements or a clearly multi-step task need an executable per-task plan before implementation. High-risk target-work planning requires current approved migration and assurance contracts. A plan limited to explicitly authorized gate-enabling prerequisites may consume the exact proposed owning gate contract, but cannot include target work. Skip single-step or trivial work.
---

# Writing Plans

Turn an aligned intent into an executable plan: a small durable **map** plus thin per-task **contracts**. Be ambitious on scope, light on implementation — pre-written code rots and produces a plan too long to read. The executor writes code at run time, with the most context.

## When to use

- Detailed requirements are approved, or a precise task spans ≥3 steps or multiple files.
- **Skip** for single-step or trivial changes — planning them costs more than doing them.
- If intent is ambiguous, route to `interview-me`; if detailed verifiable behavior is missing, route to `spec-it`. A precise task needs neither ritual.
- A high-risk target plan requires approved migration and assurance contracts;
  an authorized missing-gate-only plan may consume its exact proposal but must
  exclude target work. Unsettled facts stay evidence, not accepted deviations;
  gate establishment neither approves a contract nor passes target entry.
- Use separate plans for independent subsystems unless one cutover or rollback makes them one initiative.

## Procedure

**1. Bind inputs, files, interfaces, and effects first.** Record exact approved
input identities and freshness rules. Give each file/effect one owner; order
overlaps. For homogeneous work, bind the machine inventory and output pattern.

**2. Slice vertically, and size each task to its gate.** Each task is one
coherent independently evaluable capability; split only at a real gate boundary.

For approved high-risk target work, read `references/scalable-transformation.md`;
never redefine contract-owned transition policy. A gate-only plan has no target work.

**3. Contract, not transcript.** Give each task a stable non-positional ID,
exclusive files/effects, dependencies, and exact **Consumes**/**Produces**.
Pre-write code only where precision is fragile.

**4. Give every task a precommitted Evaluator.** Prefer executable; otherwise use
a named rubric and observations. Freeze identity/owner outside implementation
mutation; predeclare required edits and require RED/falsification before GREEN.

**5. Write the immutable proposal** to
`.sdlc-skills/plans/{{YYYY-MM-DD}}-{{topic}}/`. Build `00-index.md` from
`references/index-template.md` and thin tasks from `references/task-template.md`;
state stays external and normative changes use successors.

**6. Tag a capability tier per task** (mechanical → small, logic/design → large) — a tier, never a vendor model name; harnesses map tier → model.

### Self-review before saving (inline, ~30s)

- **Trace each requirement and accepted risk gate to a task or phase by name** — don't skim from memory. An uncovered requirement/risk is a silent gap; a task tracing to neither is scope creep.
- No undefined *scope*: `TBD`, `handle edge cases`, `similar to task N` each mean a task you haven't written. (Deferring *implementation* is fine; deferring *scope* is not.)
- Every task has an executable Evaluator or controlled rubric; the plan has one top-level **Acceptance** check.
- **Every Consumes resolves to a Produces** under the *same* name and type — a `clearLayers()` consumed but only `clearFullLayers()` produced is a build-time break — and no task violates a rule in the index's Constraints block.
- Independent tasks have disjoint files, data, effects, evaluators, and external
  state; every overlap has an explicit dependency and single transition owner.

### Present, then stop — the plan/execution handoff

Only the user can confirm the plan's *direction*, and this is the cheapest moment to redirect. A hard gate, not a formality:

- **Show the complete index and exact plan version** — goal, architecture,
  Constraints, Acceptance, trace, and task/phase list.
- Ask the recorded accountable owner or complete required approver set for the
  exact-version decision (`approve / reject / request changes / cancel`) and,
  only if approved, mode (`inline / delegated`); conflicts follow the plan rule.
- **Presenting and executing are separate turns**; require the direct version-and-mode approval above between them. Do not invoke `executing-plans`, create a task branch/workspace, or write code in the presentation turn.
- **Not a go:** prior approval, praise, comments, constraints, partial answers,
  silence, or a non-interactive session. Revise and re-ask.
- **Proceed unpaused only** under a direct standing order whose scope, owner,
  constraints, and mode explicitly cover unseen plan versions; bind the exact
  produced version to that receipt before execution.

Record approval/mode externally with the current user-role answer or trusted
version-bound receipt; the index cannot authenticate itself. Every normative
change creates a proposed successor. An approved successor invalidates
predecessor-bound reviews, tasks, and evidence until owner reconciliation;
runtime state stays in its ledger.

Before presenting a high-risk plan, run `references/plan-review.md` and resolve every blocker.
