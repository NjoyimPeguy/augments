# tests/

Two kinds of test live here, split by what they can guarantee.

## 1. Structural — deterministic, portable, CI-gated

`validate-skills.sh` checks the shape of every skill: frontmatter present, `name` matches the directory, description ≤ 1024 chars, body line limits, and — recursively, across each skill's `references/` and `scripts/` subfolders — no external references, vendor model names, scanner trigger-words, or bare `<angle>` placeholders. It also checks that no skill name shadows a common built-in slash command, that the manifests list every skill on disk, and that the manifest versions agree. It inspects files, asks nothing of any model, and exits non-zero on any violation — so it runs in CI on every push and PR.

`token-budget.sh` reports the approximate context cost (chars/4) of the always-loaded surface — every `SKILL.md` body plus the SessionStart nudge — so "earn every line" is a number you can watch. Report-only; `--max N` flags any body over N approx-tokens.

## 2. Per-harness real activation — runnable, not portable, not CI

The skills are portable Markdown, but **whether one actually activates is a fact about a specific harness** — so each harness earns its own real test layer under `tests/harness/<adapter>/`. Today only **Claude Code** is wired (`tests/harness/claude-code/`); other harnesses each get their own folder when they're added and proven.

`tests/harness/claude-code/` drives the real `claude` CLI headless against the working tree and observes whether a skill **actually fires** — a structured `Skill` tool_use parsed from `--output-format stream-json`, never a prose grep or a self-report. See its README for the runners (`run-activation.sh`, `run-flow.sh`), the scenario convention, `--working-tree`, `--verbose`, and the offline detection `selftest`.

Two kinds of check live under the harness:

- **Activation** — does the right skill fire on a representative opening? (scenarios + runners)
- **Discipline-pressure** (`behavioral/`) — once invoked, does the discipline hold under pressure to cut a corner? (dated records of pressure tests)

**Why these can't be the portable gate, and the honest cost.** A real "did it fire" test must drive one specific CLI, pass its flags, and make a real API call — it binds to a harness and is neither free nor deterministic. So it's a runnable tool you re-run for current truth, **not** a CI pass/fail and **not** a committed results log. And because real runs cost, coverage is **selective** — the scenarios exercise the skills that matter most, not all of them every time. Name what isn't covered rather than imply everything is.

## Adding a test, and adding a harness

- **A new activation scenario:** drop a file under `tests/harness/<adapter>/scenarios/<phase>/`. The **filename is the contract** — name it after the skill it should trigger; any other name (a filler, a negative) expects nothing to fire. List it in the phase's `flow` file to include it in a multi-turn run. No code change. (Mechanics in the adapter's own README.)
- **A new harness:** create `tests/harness/<name>/` with a runner that drives that harness's CLI and detects activation its way, plus scenarios. The adapter stays **unproven** until its tests pass on it, and `docs/augments/harness-support.md` must say so — files on disk are not a working integration.

This is the testing face of `docs/augments/philosophy.md`: an instruction only shifts a probability, so a skill's effect is **measured** on a real harness, not assumed — and the deterministic guarantee that stays portable is the structural gate above.
