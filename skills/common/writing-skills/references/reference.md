# Writing Skills — Reference

## Why the format is strict

Every line of a SKILL.md loads into context each time the skill fires. A 300-line skill invoked ten times in a session is 3,000 lines of overhead. The cost is real and measured: loading a whole library at startup can burn 20k+ tokens before any work begins, and audits of verbose skill libraries routinely find most lines cuttable with zero behavior loss. We pay only for what changes behavior.

## When verbosity earns its tokens

Not all length is bloat. A token-cutting pass can strip most lines from a skill library and claim "no behavioral loss" — but that usually measures only *activation* (which depends solely on the `description`), never *compliance under pressure*. For one skill type the verbose part is the active ingredient: in **discipline skills**, the rationalization table is what changes behavior, not decoration. The split:

- **Capability / template / reference / meta** — no temptation to counter. Lean. Verbosity here is genuine bloat.
- **Discipline** (for example routing, TDD, YAGNI, verifying completion,
  debugging, receiving review) — counters a tempted agent's excuses. The table
  stays in the body. Justify each line with a pressure test, never a static read.

Our large token wins come from architecture (lazy loading, no uniform ceremony, per-task plans, light bootstrap), not from gutting discipline skills — so conceding this point costs us nothing.

## Descriptions: trigger, not summary

The description is the *only* text the runtime reads when deciding whether to load a skill. Two failure modes:

- **Too vague** → the skill never fires when it should.
- **A workflow summary** → the model reads the summary, assumes it knows the procedure, and skips the skill body. Incomplete execution.

### Good (trigger conditions)

- `Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes.`
- `Use when you have an alignment brief or a clear multi-step task and need an executable plan before implementing. Skip for single-step work.`

### Bad

- `Reproduces the bug, forms a hypothesis, instruments the code, fixes it, then writes a regression test.` — summarizes the workflow; the model follows it from memory and never opens the skill.
- `A skill for debugging.` — too vague to trigger reliably.

## Progressive disclosure

SKILL.md is the always-loaded part. Sibling files load on demand.

- **In SKILL.md**: intent, when-to-use, the procedure, common mistakes.
- **In sibling files**: templates (`{{curly}}` placeholders), long examples, lookup tables, scripts, and deep rationale like this document.

Link references only **one level deep** from SKILL.md. Deeper chains (SKILL → A → B) get partially read, so the agent misses what's in B.

## Complexity gate

The most common real-world complaint about heavy skill libraries is uniform ceremony on tiny tasks. Every skill states when to skip itself. A two-line config change must not trigger a seven-step process.

## How much to write

Match instruction density to how constrained the task is:

- **One correct sequence** (a fragile path) → bundle a tested script; prose drifts.
- **A preferred pattern** → give pseudocode or a worked shape, but allow variation.
- **Open-ended / exploratory** → principles only; over-specifying flexible work makes it brittle.

## Prose hygiene

- **One term per concept.** Choose "extract" and don't also write "pull"/"get"/"retrieve" — the model may treat each synonym as a distinct operation.
- **Imperative for discipline, plain for guidance.** Discipline skills use hard imperatives (`Write the test before any implementation code.`); collaborative skills avoid them so they don't override the model's contextual judgment. Weak `Consider writing tests first.` → strong `Write the test before any implementation code.`

## Naming

- Directory name == frontmatter `name`, kebab-case.
- The invoked name is `augments:<name>` regardless of which phase folder holds it — the folder is organization for humans, not part of the address.
