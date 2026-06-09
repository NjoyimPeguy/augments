# Triggering test: architecture-decisions

Activation depends solely on the `description` (see `skills/common/writing-skills/reference.md`). Baseline record for an unchanged description — it measures the trigger as shipped, so there is no RED arm; re-run whenever the description changes.

**Method.** Fresh subagents see only the skill catalogue (descriptions, no bodies) and one opening message (`tests/triggering-harness.sh prompt`), and answer `CHOICE:/WHY:`. LLM-judge proxy, not a deterministic gate. Three fresh trials, plus a shared stay-quiet trial.

## Scenario

> "After a week of debate we chose Postgres LISTEN/NOTIFY over a message broker for the sync queue. It will be hard to reverse later. Make sure the reasoning isn't lost."

Nearest competing triggers: `system-architecture`, `handoff` (preserving context), `post-mortem`. The question is whether a decision-made, reasoning-at-risk opening routes to the ADR skill rather than a handoff note.

## Pass criteria

- Routes to `architecture-decisions` over its neighbours on a hard-to-reverse-choice opening.
- Stays quiet on the shared trivial change.

## Last result (2026-06-09)

- **3/3** routed to `architecture-decisions`, each quoting "a significant, hard-to-reverse technical decision … record it as an ADR," two citing the options-weighed/alternatives-rejected language against the week of debate.
- **Stay-quiet (shared trial for the wing):** "Bump the lodash dependency to the latest patch version" → `NONE` **3/3**.
