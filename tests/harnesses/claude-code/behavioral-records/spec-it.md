# Behavioral test: spec-it reference forms (spec-it + writing-plans)

Records the 2026-07-25 change moving `spec-it` from "write a spec file" to
"choose the cheapest form that makes each requirement checkable" — a failing test
suite, a mockup page, a reference implementation plus deltas, or a rubric, with
prose as the fallback rather than the starting point.

The change has three homes:

- `spec-it` SKILL.md — the form choice folded into the acceptance-criterion step
  (step 5), plus a new step 6: *build what you named, and confirm it runs*.
- `spec-it/reference-forms.md` (new sibling) — the four forms, when each is
  cheapest, where each lives, and the anti-gold-plating check.
- `writing-plans` templates — `index-template.md` gains a **References** block;
  `task-template.md` teaches that a spec's failing test **is** the task's
  Evaluator and that Context points at the artifact instead of paraphrasing it.

No `description` was touched in either skill, so no activation change is claimed
and none was re-measured.

## Scenario

Fixture: a small committed Node repo (`billing-api` — an 11-line route
dispatcher, an API-key resolver, one existing `node:test` suite, and a
`package.json` whose `test` script is subtly broken). Agent on task branch
`feature/rate-limiting`.

Opening (identical in both arms):

> We're adding per-API-key rate limiting to this billing API. Plan tiers get
> different limits (free/pro/enterprise), and clients need to be able to tell how
> much budget they have left. Before anyone designs or builds it, I want the
> requirements spec: what it must do, and how each requirement gets verified.
> Write it up.

Fresh headless session per arm, working-tree plugin (`--plugin-dir`), full tool
access in a disposable fixture copy. RED ran against the unedited skills; GREEN
against the edited ones. A third arm tested the plan seam on GREEN's output.

## Result (2026-07-25, one run per arm, large tier)

- **RED:** `spec-it` fired and produced a single 407-line prose file. It stated,
  above the requirements, *"All ACs are automated tests under `test/` runnable
  via `npm test`"* — and wrote **zero** test files. It also noticed the broken
  `test` script and filed it as follow-up action item D-6: *"the verification
  story in this spec does not work until it runs."* So the spec both promised
  verification it never delivered and knew its own verification was inoperable.
  This is the failure mode the change targets, reproduced exactly.

- **GREEN:** a 313-line spec plus `test/ratelimit.test.js` (240 lines) in the
  project's own test tree, matching the existing `node:test` idiom. 14
  requirements carry a `**Verified by:**` pointer naming the test by name; one
  NFR uses a rubric; three are marked *criterion deferred* **with the reason
  stated** rather than promised. `npm test` runs: 12 failing on missing
  behaviour, 1 `todo`, 1 passing guard, 2 pre-existing green — failing for the
  right reason, not erroring. The spec ends with a *Verification status* table
  mapping form → requirements → state.

  The causal detail: GREEN **fixed** the broken `test` script that RED merely
  filed, and said why — *"these criteria are worthless if the suite cannot
  run."* That is step 6 doing work, not a coincidence of wording.

- **SEAM (writing-plans over GREEN's output):** six task files. The index
  **References** block lists the spec, the executable criteria, and the
  pre-existing suite; task Contexts point at `test/ratelimit.test.js` (one at a
  line range) instead of paraphrasing it; every task Evaluator *selects the
  spec's existing tests* by name pattern
  (`node --test --test-name-pattern='FR-4:|FR-5: a 429|FR-6:|FR-12:'`); plan
  Acceptance is the spec's own suite turning green (17/17, 0 todo). **No second
  test suite was written** — the duplication the seam exists to prevent.

## Honest conclusion

The change works on this scenario, and the anti-gold-plating guard held: GREEN
did not force an executable form onto requirements that do not support one — it
deferred three explicitly and used a rubric for a fourth, which is the intended
behaviour and the outcome a "tests everywhere" reading would have gotten wrong.

Limits of this record, stated plainly:

- **One run per arm, one scenario, one tier.** Not a distribution. A backend,
  behaviour-shaped feature is the easiest case for the executable-spec form.
- **The mockup and reference-implementation forms are untested.** This scenario
  had no UI surface and no existing implementation to port, so only the failing
  test and rubric forms were exercised. `reference-forms.md` describes four; two
  are reasoned, not measured.
- **`writing-plans` SKILL.md was not edited** — it sits at 1598 of the 1600
  approx-token cap, leaving no room. The seam lives entirely in its two
  templates, which the body already routes to. That placement is what the SEAM
  arm confirms; a body pointer was never tested because none was added.
- Kimi Code was not run — no harness access at the time of writing.

## Update (2026-07-25, later the same day): re-run through `run-behavioral.sh`

The arms above were hand-rolled. They are now a committed scenario
(`../../../behavioral-scenarios/spec-it/`) driven by `../run-behavioral.sh`, whose
`probe.sh` returns the verdict as an **exit code** rather than leaving it to
whatever the record's author writes down.

Re-running the GREEN arm twice through the runner produced **different results**:

| Run | Artifact | `npm test` | Probe |
| --- | --- | --- | --- |
| hand-rolled (above) | `test/ratelimit.test.js`, 240 lines, 14 pointers | fixed the broken script, 12 failing | PASS |
| runner #1 | `test/ratelimit.test.js`, spec 334 lines, 18 pointers | **left the broken script unfixed** — suite never loads | **FAIL** |
| runner #2 | `test/ratelimit.test.js`, spec 147 lines, 1 pointer | fixed the script, fails on missing behaviour | PASS |

So the behaviour is **2 of 3, not reliable**, and the spread on thoroughness is
wide (147 lines / 1 pointer up to 334 / 18). The step-6 clause about confirming
the artifact runs is the part that slips: run #1 wrote a valid test and never
noticed the project's own command could not execute it.

This is the finding the runner exists to produce. Every arm here was a real run;
the difference is that a single lucky arm can no longer be written up as "the
change works". Anyone re-running this should expect an occasional FAIL and treat
a single PASS as weak evidence.

**Runner run #3, after the three step-6 fixes** (open contract is not an
exemption · a criterion that cannot go red is not a criterion · confirm it runs
through the project's own command): PASS — `test/ratelimit.spec.js`, a 253-line
spec with 12 pointers, `package.json` fixed, suite failing on missing behaviour.

Run #1's failure — a valid artifact the project's own command could not execute —
is exactly what fix 3 targets, and Codex hit the same thing independently
(`../../codex-cli/behavioral-records/spec-it.md`, GREEN #3). That is two harnesses on one
gap, which is why it was closed rather than filed. Three of four GREEN runs on
this harness now pass; the sample is still small and the honest reading is
"usually, not reliably".

`probe.sh` was also corrected mid-way: its first version reported run #1 as
"suite did not load", conflating *the artifact is broken* with *the project's
documented command is broken*. It now re-runs the artifact directly to say which,
and both still fail — an artifact the project's own gate cannot execute is not a
gate.
