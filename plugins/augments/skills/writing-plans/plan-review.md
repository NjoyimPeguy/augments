# Plan Review (optional)

A fresh-context subagent catches what the plan's author can't — you're anchored to your own naming and assumptions. Use for high-stakes plans (migrations, security-sensitive, wide blast radius). **Single pass, not a loop.**

This reviews the **plan** *before* execution — distinct from each task's **Evaluator**, which gates the **built code** *after* execution. Different artifact, different moment.

Dispatch a subagent with access to the plan directory and the codebase, and this brief:

> Review the plan in `{{plan directory}}`. Flag **only** issues that would cause a real implementation problem — skip style and preference. Check four things:
>
> 1. **Completeness** — list each requirement in the brief or spec and the task that implements it. Name any requirement with no covering task, and any task that traces to no requirement.
> 2. **Correctness** — do the files, function names, and data shapes the tasks reference match the actual codebase? Quote each mismatch.
> 3. **Decomposition** — is each task independently verifiable, ~one commit, with no hidden placeholders?
> 4. **Consistency** — does every task's *Consumes* resolve to an earlier task's *Produces* under the same name and type? Quote each mismatch.
>
> Return a short list, one line each: `task — issue — suggested fix`. If nothing blocks implementation, say so in one line.

Apply the fixes to the task files yourself. Don't re-dispatch unless the plan changed substantially — re-review loops are the cost trap this skill is calibrated to avoid.
