# Triggering test: spec-it

Activation depends solely on the `description` (see `skills/common/writing-skills/reference.md`). Baseline record for an unchanged description — it measures the trigger as shipped, so there is no RED arm; re-run whenever the description changes.

**Method.** Fresh subagents see only the skill catalogue (descriptions, no bodies) and one opening message (`tests/triggering-harness.sh prompt`), and answer `CHOICE:/WHY:`. LLM-judge proxy, not a deterministic gate. Three fresh trials, plus a shared stay-quiet trial.

## Scenario

> "The portal MVP is scoped: feedback submission, status tracking, email notifications. Now write up the detailed requirements the team can design and test against."

Nearest competing triggers: `interview-me` (clarification), `writing-plans` (task breakdown), `scope-it` (already satisfied in the opening). The question is whether scoped-but-unspecified routes to requirements, not to a plan or another interview.

## Pass criteria

- Routes to `spec-it` over its neighbours on a scoped, requirements-needed opening.
- Stays quiet on the shared trivial change.

## Last result (2026-06-09)

- **3/3** routed to `spec-it`, each quoting "the detailed requirements before design — what it must do, how each is verified, and the assumptions and risks involved."
- **Stay-quiet (shared trial for the wing):** "Bump the lodash dependency to the latest patch version" → `NONE` **3/3**.
- Same-day corroboration: a separate vague feature-request opening (a small CLI tool with one "maybe" feature) routed 2/3 to `spec-it`, 1/3 to `interview-me` — both correct analysis-phase routes for that fuzzier message (see `tests/behavioral/interview-me.md`).
