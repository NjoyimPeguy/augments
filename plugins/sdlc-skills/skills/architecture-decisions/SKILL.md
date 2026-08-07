---
name: architecture-decisions
description: Use when making a significant, hard-to-reverse technical decision — a datastore, sync vs async, a framework, a public contract, a security model — to record it as an ADR before building on it. Skip for easily-reversible choices.
---

# Architecture Decisions

Record the decisions you'd regret not being able to explain in six months. An ADR (Architecture Decision Record) captures *why*, not just *what* — so the next person, or you, doesn't relitigate it or quietly undo it.

## When to use

- Record a decision only when **all three** hold: it's **hard to reverse**, it would be **surprising without the rationale**, and there were **genuine trade-offs** between real options — a datastore, a sync/async boundary, a framework, a public contract, a security model.
- **Skip** when any of the three is missing — a reversible, obvious, or inevitable choice (a variable name; the only option that could work) is noise as an ADR.

## Procedure

1. **Name the decision and authority.** State the question, artifact/system
   scope, forces, and either one accountable decision owner or required
   approvers plus conflict resolver/decision rule.
2. **Weigh real options** — at least two — on assumptions, failure limits,
   disqualifiers, reversal cost, and evidence. Evaluate status quo/defer when
   viable or record why it is not. Give every assumption stable identity,
   evidence/state, validation action, owner, expiry/reopen, and failure response.
3. **Record the proposed choice and rejected alternatives.** The rejection is
   load-bearing; preserve it rather than silently editing history.
4. **Record consequences and reversal.** What this commits you to, migration or
   data consequences, how it could be reversed, and what it closes off.
5. **Challenge independently.** A reviewer other than the sole author challenges
   options, assumptions, consequences, and reversal unless a current independent
   design review explicitly covers this exact ADR identity. Bind access,
   artifact controls, attempt/deadline, quiescence, report, and finding
   disposition as defined in `references/adr-template.md`.
6. **Persist and present the complete proposal.** Append the immutable
   `proposed` ADR to `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}.md` (or the
   project decision log), preserving other sections.
7. **Obtain the direct decision.** `proposed` means drafted and unapproved;
   record accepted/rejected/cancelled externally with trusted exact-version
   evidence. Praise or momentum does not accept it. Once issued, every normative
   change creates a proposed successor with an exact delta; the old identity
   never mutates. An accepted successor inventories and invalidates
   predecessor-bound consumers until their owners reconcile.
8. **Track decision and conformance separately.** Acceptance may supersede the
   prior normative decision; it neither makes the successor `in force` nor
   proves the old implementation absent. Transition work owns mixed state.
   Conformance gates `in force`; retirement needs owner action and governed-
   surface absence. A contradiction reopens every affected artifact owner.

## Common mistakes

- Recording the *what* without the *why* — it reads as arbitrary and gets undone.
- No rejected alternatives — the next person re-explores the same dead ends.
- An ADR for a reversible choice — only the decisions you'd defend belong here.
- An accepted ADR never moved `in force` when work landed, or an obsolete
  in-force ADR was never linked as superseded or retired.
- Treating “the code now does this” as owner approval or conformance proof.

For a copyable ADR template, a filled example, and common failure patterns, see `references/adr-template.md`.
