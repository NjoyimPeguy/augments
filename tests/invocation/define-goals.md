# Invocation test: define-goals

*Invocation, not triggering — see `README.md`. Triggering asks "given that you
route, do you route right?"; this asks "do you reach for a skill at all, on a
terse opening, with proceed offered as a co-equal outcome?"*

**Method.** Fresh subagents (no shared context) each get the shipped nudge
(`--nudge on`) or not (`--nudge off`), the skill catalogue framed as available
tools, one realistic terse opening, and the `FIRST: invoke | proceed` label
format (`tests/invocation-harness.sh prompt`). Model-judged proxy, not a gate.

## Scenario

> "Fresh repo, nothing in it yet. Let's build a customer-feedback portal."

This is the **realistic terse** form of the kickoff opening — a bare build verb,
no "kick this initiative off with me" framing. The triggering record uses the
richly-framed version; the question here is whether the un-framed build request
still pulls a pause-and-define-goals first move, or dives into scaffolding.

## What a useful result shows

The gap between arms (nudge's lift) and the gap to a real un-scaffolded session
(this proxy over-measures — see `README.md`).

## Last result (2026-06-21 · Claude Code · large-tier judge)

- **nudge ON — 3/3 invoked, 0 proceeded:** 2 `define-goals`, 1 `interview-me`.
- **nudge OFF — 3/3 invoked, 0 proceeded:** 3 `define-goals`.
- **No agent proceeded into scaffolding.** Every reply paused on the open goal,
  reasoning from the *description* ("start of a brand-new initiative with no
  defined objective"), not from the nudge prose — the off-arm WHYs cite skill
  language, showing no nudge leak.

**Finding (against the starting hypothesis that planning skills don't fire).**
With the catalogue in front of the model, `define-goals` fires reliably *whether
or not the nudge is present* — the nudge prose did not change whether a skill
fired. The load-bearing ingredient is the catalogue being visible plus a good
description; the nudge's real job (inducing the *pause* in an un-scaffolded
session) is the one thing this harness cannot measure, because the `FIRST:`
label bakes the pause in. So read 3/3 as a ceiling: it shows the description is
strong enough to route once a pause exists, not that the agent pauses on its
own. The one `interview-me` is a reasonable neighbour (grill the unknowns
first), not a misfire.

**Owed next:** a no-catalogue arm (bare request, augments not surfaced) to model
the "other projects, nothing fired" condition — expected to proceed, isolating
catalogue-presence as the necessary condition.
