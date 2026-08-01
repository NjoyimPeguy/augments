---
name: system-architecture
description: Use when approved requirements need a non-trivial target system design before planning or implementation. Owns components, boundaries, data flow, failure/recovery, and justified seams—not the transition from an existing system. Skip a small feature whose structure fits in its bounded task or plan.
---

# System Architecture

Design the shape of the solution before anyone builds it: what the pieces are, how they fit, and where the seams go. Aim for **deep modules**, not a sprawl of shallow ones.

## When to use

- You have approved requirements and the work is non-trivial — a new subsystem, several components, real integration.
- **Skip** for a small feature; keep its structure in the bounded task or plan
  rather than creating a separate architecture artifact.
- This skill owns the target system's structure. `migration-strategy` owns how an
  existing system reaches that target; `verification-strategy` owns the
  initiative-wide proof battery.

## Procedure

1. **Trace the contract.** Map every requirement, preserved obligation, and
   material risk to the component, interface, and owning evaluator reference
   that covers it. Do not redefine assurance gates here. Unmapped rows block
   approval.
2. **Components and boundaries.** Name each module by what it *does* and
   deliberately *doesn't*. A module earns its place if removing it would spread
   its complexity across callers; if complexity merely relocates, merge it.
3. **Trace data and trust.** Follow request, response, event, and sensitive-data
   paths from entry to effect. Mark ownership, authorization boundaries, and
   source-of-truth transitions.
4. **Design failure and recovery.** For each dependency and asynchronous path,
   state timeouts, retry and idempotency behavior, degraded operation, recovery,
   and how each path is exercised.
5. **Select operational views by risk.** Cover deployment and runtime topology,
   scale and resource budgets, observability, and target capabilities that make
   rollout and compatibility possible where they affect correctness. The
   migration contract owns the transition procedure. Record each omitted view
   with skip ID, rationale/evidence, owner, expiry/revisit, compensating
   evaluator, and approval rather than skipping by ritual.
6. **Place justified seams.** Repeated behavior with a stable owner and measured
   change friction may justify substitution. One real volatile or external boundary
   can also justify a seam when it
   contains measured impedance, failure policy, or test isolation. Hypothetical
   future variation cannot; implementation count alone neither requires nor
   forbids a seam.
7. **Record load-bearing decisions.** Route hard-to-reverse choices through
   `architecture-decisions`; unresolved material choices route through
   `interview-me`. Name everything in the domain's language.
8. **Write an immutable proposed architecture section**, preserving approved
   sections, in
   `.augments/designs/{{YYYY-MM-DD}}-{{topic}}.md` (or the user-set location).
   Record normative identity, predecessor, external decision-ledger location,
   stable IDs for components/interfaces/flows/risks/evaluators, and one
   accountable decision owner or required approvers, conflict resolver, and
   decision rule.
   For a high-risk design, the independent review in
   `references/design-review.md` is mandatory and blocking.
9. **Obtain the exact decision on the reviewed version.** Record lifecycle
   externally; only approved hands off. Praise, silence, or prior-version
   approval does not authorize planning. Once identity is issued, never mutate
   it: every normative change creates a successor with per-ID
   `added / changed / removed / preserved` delta; removal needs owning approval.
   An approved successor records the downstream artifact inventory bound to its
   predecessor, invalidates stale bindings externally, and blocks use until
   owners revalidate or reconcile.

## Common mistakes

- Shallow modules — an interface as wide as the implementation behind it.
- Untested external-service paths — "it'll work in prod" is not a design.
- Components with no trace back to a requirement, or requirements with no
  component and evaluator.
- A happy-path diagram with no trust, recovery, runtime, or rollout view despite
  risks on those surfaces.
- Designing for hypothetical futures with no measured boundary pressure.
- Generic vocabulary that hides the domain.

For a high-risk design, use `references/design-review.md` before anyone plans
against it.
