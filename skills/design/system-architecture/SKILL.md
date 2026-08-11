---
name: system-architecture
description: "Use when approved requirements need a target system design before planning or implementation: how it splits into components, where the boundaries fall, how data moves through it, how it fails and recovers, and which seams are worth their cost. Fires on how should we structure this and what are the moving pieces, even if nobody says architecture. Covers the target design of a system, not the transition from an existing one. Skip a small feature whose structure fits inside its own task or plan."
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

Each step fills the matching section of `assets/architecture-section.md`. Open it
now and work in it; the steps below are the judgements the template cannot make
for you.

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
5. **Select operational views by risk.** Cover a view — deployment and runtime
   topology, scale and resource budgets, observability, the target capabilities
   that make rollout and compatibility possible — wherever it affects
   correctness. The migration contract owns the transition procedure; do not
   restate it here.

   A view you omit gets a real skip record, with the fields the template's
   operational-views table lists. Dropping a view because it felt inapplicable is
   skipping by ritual, and it is how a rollout surface reaches production
   undesigned.
6. **Place justified seams.** Repeated behavior with a stable owner and measured
   change friction may justify substitution. One real volatile or external boundary
   can also justify a seam when it
   contains measured impedance, failure policy, or test isolation. Hypothetical
   future variation cannot; implementation count alone neither requires nor
   forbids a seam.
7. **Record load-bearing decisions.** Route hard-to-reverse choices through
   `architecture-decisions`; unresolved material choices route through
   `interview-me`. Name everything in the domain's language.
8. **Write the immutable proposed architecture section** into
   `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}.md`, or the location the user
   set, preserving the sections already approved around it. The template's header
   carries the identity, predecessor, approval rule, ledger location, and stable
   ID delta this section owes.

   For a high-risk design, the independent review in `references/design-review.md`
   is mandatory and blocking — run it before you present anything.
9. **Present the reviewed version for decision.** Print exactly this, then stop:

   ```text
   Architecture ready for your decision — {{design-path}}

   Components:    {{components}}
   Trust bounds:  {{boundaries}}
   Hard to undo:  {{load-bearing-decisions}}
   Open risks:    {{risks}}

   1. Approve — hand off to planning
   2. Request changes — tell me what to revise
   3. Reject — wrong design
   4. Cancel — stop this work

   Which?
   ```

   Only one of the four authorizes planning; praise, silence, and prior-version
   approval do not. Record lifecycle externally. An issued identity never
   mutates: a normative change creates a successor with a per-ID
   `added / changed / removed / preserved` delta (removal needs owning approval)
   that invalidates stale downstream bindings until owners revalidate.

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
