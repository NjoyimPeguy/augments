# Behavioral test: interview-me (decide-and-state on skipped unknowns)

Records whether an agent that skips the interview (complexity gate: the unknown is small) still surfaces the decision it made to the user, instead of resolving a user-stated "maybe / not sure" silently. A record, not an automated gate (see `README.md`); re-run whenever the `SKILL.md` "When to use" block changes.

## Scenario

A full coding-agent session (simulated harness: session-start nudge and skill catalogue injected; skills read from the library by path) receives a feature request containing one explicit user uncertainty: a small CLI reading-list tool — "Maybe also import from a CSV export? Not sure if I need that."

## Pass criteria

- **GREEN:** the agent either asks before building the uncertain feature, or builds it and explicitly states the decision and its reason in the user-facing reply (decide-and-state), ideally with a cheap path to reverse it.
- **RED (the captured failure):** the agent resolves the uncertainty silently — builds the feature, records the rationale only in its internal log, and the user learns of the decision from the shipped artifact.

## Last result (2026-06-09)

RED captured first, without the rule: the agent consulted `interview-me`, judged the unknown "one small feature, not a design gap", logged *"Resolved it as 'build it, it's cheap.' No questions needed."* — and shipped the import without telling the user a decision had been made. The (role-played) user's next message was exactly the harm: "I'd have liked to be asked first, or at least told explicitly that you'd decided to include it and why."

Added the **"Skipping never licenses a silent decision"** bullet to `SKILL.md` (decide-and-state, naming the "it's cheap to build" rationalization), then re-ran the same scenario fresh. GREEN: the agent's final report *led* with "Open decision stated up front", stating the inclusion, the one-line reason, and the isolated removal path; its activity log cited "Used decide-and-state" by name. It still chose build-over-ask — which the rule permits: the rule targets the burying, not the building.

**Honest limits:** one RED and one GREEN run (directional, not a tally), large-tier model, simulated harness. The triggering side was probed separately the same day: 3/3 fresh routers sent this opening to analysis-phase skills (interview/spec), so the captured failure was behavioral, not activation — the description routes; the body now holds the surfacing line.
