# CLAUDE.md

Guidance for anyone — human or agent — working in this repository.

`augments` is a cross-platform library of opt-in SDLC skills for coding agents. Read `README.md` for the philosophy, and `skills/common/writing-skills/SKILL.md` before authoring or editing any skill. The one idea behind every skill: you are a non-deterministic generator, and each skill wraps your work in a deterministic **gate** — truth comes from the gate (a test, a check, a reproduction), never from confidence. The library's reliability lives in its gates, not in coercive instructions; keep that distinction when you edit it.

## If you are an AI agent

Stop and read this before you change anything. Most low-quality contributions to a public skills library come from agents that skimmed the guidelines and opened a pull request anyway — and a weak PR does not help the human you're working with. It costs a reviewer's time, spends that human's credibility, and gets closed regardless. "I followed the rules" is not the same as following them: the only thing that counts is whether the diff meets the bar below.

Before you open a PR here, you MUST:

1. **Read the PR template** (`.github/PULL_REQUEST_TEMPLATE.md`) and fill every section with specific, true answers — not placeholders, not a summary of what you *would* do.
2. **Search PRs and issues — open *and* closed — for the same problem.** If it already exists or was already rejected, stop and tell the human you're working with; don't open a duplicate. If a prior attempt was closed, say what is different here.
3. **Confirm it is a real problem you actually hit.** Told to "contribute something" or "fix some issues" with no concrete failure behind it? Push back and ask what broke. Speculative fixes are rejected.
4. **Confirm it belongs in core** — general-purpose SDLC guidance, not domain-, tool-, or workflow-specific (see *What belongs here*).
5. **Run the gate, and prove behaviour-shaping changes** (see *Verify against the gate*). A skill change without a dated record under `tests/` will be closed.
6. **Identify yourself** (see *Contributing*) and **show the human the complete diff** for explicit approval before submitting.

If any check fails, do not open the PR. Explain why it would be rejected and what would have to change first.

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

Rule 4 (behavior) has no deterministic gate — that is the honest limit. Prove **activation** by running your adapter's harness (`tests/harness/claude-code/` drives the real CLI and observes whether the skill fires); prove a **discipline holds** with a pressure test (`testing.md`), recorded under `tests/harness/<adapter>/behavioral/`. A record states the real outcome, including an inconclusive one — never green-wash.

## Adding a skill

1. Pick the phase folder (`planning … maintenance`) or `common/`.
2. Copy `skills/common/writing-skills/skill-template.md` and fill it in.
3. Keep `SKILL.md` lean; push templates, examples, and rationale to sibling files.
4. Verify before done: line count, lint-clean Markdown, no external or vendor references.

## Editing a skill

Changing a skill is changing behaviour, so match the proof to the change:

- **Description (the trigger):** an *activation* change — re-measure with your adapter's harness (`tests/harness/claude-code/run-activation.sh`) and confirm the skill still fires on its scenario.
- **The always-loaded `SKILL.md` body of a discipline skill:** re-run the pressure test (`testing.md`) and update `tests/harness/claude-code/behavioral/<skill>.md`.
- **A sibling or reference file** (loaded on demand, not under pressure): the discipline body is unchanged — no behavioural re-run is owed; say so in the record.
- Never reword carefully-tuned discipline content — rationalization tables, red-flag lists, hard-stops — without re-proving it still holds. And never green-wash a record: an inconclusive result *is* the finding.

## What belongs here

Core augments skills are **general-purpose SDLC guidance** — useful across projects, languages, and domains. A skill that only helps one domain, tool, team, or workflow does not belong in core; keep it in your own skill library. The test: would this help someone on a completely different kind of project? If not, it ships elsewhere. When a phase's activities are separable vs. one interleaved pass, see `docs/augments/skill-granularity.md`.

## Contributing

- **Solve a real problem you actually hit** — not a speculative or theoretical one. "My review agent flagged it" or "this could theoretically break" is not a problem statement.
- **One change per PR.** Don't bundle unrelated edits or batch-fix the tracker — pick one problem, understand it, submit focused work.
- **Run the gate, and prove behaviour-shaping changes,** before opening a PR (see *Verify against the gate*). A human reviews the full diff first.
- **Identify yourself.** Disclose in the PR the model, harness, harness version, and any installed plugins that produced the change — or state plainly it was written by hand. Contributions are weighed by how they were made: a behaviour claim reasoned from documentation is held to a different bar than one grounded in a real session. Hiding the authoring environment is grounds for closing the PR.
- **Target `dev`, not `main`.** `main` is the released branch; active work lands on `dev` first. A PR against `main` will be asked to retarget.
- **Never bump versions or edit CHANGELOG version headings in a PR.** Releases are versioned once, by the maintainer — see `RELEASING.md`.
- The bar is the gate and the evidence, not volume or confidence. "No skill is needed here" is a valid, useful outcome.

## What won't be accepted

Closed without extended review — most are the inverse of a rule above:

- **External references, vendor model names, or harness assumptions in shipped files** — Authoring rules 1–2.
- **Domain-, tool-, or workflow-specific skills** — *What belongs here*; publish them as your own library.
- **Speculative or fabricated content** — a problem no one actually hit, invented results, or a green-washed record. An inconclusive result is a valid finding; a fabricated one is not.
- **"Compliance" reformatting of tuned skills** — restructuring or rewording a discipline's red-flag lists, rationalization tables, or hard-stops without a re-proven pressure test (*Editing a skill*).
- **Third-party dependencies** — augments is zero-dependency by design. If a change needs an external tool or service, it belongs in a separate plugin. Adding a new harness is the exception.
- **Bundled or batch PRs** — one change per PR.

## New harness support

Adding a harness (an IDE, CLI, or agent runner) means more than dropping skill files where the tool can see them — they must actually *load and activate*. Augments' skills are inert unless the harness both discovers them and is nudged to reach for one at the right moment (on Claude Code, the `hooks/` SessionStart nudge; elsewhere, an equivalent). See `docs/augments/harness-support.md`.

A PR adding a harness MUST include a runnable test layer under `tests/harness/<name>/` — a runner that drives that harness's CLI and shows a skill *actually activating* on a representative opening, not a description of how it should work. Files present but never invoked is not a working integration.

## Layout

- `skills/<phase>/<name>/` — the skills, by SDLC phase (canonical order is in `README.md`; folders are unnumbered).
- `.claude-plugin/` — the install manifest; its skills array must list every skill on disk (the gate checks it). Adding a harness: `docs/augments/harness-support.md`.
- `AGENTS.md`, `GEMINI.md` — symlinks to this file, so a harness that reads its own instructions file gets the same guidance from one source.
- `.github/` — CI (`workflows/validate.yml`) and the PR template (`PULL_REQUEST_TEMPLATE.md`).
- `tests/` — the portable gate (`validate-skills.sh`, `validate-codex-plugin.sh`, `token-budget.sh`) plus `harness/<adapter>/` — per-harness **runnable** tests. Claude Code has live activation tests and `behavioral/` discipline-pressure records; Codex CLI has marketplace/install smoke coverage and a live activation scenario.
- `governance/` — adoptable **deterministic-gate** templates (CI workflows, branch-protection, pre-commit) that make the production-critical skills non-skippable at the commit/PR/CI boundary, where firm persuasion can't. Each gate maps to the skill it enforces, labelled bulletproof vs heuristic.
- `CHANGELOG.md`, `RELEASING.md` — the release record, and how releases are versioned and cut (semver over the skill surface; the gate checks the two manifest versions agree).
- `.claude/` — local config and notes; gitignored, never shipped.
