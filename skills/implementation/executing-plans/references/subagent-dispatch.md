# Executing Plans — Subagent Dispatch

Dispatching a task to a subagent gives it a fresh context window. Reach for it
when your context is filling or one task is large and self-contained, then
offload, gate its Evaluator, and move on sequentially. A small fully specified
task is faster inline; do not dispatch it or invent an independent task reviewer.
This never waives final done-boundary classification or shallow self-review.

*One-at-a-time offload, not fan-out.* "Self-contained" means the task carries no inherited history — not that it is independent of the *other* tasks. When several tasks are independent *of each other* and could run at once, fan them out with `dispatching-parallel-agents` instead — it owns the independence check and the combined verification.

## The dispatch packet

Build it from `dispatching-parallel-agents`' dispatch packet — scope, explicit capability tier, isolation, and the exact report shape — that skill owns the contract for handing work to a cold agent. A plan task pastes four more things in, because a subagent inherits none of your context:

- **Task contract** — paste the full task text. It is the small, authoritative thing the agent starts from, so per that packet's paste-vs-path rule you paste it rather than point at the task file.
- **Accumulated discoveries** — paste only verified identity-bound learnings from
  the external execution ledger (or “none”). Never mutate or read runtime
  learning state from the immutable plan index.
- **Quality rules** — paste verbatim: *escalate rather than guess; bad work is
  worse than no work; this packet is already routed—follow its named applicable
  disciplines, TDD entry cycle, YAGNI, tier, and owning contracts; if the packet
  is invalid, report needs-context rather than re-route or guess.* A packet
  cannot waive discipline or reopen approved scope.
- **Expected outcome** — one of the four execution states (done / done-with-concerns / blocked / needs-context — see `../SKILL.md`), with file and line references for anything flagged.
- **Authority boundary** — the worker may change only its owned task state. It
  reports raw diff, authorized checkpoint commits (or none), result revision,
  and evaluator output; subdispatch is prohibited unless the packet explicitly
  suballocates scope, capacity, data/egress, and reconciliation. The coordinator
  alone accepts the result and appends the external execution ledger/queue;
  neither party mutates the normative plan.
- **Attempt lifecycle** — bind attempt ID, terminal deadline, timeout/cancel
  owner/action, process/effect boundary, and report location. Failure/deadline
  enters cancellation-requested until worker, descendants, and effects are
  quiescent; quarantine partials. Retry links its predecessor and rejects late
  predecessor results/mutations.

## Git safety (silent-data-loss guards)

- **Write with an absolute workspace path** — every Git mutation or authorized
  checkpoint uses `git -C {{absolute-path-to-task-workspace}}`. A wrong cwd can
  make status look empty or target the wrong branch.
- **Inspect read-only** — use `git show <ref>` or `git diff <a>..<b>`. Never bare `git checkout` / `switch` / `reset` in a subagent; they detach HEAD and orphan commits with no error.

## Reviewing a dispatched task (only when it earns it)

For a large or risky task, give the reviewer the exact range, task contract, and
risk/equivalence references. Start from changed files, but permit
evidence-driven traversal to relevant callers, contracts, generated sources,
history, and tests; arbitrary whole-repository review is still out of scope.
Use `requesting-code-review` for its required topology. Skip independent review
for a trivial task checkpoint unless plan/risk requires it; the final exact
candidate still enters that skill at its done or integration boundary.
