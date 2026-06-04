# Executing Plans — Optional Subagent Dispatch

Dispatching a task to a subagent gives it a fresh context window — useful for a **large-tier, independent task in a long run**, when the coordinator's own context is filling up. It is optional: small and medium tasks are usually faster inline. Don't dispatch a fully-specified mechanical task, and don't force a review pass on one.

## The dispatch packet

Build the prompt from these fields — don't make the subagent hunt for any of them:

- **Task contract** — paste the full task text. Never tell it to "go read the task file"; give it the text, so it starts from a known snapshot with no inherited history.
- **Capability tier** — state it explicitly (small / medium / large) and tell the subagent to run at that tier, not reach above it. A tier left implicit defaults to the expensive parent model.
- **Accumulated discoveries** — paste the current `## Learnings` from the index (or "none yet"). This is what stops a later task re-debugging what an earlier one already solved.
- **Quality rules** — paste verbatim: *escalate rather than guess; bad work is worse than no work; write the test unless the contract says otherwise; honor the tier.* Behavioral rules don't reach a subagent unless you send them.
- **Expected outcome** — ask for one of: done / done-with-concerns / blocked / needs-context, with file and line references for anything flagged.

## Git safety (silent-data-loss guards)

- **Write with an absolute worktree path** — every commit-ish command uses `git -C <absolute-path-to-worktree>`. A gitignored worktree makes a bare `git status` look empty, and the subagent silently falls back to **main**.
- **Inspect read-only** — use `git show <ref>` or `git diff <a>..<b>`. Never bare `git checkout` / `switch` / `reset` in a subagent; they detach HEAD and orphan commits with no error.

## Reviewing a dispatched task (only when it earns it)

For a large or risky task, review the diff — and *constrain* the reviewer: give it the commit range, tell it to read only files in `git diff --name-only <a>..<b>`, and to report "out of scope" rather than read anything outside that set. Unbounded reviewers crawl the whole repo and cost more than the task did. Skip review entirely for small tasks; the Evaluator is the gate there.
