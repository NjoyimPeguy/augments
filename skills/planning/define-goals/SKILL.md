---
name: define-goals
description: Use at the start of a new project or initiative — before scoping or building — to pin down what success means. Extracts the core objective and measurable success criteria into the project brief. Skip for a single feature; use interview-me for feature requirements.
---

# Define Goals

A project without a clear goal ships features no one needed. Before scope or design, name the outcome — and how you'll know you hit it.

## When to use

- Starting a new project, product, or substantial initiative with a fuzzy "why".
- **Skip** for a single feature or task — that's `interview-me`'s requirements job, not project goals.

## Procedure

1. **Find the real objective.** Ask "why this, why now?" until you reach an outcome, not a feature. A goal is something the world does differently afterward, not code that exists.
2. **Name the primary users or stakeholders** and what changes for them.
3. **Make success measurable.** For each goal, a criterion you could check later: a number, an observable behavior, a yes/no. "Users can X in under N seconds", not "better UX".
4. **State the value in one sentence** — the elevator version.
5. **Write the `## Goals` section** of the project brief (`docs/briefs/<name>.md`): objective, users, success criteria, one-line value.

## Common mistakes

- Listing features as goals — features are *how*; goals are *what changes*.
- Unmeasurable goals ("make it great") — if you can't check it later, it isn't a success criterion.
- Jumping to scope before the goal is agreed.
