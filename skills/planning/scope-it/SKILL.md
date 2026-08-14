---
name: scope-it
description: "Use after the goals are set and before design, to draw a project's boundary: what is in, what is explicitly out, and the smallest cut that still meets the goal. Fires on what goes in v1, what should we cut, and this is getting too big, even if nobody says scope. Skip a single feature, unresolved ambiguity about intent, and detailed feature requirements."
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
7. **Write the proposed `## Scope` section** into
   `.sdlc-skills/briefs/{{YYYY-MM-DD}}-{{topic}}.md` (or the user-set path). Open
   `assets/scope-section.md` and fill it — it carries the constraint, exclusion,
   assumption, and change-rule tables along with the identity fields. Do not
   replace the other approved sections; the section is immutable once its
   identity is issued.
8. **Present the cut for decision.** State the brief path, in-scope and excluded
   work, thinnest version, and owned assumptions. Ask one conversational
   question with four accepted answers: approve this boundary, request a scope
   change, reject the cut, or cancel. Recommend the thinnest answer that still
   reaches the approved goal, with one sentence of reasoning, then stop.

   Only one of the four hands off; praise, constraints, silence, and a partial
   reply leave it pending. Record every lifecycle outcome externally. Once
   identity is issued, never mutate it: a normative change creates a replacement,
   contradiction reopens owners, and an approved successor invalidates stale
   downstream bindings until owners revalidate or reconcile them.

After approval, route to `spec-it` only when detailed requirements are the next
missing input; do not impose a phase that is already complete.

## Common mistakes

- No explicit out-of-scope list — then everything is in scope, and nothing ships.
- Scoping to what's interesting to build rather than what the goal needs.
- Hiding a large dependency as a one-word "assumption".
- Calling compatibility, rollback, accessibility, security, or data preservation
  “out of scope” to make the cut look smaller.
