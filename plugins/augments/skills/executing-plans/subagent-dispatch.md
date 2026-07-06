# Executing Plans — Subagent Dispatch

Dispatching a task to a subagent gives it a fresh context window. Reach for it when your own context is filling on a long run, or when a single task is large and self-contained enough to run in its own window — then offload it, gate it on its Evaluator, and move on. This is *sequential*, one task at a time. A small, fully-specified mechanical task is faster inline; don't dispatch one, and don't force a review pass on it.

*One-at-a-time offload, not fan-out.* "Self-contained" means the task carries no inherited history — not that it is independent of the *other* tasks. When several tasks are independent *of each other* and could run at once, fan them out with `dispatching-parallel-agents` instead — it owns the independence check and the combined verification.

## The dispatch packet

Build it from `dispatching-parallel-agents`' dispatch packet — scope, explicit capability tier, isolation, and the exact report shape — that skill owns the contract for handing work to a cold agent. A plan task pastes four more things in, because a subagent inherits none of your context:

- **Task contract** — paste the full task text. It is the small, authoritative thing the agent starts from, so per that packet's paste-vs-path rule you paste it rather than point at the task file.
- **Accumulated discoveries** — paste the current `## Learnings` from the index (or "none yet"). This is what stops a later task re-debugging what an earlier one already solved.
- **Quality rules** — paste verbatim: *escalate rather than guess; bad work is worse than no work; write the test unless the contract says otherwise; honor the tier.* Behavioral rules don't reach a subagent unless you send them.
- **Expected outcome** — one of the four execution states (done / done-with-concerns / blocked / needs-context — see `SKILL.md`), with file and line references for anything flagged.

## Git safety (silent-data-loss guards)

- **Write with an absolute worktree path** — every commit-ish command uses `git -C <absolute-path-to-worktree>`. A gitignored worktree makes a bare `git status` look empty, and the subagent silently falls back to **main**.
- **Inspect read-only** — use `git show <ref>` or `git diff <a>..<b>`. Never bare `git checkout` / `switch` / `reset` in a subagent; they detach HEAD and orphan commits with no error.

## Reviewing a dispatched task (only when it earns it)

For a large or risky task, review the diff — and *constrain* the reviewer: give it the commit range, tell it to read only files in `git diff --name-only <a>..<b>`, and to report "out of scope" rather than read anything outside that set. Unbounded reviewers crawl the whole repo and cost more than the task did. Skip review entirely for small tasks; the Evaluator is the gate there.
