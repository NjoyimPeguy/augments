# Task NN: {{name}}

**Objective:** {{what this task accomplishes — one sentence}}
**Depends on:** {{none, or task numbers that must finish first — lets a dispatcher parallelize}}
**Files:** `path/to/file` (new) · `path/to/other` (edit)
**Suggested tier:** {{small | medium | large}} — {{mechanical | logic | design}}

## Change

{{Intent + the interface that locks it (names, signatures, data shapes). Don't pre-write the implementation — the executor writes it at run time with full context. Include exact code ONLY where precision is fragile (tricky regex, security check, migration SQL).}}

## Evaluator

The deterministic pass/fail gate — declared now, run on the built code.

```bash
{{command}}
```

Expected: {{exit 0 / named tests pass / HTTP 200 body X / query returns Y}}

{{No deterministic check possible (design/AI work)? Replace the command with a rubric pass-list — explicit criteria, each one checkable.}}
