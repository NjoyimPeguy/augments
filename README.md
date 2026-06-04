# Augments

A collection of rigorous, phase-isolated SDLC skills to tether autonomous agents to real-world engineering standards.

Augments is a cross-platform library of **opt-in engineering skills** for coding agents, organized by the phases of the software development life cycle. It gives agents real engineering discipline while staying lean and leaving *you* in control of the process.

## Philosophy

- **Toolbox, not pipeline.** Every skill is a tool you reach for when you need it — never a gate that forces a sequence. The phase folders are a map for discovery, not a workflow you must walk. You own the process; the skills support it.
- **Earn every line.** A skill loads into context each time it fires, so it carries only what changes behavior; templates, examples, and rationale live in sibling files loaded on demand. Low token cost is a consequence of that discipline — not a goal that overrides correctness, so discipline skills keep what they need to hold the line under pressure.
- **Any harness, any model.** Skills refer to capability *tiers* (small / medium / large), never vendor model names, so they behave the same on Claude Code, Codex, Gemini CLI, Opencode, or Cursor.

## The SDLC phases

Skills live under `skills/<phase>/<name>/`. The folders are unnumbered (they sort alphabetically on disk); the canonical order is:

1. **planning** — scope, requirements, work breakdown
2. **analysis** — understand the problem and the existing system
3. **design** — architecture and interfaces, before code
4. **implementation** — build it
5. **testing** — does it work, and is it good?
6. **deployment** — ship it
7. **maintenance** — debug and evolve after ship

Plus **common** — phase-agnostic and meta skills (authoring skills, communication, handoff).

A skill is invoked as `augments:<name>` regardless of which phase folder holds it — the phase is organization for humans, not part of the address.

## Available skills

| Phase | Skill | What it does |
| ----- | ----- | ------------ |
| common | `writing-skills` | The lean format every skill follows, and how to prove a skill actually works |
| planning | `interview-me` | Grills you one question at a time — answering from the codebase first — then writes a short alignment brief |
| planning | `writing-plans` | Turns intent into a durable plan: a one-page map plus thin per-task contracts, each with its own acceptance check |
| implementation | `test-driven-development` | Red-green-refactor as a discipline that holds under pressure, with test-craft and mocking references |

The remaining phases are scaffolded and filled in incrementally.

## Status

Early and growing. The planning phase and the skill-authoring meta-skill are usable today; analysis, design, implementation, testing, deployment, and maintenance are scaffolded. The repo ships a Claude Code plugin manifest (`.claude-plugin/`); adapters for other harnesses are scaffolded under `.codex-plugin/` and `.cursor-plugin/`. Install through your harness's plugin or marketplace mechanism, then invoke skills by name.

## Acknowledgements

This ADK draws on prior art and ongoing work from across the
multi-agent ecosystem:

- [**Superpowers**](https://github.com/obra/superpowers) —
  A complete software development methodology for coding agents.
- [**Matt Pocock skills**](https://github.com/mattpocock/skills) —
  Agent skills for real engineering.
