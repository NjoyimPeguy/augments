---
name: ui-ux
description: Use when designing a user-facing interface — the flows, layout, and experience — before building it. Produces the UI/UX section of the design document as concrete user flows with acceptance criteria. Skip for backend-only or non-interactive work.
---

# UI/UX

Design the experience before the components. A UI is the set of flows a user moves through — design those, and the layout and acceptance criteria fall out. Validate uncertain look-and-feel with a throwaway `prototyping` spike, not in the spec.

## When to use

- The work has a user-facing interface and the flows or layout aren't obvious.
- **Skip** for backend-only, library, or non-interactive work.

## Procedure

1. **List the key user flows** — the path a user takes to accomplish each goal. Write each as a scenario: *given* a state, *when* the user acts, *then* what they see.
2. **Decide the layout and information hierarchy** per screen — what's primary, what's secondary, what's one tap away. Name the primary affordance.
3. **Cover the unhappy states** — empty, loading, error, no-permission, offline. These are most of the real experience and where designs fail.
4. **Write the human acceptance criteria** — the things automated tests can't judge (does it feel responsive, is the journey clear), each linked to a manual check.
5. **For genuinely uncertain look-and-feel, run a `prototyping` spike** — structurally different variants (layout, hierarchy, affordance), not colour tweaks — and record which won and why.
6. **Write the UI/UX section** of the shared design document `.augments/designs/{{YYYY-MM-DD}}-{{topic}}.md` (the standard designs location; another path only if the user has set one).

## Common mistakes

- Designing only the happy path — empty/error/loading states are the real work.
- Variants that differ only in colour — that's a tweak, not a design choice.
- Acceptance criteria a test can't check, with no manual step assigned.
