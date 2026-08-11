---
name: spec-it
description: "Use when settled intent for a goal or feature needs detailed requirements before design — what it must do, how each requirement is verified, and the assumptions and risks behind it. Fires on write up what this needs to do and what are the acceptance criteria, even if nobody says spec or requirements. Covers what the system must do, not how it is built. Skip when requirements already exist, and skip while a material decision or approval reply is pending."
---

# Spec It

Turn an intent into a requirements spec (SRS): gather and analyze what the software must do, how each requirement is verified, and the assumptions, dependencies, and risks involved. Requirements are the *what* — keep the *how* (architecture, schemas, code) for design.

## When to use

- You have a goal, brief, or feature request and need its detailed requirements before designing or building.
- **Skip** for a trivial change whose single requirement is obvious — just state it and go.
- If the intent itself is unclear, grill it first with `interview-me`; this skill assumes you roughly know what you want.
- A reply that has not directly closed a pending material decision routes to
  `interview-me`; this skill cannot convert it into approved requirements.

## Procedure

1. **Gather the inputs.** Pull the goal or brief (from planning), read the relevant existing code to see what's already there, and grill any genuine gap with `interview-me`. Don't invent what you could have found.
2. **State the problem** in a line or two, and link the goal it serves.
3. **Write functional requirements as testable behaviours.** Give each a stable
   requirement ID that successors never recycle. Each is observable—"rejects an
   expired token with a 401", not "good auth". Uncheckable is a wish.
4. **Carry every applicable goal/scope guardrail and obligation.** Trace trust/
   data, security, accessibility, compatibility, operational/recovery,
   performance/resource, and supported platform/mode requirements. Add no
   unbounded generic NFR list.
5. **Give each requirement the cheapest honest acceptance form.** Read
   [reference-forms.md](references/reference-forms.md). Use an executable gate
   only when the observable contract is settled **and** project mutation is
   authorized; use a disposable mockup for spatial/state requirements, a
   source-fact + preserved-invariant + intentional-delta contract for existing
   behavior, or a rubric for judgment. Prose is correct when richer form would
   choose design or cost more ambiguity than it removes.
6. **Do not promise an artifact that does not exist.** If authorized to create a
   runnable criterion now, put it in the project's real gate and run it: new
   behavior fails for the missing behavior; preserved behavior starts green and
   later must be deliberately falsified by TDD. If interface or mutation
   authority is open, specify the observable, intended gate, owner, and handoff
   instead—never invent an interface or silently edit the project.
7. **List the edge cases and scenarios** that break a naive build — empty input, concurrency, the unhappy paths.
8. **Contract assumptions and dependencies.** Give each stable ID, evidence/
   state, validation action, owner, freshness/expiry, and failure response.
   Unresolved material state stays an open decision, never a hidden premise.
9. **Surface the open questions and risks** — the unresolved ambiguities and requirement-level challenges that could derail the build. Naming them now is the cheapest they'll ever be.
10. **State what is out of scope** — the requirements you are deliberately *not* covering this round.
11. **Write the proposed spec** to
    `.sdlc-skills/specs/{{YYYY-MM-DD}}-{{topic}}.md` (or the user-set path). Open
    `assets/spec-template.md` and fill it — it carries the identity fields, the
    requirement table with each requirement's real artifact or future gate and
    owner, and the decision-owner block. The spec is immutable once its identity
    is issued.
12. **Present the spec for decision.** Print exactly this, then stop:

    ```text
    Spec ready for your decision — {{spec-path}}
    {{n}} requirements · {{m}} open questions · out of scope: {{excluded}}

    1. Approve — hand off to design
    2. Request changes — tell me what to revise
    3. Reject — wrong requirements
    4. Cancel — stop this work

    Which?
    ```

    Only one of the four hands off; praise, silence, and a partial reply leave
    it pending. Record the outcome externally. An issued identity never mutates:
    a normative change creates a proposed successor carrying a per-ID
    `added / changed / removed / preserved` delta — removal needs its owning
    approval — which invalidates stale downstream bindings until owners
    revalidate or reconcile them.

## Common mistakes

- Requirements with no criterion — "fast", "secure", "intuitive" prove nothing.
- **Promising verification you never wrote** — name the real artifact, or state
  the future gate and owner plainly.
- Prose by reflex — restating a behaviour in a sentence when a failing test would have pinned it exactly.
- Smuggling design or mutation in — a guessed endpoint, schema, internal call, or
  project edit is not made safe by calling it an acceptance criterion.
- A thin happy-path spec with no edge cases, assumptions, or risks — that's exactly where builds break.

For a high-stakes spec, the independent review in
`references/spec-review.md` is mandatory before approval. The reviewer must not
be the spec's sole author.

After approval, re-route from the current phase and next missing precondition.
Use design only for unresolved non-trivial shape and `writing-plans` only when
an executable task contract is still missing.
