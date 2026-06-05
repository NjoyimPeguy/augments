---
name: data-model
description: Use when designing the data a system stores and how it relates — entities, attributes, relationships, and the invariants that keep it correct. Produces the data-model section of the design document. Skip for a feature that adds no persistent state.
---

# Data Model

Design the data before the code that moves it. A schema is more than columns — it's the entities, how they relate, and the invariants that must always hold. Getting these wrong is the most expensive mistake to fix later.

## When to use

- The work introduces or changes persistent data — new entities, relationships, or storage.
- **Skip** for a feature with no persistent state (a pure UI tweak, a stateless transform).

## Procedure

1. **Name the entities** in the domain's language — one concept per entity, and what it represents.
2. **List each entity's attributes** with type and meaning. State the **null semantics** (what absence means) and the **enumerations** (allowed values), not just the column.
3. **Map the relationships** — their **cardinality** (one-to-many, many-to-many) and **ownership** (whose lifecycle controls the other; what cascades on delete).
4. **Write down the invariants** — rules that must always hold (a balance is never negative; an order always has a customer). These become constraints and tests.
5. **Note what's deliberately denormalized or cached, and why** — every copy of data is a consistency risk you're choosing to accept.
6. **Write the data-model section** of the design document — default `.augments/designs/{{YYYY-MM-DD}}-{{topic}}.md`.

## Common mistakes

- Columns without invariants — the schema says what *can* be stored, not what must be *true*.
- Ignoring null semantics and cardinality — where data bugs are born.
- Modeling the UI's shape instead of the domain's.
