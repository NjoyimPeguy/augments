---
name: interview-me
description: Use whenever a request, plan, or design is unclear or underspecified — in any phase, before you build on it. Grills you one question at a time, answering from the codebase first and asking only what it genuinely cannot determine, then writes a short alignment brief. Skip for trivial or already-precise requests.
---

# Interview Me

Close the gap between what was asked and what is actually wanted — *before* you build on it. A cross-cutting clarification technique: grill a goal, a requirement, or a plan — the method is the same. The cheapest bug to fix is the one never built.

## When to use

- A request is vague ("add auth", "make it faster") or has more than one reasonable reading.
- Assumptions are piling up before a plan or feature.
- **Skip** when the task is trivial or already fully specified — interrogating wastes turns.

## Procedure

**1. Scan before you ask.** Read the request, then explore the codebase and context for what is already decided: conventions, similar features, libraries in use, naming. Never ask what the code already answers.

**2. Ask ONE question at a time.** For each open decision, in one short message:
- state what you found ("you already use Zod for validation"),
- name the decision,
- recommend a default with one line of reasoning.

Prefer yes/no or a small multiple choice. Wait for the answer before the next question.

**3. Use each answer to prune.** An answer often settles later questions — drop them. Aim for ~3–6 questions total. If you need more, say why first.

**4. Stop when another question would not change the outcome** — or when the user says go. Do not gold-plate the interview.

**5. Write a short alignment brief** (not a spec): goal, decisions + rationale, explicit non-goals, open risks. Keep it tight — see `brief-template.md`. Save it to the project's briefs location (default `.augments/briefs/{{YYYY-MM-DD}}-{{topic}}.md`), or inline if tiny.

**6. Offer, do not force, the next step:** "Turn this into a plan?" → `writing-plans`.

## Common mistakes

- Asking what a 30-second code search would answer.
- Dumping many questions at once instead of adapting to answers.
- Producing a heavy spec — the brief is a short paragraph plus a few bullets.
- Interviewing trivial tasks.
