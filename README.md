# Augments

A collection of rigorous, phase-isolated SDLC skills to tether autonomous agents to real-world engineering standards.

Augments is a cross-platform library of **opt-in engineering skills** for coding agents, organized by the phases of the software development life cycle. It gives agents real engineering discipline while staying lean and leaving *you* in control of the process.

## Philosophy

- **Toolbox, not pipeline.** The skills are tools you reach for when they apply — the phase folders are a map for discovery, not a sequence you must walk in order. What is *not* optional is reaching for the one that fits: skipping a skill that applies is the mistake the library exists to prevent. You own the path; the routing keeps you from walking past the tool you needed.
- **Earn every line.** A skill loads into context each time it fires, so it carries only what changes behavior; templates, examples, and rationale live in sibling files loaded on demand. Low token cost is a consequence of that discipline — not a goal that overrides correctness, so discipline skills keep what they need to hold the line under pressure.
- **Any harness, any model.** Skills refer to capability *tiers* (small / medium / large), never vendor model names, and assume no specific harness's tooling — so the same skill behaves the same wherever it is loaded. Claude Code, Codex CLI, and Kimi Code CLI all have adapter tests; behavioral pressure records are still added per harness.
- **Alongside intelligence, not in its way.** A skill adds the one thing a model cannot supply — a deterministic verdict on its own work — and otherwise defers to the model's judgment. As models grow more capable, skills and intelligence are meant to work together, never to impede each other: every skill states when to *skip* it, so ceremony scales down as capability scales up.

The deeper rationale — why every skill is a *deterministic gate around a non-deterministic generator* — is in [`docs/augments/philosophy.md`](docs/augments/philosophy.md); when a phase is one skill versus several is in [`docs/augments/skill-granularity.md`](docs/augments/skill-granularity.md).

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
| common | `using-task-branches` | Start repo edits on a meaningful task branch or harness workspace, using a worktree only when the user/project prefers it or runtime isolation requires it |
| common | `dispatching-parallel-agents` | Fan out two or more pieces of work that don't touch the same files to concurrent agents — scope each, isolate state, then reconcile with a combined check |
| design | `system-architecture` | Design how a non-trivial system is structured — components, boundaries, data flow, and testable seams |
| design | `data-model` | Design the entities, relationships, and invariants the system stores — before the code that moves them |
| design | `ui-ux-design` | Design user flows, visual direction, layout, unhappy states, and evidence-backed interface alternatives before implementation |
| design | `coding-standards` | Set the project's conventions and domain vocabulary so all contributors write code like one author |
| design | `architecture-decisions` | Record significant, hard-to-reverse choices as ADRs — options weighed, decision, why the alternatives were rejected |
| design | `writing-plans` | Turns intent into a durable plan: a one-page map plus thin per-task contracts, each with its own acceptance check |
| implementation | `test-driven-development` | Red-green-refactor as a discipline that holds under pressure, with test-craft and mocking references |
| implementation | `yagni` | Build only what's needed and make it work — guards over-engineering and its opposite, laziness dressed as simplicity (stubs, TODOs, wrong-place diffs); "needed" means it solves the task and runs |
| implementation | `executing-plans` | Runs a plan to done one task at a time, gating each on its Evaluator and the index, with optional subagent dispatch |
| testing | `verifying-completion` | Evidence before claims — run the check and read its output before saying complete/fixed/passing; catches hollow verifications |
| testing | `requesting-code-review` | Dispatch an independent, diff-scoped reviewer — checks convention-conformance and whether the change does what was asked, with a clear merge verdict |
| testing | `receiving-code-review` | The author's side of review — verify each finding against the code before acting, push back with evidence, refuse performative agreement |
| testing | `security-audits` | Review a change for security holes by tracing attacker-controlled input source-to-sink — authz, injection, secrets, data exposure, weakened guards |
| deployment | `finishing-a-branch` | Take a working branch to merge-ready — green-check gate, clean commits, a real PR description, and a clear merge / keep / discard decision |
| deployment | `release-readiness` | A portable pre-deploy gate — CI green, migrations reversible, rollback named, flags set, changelog, breaking changes flagged; defers the deploy command to your environment |
| maintenance | `debugging` | Root cause before fix — build a runnable reproduction, test ranked hypotheses, fix the cause; stop and rethink architecture after three failed fixes |
| maintenance | `post-mortem` | After a failure escapes or is caught late — find why the *process* let it through (which gate was missing) and convert it into a structural fix; starts where `debugging` ends |
| maintenance | `refactor-architecture` | Improve an existing codebase's structure — deep modules, real seams — via targeted, leverage-first refactors |

Every SDLC phase ships at least one skill, alongside the cross-cutting `common/` tools.

## Status

Early and growing. All seven SDLC phases — planning, analysis, design, implementation, testing, deployment, and maintenance — now ship at least one working skill, alongside the eight `common` skills (orientation, skill-authoring, and the cross-cutting tools: interviewing, prototyping, zoom-out, handoff, task branches, and parallel dispatch). The repo ships a Claude Code plugin (`.claude-plugin/`, with SessionStart and Stop nudges), a Codex plugin adapter (`plugins/augments/.codex-plugin/`, exposed through `.agents/plugins/marketplace.json`) with Codex project-hook files for the Stop nudge, and a Kimi Code plugin (`.kimi-plugin/`, with a session-start router and tool-binding instructions). `AGENTS.md` and `GEMINI.md` symlink to `CLAUDE.md` so a harness that reads its own instructions file gets the same guidance. Because the skills are portable Markdown invoked by name, other harnesses can adopt them — each proven by its own tests when added; see [`docs/augments/harness-support.md`](docs/augments/harness-support.md).

Install in Claude Code with `/plugin marketplace add NjoyimPeguy/augments` then `/plugin install augments@augments`. For local Codex development, register this checkout as a marketplace with `codex plugin marketplace add /path/to/augments`, then install `augments@augments-dev`. Install in Kimi Code with `/plugins install https://github.com/NjoyimPeguy/augments` (or the `/plugins` manager, Custom tab), then `/reload`.

## Proactive Skill Use

A coding agent treats an installed skill library as available-but-optional and walks past it unless you name a skill. So augments pairs each adapter with the strongest honest routing support that harness can prove.

On Claude Code, augments ships a **SessionStart bootstrap** (`hooks/`) that injects a short pointer each session (re-applied on resume and after compaction): before any non-trivial work, invoke the `using-augments` skill to route to the one that fits. It also ships a Stop re-nudge at the done boundary. Skipping a skill that applies is treated as the mistake, not a shortcut.

On Codex, augments ships a plugin adapter, local marketplace metadata, and project-level Stop hook config (`.codex/hooks.json`, backed by `hooks/hooks-codex.json`). The skills install through Codex, durable repo guidance still comes through `AGENTS.md`, and the Codex harness test observes activation by watching the agent read the installed `SKILL.md` file from the plugin cache. Current Codex builds do not auto-install plugin hooks from the plugin manifest, so the Codex hook is project-level rather than plugin-level.

On Kimi Code, augments ships a plugin manifest (`.kimi-plugin/plugin.json`) whose `sessionStart.skill` loads the `using-augments` router into every new and resumed session, whose `skillInstructions` bind the skills' tool language to Kimi's real tools whenever a plugin skill loads, and whose declared Stop hook re-nudges at the done boundary (`hooks/stop-nudge-kimi.sh`, sharing its detection policy with the other harnesses). The manifest points at the canonical phase directories directly — no mirror. The known gap: the session-start nudge does not survive mid-session compaction (see `tests/README.md`).

The routing is **non-negotiable by default, not a gentle suggestion** where a harness supports it. The discipline behind it — the rationalizations named as signals to check rather than skip, the red-flags, the procedure — lives in the `using-augments` skill; the shared bootstrap text is a one-line pointer to it (`hooks/context.md`), so tune it to taste. See [`docs/augments/activation.md`](docs/augments/activation.md) for how routing (firm persuasion) and enforcement (deterministic gates) fit together. Harness hooks are adapter-specific; the skills themselves stay portable Markdown.

## Acknowledgements

This library draws on prior art and ongoing work from across the
multi-agent ecosystem:

- [**Superpowers**](https://github.com/obra/superpowers) —
  A complete software development methodology for coding agents.
- [**Matt Pocock skills**](https://github.com/mattpocock/skills) —
  Agent skills for real engineering.
- [**Ponytail**](https://github.com/DietrichGebert/ponytail) —
  The "laziest senior dev" discipline that inspired the `yagni` skill.
