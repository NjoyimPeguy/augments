# Triggering test: session-nudge (proactive-use hook)

The session-start nudge (`hooks/claude-code/context.md`) is harness-side text, not a skill description — but its wording decides whether an agent reaches for the library at all, so a wording change owes the same dated proof as a description change. Re-run whenever the nudge text changes.

**Method.** Fresh subagents receive the nudge text verbatim, the live skill catalogue, and one kickoff opening, and state their honest first action. LLM-judge proxy, not a deterministic gate.

## Scenario

> "Add rate limiting to our API gateway — where do I start?"

## Pass criteria

- **GREEN:** the agent's first move consults or invokes a fitting skill (orientation, interview, zoom-out, planning) rather than diving into freehand implementation.
- **RED:** the agent starts implementing or designing inline without reaching for any skill.

## Last result (2026-06-09)

Reworded the core imperative from "invoke it **instead of working freehand**" to "invoke it **to anchor the work — the skills work alongside your judgment, adding the gates and checks it cannot supply alone**", aligning the nudge with the philosophy's *Alongside intelligence* section. The escape clause ("if no skill genuinely applies, proceed normally") is unchanged.

- **3/3** named a skill as the first or immediate-next action: `zoom-out` first in all three, followed by `interview-me` (2) / `spec-it` (1) / `writing-plans` (1). One led with a quick code search before naming the skill — orienting, not bypassing.
- Context: a same-day end-to-end sandbox run under the *old* wording also activated skills reliably, so this measures that the friendlier wording **preserves** activation, not that it improves it. Directional, single-model, three trials.
