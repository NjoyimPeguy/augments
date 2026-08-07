# Plan: {{topic}}

- **Status:** `draft | proposed` (decision and execution state stay external)
- **Normative version:** {{immutable identity of index plus every task contract}}
- **Predecessor:** {{prior normative identity or none; a proposal only links it}}
- **Approval rule:** {{one accountable decision owner, or required approvers plus
  conflict resolver and decision rule}}
- **Bound inputs:** {{exact brief/spec/design/model/ADR/migration/assurance/code
  identities, evidence freshness, and invalidation rules}}
- **Successor delta:** {{initial, or every stable task/interface/gate/phase ID as
  added / changed / removed / preserved; removals need owning approval}}
- **Downstream impact:** {{predecessor-bound review, task attempts, evidence,
  candidate, release, and external consumers; owner reconciliation state/gate}}
- **External decision ledger:** {{location; pending / changes requested / approved /
  rejected / cancelled / superseded by approved normative identity; trusted
  evidence and inline/delegated mode bind this exact version}}
- **External execution ledger:** {{controlled location outside normative identity,
  or returned directly; append-only task states/evidence bind this version}}
- **Invalidation triggers:** {{any bound-input drift or normative scope/interface/
  evaluator/phase/ownership/cutover/rollback/decommission change}}

Every normative change creates a proposed successor with an exact delta. An
approved successor invalidates predecessor-bound consumers until each owner
revalidates or reconciles. Never write
approval, execution mode, task progress, or evidence into this normative index.

**Goal:** {{1–2 sentences}}
**Architecture:** {{2–3 sentences — the shape of the solution the tasks must stay coherent with}}
**Constraints:** {{project-wide rules every task inherits — version floors, dependency limits, naming/security/platform requirements — one line each, copied verbatim from the brief/spec. "None" if there genuinely are none.}}
**Acceptance:** {{the single end-to-end check that proves the WHOLE plan is done — an e2e test, a user-visible scenario, or a rubric. Distinct from each task's Evaluator; this is the feature-level definition of done.}}
**Brief:** {{link to the alignment brief from interview-me, if any}}   ·   **Created:** {{date}}
**References:** {{paths to artifacts the spec shipped — failing tests, mockup pages, a reference implementation, rubrics — or "none". Tasks point at these; they are never restated in prose.}}

## Trace

| Requirement or accepted risk gate | Owning task/phase | Evaluator |
| --- | --- | --- |
| {{ID and source}} | {{task/phase}} | {{command, rubric, or assurance gate ID}} |

## Tasks

- `T-001` — {{task name}}   ·   `01-{{slug}}.md`
- `T-002` — {{task name}}   ·   `02-{{slug}}.md`
- `T-003` — {{task name}}   ·   `03-{{slug}}.md`

Task IDs are stable, never renumbered or recycled; filenames may stay ordered.

The external ledger is the single source of truth for progress. Each row binds
plan version, task ID, attempt/result identity, evaluator evidence, owner/time,
and one state: `todo / in progress / done / done with concerns / blocked / needs
context / cancelled / superseded`. `Done` requires green evidence; concerns stay
durable and cannot count toward a gate until classified as non-blocking evidence
or accepted by an exact owning deviation/exclusion with compensating gate.
Blocked/needs-context retains blocker, owner, and next gate. Cancellation
or supersession requires the approved plan change/decision that removed the task.
