---
name: using-augments
description: Use to get oriented in the augments skill library — the mental model behind every skill, the map of what's available by SDLC phase, and which skill to reach for when. Read this when starting work in a repo that uses augments, or when unsure which skill fits.
---

# Using Augments

Augments is a toolbox of opt-in engineering skills, organized by the phases of the software development life cycle. This skill is the map — it points you to the right tool; it does no work itself.

## The mental model

You are a non-deterministic generator. These skills surround your work with **deterministic gates** — a test, a check, a reproduction. Truth comes from the gate, never from your confidence: **"done" means a check passed, not that you believe it's done.** That one idea is what makes every skill below cohere. The full rationale is in `docs/philosophy.md`.

These are tools, not a pipeline: reach for the one that fits the moment; there is no sequence you must walk. The disciplines enforce themselves through their own gates, not through ceremony.

## The map

Reach for a skill when its trigger fits.

Whenever a request, plan, or design is unclear, `interview-me` grills it into a short alignment brief — in any phase. When a question is faster to build than to argue, `prototyping` answers it with a throwaway spike, then deletes it.

**Planning** (a new project or initiative)

- `define-goals` — pin the objective and measurable success criteria.
- `scope-it` — draw the boundary: what's in, what's explicitly out, the MVP cut.
- `feasibility-check` — before committing, surface the killer risks and a go/no-go.

**Analysis**

- `spec-it` — turn a goal or feature into a requirements spec: testable requirements + acceptance criteria.

**Design**

- `system-architecture` — a non-trivial system needs structuring before it's built: components, boundaries, data flow, seams.
- `data-model` — persistent data: entities, relationships, invariants.
- `ui-ux` — a user-facing interface: flows, layout, unhappy states.
- `coding-standards` — set the project's conventions and domain vocabulary.
- `architecture-decisions` — record a significant, hard-to-reverse choice as an ADR.
- `writing-plans` — a clear multi-step task; turn it into a durable map plus thin per-task contracts, each with its own check.

**Implementation**

- `test-driven-development` — building any feature or bugfix with real logic; the test comes first, and you watch it fail.
- `executing-plans` — you have a plan directory; run it one task at a time, gating each on its Evaluator.

**Testing**

- `verifying-completion` — before claiming anything is complete, fixed, or passing; run the check and read the output.
- `requesting-code-review` — a finished change needs fresh eyes before merge; dispatch a diff-scoped reviewer for standards + spec.
- `receiving-code-review` — review feedback has arrived; verify each finding against the code before acting, and push back with evidence rather than caving.
- `security-audits` — a change touches a trust boundary; trace attacker-controlled input source-to-sink for security holes.

**Maintenance**

- `debugging` — any bug or unexpected behavior; build a reproduction and find the root cause before touching a fix.
- `refactor-architecture` — an existing codebase has structural friction; improve module depth and locality with targeted refactors.

**Authoring**

- `writing-skills` — creating or editing a skill in this library.

## How they compose

The skills hand off to one another: `interview-me` → `writing-plans` → `executing-plans`; `debugging` turns its reproduction into a `test-driven-development` cycle; and `verifying-completion` is the gate the others assume — it runs the Evaluator a plan defined, and confirms a debugged fix actually holds.
