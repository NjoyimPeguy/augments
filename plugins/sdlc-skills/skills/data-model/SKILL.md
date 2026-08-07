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

1. **Name the concepts** in the domain's language — one concept per entity, what
   it represents, and the words domain experts use. This canonical vocabulary
   is a deliverable: `system-architecture`, `coding-standards`, and code consume
   it without redefining domain meaning.
2. **List each entity's attributes** with type and meaning. State the **null semantics** (what absence means) and the **enumerations** (allowed values), not just the column.
3. **Map the relationships** — their **cardinality** (one-to-many, many-to-many) and **ownership** (whose lifecycle controls the other; what cascades on delete).
4. **Draw the state transitions.** For each concept with a lifecycle, the allowed states and the operations that move between them — a transition you don't draw is one the code will permit by accident.
5. **Write down the invariants and their owners.** For every material rule, name
   the constraint, transaction boundary, test, or reconciliation process that
   enforces it and who owns failures. An invariant with no enforcement path is
   only an intention.
6. **Apply the operational lenses that match the risk.** Challenge identity and
   uniqueness; source of truth versus derived data; tenancy and authorization;
   time, ordering, and late events; concurrency and atomicity; idempotency and
   retry; retention, privacy, and deletion; compatibility and versioning. Record
   every omission with skip ID, rationale/evidence, owner, expiry/revisit,
   compensating evaluator, and approval instead of skipping by ritual.
7. **Map to storage — when any of it persists.** Note what's deliberately
   denormalized or cached, its source of truth, update boundary, and drift repair.
   For a bounded existing-model change, define migration, mixed-version, and
   rollback behavior. For a high-risk transition, record the domain constraints
   and let `migration-strategy` own the transition contract.
8. **Challenge the model with evidence.** Trace representative reads, writes,
   transitions, concurrent operations, deletion, and existing-data migration.
   Record the runnable query or command and result when one exists; otherwise
   name the future evaluator and owner without pretending it has run.
9. **Write an immutable proposed data-model section** of the shared design document,
   preserving other approved sections,
   `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}.md` (the standard designs
   location; another only if user-set). Record normative identity, predecessor,
   external decision-ledger location, stable IDs for concepts, relationships,
   transitions, invariants, and mappings, plus one accountable decision owner or
   required approvers, conflict resolver, and decision rule.
10. **Obtain the exact decision.** Record lifecycle externally; only approved
    hands off. Once identity is issued, never mutate it: every normative change
    creates a successor with per-ID `added / changed / removed / preserved`
    delta; removal needs owning approval. An approved successor records the
    downstream artifact inventory bound to its predecessor, invalidates stale
    bindings externally, and blocks use until owners revalidate or reconcile.

## Common mistakes

- Skipping the model because nothing is stored — a stateless engine's invariants are still the spec its tests come from.
- Columns without invariants — the schema says what *can* be stored, not what must be *true*.
- Ignoring null semantics and cardinality — where data bugs are born.
- Naming an invariant without the transaction, constraint, test, or repair that
  keeps it true under races and retries.
- Treating migration, deletion, or mixed-version operation as somebody else's
  problem after the model is approved.
- Modeling the UI's shape instead of the domain's.

For a full domain modeled end to end at this level of rigor — null semantics, momentary vs lifetime cardinality, state transitions, invariants, denormalization — see `references/worked-example.md`.
