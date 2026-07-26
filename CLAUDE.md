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
5. **Run the gate, and prove behaviour-shaping changes** (see *Verify against the gate*) — by *re-running* the tests, and reporting what they actually returned.
6. **Identify yourself** (see *Contributing*) and **show the human the complete diff** for explicit approval before submitting.

If any check fails, do not open the PR. Explain why it would be rejected and what would have to change first.

## Authoring rules (non-negotiable)

Files under `skills/` and `docs/` ship to users. They must be self-contained, portable engineering guidance.

1. **No external references.** Do not name other repositories, projects, articles, or authors, and do not cite issue/PR numbers or tracker links. State the principle directly ("a monolithic plan is re-read on every compaction") — never attribute it. Provenance belongs in private notes, not a shipped skill.
2. **Model- and harness-agnostic.** Refer to models by capability tier — `small | medium | large` — never vendor names (haiku, sonnet, gpt, gemini, …). Don't assume a specific harness's tooling or paths. Each harness binds tier → model and action → command.
3. **Lean format.** Every skill follows `skills/common/writing-skills`: a thin `SKILL.md` (≤ ~80 lines), a trigger-style `description`, progressive disclosure to sibling files, a complexity gate, and `{{double-curly}}` placeholders. Discipline skills (those that hold an agent to a discipline under pressure) are the one exception to the line limit — that skill explains why.
4. **Prove behavior-shaping changes.** A new or edited skill is not done until you have watched it work — see `skills/common/writing-skills/references/testing.md`.

## Verify against the gate

Rules 1–3 are not honor-system. `scripts/sh/validate-skills.sh` enforces them deterministically — frontmatter shape, line budgets, no external references, no vendor model names, and that every skill is registered in the plugin manifests — and CI (`.github/workflows/`) runs it on every push and PR. Run it before you commit:

```bash
bash scripts/sh/validate-skills.sh
```

Rule 4 (behavior) has no deterministic gate — that is the honest limit. Prove it by **re-running the tests and reading what they return**:

- **Activation** — does the right skill fire? `tests/<adapter>/run-activation.sh --scenario-file <phase>/<skill>` for one scenario, `run-all-activation.sh` for the whole set. The exit code is the verdict.
- **Behaviour** — does the skill change what actually gets *built*? `tests/<adapter>/run-behavioral.sh --scenario <name> --arm red|green`. The scenario's own `scenario_assert` returns the verdict as an exit code. A scenario is one file: `tests/scenarios/behavioral/<name>.sh`.

Report the real numbers in the PR, including an inconclusive or failing result — these tests are live and non-deterministic, so a single green run is weak evidence. Say how many runs you did. Never green-wash.

## Adding a skill

1. Pick the phase folder (`planning … maintenance`) or `common/`.
2. Copy `skills/common/writing-skills/references/skill-template.md` and fill it in.
3. Keep `SKILL.md` lean; push templates, examples, and rationale to sibling files.
4. Verify before done: line count, lint-clean Markdown, no external or vendor references.

## Editing a skill

Changing a skill is changing behaviour, so match the proof to the change:

- **Description (the trigger):** an *activation* change — re-run `tests/<adapter>/run-activation.sh` on that skill's scenario and confirm it still fires.
- **The always-loaded `SKILL.md` body:** a *behaviour* change — re-run `tests/<adapter>/run-behavioral.sh` on a scenario that exercises it, both arms, and report the result.
- **A sibling or reference file** (loaded on demand, not under pressure): the always-loaded body is unchanged — no behavioural re-run is owed; say so.
- Never reword carefully-tuned discipline content — rationalization tables, red-flag lists, hard-stops — without re-proving it still holds. An inconclusive result *is* the finding; report it.

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
- **Speculative or fabricated content** — a problem no one actually hit, or invented test results. An inconclusive result is a valid finding; a fabricated one is not.
- **"Compliance" reformatting of tuned skills** — restructuring or rewording a discipline's red-flag lists, rationalization tables, or hard-stops without a re-proven pressure test (*Editing a skill*).
- **Third-party dependencies** — augments is zero-dependency by design. If a change needs an external tool or service, it belongs in a separate plugin. Adding a new harness is the exception.
- **Bundled or batch PRs** — one change per PR.

## New harness support

Adding a harness (an IDE, CLI, or agent runner) means more than dropping skill files where the tool can see them — they must actually *load and activate*. Augments' skills are inert unless the harness both discovers them and is nudged to reach for one at the right moment (on Claude Code, the `hooks/` SessionStart nudge; elsewhere, an equivalent). See `docs/augments/harness-support.md`.

A PR adding a harness MUST include a runnable test layer under `tests/<name>/` — a runner that drives that harness's CLI and shows a skill *actually activating* on a representative opening, not a description of how it should work. Files present but never invoked is not a working integration.

## Layout

- `skills/<phase>/<name>/` — the skills, by SDLC phase (canonical order is in `README.md`; folders are unnumbered).
- `.claude-plugin/` — the install manifest; its skills array must list every skill on disk (the gate checks it). `.kimi-plugin/` — the Kimi Code manifest; its skills paths must resolve to the same canonical set. Adding a harness: `docs/augments/harness-support.md`.
- `AGENTS.md`, `GEMINI.md` — symlinks to this file, so a harness that reads its own instructions file gets the same guidance from one source.
- `.github/` — CI (`workflows/validate.yml`) and the PR template (`PULL_REQUEST_TEMPLATE.md`).
- `tests/` — `gate/` is the portable deterministic gate CI runs on every push and PR (`validate-skills.sh`, the two plugin validators, `token-budget.sh`). `scenarios/` holds every test input **once**, shared by all harnesses: `activation/<phase>/<skill>` openings and `behavioral/<name>/` fixtures. `claude-code/`, `codex/`, `kimi-code/` hold only that harness's runners — the scenarios were byte-identical across all three, so they live in one place.
- `CHANGELOG.md`, `RELEASING.md` — the release record, and how releases are versioned and cut (semver over the skill surface; the gate checks the two manifest versions agree).
- `.claude/` — local config and notes; gitignored, never shipped.
