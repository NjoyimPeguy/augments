# tests/

The skills are portable Markdown, but **whether one actually fires, and whether
it changes what gets built, are facts about a specific harness**. So everything
here drives a real CLI. The deterministic, portable gate lives in `scripts/sh/`
and runs in CI; nothing in this folder does.

## Layout

```
tests/
  run-activation.sh       does the right skill fire?             (1 API call/scenario)
  run-all-activation.sh   the whole activation set for a harness
  run-flow.sh             multi-turn sequences, one resumed conversation
  run-behavioral.sh       does the skill change what gets BUILT? (two arms)
  run-stop-nudge.sh       done-boundary hook policy              (offline)
  run-plugin-smoke.sh     install / marketplace mechanics        (offline)
  harnesses/<name>.sh     ONLY what differs per CLI: install, invoke, detect
  assert.sh               assertion helpers every scenario uses
  scenarios/
    activation/<phase>/<skill>   one opening per skill
    flows/<name>/                multi-turn reproductions (momentum, decay)
    behavioral/<skill>.sh        fixture + opening + assertions, one file
```

Every runner takes `--harness claude-code|codex|kimi-code`:

```bash
tests/run-activation.sh     --harness claude-code --scenario-file common/yagni
tests/run-all-activation.sh --harness codex
tests/run-behavioral.sh     --harness kimi-code --scenario spec-it --arm green
tests/run-stop-nudge.sh     --harness codex
tests/run-activation.sh     selftest        # offline detector check, no API
```

**Scenarios are shared by every harness.** They were byte-identical across three
copies before this; a per-harness override exists only for a real constraint —
`codex exec` is single-turn, so a scenario that invites a clarifying question
ends that run with no deliverable, and `scenario_opening_codex()` pre-empts it.
A per-adapter `scenario_setup_<harness>()` override works the same way for fixtures. Never use an override to make an arm look better, and say so when you use one.

## The three kinds, and what each can prove

**Activation** — the verdict comes only from a structured tool call in the
harness's own stream. A raw grep reports phantom activations: the SessionStart
nudge and the init manifest both contain `augments:` tokens that are not
actions, and the first version of this harness fell for exactly that. The
**filename is the contract**: a scenario named after a real skill expects that
skill anywhere in the routing chain (under routing-first the first call is
`using-augments`, the router — judge the whole chain); any other name expects
nothing to fire. Exit code is the verdict, so it is scriptable.

**Behavioural** — runs the skill for real and reads the artifact it produced.
This is the only kind that catches a skill described correctly and *applied*
wrongly: a spec that promises "all criteria are automated tests" and ships none,
or ships them marked `todo` so the suite can never go red. A test that asked the
agent to *describe* the skill would pass all of those. Two arms, because a
behavioural claim is a comparison — RED loads the skills from a `git worktree`
at `--base`, GREEN from the working tree, so the before-arm stays reproducible
after the change is committed.

**Offline** — `run-activation.sh selftest`, `run-stop-nudge.sh` and
`run-plugin-smoke.sh` need no model. Prefer them: they are the only tests here
that are deterministic, and they are free.

## Adding things

- **An activation scenario:** drop a file at `scenarios/activation/<phase>/<skill>`.
  The filename is the contract; no registration, no code change.
- **A behavioural scenario:** one file, `scenarios/behavioral/<skill>.sh`, defining
  `scenario_opening`, `scenario_setup <dir>` and `scenario_assert <dir>`. Write the
  assertions so the **exit code** is the verdict — a summary is written by the same
  agent that wants it green; an exit code is not. Check what is easy to fake and
  hard to see in a transcript: that an artifact exists, that it *loads*, and that
  it can actually fail.
- **A harness:** add `harnesses/<name>.sh` implementing `adapter_check`,
  `adapter_install`, `adapter_chain`, `adapter_run_activation`,
  `adapter_run_behavioral`, `adapter_stop_hook`, `adapter_stop_payload`. Nothing
  else should need to change. A harness stays **unproven** until its tests pass on
  it — files present but never invoked is not a working integration.

## What this costs, before you run it

These are the only tests here that hit an API, and the matrix multiplies fast.
Measured on this repo:

| Kind | Runs | Per run | Full sweep |
| --- | --- | --- | --- |
| Activation, one harness | 32 scenarios | ~1–2 min | ~40–60 min |
| Activation, all three | 96 | ~1–2 min | **2–4 h** |
| Behavioural, one scenario, one harness, one arm | 1 | ~5–40 min | — |
| Behavioural, all scenarios × 3 harnesses × 1 arm | 30 × 3 | ~5–40 min | **15–40 h** |

So the behavioural matrix is **deliberately not filled**. Scenarios exist for the
skills where the failure is both likely and mechanically checkable; the rest are
covered by activation only, and that limit is stated rather than papered over.
Adding a behavioural scenario is cheap; *running* the full matrix is not.

Practical guidance:

- **Default to the offline tests.** They are free, deterministic, and catch real
  defects — a broken detector, a hook that stopped firing, a manifest drift.
- **Run one behavioural arm before a full sweep.** If GREEN fails on one harness,
  the other 89 runs will not tell you anything new yet.
- **Budget a sweep deliberately.** `run-all-activation.sh --harness X` is the
  cheapest broad signal; reach for the behavioural matrix only when a skill's
  *applied* behaviour is what changed.
- **Report N.** A single green run is weak evidence on a non-deterministic test.
  Say how many you did and what the spread was.

## Honest limits

Live runs cost tokens and are **not deterministic**: the same scenario passes and
fails across runs, and coverage is selective by design. So these are manual tools,
never CI, and no result is committed as a record — re-run for current truth and
report the numbers you actually got, failures included. A single green run is weak
evidence; say how many you did.
