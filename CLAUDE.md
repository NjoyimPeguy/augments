# CLAUDE.md

Guidance for anyone — human or agent — working in this repository.

`augments` is a cross-platform library of opt-in SDLC skills for coding agents. Read `README.md` for the philosophy, and `skills/common/writing-skills/SKILL.md` before authoring or editing any skill. The one idea behind every skill: you are a non-deterministic generator, and each skill wraps your work in a deterministic **gate** — truth comes from the gate (a test, a check, a reproduction), never from confidence. The library's reliability lives in its gates, not in coercive instructions; keep that distinction when you edit it.

## Authoring rules (non-negotiable)

Files under `skills/` and `docs/` ship to users. They must be self-contained, portable engineering guidance.

1. **No external references.** Do not name other repositories, projects, articles, or authors, and do not cite issue/PR numbers or tracker links. State the principle directly ("a monolithic plan is re-read on every compaction") — never attribute it. Provenance belongs in private notes, not a shipped skill.
2. **Model- and harness-agnostic.** Refer to models by capability tier — `small | medium | large` — never vendor names (haiku, sonnet, gpt, gemini, …). Don't assume a specific harness's tooling or paths. Each harness binds tier → model and action → command.
3. **Lean format.** Every skill follows `skills/common/writing-skills`: a thin `SKILL.md` (≤ ~80 lines), a trigger-style `description`, progressive disclosure to sibling files, a complexity gate, and `{{double-curly}}` placeholders. Discipline skills (those that hold an agent to a discipline under pressure) are the one exception to the line limit — that skill explains why.
4. **Prove behavior-shaping changes.** A new or edited skill is not done until you have watched it work — see `skills/common/writing-skills/testing.md`.

## Verify against the gate

Rules 1–3 are not honor-system. `tests/validate-skills.sh` enforces them deterministically — frontmatter shape, line budgets, no external references, no vendor model names, and that every skill is registered in the plugin manifests — and CI (`.github/workflows/`) runs it on every push and PR. Run it before you commit:

```bash
bash tests/validate-skills.sh
```

Rule 4 (behavior) has no deterministic gate — that is the honest limit. Prove it with a pressure test (`testing.md`) and record the dated result under `tests/` (`triggering/` for activation, `behavioral/` for discipline-under-pressure). A record states the real outcome, including an inconclusive one — never green-wash.

## Adding a skill

1. Pick the phase folder (`planning … maintenance`) or `common/`.
2. Copy `skills/common/writing-skills/skill-template.md` and fill it in.
3. Keep `SKILL.md` lean; push templates, examples, and rationale to sibling files.
4. Verify before done: line count, lint-clean Markdown, no external or vendor references.

## What belongs here

Core augments skills are **general-purpose SDLC guidance** — useful across projects, languages, and domains. A skill that only helps one domain, tool, team, or workflow does not belong in core; keep it in your own skill library. The test: would this help someone on a completely different kind of project? If not, it ships elsewhere. When a phase's activities are separable vs. one interleaved pass, see `docs/augments/skill-granularity.md`.

## Contributing

- Solve a real problem you actually hit — not a speculative or theoretical one.
- One change per PR; don't bundle unrelated edits or batch-fix the tracker.
- Run the gate above, and for behavior-shaping changes prove it, before opening a PR. A human reviews the full diff first.
- If a change is agent-generated, say so and on which harness — behavior claims reasoned from documentation are weighed differently from those grounded in a real session.
- The bar is the gate and the evidence, not volume or confidence. "No skill is needed here" is a valid, useful outcome.

## Layout

- `skills/<phase>/<name>/` — the skills, by SDLC phase (canonical order is in `README.md`; folders are unnumbered).
- `.claude-plugin/`, `.codex-plugin/` — per-harness install manifests; their skills arrays must stay in sync (the gate checks `.claude-plugin/`). Adding a harness: `docs/augments/harness-support.md`.
- `AGENTS.md`, `GEMINI.md` — symlinks to this file, so a harness that reads its own instructions file gets the same guidance from one source.
- `tests/` — the gate (`validate-skills.sh`) plus dated triggering/behavioral records.
- `.claude/` — local config and notes; gitignored, never shipped.
