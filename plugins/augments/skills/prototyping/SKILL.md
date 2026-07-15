---
name: prototyping
description: Use when a design or feasibility question is genuinely uncertain and cheaper to answer by building a throwaway than by arguing — a tricky bit of logic, a layout choice, a library's real behaviour. Skip when you already know the answer.
---

# Prototyping

A prototype answers one question and dies. Its only job is to turn an uncertainty into a fact cheaply — the code is disposable; the *answer* is what you keep.

## When to use

- A specific question is uncertain and faster to *build* than to argue: does this algorithm work, does this layout read, does this library do what its docs claim.
- Reached from `feasibility-check` (a killer risk) or `ui-ux-design` (a layout choice).
- **Skip** when you already know the answer, or the question is vague — a prototype that answers the wrong question is pure waste.

## Procedure

1. **Write the question down**, explicitly, before any code. If you can't state it in one sentence, you're not ready to prototype.
2. **Build the smallest thing that answers it** — in memory, with no persistence, no tests, no generality. "What if we needed X later" is banned; that's not the question.
3. **For logic:** isolate it in a portable module behind a tiny throwaway driver (a CLI or loop). The driver dies; the validated logic can be lifted into the real code.
4. **For UI:** build 2–3 *structurally different* variants (different layout, hierarchy, primary affordance — not colour) inside a real, populated page, not an empty route where everything looks fine.
5. **Record the answer** — the question and what you learned — durably (a note, or an ADR via `architecture-decisions` if it settles a decision). Then **delete the prototype.**

## Common mistakes

- No written question — you can't tell when you're done, and the code becomes "real" by accident.
- Adding tests or generality — a prototype that needs tests is no longer a prototype.
- Variants that differ only in colour — that's a tweak, not an answer.
- Keeping the prototype "as a base" — you'll ship unvalidated throwaway code. Delete means delete.
