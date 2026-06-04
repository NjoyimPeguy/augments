---
name: spec-it
description: Use when you have a goal or feature and need the detailed requirements before design — what it must do and how each one is verified. Produces a requirements spec under docs/augments/specs/. Grill unknowns with interview-me first; this captures the WHAT, never the HOW.
---

# Spec It

Turn an intent into a requirements spec: the testable statements of what the software must do, and how each is verified. Requirements are the *what* — keep the *how* (architecture, schemas, code) for design.

## When to use

- You have a goal, brief, or feature request and need its detailed requirements before designing or building.
- **Skip** for a trivial change whose single requirement is obvious — just state it and go.
- If the intent itself is unclear, grill it first with `interview-me`; this skill assumes you roughly know what you want.

## Procedure

1. **State the problem** in a line or two, and link the goal it serves (a planning brief, or the request).
2. **Write functional requirements as testable behaviors.** Each is something a user or caller can observe — "rejects an expired token with a 401", not "good auth". If you can't phrase it as checkable, it's a wish, not a requirement.
3. **Add only the non-functional requirements that actually matter** — performance, security, accessibility, compatibility. An unbounded NFR list is noise.
4. **Give each requirement an acceptance criterion** — the concrete check that proves it. These become the plan's **Evaluator** and **Acceptance**, so make them runnable where you can.
5. **List the edge cases and scenarios** that break a naive build — empty input, concurrency, the unhappy paths.
6. **State what is out of scope** — the requirements you are deliberately *not* covering this round.
7. **Write the spec** to `docs/augments/specs/{{YYYY-MM-DD}}-{{topic}}.md`.

## Common mistakes

- Requirements with no criterion — "fast", "secure", "intuitive" prove nothing.
- Smuggling design in — file names, schemas, and code belong in the plan, not the spec.
- A thin happy-path spec with no edge cases — that's exactly where builds break.
