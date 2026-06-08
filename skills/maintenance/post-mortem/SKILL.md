---
name: post-mortem
description: Use after a failure escaped to production or was caught late — a regression, outage, data corruption, or a defect found long after it shipped — to find why the process let it through and turn that into a structural fix. Also for an end-of-cycle retrospective on work that went badly. Skip for a bug you can simply fix — that is debugging; this asks why it escaped, not what the code did wrong.
---

# Post-Mortem

`debugging` finds why the code broke. This finds why the break *escaped* — which gate should have caught it and didn't — and converts that into a change that makes the whole class impossible next time. The deliverable is not a fix; it is a stronger gate.

Be honest about what this is: a structured reasoning pass, not a deterministic gate itself. Its value lives entirely in the **gates it produces** — a test, a check, an assertion — not in the reflection. A post-mortem that ends in resolutions instead of gates changed nothing.

## When to use

- A failure reached production, or a defect surfaced far downstream of where it was introduced.
- A unit of work went badly enough to be worth learning from (a retrospective).
- **Skip** for a bug you simply reproduce and fix — that is `debugging`. This skill starts *after* the cause is known and asks why it got past everyone.

## Procedure

1. **Reconstruct the timeline from artifacts, not memory.** Walk the commits, CI runs, logs, and review history: when was the defect introduced, when did each check run, when was it noticed? Memory rewrites history into a tidy story; the artifacts don't.

2. **Find the cause of the escape, not the bug.** The code cause is `debugging`'s job. Here, list every gate the change passed through — spec, review, tests, CI, release — and for each ask: was it *missing*, *present but too weak*, or *skipped*? The escape is wherever a gate should have stood and didn't.

3. **Drive each finding to a structural cause.** Keep asking "and why did *that* get through?" until the answer is structural — a test class that doesn't exist, an unstated assumption, a check nothing runs — not a person. "The reviewer missed it" is a symptom; "nothing tests this path" is the cause. Look across code, tests, tooling/CI, and process.

4. **One action per root cause — prefer a gate over a promise.** The strongest action is deterministic: a regression test, a CI check, a lint rule, a runtime assertion — something that makes recurrence *impossible*, not "be more careful". A promise to try harder is the weakest action; rank it last, and only when nothing can be automated.

5. **Self-challenge each action.** Ask: would this actually have caught *this* failure? If not, it is theater — cut it or replace it. Action items that wouldn't have stopped the incident are the main way a post-mortem fails.

## Common mistakes

- Stopping at "human error" or "reviewer missed it" — a symptom, not a cause. Ask why the process allowed the error.
- Action items that are promises ("review more carefully") instead of gates (a check that fails on the bad input).
- Reconstructing the timeline from memory — it launders the real sequence into a story where the outcome looks inevitable or excusable.
- Blame. The question is always which gate was missing, never who is at fault.
