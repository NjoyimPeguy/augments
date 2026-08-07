---
name: scope-it
description: "Use after the goals are set and before design — to draw a project's boundary: what's in, what's explicitly out, and the smallest cut that still meets the goal. Skip a single feature: interview-me resolves genuine ambiguity, while spec-it owns detailed feature requirements."
---

# Scope It

Scope is decided by what you say no to. An unbounded project never ships — name the boundary before anyone starts building.

## When to use

- After goals are approved—whether already present or produced by
  `define-goals`—and before an unresolved project boundary is consumed.
- When scope is unclear or creeping mid-project.
- **Skip** for a single feature. Use `interview-me` only when its intent or
  boundary is ambiguous; `spec-it` owns its detailed requirements and non-goals.

## Procedure

1. **Carry the non-negotiables first.** Bring forward goal guardrails, existing
   contracts, preserved behavior/data, security, accessibility, compatibility,
   operability, and recovery. These are constraints on every cut, not optional
   capabilities to move out of scope.
2. **In scope:** the smallest set of capabilities that achieves the approved
   outcome under those constraints.
3. **Explicitly out of scope:** tempting capabilities deliberately deferred.
   Give each exclusion a stable ID, rationale, goal impact, owner, and revisit
   trigger. Never put a preserved invariant or existing commitment here.
4. **The MVP cut:** the thinnest version that still meets the goal **and every
   non-negotiable**. Smaller but unsafe/incompatible is not an MVP.
5. **Assumptions and dependencies:** for each, name its validation action, owner,
   and expiry/decision point. A hidden project inside “assumes X” is scope.
6. **Set change rules:** observations that abort this cut, changes material enough
   to reopen approval, and who decides them.
7. **Write and present an immutable proposed `## Scope` section** without replacing
   other approved sections at
   `.sdlc-skills/briefs/{{YYYY-MM-DD}}-{{topic}}.md` (or the user-set path):
   constraints, preserved invariants, in/out, MVP, assumptions, dependencies,
   change rules, normative identity, predecessor, and external decision-ledger
   location. Record every lifecycle outcome externally; only approved hands off.
   Once identity is issued, never mutate it: every normative change creates a
   replacement and contradiction reopens owners. An approved successor records
   the downstream artifact inventory bound to its predecessor, invalidates stale
   bindings externally, and blocks use until owners revalidate or reconcile them.

After approval, route to `spec-it` only when detailed requirements are the next
missing input; do not impose a phase that is already complete.

## Common mistakes

- No explicit out-of-scope list — then everything is in scope, and nothing ships.
- Scoping to what's interesting to build rather than what the goal needs.
- Hiding a large dependency as a one-word "assumption".
- Calling compatibility, rollback, accessibility, security, or data preservation
  “out of scope” to make the cut look smaller.
