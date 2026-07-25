---
name: spec-it
description: Use when you have a goal or feature and need detailed requirements before design — what it must do, how each is verified, and the assumptions and risks. Captures the WHAT, not the HOW; grill unknowns with interview-me first. Skip when verifiable requirements are already written down.
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
5. **Give each requirement an acceptance criterion — in the cheapest form that makes it checkable.** Prose is the fallback, not the starting point. Behaviour with observable inputs and outputs is cheapest as a *failing test* in the project's own test tree; a layout or state requirement as a *mockup page*; behaviour that already exists elsewhere as a *reference implementation* plus its deltas; a real criterion no machine can check as a *rubric* pass-list. Read [reference-forms.md](reference-forms.md) before choosing. A richer form must remove more ambiguity than it costs to build — don't mock up a requirement nobody would misread.
6. **Build what you named, and confirm it runs.** A criterion you promised and never wrote is worse than the prose it replaced: the spec reads as verified while nothing is. Each executable artifact must fail for the *right* reason — the behaviour is missing — not error because it never loaded, and not sit `skip`/`todo`/pending so the suite stays green: a criterion that cannot go red is not a criterion. **An open contract is not an exemption.** If the interface a test would assert isn't chosen yet, assert at the level the requirement actually fixes (*"two keys of one tenant hold independent budgets"* is true whatever the wire format), or write the test against the contract you assume and record that assumption beside it. "This is requirements-only" and "the design isn't settled" defer the test's *shape*, never its existence.
7. **List the edge cases and scenarios** that break a naive build — empty input, concurrency, the unhappy paths.
8. **Record the assumptions and dependencies** — what you're taking as true, and what external systems, data, or people this relies on. An unstated assumption is a hidden risk.
9. **Surface the open questions and risks** — the unresolved ambiguities and requirement-level challenges that could derail the build. Naming them now is the cheapest they'll ever be.
10. **State what is out of scope** — the requirements you are deliberately *not* covering this round.
11. **Write the spec** to `.augments/specs/{{YYYY-MM-DD}}-{{topic}}.md` (the standard specs location; another path only if the user has set one). The file is the map: every requirement names its form and the path to its artifact, so a reader gets from requirement to check in one hop. Artifacts themselves live where they are useful — tests in the test tree, not parked beside the spec.

## Common mistakes

- Requirements with no criterion — "fast", "secure", "intuitive" prove nothing.
- **Promising verification you never wrote** — "all criteria are automated tests under `test/`" above thirty requirements and zero test files. Write them, or say plainly they're deferred.
- Prose by reflex — restating a behaviour in a sentence when a failing test would have pinned it exactly.
- Smuggling design in — file names, schemas, and code belong in the plan, not the spec. A *failing test* asserting observable behaviour is a requirement; one asserting an internal call you haven't designed is not. The guard is against asserting **internals**, not against picking an observable surface — don't stretch it into "the contract is open, so no test is possible."
- A thin happy-path spec with no edge cases, assumptions, or risks — that's exactly where builds break.

For a high-stakes spec, optionally dispatch `spec-review.md` (a fresh subagent that checks the requirements before anything is built against them).

Next: for a non-trivial system the requirements flow into design (`system-architecture`, `data-model`, `ui-ux-design`); otherwise straight to `writing-plans`.
