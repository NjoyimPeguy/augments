# Triggering test: coding-standards

Activation depends solely on the `description` (see `skills/common/writing-skills/reference.md`). Baseline record for an unchanged description — it measures the trigger as shipped, so there is no RED arm; re-run whenever the description changes.

**Method.** Fresh subagents see only the skill catalogue (descriptions, no bodies) and one opening message (`tests/triggering-harness.sh prompt`), and answer `CHOICE:/WHY:`. LLM-judge proxy, not a deterministic gate. Three fresh trials, plus a shared stay-quiet trial.

## Scenario

> "Three contractors join the codebase next sprint. Write down the project's conventions — naming, structure, the domain vocabulary — so everyone writes code like one author."

Nearest competing triggers: `writing-skills` (authoring skills, not standards), `zoom-out`. The question is whether a conventions ask routes to standards, not to skill-authoring.

## Pass criteria

- Routes to `coding-standards` over its neighbours on a conventions opening.
- Stays quiet on the shared trivial change.

## Last result (2026-06-09)

- **3/3** routed to `coding-standards`, each quoting "the coding standards agents and humans follow — the domain vocabulary, the patterns to use" — and the "writes code like one author" phrasing in the opening matched the description's intent without naming it verbatim. None confused it with `writing-skills`.
- **Stay-quiet (shared trial for the wing):** "Bump the lodash dependency to the latest patch version" → `NONE` **3/3**.
