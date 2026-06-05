---
name: system-architecture
description: Use after the requirements are set, when a non-trivial system needs designing before it's built — components, boundaries, data flow, and the seams that keep it testable. Produces the architecture section of the design document. Skip for a small feature; its structure lives in the plan.
---

# System Architecture

Design the shape of the solution before anyone builds it: what the pieces are, how they fit, and where the seams go. Aim for **deep modules** — a lot of behaviour behind a small interface — not a sprawl of shallow ones.

## When to use

- You have approved requirements and the work is non-trivial — a new subsystem, several components, real integration.
- **Skip** for a small feature; its structure lives in `writing-plans`' interface map, not a separate design.

## Procedure

1. **Components and boundaries.** Name each module by what it *does* and what it deliberately *doesn't*. A module earns its place if removing it would spread its complexity across the callers; if complexity merely relocates, it's shallow — merge it.
2. **Data flow.** Trace the request/response and event paths end to end. Each should be followable from entry to effect.
3. **External services.** Map every third party (payments, mail, realtime, storage). For each, state the testability strategy: how you trace the data path through it, and how you behave — and test — when it's unavailable.
4. **Seams.** Put boundaries where you'd swap an implementation, and inject across them. Don't add a port for a *hypothetical* seam — two real adapters justify one; one doesn't.
5. **Decide the load-bearing choices deliberately.** For each significant, hard-to-reverse structural decision, weigh the options on four axes — what it assumes, where it breaks down, what would rule it out, what evidence supports it — and record the result as an ADR (`architecture-decisions`).
6. **Name things in the domain's language**, not generic "service / manager / handler". The vocabulary is itself a design decision.
7. **Write the architecture section** of the design document — the project's designs location, default `.augments/designs/{{YYYY-MM-DD}}-{{topic}}.md`.

## Common mistakes

- Shallow modules — an interface as wide as the implementation behind it.
- Untested external-service paths — "it'll work in prod" is not a design.
- Designing for hypothetical futures (a port with one adapter, "for extensibility").
- Generic vocabulary that hides the domain.

For a high-stakes design, once the document is compiled, dispatch `design-review.md` — a fresh subagent that checks the whole design before anyone builds against it.
