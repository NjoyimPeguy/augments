---
name: architecture-decisions
description: "Use when a significant, hard-to-reverse technical choice is being weighed or has just been settled — a datastore, sync vs async, a framework, a public contract, an auth or security model — so it is recorded with its alternatives and consequences before anything is built on it. Fires on should we use X or Y, on a choice made in passing during discussion, and on a request to revisit an old one, even if nobody says ADR or decision record. Skip easily-reversible choices."
---

# Architecture Decisions

Record the decisions you'd regret not being able to explain in six months. An ADR (Architecture Decision Record) captures *why*, not just *what* — so the next person, or you, doesn't relitigate it or quietly undo it.

## When to use

- Record a decision only when **all three** hold: it's **hard to reverse**, it would be **surprising without the rationale**, and there were **genuine trade-offs** between real options — a datastore, a sync/async boundary, a framework, a public contract, a security model.
- **Skip** when any of the three is missing — a reversible, obvious, or inevitable choice (a variable name; the only option that could work) is noise as an ADR.

## Procedure

`assets/adr-template.md` owns the fields and what each one must contain. Read it
while drafting; the steps below are the judgements it cannot make for you.

1. **Name the decision and its authority.** State the question, the artifact or
   system scope, the forces bearing on it, and either one accountable decision
   owner or the required approvers with a conflict rule.

2. **Weigh at least two real options** on their assumptions, failure limits,
   disqualifiers, reversal cost, and evidence. Evaluate the status quo, or
   deferring, wherever that is viable — and record the evidence when it is not.

   Every assumption gets a stable identity and a stated way to be proved wrong;
   the template's assumptions field names the rest of what it carries.

3. **Record the proposed choice and the rejected alternatives.** The rejection is
   the load-bearing part — it is what stops a later reader reopening a settled
   question. Preserve it rather than silently editing history.

4. **Record consequences and reversal:** what this commits you to, its data and
   migration consequences, how it could be undone, and what it closes off. A
   decision with only upsides was not examined.

5. **Challenge independently.** A reviewer other than the sole author challenges
   the options, assumptions, consequences, and reversal — unless a current
   independent design review already covers this exact ADR identity. The
   template's challenge contract binds the access, deadline, quiescence, and
   finding disposition.

6. **Persist the complete proposal.** Append the immutable `proposed` ADR to
   `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}.md`, or the project's decision
   log, preserving the sections already there.

7. **Present the ADR for decision.** `proposed` means drafted and unapproved.
   State its identity, proposed choice, rationale, rejected alternatives,
   consequences, and reversal cost. Ask one conversational question offering
   accept, reject in favor of another option, request changes, or cancel. Lead
   with the option supported by the recorded trade-offs and one sentence of
   reasoning, then stop.

   Praise and momentum accept nothing. Record accepted, rejected, or cancelled
   externally, with trusted exact-version evidence.

   Once issued, the old identity never mutates. A normative change creates a
   proposed successor with an exact delta, and an accepted successor inventories
   and invalidates predecessor-bound consumers until their owners reconcile.

8. **Track the decision and its conformance separately.** Acceptance may
   supersede the prior normative decision, but it neither puts the successor
   `in force` nor proves the old implementation is gone — the transition work
   owns that mixed state.

   Conformance is what gates `in force`; retirement needs owner action and the
   absence of the governed surface. A contradiction between the two reopens
   every affected artifact owner.

## Common mistakes

- Recording the *what* without the *why* — it reads as arbitrary and gets undone.
- No rejected alternatives — the next person re-explores the same dead ends.
- An ADR for a reversible choice — only the decisions you'd defend belong here.
- An accepted ADR never moved `in force` when work landed, or an obsolete
  in-force ADR was never linked as superseded or retired.
- Treating “the code now does this” as owner approval or conformance proof.

For a copyable ADR template, a filled example, and common failure patterns, see `assets/adr-template.md`.
