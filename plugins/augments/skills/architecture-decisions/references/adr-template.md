# ADR template

Copyable template behind `../SKILL.md`. Loaded on demand.

## How to use this

- Fill every section; an ADR with an empty section is worse than none — a reader can't tell "considered and rejected" from "never thought about it."
- Write for the reader in six months who has none of today's context. They can see *what* the code does; only you can tell them *why*.
- Keep the whole record to one screen. Depth belongs in the design document around it; the ADR is the index card that keeps the decision findable and reversible-looking decisions out of reach.

## The template

```markdown
## ADR: {{decision-title}}

**Status:** {{status — proposed, in force, or superseded by another ADR (name it)}}

**Context:** {{the forces bearing on the decision — the requirement or constraint
that makes a choice necessary, and the facts (scale, team, existing code, hard
deadlines) that rule options in or out}}

**Decision:** {{the choice, in one or two sentences, stated as something the
code will actually do — not "we'll explore X" but "X does Y"}}

**Alternatives considered:**

- {{option}} — {{why rejected: what it assumes, where it breaks, what ruled it
  out}}
- {{option}} — {{why rejected}}

**Consequences:** {{what this commits us to and what it closes off — both
directions. The follow-up work it creates, the migration it would take to
reverse, the option it forecloses}}
```

## What each field must contain

- **Title** — the decision as a short active statement: "Session state lives in the datastore, not the process." Not "Database discussion."
- **Status** — `proposed` until the code exists, then flip to `in force`. Never leave a `proposed` ADR behind after the work lands; readers will mistake the unbuilt plan for the architecture. When replaced, edit the old record's status to `superseded by {{new-adr}}` and link back from the new one — do not delete it; the history is the point.
- **Context** — only what a reader needs to judge the decision without re-running the investigation. A requirement, a measured constraint ("p99 must stay under 200 ms"), an existing commitment ("the rest of the system is synchronous"). Opinions and aspirations don't belong here.
- **Decision** — concrete enough that someone could verify it against the code. "Retries happen at the queue consumer with exponential backoff" is a decision; "we'll make messaging robust" is a wish.
- **Alternatives considered** — at least two real options, each with the reason it lost. This is the load-bearing section: it stops a later reader from re-opening a settled question and from silently reversing the decision. "Rejected: can't do X" beats "X is nicer."
- **Consequences** — honest about both directions: what you gain *and* what you now own (an operational burden, a migration path, a capability you gave up). A decision with only upsides was not examined.

## Worked example

```markdown
## ADR: Background jobs run on a database-backed queue, not an external broker

**Status:** in force

**Context:** The service must send emails and run report generation outside the
request path. Load today is tens of jobs per hour, run by a two-person team
with no dedicated operations capacity. The system already runs a relational
datastore with row-level locking.

**Decision:** Jobs are rows in a `jobs` table; a worker inside the app process
claims them with `SELECT ... FOR UPDATE SKIP LOCKED` and retries with capped
exponential backoff.

**Alternatives considered:**

- Dedicated message broker — rejected: a second stateful service to deploy,
  monitor, and back up; its throughput and routing features are unneeded at
  this load and the team can't operate it well.
- In-process task queue with no persistence — rejected: jobs vanish on deploy
  or crash, and email delivery is user-visible loss.

**Consequences:** No new infrastructure to operate, and jobs survive restarts.
In exchange, job throughput is bounded by the datastore, heavy job bursts can
contend with request traffic on the same database, and moving to a broker
later means a worker rewrite — acceptable while load stays orders of magnitude
below the datastore's headroom.
```

## Common failure patterns

- **The diary entry.** Context recounts the meeting instead of the forces. If a sentence wouldn't change whether the decision is right, cut it.
- **The verdict without the trial.** Decision recorded, alternatives missing. Six months later someone re-proposes the rejected option and the cycle repeats.
- **The forever-proposed record.** The work shipped but the status never flipped. Readers now trust a plan that may differ from what was built.
- **The amended ADR.** The decision changed and the record was edited in place. Supersede instead: old ADR stays, marked `superseded by`, new ADR links back. Silent edits destroy the audit trail.
- **The resume line.** Consequences list only benefits. If reversing the decision would be expensive or impossible, that belongs in the record — it's the warning label.
