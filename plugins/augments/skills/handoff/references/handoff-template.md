# Handoff template

Fill-in template for `../SKILL.md`. Loaded on demand.

## The template

Copy this, fill every `{{placeholder}}`, delete nothing silently — a section you can't fill is a signal the handoff isn't ready. "Next step unknown" is honest; an omitted section is a trap.

```markdown
# Handoff: {{work item name}}

## Goal
{{what this work is trying to achieve, in one or two lines — the WHY}}

## State
- Branch: {{branch name}}
- Uncommitted: {{files changed but not committed, or "none"}}
- Done: {{what is complete and verified — cite the check that proved it}}
- In flight: {{what is half-done, exactly where it stopped}}

## Decisions
{{choices already made and their reasoning, one per line — so the next session doesn't relitigate them}}
- {{decision}} — because {{reason}}
- Open question: {{a decision still pending, and the options on the table}}

## Gotchas
{{traps discovered, with file and line references so they can be verified}}
- {{file:line}} — {{what bites and why}}

## Next step
{{the single concrete action to take first — a command to run, a file to edit, a test to write}}

## Suggested skills
{{which skills the next session should reach for, and at what point}}

## References
{{paths to existing specs, plans, ADRs, commits — the documents NOT duplicated into this handoff}}
```

## A worked example: bad vs good

Bad handoff — a summary of the conversation:

> We spent a while trying to get the cache invalidation working. Tried a few approaches, some didn't work. Eventually got somewhere with the TTL approach. There's still an issue with stale entries. Good luck!

The next session learns nothing resumable: no goal, no state, no next step, and "tried a few approaches" forces it to rediscover each failure.

Good handoff — the state to resume from:

```markdown
# Handoff: cache invalidation for the session store

## Goal
Entries in the session store expire on idle timeout, not just on absolute TTL.

## State
- Branch: fix/session-idle-expiry
- Uncommitted: src/store/memory.js — half-done sweep pass, not yet wired in
- Done: TTL-based expiry (commit a1b2c3d), covered by store-expiry test
- In flight: idle-expiry sweep — the sweep function exists but is never scheduled

## Decisions
- Sweep-based expiry over per-read checks — because per-read checks made the hot path measurable slower
- Open question: sweep interval — 30s vs 60s, needs a load test to decide

## Gotchas
- src/store/memory.js:88 — expiry timestamps are stored in seconds, not milliseconds; mixing them silently expires entries 1000x early
- tests/store-expiry.test.js — the fake-clock helper must be reset between cases or tests pass individually but fail together

## Next step
Wire `scheduleSweep()` into store construction at src/store/index.js:14, then run the store-expiry test.

## Suggested skills
- test-driven-development — the sweep scheduling has no failing test yet; write one first
- verifying-completion — before claiming the idle-expiry behaviour works

## References
- plan directory from writing-plans: docs/plans/session-expiry/
- TTL work: commit a1b2c3d
```

The difference is not length — it's that every line lets the next session *act* without re-deriving.

## What NOT to include

A handoff is a state transfer, not a transcript. Cut all of these:

- **Narration of the session.** What was tried in what order, who said what, how long it took. The next session needs where things *stand*, not how they got there. A failed approach earns one line under Decisions ("rejected X — because Y") only if it would otherwise be retried.
- **Duplicated artifacts.** If the plan, spec, or ADR exists on disk, point to it. Copying its content in creates a second version that drifts the moment either changes.
- **Your working notes verbatim.** Scratch reasoning, dead-end dumps, half-formed ideas. Distill to the decision or the gotcha, delete the journey.
- **Obvious context.** Anything the next session will read from the repo itself in seconds (file listings, the test command in the project README). Handoffs age; the repo doesn't lie at the time it's read.
- **Secrets and personal data.** Keys, tokens, passwords, credentials — redact, always. If a secret is *relevant* (e.g. "the API key expired mid-session"), say that it expired, never what it was.
- **False certainty.** Don't smooth over a half-understood bug with a confident summary. "Root cause not yet found; suspicion is the retry loop, unverified" is a good line. A guessed explanation the next session trusts is worse than none.

## Edge cases

- **Handing off to yourself after compaction.** Write it as if to a stranger — you will have lost exactly the context you're tempted to leave implicit.
- **Multiple open threads.** One handoff document, but a Next step per thread, ordered — never one blended paragraph.
- **Nothing is in flight, only decisions pending.** Still write the handoff; a pending decision with its options recorded is resumable work.
- **The failure is the finding.** If the session's result is "this approach doesn't work," the handoff's Goal stays, State says "approach rejected," and Decisions carries the evidence — so the next session doesn't repeat the experiment.
- **Long-lived handoffs.** If a handoff may sit for days, add a date at the top and double-check every branch/commit reference still exists when you resume.
