---
name: dispatching-parallel-agents
description: Use when two or more work items can run concurrently with disjoint file ownership, mutable state, and outputs—such as unrelated bugs or parallel research. Skip shared generators/manifests/runtime state, dependent outputs, and work quicker to do inline.
---

# Dispatching Parallel Agents

Run independent work concurrently instead of in series. The win is wall-clock; the risk is collision — so this applies only when the pieces genuinely don't touch each other.

## When to use

- Two or more pieces of work that are **provably independent**: disjoint files, disjoint state, and no "B needs A's result."
- **Skip** shared files/dependencies, output ordering, or quick inline work.
  Sequence in the current task/plan; use `executing-plans` only for an approved plan.

## The independence test — confirm before fanning out

Check every pair; if any fails, group them into one agent or sequence them instead:

- **Base** — every writer starts from the same immutable revision, or an
  explicitly ordered dependency revision.
- **Files** — they own exclusive paths, including generated outputs, manifests,
  lockfiles, shared fixtures, and tests. Name one later integration owner for a
  truly shared file; nobody else edits it concurrently.
- **State** — disjoint ports, databases, fixtures. If they run a server or migrations, isolate each (`using-task-branches`).
- **Order** — none consumes another's output. A dependency is a sequence, not a fan-out.

## The dispatch packet (per agent)

Each agent starts cold — hand it everything, never your session history:

- **Scope** — the exact problem and files this agent owns, and what it must NOT touch.
- **Objective + deliverable** — what "done" means, and the precise shape to report back, so results reconcile.
- **Constraints** — name the tier (omission inherits the costliest), invoke
  `using-sdlc-skills` once, follow disciplines/scope, and do not subdispatch unless
  the packet allocates sub-scope/capacity/data/reconciliation; otherwise report.
- **Isolation, identity, and data boundary** — immutable base, owned workspace,
  exclusive paths and runtime; classify reachable material, allowed worker/
  provider/storage/access, prohibited secrets/data/effects/egress, and evidence
  retention plus exact authority-bound cleanup/disposition; configuration is not
  disclosure authority—new recipients or egress need a direct scoped decision.
- **Evidence** — required diff range, evaluator command/output, resulting
  revision, and out-of-scope discoveries.

Two ways to hand over context, and the choice matters: **paste** the small, authoritative thing the agent must start from verbatim — its task contract, the exact spec — so it works from a known snapshot; pass **bulky reference** — a diff, a log, a large file — as a **path the agent reads**, since a paste sits in the most expensive context for the whole run while a path costs nothing until opened. Paste what *defines* the task; point at what merely *informs* it.

## The dispatch-receipt gate

Freeze the exact expected packet IDs/count, terminal deadline, and timeout/
cancel action and owner before fan-out. Invoke the real callable action and join
each returned nonempty agent/job ID as an attempt identity under one packet.
Names or “running” prose are not receipts. Unavailable/refused/empty means **not
dispatched**: retain the packet pending and stop. At failure/deadline, record
`cancellation requested` until worker, descendants, and effects are confirmed
quiescent; quarantine partial outputs. Only then record failed/timed out/
cancelled. Reassignment creates a linked successor attempt; reject every late
result or mutation from its predecessor. Non-success never disappears.

If any writer discovers a shared generator, file, state, dependency, or required
scope outside its packet, pause affected work. Preserve the diffs, reclassify the
dependency, assign one owner or sequence it, and issue revised packets. “Small
overlap” is still overlap.

## Reconcile (the coordinator's job, not the agents')

Reconcile the frozen packet set and every terminal outcome. Inspect each returned
diff against its declared base and ownership set, authorized checkpoints (or
none), and raw evaluator evidence. Reject scope leaks, mixed changes, or missing
evidence even if a suite is green. Required scope advances only when every packet
has an accepted success report or a directly approved scope change/reassignment;
then integrate through the named owner and run combined checks on the exact result.

## Common mistakes

- Shared file/order/runtime ownership — one writer or sequence, never “coordinate.”
- Session-history briefs or undeclared data/egress — neither is bounded context.
- No combined exact-result check, or accepting late/quarantined output.
- Treating combined green as permission to ignore scope leaks or mixed commits.

When writing the actual briefs, `references/brief-examples.md` has a fill-in template and weak-vs-strong pairs for the three typical cases (failing tests, unrelated bugs, parallel research).
