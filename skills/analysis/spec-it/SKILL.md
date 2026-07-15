---
name: spec-it
description: Use when you have a goal or feature and need detailed requirements before design — what it must do, how each is verified, and the assumptions and risks. Captures the WHAT, not the HOW; grill unknowns with interview-me first.
---

# Spec It

Turn an intent into a requirements spec (SRS): gather and analyze what the software must do, how each requirement is verified, and the assumptions, dependencies, and risks involved. Requirements are the *what* — keep the *how* (architecture, schemas, code) for design.

## When to use

- You have a goal, brief, or feature request and need its detailed requirements before designing or building.
- **Skip** for a trivial change whose single requirement is obvious — just state it and go.
- If the intent itself is unclear, grill it first with `interview-me`; this skill assumes you roughly know what you want.

## Procedure

1. **Gather the inputs.** Pull the goal or brief (from planning), read the relevant existing code to see what's already there, and grill any genuine gap with `interview-me`. Don't invent what you could have found.
2. **State the problem** in a line or two, and link the goal it serves.
3. **Write functional requirements as testable behaviours.** Each is something a user or caller can observe — "rejects an expired token with a 401", not "good auth". If you can't phrase it as checkable, it's a wish, not a requirement.
4. **Add only the non-functional requirements that matter** — performance, security, accessibility, compatibility. An unbounded NFR list is noise.
5. **Give each requirement an acceptance criterion** — the concrete check that proves it. These become the plan's **Evaluator** and **Acceptance**, so make them runnable where you can.
6. **List the edge cases and scenarios** that break a naive build — empty input, concurrency, the unhappy paths.
7. **Record the assumptions and dependencies** — what you're taking as true, and what external systems, data, or people this relies on. An unstated assumption is a hidden risk.
8. **Surface the open questions and risks** — the unresolved ambiguities and requirement-level challenges that could derail the build. Naming them now is the cheapest they'll ever be.
9. **State what is out of scope** — the requirements you are deliberately *not* covering this round.
10. **Write the spec** to `.augments/specs/{{YYYY-MM-DD}}-{{topic}}.md` (the standard specs location; another path only if the user has set one).

## Common mistakes

- Requirements with no criterion — "fast", "secure", "intuitive" prove nothing.
- Smuggling design in — file names, schemas, and code belong in the plan, not the spec.
- A thin happy-path spec with no edge cases, assumptions, or risks — that's exactly where builds break.

For a high-stakes spec, optionally dispatch `spec-review.md` (a fresh subagent that checks the requirements before anything is built against them).

Next: for a non-trivial system the requirements flow into design (`system-architecture`, `data-model`, `ui-ux-design`); otherwise straight to `writing-plans`.
