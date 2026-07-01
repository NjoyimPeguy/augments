# Activation record — executing-plans wording, subagent modes, main-branch guard (2026-06-30)

Three related always-loaded-surface changes, re-measured on the real `claude` CLI.
Activation results are ephemeral — re-run for current truth.

## What changed

1. **executing-plans — de-serialized the surface (#2).** The `description` and the
   opening line said "Works one task at a time" / "Run a plan to done one task at a
   time," which read as a hard serial constraint. Both now lead with the real
   discipline — *gate every task on its Evaluator* — and state plainly that the gate
   cadence is per-task, **not** a ban on concurrency (the body's "Sequential is the
   default, not a rule" paragraph already said this; the surface now matches it).
2. **executing-plans — named the three execution modes (#3).** Step 3 of the loop
   was one run-on sentence mixing inline and subagent work. It now names **Inline /
   Sequential offload (`subagent-dispatch.md`) / Parallel fan-out
   (`dispatching-parallel-agents`)** with the trigger for each, and that every mode
   gates on the Evaluator. This is the crisp decision the subagent path was missing.
3. **main-branch guard, consent-based (#4).** Surfaced beyond executing-plans:
   `using-git-worktrees` now opens with a prominent rule — *never start non-trivial
   work on `main`/`master` without explicit user consent; a trivial one-liner can
   stay on the current branch* — and the `using-augments` router carries a
   build-entry reminder pointing to it, so the guard reaches ad-hoc (non-plan) builds.

## Runs and results (real `claude` CLI; new = `--working-tree`, old = installed 2.1.1 cache)

| Run | Opening | Result |
| --- | --- | --- |
| Router fires | `scenarios/common/using-augments`, new | **ACTIVATED** `using-augments` — the body changes (#1 yagni move, #4 branch line) did not break routing |
| executing-plans, new | `scenarios/implementation/executing-plans`, new | NONE — empty-dir **artifact** (scenario implies "the plan directory we wrote earlier"; the empty temp dir has none, so the model goes hunting for it) |
| executing-plans, old | same scenario, cached 2.1.1 | NONE — **same artifact**, identical first move. Parity ⇒ the #2/#3 description change causes **no activation regression** |

## Honest limits

- **#2 and #3 are behavioral, not activation.** Whether the model actually fans out
  independent tasks (#2) or picks the right execution mode (#3) is an execution trace,
  not a single `Skill` tool_use — the activation harness cannot score it, and the
  empty temp dir has no real plan to execute. The provable claims here are: the gate
  is green, the always-loaded surface no longer mis-states seriality, and activation
  did not regress (parity A/B). The behavioral effect rests on the corrected prose
  reaching the model, not on a measured run.
- **#4 is also behavioral.** The branch guard is prose on the routing surface and in
  `using-git-worktrees`; whether the model isolates before building on `main` is not
  a detectable tool_use. No harness claim is made that it changes that behavior — only
  that the guard is now present at the build entry, consent-based, beyond plan execution.
- Single runs, not N-of-N.
