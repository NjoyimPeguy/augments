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

1. **State the decision** as a question with context: what are you deciding, and what forces it (which requirement, which constraint)?
2. **Weigh the real options** — at least two — each on four axes: what it assumes, where it breaks down, what would rule it out, what evidence supports it. "A vs B because B is nicer" is not a decision.
3. **Record the choice and its rationale** — and, explicitly, **the rejected alternatives and why**. The rejection is the load-bearing part: it stops the decision being silently reversed later.
4. **Note the consequences** — what this commits you to, and what it closes off.
5. **Mark its status** — `proposed` when recorded ahead of the work, flipped to `in force` once the decision is built, `superseded by {{adr}}` when replaced. A reader must be able to tell a decision in force from a plan that never landed — otherwise a later session reads unbuilt intentions as the current architecture.
6. **Append the ADR** to the decisions section of the shared design document `.augments/designs/{{YYYY-MM-DD}}-{{topic}}.md` (the standard designs location; another path, e.g. a standing decisions log, only if the user has set one).

## Common mistakes

- Recording the *what* without the *why* — it reads as arbitrary and gets undone.
- No rejected alternatives — the next person re-explores the same dead ends.
- An ADR for a reversible choice — only the decisions you'd defend belong here.
- A `proposed` ADR never flipped to `in force` (or retired) when the work lands — downstream readers treat the unbuilt plan as what the system actually does.
