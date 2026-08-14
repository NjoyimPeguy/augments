---
name: ui-ux-design
description: "Use when a new or revised user interface still has open decisions about flow, state, hierarchy, responsive behaviour, accessibility, content, or visual direction, before it is implemented. Fires on design this screen, what should this look like, and how does the user get through this, even if nobody says UX or design. Skip backend-only work, and skip exact cosmetic edits whose direction is already decided."
---

# UI/UX Design

Design the experience and decide its direction before implementation. In an existing product, the current system is evidence: extend it unless the brief explicitly calls for change.

## When to use

- A new or revised flow, screen, or interface leaves behavior, hierarchy, or visual direction open.
- A visual decision would be clearer through comparable variants than prose.
- **Skip** for backend-only or non-interactive work, and for an exact cosmetic edit whose direction is already fixed.
- **Scale down:** a small, settled interface may need one flow, its states, hierarchy, and acceptance checks; alternatives are not mandatory.

## Procedure

Each step fills the matching section of `assets/ui-ux-section.md`. Open it now
and work in it; the steps below are the judgements the template cannot make for
you.

1. **Read the real context.** Establish the requirements and audience, then, in an
   existing project, go and find the system that is already there — its routes and
   screens, its components and tokens, its type and content patterns, its preview
   tooling, its responsive and accessibility conventions, and its tests.

   Sort what you find into two piles: deliberate constraints you are bound by, and
   inconsistencies this work may correct. If the task depends on an existing
   product and that evidence is simply unavailable, stop before proposing any
   direction and ask for the repository, a preview, screenshots, or the system
   documentation. Do not substitute a generic system for the one you could not read.
2. **Frame the experience.** Name the user's situation, the interface's single
   primary job, the primary affordance that does that job, and what success and
   failure each look like.
3. **Map flows and states.** Write the key journeys as *given / when / then*
   scenarios, each with an entry, a completion, an escape, and a recovery.

   Then cover the states a happy path hides: empty, loading, partial, validation,
   error, offline, and no-permission, wherever they can occur.
4. **Set hierarchy and content.** Decide what is primary, secondary, contextual,
   and deferred on each screen.

   Use realistic content and the user's own vocabulary, and keep an action's name
   identical through its control, its confirmation, and its errors.
5. **Choose an intentional direction.** For any open visual direction, read
   [design-quality.md](references/design-quality.md). Define layout, type, color,
   spacing, shape, imagery, and motion as one product-specific system — and do not
   decorate around a hierarchy that is still unresolved.
6. **Show alternatives only when seeing helps.** For a spatial, visual, or motion
   decision, read [visual-decisions.md](references/visual-decisions.md) and compare
   2–4 controlled, meaningfully different variants.

   Conceptual requirements and trade-offs stay in conversation — they are not
   easier to see. And if what is uncertain is feasibility rather than preference,
   invoke `prototyping` instead.
7. **Design across conditions.** The template's *Conditions* table lists the eight
   families this owes and the fields a skip record carries.

   An interface does not have to answer all eight. It does have to say which ones
   it is not answering, and leave someone accountable for each — a family dropped
   without a skip record is one nobody will notice is missing.
8. **Classify the evidence.** Tag every claim with where it came from, using the
   template's *Evidence* kinds.

   The tag that carries the weight is stakeholder preference. A preference can
   select a direction; it cannot masquerade as proof that users can complete the
   flow. Where a usability risk stays open, record it as open, with a named future
   evaluator and an owner.
9. **Compile one immutable proposed whole UI/UX section.** Write the filled
   template to `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}.md`, or the
   user-set location, preserving the sections already approved around it.

   The word doing the work is *whole*. Individually selected screens, a chosen
   variant, an agreed flow — those are inputs to the section, not the section,
   and none of them is what gets presented for decision.
10. **Present the design for decision.** State the path, flows, visual direction,
    and open risks. Ask one conversational question offering approve and hand
    off to planning, request changes, reject the direction, or cancel. Recommend
    the answer supported by the evidence and unresolved risks, with one sentence
    of reasoning, then stop.

    Only one of the four authorizes planning. A preference selects a direction
    but does not approve the design; praise and silence decide nothing. Record
    lifecycle externally.

    An issued identity never mutates: a normative change creates a successor with
    `added / changed / removed / preserved` IDs (removal needs owning approval)
    that invalidates stale downstream bindings until owners revalidate.

## Common mistakes

- Inventing a parallel design system before reading the one already in the project.
- Showing cosmetic variations when the decision is really hierarchy or flow.
- Visualizing a question whose answer is requirements or technical trade-offs.
- Using placeholder content that hides overflow, density, error, and empty-state problems.
- Calling stakeholder preference “usability evidence,” or hiding an unresolved
  risk behind polished visuals.
- Combining individually selected screens into an unreviewed journey.
- Self-approving subjective criteria instead of assigning a human check.
