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

Match the form to the need (see `references/reference.md` for how much detail each needs):

- **Instruction** — a prose procedure. Most skills.
- **Template** — ships a `{{placeholder}}` file to copy (like `references/skill-template.md`).
- **Script** — bundles a tested, deterministic script when prose would be error-prone.
- **Reference** — a doc loaded on demand for lookup; large is fine, it isn't always-loaded.

## The format (non-negotiable)

1. **Frontmatter**: `name` (kebab-case, matches the directory) and `description` (capability + "Use when…" trigger, ≤1024 chars, third person, **never** a workflow summary).
2. **Body ≤ ~80 lines** (capability skills; discipline skills are the exception — see below). Intent + procedure only. Cut marketing ("why this matters") and long worked examples.
3. **Progressive disclosure.** Templates, long examples, lookup tables, scripts → sibling files under `references/`. SKILL.md links to them; it never inlines them.
4. **Complexity gate up top.** State when to *skip* the skill. Ceremony must scale down with task size.
5. **Lint-clean markdown.** Fill-in placeholders use `{{double-curly}}` — `<angle>` brackets render as HTML and trip linters. Fence code blocks with a language. Blank lines around lists.

## Discipline skills are the exception

A few skills exist to hold an agent to a discipline it is tempted to skip under
pressure—for example routing, TDD, YAGNI, verifying completion, systematic
debugging, and receiving review. For these only:

- Keep the **rationalization table** (each tempting excuse → its rebuttal) and **red-flag list** in the *body*, never a sibling — a tempted agent won't choose to load a sibling file, and the counter must be in context when the temptation hits. You cannot lazy-load willpower.
- They may exceed ~80 lines. Each extra line must earn its place by passing a pressure test (`references/testing.md`), not by sounding good.
- Everything else (capability, template, reference, meta) has no temptation to counter — keep it lean.

## Procedure

1. **Confirm it should be a skill—and whether it is one.** Write one only if an
   agent reliably gets this wrong without guidance. Plain prompt text or a
   one-off? Do not. An exact fragile sequence belongs in a tested script. Split
   activities only when each is independently invokable; otherwise keep one
   cohesive skill.
2. Choose the phase folder (`planning`…`maintenance`) or `common/`, create `skills/<phase>/<name>/`, and copy `references/skill-template.md` to start.
3. Write `description` as a trigger first. Test it: does it say **when**, not **how**? If it lists steps, rewrite.
4. Write the body: **When to use** (incl. Skip), **Procedure** (numbered), **Common mistakes**.
5. Move anything heavy to sibling files under `references/`.
6. Verify the shape (below), then **prove the behavior at the failure surface** —
   trigger, artifact/side effect, or pressured discipline. Read
   `references/testing.md`; an agent explaining the rule is not evidence that it
   follows it.

## Verify before done

- `wc -l SKILL.md` ≤ ~80 · description ≤ 1024 chars · directory name == frontmatter `name`.
- Every sibling reference is linked directly from `SKILL.md`, and every path resolves.
- Markdown lints clean · description states triggers, not a summary.
- The targeted before/after proof observes behavior, reports every run, and does
  not turn unchanged skills into a costly coverage exercise.

## Common mistakes

- A body that reads like documentation — it reloads into context every invocation.
- A description that summarizes the workflow → the model follows the summary and skips the skill body.
- Inlining templates/examples that belong in sibling files.
- No complexity gate → ceremony on trivial tasks (the #1 complaint about heavy skill libraries).
- Shipping a skill you never watched fail without — you don't know it prevents the right failure.

See `references/reference.md` for examples and reasoning, and `references/testing.md` for proving a skill actually changes behavior.
