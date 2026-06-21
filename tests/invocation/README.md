# tests/invocation/ — the invocation proxy

A third model-judged record, beside `triggering/` and `behavioral/`. It exists
because the triggering harness answers a narrower question than its name
suggests, and the gap between the two is exactly where "none of the skills
fired" lives.

## What triggering measures, and what it skips

`triggering-harness.sh` hands a subagent the catalogue and *commands*: "pick the
SINGLE skill whose trigger best fits the user's FIRST action." That is a forced
**classification** — it presumes the agent has already decided to reach for a
skill, and measures only whether it discriminates correctly between them. It is
a good test of *description collisions* (do two skills fight over one opening?).

It cannot see the step that actually fails in the field: the decision to reach
for a skill **at all**. In a real session no one asks "which skill matches?" The
user says "build me X", and the path of least resistance is to start building.
A skill whose triggering record is a clean 3/3 can still never fire, because the
agent never reaches the routing step the record assumed.

## What invocation measures

`invocation-harness.sh` puts a fresh subagent in a real opening instead of a
classification task:

- the **shipped** nudge, read live from the adapter (`--nudge on`), or absent
  (`--nudge off`) — the two arms isolate the nudge's lift, the RED baseline the
  triggering records note they lack;
- the skills framed as tools that are **available**, not a menu to pick from;
- a **realistic, terse** opening (the kind that actually fails — "build me X",
  not a richly-framed "kick off this new initiative with me");
- "proceed without a skill" offered as a **co-equal** outcome.

It then observes the agent's first move and tallies invoked-vs-proceeded.

## Honest limits (read before trusting a number)

This is a proxy, not a gate — same portability reason as triggering
(`../README.md`, `../../docs/augments/philosophy.md`): a deterministic "did it
fire" test would have to drive one specific harness. More specific to *this*
proxy, two effects push the measured firing rate **above** a real session's, so
read a high number as a ceiling, not a field rate:

1. **Catalogue-presence.** Both arms lay the full catalogue in front of the
   agent. A real session under context pressure may not have it salient.
2. **Deliberation-scaffold.** Asking the agent to emit `FIRST: invoke | proceed`
   *creates* a pause to consider invoking — the very pause the nudge exists to
   induce. The harness cannot bake in that pause and also measure whether it
   happens on its own. So a high firing rate here chiefly shows the
   *descriptions* are good enough to route once a pause exists; it does **not**
   show the agent will pause unprompted.

The useful signal is therefore less the absolute rate than (a) the **gap**
between the two arms, and (b) the **gap** between this controlled rate and what
the same opening does in a real, un-scaffolded session. When the controlled rate
is high but the field experience is "nothing fired," the failure is upstream of
routing — availability (was the catalogue even loaded?) or the missing pause —
not a weak description.

## Files

- `invocation-harness.sh` (in `tests/`) — mechanical half: emit prompt, tally.
- `invocation/<skill>.md` — dated reading, naming the harness and model tier
  that judged it, same as the other records. Selective, not owed by every skill:
  most worth measuring for skills whose absence leaves no failing artifact
  (the planning wing), where the nudge is the only thing that makes them fire.
