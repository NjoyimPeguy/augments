# tests/harness/claude-code/ — real activation tooling

The faithful, harness-bound counterpart to the portable proxies. Where
`tests/triggering/` and `tests/invocation/` ask a fresh *subagent* what it
*would* do, `run-activation.sh` drives the actual `claude` CLI headless against
the really-installed plugin and observes whether a skill **actually** activates
— a structured `Skill` tool_use, parsed from `--output-format stream-json`, not
a prose grep and not a self-report.

## Why it lives here, not in the core gate

It binds to one harness (the `claude` binary) and makes a **real API call** — it
costs tokens and is not deterministic. So it is a manual/record tool, never CI
pass/fail. The harness-agnostic core (`validate-skills.sh`, the proxies) stays
free and portable; this adds the one thing they structurally can't: ground truth
for *this* adapter. See `../../README.md` and `../../../docs/augments/philosophy.md`.

## Scenarios live by filename, not inline

The two scripts are generic engines and carry **no** scenario text. Openings live
as named files under `scenarios/`, mirroring `skills/` — a folder per SDLC phase,
plus `common/` for cross-cutting skills. **The filename is the contract:**

```
scenarios/
  planning/                 # the planning phase
    define-goals.txt        # opening expected to activate augments:define-goals
    feasibility-check.txt    #   "          "            augments:feasibility-check
    scope-it.txt             #   "          "            augments:scope-it
    _negative.txt            # leading "_" => expects NOTHING to fire
    _flow.txt                # lists the above in order = the planning sequence
  common/
    dispatching-parallel-agents.txt
```

A `_flow.txt` names its phase's scenario files in order; the engine runs them as
one resumed conversation and checks each turn against its filename. To change
what a turn says, edit the per-skill `.txt`; to add a skill to a phase, drop in a
`<skill>.txt` and list it in `_flow.txt`. No script edit, no inline text.

## Run it

```bash
# Whole planning phase (define-goals -> feasibility-check -> scope-it, + negative):
tests/harness/claude-code/run-flow.sh --flow scenarios/planning/_flow.txt --keep
tests/harness/claude-code/run-flow.sh --flow scenarios/planning/_flow.txt --print   # parse only, no API call

# A single cross-cutting skill:
tests/harness/claude-code/run-activation.sh \
  --scenario-file scenarios/common/dispatching-parallel-agents.txt --keep
```

- Runs the nested session in an **isolated empty temp dir** — safe (writes can't
  reach this repo) and faithful (reproduces a brand-new-project opening). The
  user-level plugin and SessionStart hook apply regardless of cwd.
- Permission gates are **not** bypassed: an explicit allowlist (`Skill` +
  read-only) lets activation happen while denying any Write/Edit/Bash.
- `run-activation.sh` kills on the first real `Skill` tool_use (cost ≈ one turn);
  `run-flow.sh` runs each turn to completion so it can score the whole sequence.
- `--keep` writes the raw stream to `last-stream.jsonl` / `last-flow.jsonl`
  (gitignored scratch); copy to a dated `YYYY-MM-DD-<skill>-activation.jsonl` as
  evidence. `--no-augments` (run-activation) runs the auth-safe Skill-blocked arm.

## Detection (and a bug worth remembering)

Verdict comes **only** from a `Skill` tool_use in an *assistant* event. A naive
grep of the raw stream reports phantom activations: the SessionStart nudge text
itself says "invoke `augments:using-augments`", and the init manifest lists every
skill — both contain `augments:` tokens that are not actions. The first cut of
this script grepped the raw stream and "detected" `augments:using-augments`
straight out of the injected nudge. Trust the structured tool_use, nothing else.

## Records

Dated activation results are appended to `../claude-code.md` (the adapter
record), with the raw transcript kept beside this README as evidence.
