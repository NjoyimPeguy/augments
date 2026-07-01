---
name: writing-skills
description: Use when creating or editing a skill in this library — the lean format, progressive disclosure, and how to prove a skill works. For AUTHORING skills, not using them.
---

# Writing Skills

Skills are tools, not pipelines. Each one loads into context every time it fires, so every line costs tokens on every use. Write the minimum that changes behavior; push the rest to sibling files.

## When to use

- Creating or editing a skill under `skills/<phase>/<name>/`.
- **Skip** when you're *using* a skill — this is only for authoring.

## Skill types

Match the form to the need (see `reference.md` for how much detail each needs):

- **Instruction** — a prose procedure. Most skills.
- **Template** — ships a `{{placeholder}}` file to copy (like `skill-template.md`).
- **Script** — bundles a tested, deterministic script when prose would be error-prone.
- **Reference** — a doc loaded on demand for lookup; large is fine, it isn't always-loaded.

## The format (non-negotiable)

1. **Frontmatter**: `name` (kebab-case, matches the directory) and `description` (capability + "Use when…" trigger, ≤1024 chars, third person, **never** a workflow summary). Add `disable-model-invocation: true` only for pure prompt-injection skills with no agentic steps (e.g. a one-line `zoom-out`).
2. **Body ≤ ~80 lines** (capability skills; discipline skills are the exception — see below). Intent + procedure only. Cut marketing ("why this matters") and long worked examples.
3. **Progressive disclosure.** Templates, long examples, lookup tables, scripts → sibling files. SKILL.md links to them; it never inlines them.
4. **Complexity gate up top.** State when to *skip* the skill. Ceremony must scale down with task size.
5. **Lint-clean markdown.** Fill-in placeholders use `{{double-curly}}` — `<angle>` brackets render as HTML and trip linters. Fence code blocks with a language. Blank lines around lists.

## Discipline skills are the exception

A few skills exist to hold an agent to a discipline it is tempted to skip under pressure (TDD, verifying-completion, systematic debugging, receiving-code-review). For these only:

- Keep the **rationalization table** (each tempting excuse → its rebuttal) and **red-flag list** in the *body*, never a sibling — a tempted agent won't choose to load a sibling file, and the counter must be in context when the temptation hits. You cannot lazy-load willpower.
- They may exceed ~80 lines. Each extra line must earn its place by passing a pressure test (`testing.md`), not by sounding good.
- Everything else (capability, template, reference, meta) has no temptation to counter — keep it lean.

## Procedure

1. **Confirm it should be a skill — and whether it's one.** Write one only if an agent reliably gets this *wrong without guidance*. Plain prompt text or a one-off? Don't. Needs an exact, deterministic sequence? Bundle a script, not prose. A needless skill taxes every session it fires. If a phase has several activities, decide one cohesive skill vs several — see `docs/augments/skill-granularity.md`.
2. Choose the phase folder (`planning`…`maintenance`) or `common/`, create `skills/<phase>/<name>/`, and copy `skill-template.md` to start.
3. Write `description` as a trigger first. Test it: does it say **when**, not **how**? If it lists steps, rewrite.
4. Write the body: **When to use** (incl. Skip), **Procedure** (numbered), **Common mistakes**.
5. Move anything heavy to sibling files.
6. Verify (below), then **prove it works** with a subagent test — see `testing.md`.

## Verify before done

- `wc -l SKILL.md` ≤ ~80 · description ≤ 1024 chars · directory name == frontmatter `name`.
- Markdown lints clean · description states triggers, not a summary.

## Common mistakes

- A body that reads like documentation — it reloads into context every invocation.
- A description that summarizes the workflow → the model follows the summary and skips the skill body.
- Inlining templates/examples that belong in sibling files.
- No complexity gate → ceremony on trivial tasks (the #1 complaint about heavy skill libraries).
- Shipping a skill you never watched fail without — you don't know it prevents the right failure.

See `reference.md` for examples and reasoning, and `testing.md` for proving a skill actually changes behavior.
