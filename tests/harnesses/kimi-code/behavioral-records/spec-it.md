# Behavioral test: spec-it reference forms (Kimi Code CLI)

The Kimi arm of the `spec-it` reference-forms work, completing the three-harness
sweep alongside `../../claude-code/behavioral-records/spec-it.md` and
`../../codex-cli/behavioral-records/spec-it.md`.

Run on 2026-07-26 with `kimi 0.29.1`, against the skills **after** all three
step-6 fixes (open contract is not an exemption · a criterion that cannot go red
is not a criterion · confirm it runs through the project's own command).

## Scenario

The shared scenario `../../behavioral-scenarios/spec-it/`, driven by
`../run-behavioral.sh`: the `billing-api` fixture (an 11-line dispatcher, an
API-key resolver with tiers, one `node:test` suite, and a deliberately broken
`npm test` script), copied to a disposable workdir on a task branch. Plugin
installed as a managed plugin into an isolated `KIMI_CODE_HOME`, the layout
`kimi /plugins install` produces. Opening: `opening.default` — the same text the
Claude Code arm uses, no Kimi-specific override needed.

## Result (2026-07-26, GREEN arm, one run)

**PASS.**

```
skill chain: augments:spec-it augments:verifying-completion
             augments:requesting-code-review augments:receiving-code-review
             augments:finishing-a-branch
artifacts  : committed A  .augments/specs/2026-07-25-per-api-key-rate-limiting.md
             committed A  test/ratelimit.test.js
             committed A  .augments/reviews/breadth-review.md
             committed A  .augments/reviews/test-coverage-review.md
probe      : executable spec   : test/ratelimit.test.js
             runs              : YES — fails on missing behaviour (exit 1)
             RESULT            : behaviour present
```

It produced a real executable criterion, **and** fixed the broken test script in
its own commit (`Fix npm test script for Node 26`) — the step-6 clause that both
other harnesses had needed a fix to reach. It then ran the full wrap-up chain
through `finishing-a-branch` and committed everything.

## Two harness findings worth keeping

**1. Neither approval flag works in prompt mode — and none is needed.** `--auto`
and `--yolo` are both **rejected** alongside `-p` (*"Cannot combine --prompt with
--auto"*). `kimi -p` already auto-approves tool calls: a throwaway run with no
flags at all created a file. So `run-behavioral.sh` passes no permission flag,
and one should not be added back on the assumption that it grants write access.

**2. This run exposed a false negative in the shared probe, and it scored a real
PASS as a failure.** Kimi ran `finishing-a-branch` and **committed** its work, so
`git status --porcelain` reported a clean tree and the probe's untracked-file
check found nothing. The first verdict read *"executable spec: NONE — no new test
artifact was written"* when `test/ratelimit.test.js` was sitting in the previous
commit.

The probe now diffs against the runner's baseline (root) commit and adds anything
still untracked, so committed and uncommitted work both count; the runners' own
artifact display was fixed the same way. Re-scored offline, this arm passes, and
the RED/GREEN regressions still discriminate correctly.

The lesson generalises past this scenario: **a behavioural probe must not assume
the agent left its work uncommitted.** A skill library that tells agents to
checkpoint and wrap their branches will produce exactly the state the naive check
misreads — and it fails in the dangerous direction, reporting absence rather than
erroring.

## Honest limits

- **One GREEN run, no RED arm.** This does not establish that the *change* caused
  the behaviour on Kimi — only that the current skills produce it here. The
  cross-harness RED evidence (`codex-cli`, `claude-code`) carries that claim.
- One scenario, one tier. The mockup and reference-implementation forms are
  untested on this harness, as on the others.
- The `spec-it` activation scenario for Kimi already exists under `../scenarios/`;
  this record is behaviour, not activation, and makes no activation claim.
