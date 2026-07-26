---
name: data-model
description: "Use when the domain needs modeling before design or code — the concepts a system stores or merely computes over: entities, relationships, state transitions, and the invariants that keep them true. Fires for a stateless engine (pricing, rules, workflow) as much as for schema design. Skip for a feature that adds no domain concepts."
---

# Data Model

Model the domain before the code that manipulates it. A domain model is more than columns — it's the concepts, how they relate, the transitions they may make, and the invariants that must always hold. That is true whether or not any of it is ever stored; getting it wrong is the most expensive mistake to fix later.

## When to use

- The work introduces or changes domain concepts — persistent entities, or the in-memory ones a stateless engine computes over (pricing, rules, workflow).
- **Skip** for a feature that adds no domain concepts (a pure UI tweak, plumbing between existing models).

## Procedure

1. **Name the concepts** in the domain's language — one concept per entity, what it represents, and the words the domain experts actually use. This vocabulary is a deliverable: `system-architecture` and the code reuse it, and a generic name here becomes a generic name everywhere.
2. **List each entity's attributes** with type and meaning. State the **null semantics** (what absence means) and the **enumerations** (allowed values), not just the column.
3. **Map the relationships** — their **cardinality** (one-to-many, many-to-many) and **ownership** (whose lifecycle controls the other; what cascades on delete).
4. **Draw the state transitions.** For each concept with a lifecycle, the allowed states and the operations that move between them — a transition you don't draw is one the code will permit by accident.
5. **Write down the invariants** — rules that must always hold (a balance is never negative; an order always has a customer). These become constraints and tests.
6. **Map to storage — when any of it persists.** Note what's deliberately denormalized or cached, and why — every copy of data is a consistency risk you're choosing to accept. A model nothing stores skips this step, never the ones above.
7. **Write the data-model section** of the shared design document `.augments/designs/{{YYYY-MM-DD}}-{{topic}}.md` (the standard designs location; another path only if the user has set one).

## Common mistakes

- Skipping the model because nothing is stored — a stateless engine's invariants are still the spec its tests come from.
- Columns without invariants — the schema says what *can* be stored, not what must be *true*.
- Ignoring null semantics and cardinality — where data bugs are born.
- Modeling the UI's shape instead of the domain's.

For a full domain modeled end to end at this level of rigor — null semantics, momentary vs lifetime cardinality, state transitions, invariants, denormalization — see `references/worked-example.md`.
