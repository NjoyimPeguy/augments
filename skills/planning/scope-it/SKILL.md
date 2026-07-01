---
name: scope-it
description: Use after the goals are set and before design — to draw a project's boundary: what's in, what's explicitly out, and the smallest cut that still meets the goal. Skip for a single feature; use interview-me.
---

# Scope It

Scope is decided by what you say no to. An unbounded project never ships — name the boundary before anyone starts building.

## When to use

- After `define-goals`, before design, on a project or initiative.
- When scope is unclear or creeping mid-project.
- **Skip** for a single feature — `interview-me` handles feature-level boundaries.

## Procedure

1. **In scope:** the smallest set of capabilities that actually achieves the goal — nothing more.
2. **Explicitly out of scope:** the tempting things you are deliberately *not* doing this round. Naming non-goals is what stops scope creep later.
3. **The MVP cut:** if you had to ship in a fraction of the time, what is the thinnest version that still meets the goal? Make that the spine.
4. **Assumptions and dependencies:** what must be true or available for this scope to hold.
5. **Write the `## Scope` section** of the project brief: in, out, the MVP cut, assumptions.

With the boundary set, requirements come next (`spec-it`), then design.

## Common mistakes

- No explicit out-of-scope list — then everything is in scope, and nothing ships.
- Scoping to what's interesting to build rather than what the goal needs.
- Hiding a large dependency as a one-word "assumption".
