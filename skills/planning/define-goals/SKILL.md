---
name: define-goals
description: "Use at the start of a new project or initiative, before scoping or building, to pin down what it is for: the objective, the stakeholders, how success is measured, and the guardrails. Fires on we want to build X with no stated objective, even if nobody says goals. A vague or missing objective is the reason to use this, not a reason to go elsewhere first. Skip a single feature, and skip while a named decision or approval reply is still pending."
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
6. **Write the proposed `## Goals` section** into
   `.sdlc-skills/briefs/{{YYYY-MM-DD}}-{{topic}}.md` (another path only if the user
   set one). Open `assets/goals-section.md` and fill it — it carries every field
   the section owes, including its normative identity and where the decision
   ledger lives. Preserve the other approved sections, and treat the section as
   immutable once its identity is issued.
7. **Present the goal set for decision.** State the brief path, objective,
   baseline-to-target measure and horizon, and guardrails. Ask one conversational
   question with four accepted answers: approve the goals, request changes,
   reject the objective, or cancel. Recommend the answer best supported by the
   open assumptions, with one sentence of reasoning, then stop.

   Nothing hands off until one of the four arrives; praise, constraints,
   silence, and a partial reply leave it pending. Record the outcome externally
   and never mutate the normative section to mirror lifecycle. Once identity is
   issued, never mutate it: a normative change creates a replacement that
   reopens the required owners, and an approved successor invalidates stale
   downstream bindings until each owner revalidates or reconciles them.

After approval, route from the actual next uncertainty: use `feasibility-check`
only if viability is unresolved; use `scope-it` when the boundary is next.

## Common mistakes

- Listing features as goals — features are *how*; goals are *what changes*.
- Unmeasurable goals ("make it great") — if you can't check it later, it isn't a success criterion.
- A target with no baseline, source, horizon, owner, or guardrail —
  measurable-looking is not measurable.
- Jumping to scope before the goal is agreed.
