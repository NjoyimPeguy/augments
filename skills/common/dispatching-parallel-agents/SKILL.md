---
name: dispatching-parallel-agents
description: Use when you have two or more genuinely independent pieces of work — separate failing tests, unrelated bugs, parallel research threads — that share no files, no state, and no ordering. Fan them out to concurrent agents, each with its own scope and deliverable, then reconcile. Skip when tasks depend on each other or share a file (sequence them with executing-plans), or when the work is quick enough inline.
---

# Dispatching Parallel Agents

Run independent work concurrently instead of in series. The win is wall-clock; the risk is collision — so this applies only when the pieces genuinely don't touch each other.

## When to use

- Two or more pieces of work that are **provably independent**: disjoint files, disjoint state, and no "B needs A's result."
- **Skip** when tasks share a file or dependency (sequence them — `executing-plans`), when one needs another's output, or when the whole thing is quick inline.

## The independence test — confirm before fanning out

Check every pair; if any fails, group them into one agent or sequence them instead:

- **Files** — they edit disjoint paths. Two agents on the same file race.
- **State** — disjoint ports, databases, fixtures. If they run a server or migrations, isolate each (`using-git-worktrees`).
- **Order** — none consumes another's output. A dependency is a sequence, not a fan-out.

## The dispatch packet (per agent)

Each agent starts cold — hand it everything, never your session history:

- **Scope** — the exact problem and files this agent owns, and what it must NOT touch.
- **Objective + deliverable** — what "done" means, and the precise shape to report back, so results reconcile.
- **Constraints** — the tier to run at, the quality rules, and "stay in scope; report out-of-scope rather than reaching."
- **Isolation** — if it builds or runs anything, its own workspace/port/DB.

## Reconcile (the coordinator's job, not the agents')

When agents return: read each deliverable, integrate them yourself, then run the **combined** check — the tests across all the changes together. N green agents do not prove the whole is green. Surface any agent that reported blocked or out-of-scope rather than papering over it.

## Common mistakes

- Fanning out work that shares a file or an ordering — the race corrupts both.
- Passing session history instead of a self-contained packet — the agent inherits your blind spots.
- No combined check — independently-green changes can still break together.
- Parallel agents sharing one dev server or database — isolate each (`using-git-worktrees`).
