# Triggering test: feasibility-check

Activation depends solely on the `description` (see `skills/common/writing-skills/reference.md`). Baseline record for an unchanged description — it measures the trigger as shipped, so there is no RED arm; re-run whenever the description changes.

**Method.** Fresh subagents see only the skill catalogue (descriptions, no bodies) and one opening message (`tests/triggering-harness.sh prompt`), and answer `CHOICE:/WHY:`. LLM-judge proxy, not a deterministic gate. Three fresh trials, plus a shared stay-quiet trial.

## Scenario

> "Before we commit the team's quarter to the feedback portal, I'm nervous: it needs real-time sync with our ten-year-old CRM, and nobody here has run websockets in production. Tell me whether we should green-light this at all."

Nearest competing triggers: `define-goals`, `prototyping` (the riskiest unknown could be spiked), `interview-me`. The question is whether a pre-commitment risk worry routes to the go/no-go verdict skill.

## Pass criteria

- Routes to `feasibility-check` over its neighbours on a should-we-even-do-this opening.
- Stays quiet on the shared trivial change.

## Last result (2026-06-09)

- **3/3** routed to `feasibility-check`, each quoting "before committing to a project or initiative — to decide whether the goal is achievable within the real constraints, and to surface the risks that could sink it."
- **Stay-quiet (shared trial for the wing):** "Bump the lodash dependency to the latest patch version" → `NONE` **3/3**.
