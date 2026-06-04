# Augments

A collection of rigorous, phase-isolated SDLC skills to tether autonomous agents to real-world engineering standards.

Augments is a cross-platform library of **opt-in engineering skills** for coding agents, organized by the phases of the software development life cycle. It gives agents real engineering discipline while staying lean and leaving *you* in control of the process.

## Philosophy

- **Toolbox, not pipeline.** Every skill is a tool you reach for when you need it — never a gate that forces a sequence. The phase folders are a map for discovery, not a workflow you must walk. You own the process; the skills support it.
- **Earn every line.** A skill loads into context each time it fires, so it carries only what changes behavior; templates, examples, and rationale live in sibling files loaded on demand. Low token cost is a consequence of that discipline — not a goal that overrides correctness, so discipline skills keep what they need to hold the line under pressure.
- **Any harness, any model.** Skills refer to capability *tiers* (small / medium / large), never vendor model names, so they behave the same on Claude Code, Codex, Gemini CLI, Opencode, or Cursor.

The deeper rationale — why every skill is a *deterministic gate around a non-deterministic generator* — is in [`docs/philosophy.md`](docs/philosophy.md); when a phase is one skill versus several is in [`docs/skill-granularity.md`](docs/skill-granularity.md).

## The SDLC phases

Skills live under `skills/<phase>/<name>/`. The folders are unnumbered (they sort alphabetically on disk); the canonical order is:

1. **planning** — feasibility, scope, and goals → a project brief
2. **analysis** — the detailed requirements: what the software must do → a spec
3. **design** — architecture, interfaces, and the build plan
4. **implementation** — build it
5. **testing** — does it work, and is it good?
6. **deployment** — ship it
7. **maintenance** — debug and evolve after ship

Plus **common** — phase-agnostic and meta skills (authoring skills, communication, handoff).

A skill is invoked as `augments:<name>` regardless of which phase folder holds it — the phase is organization for humans, not part of the address.

## Available skills

| Phase | Skill | What it does |
| ----- | ----- | ------------ |
| common | `using-augments` | Start here — the mental model behind the library and the map of which skill to reach for when |
| common | `writing-skills` | The lean format every skill follows, and how to prove a skill actually works |
| planning | `define-goals` | At project kickoff — pin the objective and measurable success criteria into the project brief |
| planning | `scope-it` | Draw the boundary — what's in, what's explicitly out, the MVP cut |
| planning | `feasibility-check` | Before committing — surface the killer risks and a go / no-go verdict |
| analysis | `spec-it` | Turn a goal or feature into a requirements spec — testable requirements, acceptance criteria, edge cases |
| common | `interview-me` | Cross-cutting — grills an unclear request, plan, or design into a short alignment brief, in any phase |
| common | `prototyping` | Answer one uncertain design or feasibility question with a throwaway spike, then delete it |
| common | `zoom-out` | Before changing unfamiliar code, go up a layer and map the relevant modules and their callers in the project's own vocabulary |
| common | `handoff` | Write a durable, resumable handoff when a session ends — goal, state, decisions, gotchas, and the one concrete next step |
| common | `caveman` | Ultra-compressed output mode on request — drop filler, keep every technical fact, code block, and error exact; persists until stopped |
| design | `system-architecture` | Design how a non-trivial system is structured — components, boundaries, data flow, and testable seams |
| design | `data-model` | Design the entities, relationships, and invariants the system stores — before the code that moves them |
| design | `ui-ux` | Design the user flows, layout, and unhappy states as scenarios with acceptance criteria — before building the interface |
| design | `coding-standards` | Set the project's conventions and domain vocabulary so all contributors write code like one author |
| design | `architecture-decisions` | Record significant, hard-to-reverse choices as ADRs — options weighed, decision, why the alternatives were rejected |
| design | `writing-plans` | Turns intent into a durable plan: a one-page map plus thin per-task contracts, each with its own acceptance check |
| implementation | `test-driven-development` | Red-green-refactor as a discipline that holds under pressure, with test-craft and mocking references |
| implementation | `executing-plans` | Runs a plan to done one task at a time, gating each on its Evaluator and the index, with optional subagent dispatch |
| testing | `verifying-completion` | Evidence before claims — run the check and read its output before saying complete/fixed/passing; catches hollow verifications |
| testing | `requesting-code-review` | Dispatch an independent, diff-scoped reviewer — checks convention-conformance and whether the change does what was asked, with a clear merge verdict |
| testing | `receiving-code-review` | The author's side of review — verify each finding against the code before acting, push back with evidence, refuse performative agreement |
| testing | `security-audits` | Review a change for security holes by tracing attacker-controlled input source-to-sink — authz, injection, secrets, data exposure, weakened guards |
| deployment | `finishing-a-branch` | Take a working branch to merge-ready — green-check gate, clean commits, a real PR description, and a clear merge / keep / discard decision |
| deployment | `release-readiness` | A portable pre-deploy gate — CI green, migrations reversible, rollback named, flags set, changelog, breaking changes flagged; defers the deploy command to your environment |
| maintenance | `debugging` | Root cause before fix — build a runnable reproduction, test ranked hypotheses, fix the cause; stop and rethink architecture after three failed fixes |
| maintenance | `refactor-architecture` | Improve an existing codebase's structure — deep modules, real seams — via targeted, leverage-first refactors |

Every SDLC phase now ships at least one skill; a few cross-cutting `common/` tools (`caveman`, `handoff`, `zoom-out`) remain scaffolded and are filled in as needed.

## Status

Early and growing. All seven SDLC phases — planning, analysis, design, implementation, testing, deployment, and maintenance — now ship at least one working skill, alongside the `common` skills (orientation, skill-authoring, prototyping, and the cross-cutting `interview-me`). The repo ships a Claude Code plugin manifest (`.claude-plugin/`); adapters for other harnesses are scaffolded under `.codex-plugin/` and `.cursor-plugin/`. Install through your harness's plugin or marketplace mechanism, then invoke skills by name.

## Acknowledgements

This ADK draws on prior art and ongoing work from across the
multi-agent ecosystem:

- [**Superpowers**](https://github.com/obra/superpowers) —
  A complete software development methodology for coding agents.
- [**Matt Pocock skills**](https://github.com/mattpocock/skills) —
  Agent skills for real engineering.
