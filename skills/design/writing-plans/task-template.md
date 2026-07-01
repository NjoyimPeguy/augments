# Task NN: {{name}}

**Objective:** {{what this task accomplishes — one sentence}}
**Depends on:** {{none, or task numbers that must finish first — lets a dispatcher parallelize}}
**Files:** `path/to/file` (new) · `path/to/other` (edit)
**Context:** {{key files or entrypoints to read first for this task — or "none"}}
**Suggested tier:** {{small | medium | large}} — {{mechanical | logic | design}}

## Change

{{Intent — what this task makes true, in a sentence or two.}}

**Interface** — the contract that lets other tasks build against this one without reading it:

- **Consumes:** {{names, signatures, data shapes this task takes from earlier tasks — or "nothing"}}
- **Produces:** {{the exact names and types later tasks will rely on — another task's executor sees only this line to learn them}}

{{Don't pre-write the implementation — the executor writes it at run time with full context. Include exact code ONLY where precision is fragile (tricky regex, security check, migration SQL).}}

## Evaluator

The deterministic pass/fail gate — declared now, run on the built code.

```bash
{{command}}
```

Expected: {{exit 0 / named tests pass / HTTP 200 body X / query returns Y}}

{{No deterministic check possible (design/AI work)? Replace the command with a rubric pass-list — explicit criteria, each one checkable.}}
