---
name: ui-ux-design
description: Use when a new or revised user interface still has open flow, state, hierarchy, responsive, accessibility, content, or visual-direction decisions before implementation. Skip backend-only work and exact cosmetic edits whose direction is already decided.
---

# UI/UX Design

Design the experience and decide its direction before implementation. In an existing product, the current system is evidence: extend it unless the brief explicitly calls for change.

## When to use

- A new or revised flow, screen, or interface leaves behavior, hierarchy, or visual direction open.
- A visual decision would be clearer through comparable variants than prose.
- **Skip** for backend-only or non-interactive work, and for an exact cosmetic edit whose direction is already fixed.
- **Scale down:** a small, settled interface may need one flow, its states, hierarchy, and acceptance checks; alternatives are not mandatory.

## Procedure

1. **Read the real context.** Establish the requirements and audience. In an existing project, locate its routes, screens, components, tokens, type, content patterns, preview tooling, responsive and accessibility conventions, and relevant tests. Separate deliberate constraints from inconsistencies the work may address. If the task depends on an existing product but that evidence is unavailable, stop before proposing directions and ask for the repository, preview, screenshots, or system documentation; do not substitute a generic system.
2. **Frame the experience.** Name the user's situation, the interface's single primary job, the primary affordance, and what success and failure mean.
3. **Map flows and states.** Write key journeys as *given / when / then* scenarios with entry, completion, escape, and recovery. Cover empty, loading, partial, validation, error, offline, and no-permission states where applicable.
4. **Set hierarchy and content.** Decide what is primary, secondary, contextual, and deferred on each screen. Use realistic content and the user's vocabulary; keep action names consistent through controls, confirmation, and errors.
5. **Choose an intentional direction.** For any open visual direction, read [design-quality.md](references/design-quality.md). Define layout, type, color, spacing, shape, imagery, and motion as one product-specific system; do not decorate around an unresolved hierarchy.
6. **Show alternatives only when seeing helps.** For a spatial, visual, or motion decision, read [visual-decisions.md](references/visual-decisions.md) and compare 2–4 controlled, meaningfully different variants. Keep conceptual requirements and trade-offs in conversation. If feasibility, not preference, is uncertain, invoke `prototyping`.
7. **Design across conditions.** Specify responsive changes, input methods, keyboard and focus behavior, semantic structure, contrast, reduced motion, content extremes, and localization pressure relevant to the interface.
   Record every omitted condition family with skip ID, rationale/evidence,
   owner, expiry/revisit, compensating evaluator, and approval.
8. **Classify the evidence.** Distinguish observed project fact, user research,
   usability observation, accessibility or policy constraint, stakeholder
   preference, and inference. A preference can select a direction; it cannot
   masquerade as proof that users can complete the flow. Record unresolved
   usability risks with a future evaluator and owner.
9. **Compile one immutable proposed whole UI/UX section.** Put context, flows, state matrix,
   hierarchy, direction, responsive/accessibility behavior, decisions,
   deviations, and acceptance checks in
   `.augments/designs/{{YYYY-MM-DD}}-{{topic}}.md` (or the user-set location).
   Preserve approved sections. Record normative identity, predecessor, external
   decision-ledger location, open risks, stable IDs for flows/states/decisions/
   checks, per-ID delta, and one accountable decision owner or required
   approvers, conflict resolver, and decision rule. Piecemeal selections are inputs.
10. **Obtain the exact decision.** Record lifecycle externally; only approved
    hands off. Preference, praise, or silence does not authorize planning.
    Once identity is issued, never mutate it: every normative change creates a
    successor with `added / changed / removed / preserved` IDs; removal needs
    owning approval. An approved successor records the downstream artifact
    inventory bound to its predecessor, invalidates stale bindings externally,
    and blocks use until owners revalidate or reconcile.

## Common mistakes

- Inventing a parallel design system before reading the one already in the project.
- Showing cosmetic variations when the decision is really hierarchy or flow.
- Visualizing a question whose answer is requirements or technical trade-offs.
- Using placeholder content that hides overflow, density, error, and empty-state problems.
- Calling stakeholder preference “usability evidence,” or hiding an unresolved
  risk behind polished visuals.
- Combining individually selected screens into an unreviewed journey.
- Self-approving subjective criteria instead of assigning a human check.
