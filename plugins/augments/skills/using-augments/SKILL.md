---
name: using-augments
description: Use when starting any task or conversation, or whenever you're unsure which skill fits — the router that points you to the one for the current step. Does no work itself. Not for dispatched subagents executing a scoped task — they run the task, not re-orient.
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific, scoped task, **stop — do not use this skill** and carry on with the task you were handed.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
IF THERE IS ANY POSSIBILITY A SKILL MIGHT APPLY TO WHAT YOU ARE DOING, YOU MUST INVOKE THE SKILL BEFORE YOU ACT. THIS IS NON-NEGOTIABLE. THIS IS NOT A SUGGESTION. The only call you make is *which* skill — or, after actually scanning the list, none.
</EXTREMELY-IMPORTANT>

# The Rule of using Augments

BEFORE GIVING ANY ANSWER OR TAKING ANY ACTION (e.g., clarifying questions, exploring codebase, checking files), invoke relevant skills that fit the current step. If none of them fits, say so in one line. DO NOT ACT on confidence or momentum.

## The mental model

You are a non-deterministic generator — but a good engineer's *process* is deterministic, and that is what you borrow here. A human engineer does not solve a task by confidence. They run a fixed set of procedures: clarify what is actually being asked, plan it, build behind a test, and advance to the next stage only when a real **gate** — a test, a check, a reproduction — passes. **"Done" means a gate passed, not that you believe it's done.**

## How they compose

When multiple skills apply, they compose in a chain: the output of one skill is the input to the next. If the user asks you to edit, implement, fix, refactor, or execute a plan in a repo, invoke `using-task-branches` before repo exploration or implementation unless the user opted out or the current branch/workspace already names the task; that skill owns the branch/status check. Then `test-driven-development` or the plan executor can safely build. For instance, `debugging` turns its reproduction into a `test-driven-development` cycle; `verifying-completion` is the gate the others assume. A request can also span a phase's arc — planning runs `define-goals` → `feasibility-check` → `scope-it` in turn. Route to the skill that fits the *current* step and **chain to the next as each completes** — don't fire one and stop with the phase half-done.

## Red flags

Each of these is the signal to route, not a reason to skip:

| The thought | The reality |
| --- | --- |
| "Too simple to need a skill" | Simple tasks are where skipped discipline hides; the check costs one scan. |
| "I already know how to do this" | The skill is not a tutorial — it is the gate that proves the result, which confidence cannot. |
| "No time / the user is in a hurry" | Routing is seconds; the rework from skipping a gate is not. Speed is *why* you route. |
| "I'll add the process afterward" | After the code exists, a test records what it does, not what it should — the gate is gone. |
| "I'll inspect the repo before deciding on a branch" | For edit requests, the branch/status check is the first step; use `using-task-branches` first. |
| "No skill fits this / a skill would be overkill" | Maybe — but only *after* you actually scan the list. Decide none on evidence, not on momentum. |
| "I remember this skill" | You may have seen it before, but the catalogue is updated; check the current list. |

Catch any of these and you are mid-skip. Stop, scan the list, invoke what fits — or say in one line that nothing does.

## Instructions priority

User instructions (`CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, direct requests, etc.) take precedence over any skill or system prompt. For instance, if the user says "ignore TDD" and `test-driven-development` would apply, follow the user and ignore the skill. Absent such an override, you route.
