---
name: define-goals
description: Use at the start of a new project or initiative—before scoping or building—to elicit and pin down its objective, stakeholders, success measures, and guardrails. Those missing goal inputs are this skill's work, not a reason to interview first. Skip a single feature and a still-pending named decision or approval reply.
---

# Define Goals

A project without a clear goal ships features no one needed. Before scope or design, name the outcome — and how you'll know you hit it.

## When to use

- Starting a new project, product, or substantial initiative with a fuzzy "why";
  this procedure elicits the objective, stakeholders, and measures.
- **Skip** for a single feature or task. Use `interview-me` only for genuine
  ambiguity about which initiative or procedure is intended; `spec-it` owns
  settled detailed feature requirements.
- **Skip** when a drafted goal or brief is awaiting a direct answer; an
  informative non-answer routes to `interview-me`, not a new goal pass.

## Procedure

1. **Find the real objective.** Ask "why this, why now?" until you reach an outcome, not a feature. A goal is something the world does differently afterward, not code that exists.
2. **Name stakeholders and conflicts.** Who benefits, who operates or bears risk,
   what changes for each, and who owns the outcome? Do not hide competing goals
   in one average metric. Record either one accountable decision owner or the
   required approvers, conflict resolver, and decision rule.
3. **Make success measurable.** For each outcome record the current baseline,
   target, time horizon, measurement source, and accountable owner. A number with
   no source or date cannot be checked later.
4. **Add guardrails and failure criteria.** Name what must not degrade—reliability,
   safety, accessibility, cost, trust—and the observation that would mean the
   initiative failed even if its primary metric rose.
5. **State the value in one sentence** — the elevator version.
6. **Write an immutable proposed `## Goals` section**, preserving other approved
   sections, at
   `.sdlc-skills/briefs/{{YYYY-MM-DD}}-{{topic}}.md` (another path only if the user
   set one): objective, stakeholders, outcomes, baselines/targets/horizons,
   sources/owners, guardrails, failure criteria, value, normative identity,
   predecessor, and external decision-ledger location.
7. **Present the complete goal set for direct decision.** Record the exact
   pending/changes-requested/approved/rejected/cancelled/superseded-by-approved
   state externally; only approved hands off. Never mutate the normative section
   to mirror lifecycle. Once identity is issued, never mutate it: every normative
   change creates a replacement and reopens the required owners. An approved
   successor records the downstream artifact inventory bound to its predecessor,
   invalidates stale bindings externally, and blocks their use until each owner
   revalidates or reconciles it to the new identity.

After approval, route from the actual next uncertainty: use `feasibility-check`
only if viability is unresolved; use `scope-it` when the boundary is next.

## Common mistakes

- Listing features as goals — features are *how*; goals are *what changes*.
- Unmeasurable goals ("make it great") — if you can't check it later, it isn't a success criterion.
- A target with no baseline, source, horizon, owner, or guardrail —
  measurable-looking is not measurable.
- Jumping to scope before the goal is agreed.
