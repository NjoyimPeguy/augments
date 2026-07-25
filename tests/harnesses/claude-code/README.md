# tests/harnesses/claude-code/ — real activation tooling

The real activation layer for the Claude Code adapter. `run-activation.sh`
drives the actual `claude` CLI headless against the working tree and observes
whether a skill **actually** activates — a structured `Skill` tool_use, parsed
from `--output-format stream-json`, not a prose grep and not a self-report.

## Why it lives here, not in the core gate

It binds to one harness (the `claude` binary) and makes a **real API call** — it
costs tokens and is not deterministic. So it is a manual/record tool, never CI
pass/fail. The portable structural gate (`validate-skills.sh`) stays free and
harness-agnostic; this adds the one thing it structurally can't: ground truth
for *this* adapter. See `../../README.md` and `../../../docs/augments/philosophy.md`.

## Scenarios live by filename, not inline

The two scripts are generic engines and carry **no** scenario text. Openings live
as named files under `scenarios/`, mirroring `skills/` — a folder per SDLC phase,
plus `common/` for cross-cutting skills. **The filename is the contract:**

```
scenarios/
  planning/                  # the planning phase
    define-goals           # name == a skill => expects augments:define-goals
    feasibility-check      #   "                          augments:feasibility-check
    scope-it               #   "                          augments:scope-it
    unrelated-dep-bump     # name is NOT a skill => expects NOTHING to fire
    flow                   # lists the above in order = the planning sequence
  common/
    dispatching-parallel-agents
```

A `flow` names its phase's scenario files in order; the engine runs them as one
resumed conversation and checks each turn against its filename. The expected
skill IS the filename when it matches a real skill; any other name (a filler, a
negative) expects nothing — no marker char. To change what a turn says, edit the
per-skill file; to add a skill to a phase, drop in a `<skill>` file and list it
in `flow`. No script edit, no inline text.

## Run it

```bash
# Whole planning phase (define-goals -> feasibility-check -> scope-it, + negative):
tests/harnesses/claude-code/run-flow.sh --flow scenarios/planning/_flow --keep
tests/harnesses/claude-code/run-flow.sh --flow scenarios/planning/_flow --print   # parse only, no API call

# A single cross-cutting skill:
tests/harnesses/claude-code/run-activation.sh \
  --scenario-file scenarios/common/dispatching-parallel-agents --keep
```

- Runs the nested session in an **isolated empty temp dir** — safe (writes can't
  reach this repo) and faithful (reproduces a brand-new-project opening). The
  user-level plugin and SessionStart hook apply regardless of cwd.
- `--fixture-git-repo` turns that temp dir into a disposable git repo on `main`
  when the scenario needs real branch/status context without touching this repo.
- Permission gates are **not** bypassed: an explicit allowlist (`Skill` +
  read-only) lets activation happen while denying any Write/Edit/Bash.
- `run-activation.sh` kills on the first real `Skill` tool_use (cost ≈ one turn);
  `run-flow.sh` runs each turn to completion so it can score the whole sequence.
- `--keep` writes the raw stream to `last-stream.jsonl` / `last-flow.jsonl`
  (gitignored scratch); copy to a dated `YYYY-MM-DD-<skill>-activation.jsonl` as
  evidence. `--no-augments` (run-activation) runs the auth-safe Skill-blocked arm.

## Working tree, the offline self-test, and the decay scenario

Three additions for the v2 activation work:

- **`--working-tree`** (both scripts) loads THIS repo via `claude --plugin-dir`
  instead of the installed release cache — so a run validates live edits to the
  nudge/hooks, not the last published version. Confirmed: with it, the session
  `init` lists only the repo path; the cached plugin is overridden.
- **`run-activation.sh selftest`** runs the jq detector over committed
  inline fixture streams (a fired case, a none case, a proceeded-by-acting case) and
  asserts the verdicts — a deterministic, no-API check of the detection logic
  itself, the one part that can be gated without a model.
- **`scenarios/decay/`** is the long-session reproduction: `_flow` runs
  filler turns (expect-none) to grow the context so the SessionStart nudge
  fades, then a debugging-shaped turn that fires FRESH. A MISS on that last turn
  reproduces "skills ignored in a long session"; if it still fires, headless
  `-p` resume isn't inducing decay (itself a finding). This is the regime the
  fresh-session records above never exercised. Run with `--working-tree`.

## Behavioural runs — `run-behavioral.sh`

Activation asks *did the skill fire?* — one generic verdict, hence one generic
engine. Behaviour asks *did the skill change what got **built**?*, which has no
generic verdict: success differs per skill. So the work is split — the runner
owns the plumbing, the scenario owns the verdict.

```bash
tests/harnesses/claude-code/run-behavioral.sh --scenario spec-it --arm green --keep
tests/harnesses/claude-code/run-behavioral.sh --scenario spec-it --arm red --base origin/dev
```

Scenarios are **shared across adapters** — they live in
`../../behavioral-scenarios/` and Codex CLI and Kimi Code have sibling
`run-behavioral.sh` scripts over the same directories. The fixture and probe are
harness-agnostic (a probe reads a finished workdir), so verdicts stay directly
comparable; only the opening may be overridden per adapter, and only for a
harness constraint. See `../../behavioral-scenarios/README.md`.

Two things it does that a hand-rolled run does not:

- **It materialises both arms.** `--arm red` builds a throwaway `git worktree` at
  `--base` (default `origin/dev`) and loads *those* skills, so the before-arm
  stays reproducible **after** the change is committed. Running RED by hand
  before editing works exactly once and can never be re-run.
- **The verdict is an exit code, not prose.** A record is written by the same
  agent that wants it to be green; `probe.sh` isn't. The `spec-it` probe checks
  that a new executable artifact exists, that it *loads* (an artifact that errors
  on import is not a criterion), and that it fails on missing behaviour rather
  than passing.

Unlike activation it needs write access, so `Write`/`Edit`/`Bash` are allowed and
edits auto-accepted — safe because every run happens in a disposable copy of the
fixture under `/tmp`, never in this repo. It costs roughly a full task per arm.
Reach for it when a skill's **body** changed; `run-activation.sh` still covers a
`description` change.

`probe.sh` is worth running offline against workdirs you already captured
(`bash ../../behavioral-scenarios/spec-it/probe.sh <dir>`) — that checks the probe
itself with no API call, the way `run-activation.sh selftest` checks the detector.

## Detection (and a bug worth remembering)

Verdict comes **only** from a `Skill` tool_use in an *assistant* event. A naive
grep of the raw stream reports phantom activations: the SessionStart nudge text
itself says "invoke `augments:using-augments`", and the init manifest lists every
skill — both contain `augments:` tokens that are not actions. The first cut of
this script grepped the raw stream and "detected" `augments:using-augments`
straight out of the injected nudge. Trust the structured tool_use, nothing else.

## Results

Results are ephemeral — re-run the scripts for current truth (the script is the
record, not a committed log). With `--keep`, the raw stream is saved beside this
README (gitignored); copy one out to a dated file if you want to keep a specific
transcript as evidence.
