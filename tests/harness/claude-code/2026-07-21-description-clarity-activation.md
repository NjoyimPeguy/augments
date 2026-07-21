# Activation record — description clarity pass (2026-07-21)

## Problem

A maintainer vagueness audit of all 30 descriptions flagged five that fail a
cold reader: `release-readiness` described its portability limitation instead
of its trigger signals; `writing-plans` used undefined internal vocabulary
("an alignment brief"); `refactor-architecture` leaned on design-book
shorthand ("modules are shallow, seams leak"); `spec-it` had no Skip clause;
`feasibility-check` had no Skip clause and ended on a how-fragment. A vague
description is a routing liability — the trigger is the only part of a skill
a model sees before deciding to invoke it. The other 25 passed the audit and
were deliberately left untouched (tuned text is not churned without a
defect).

## Change

Each description was rewritten from its own body's vocabulary — no new
claims, just the body's concrete signals surfaced into the trigger:

- `release-readiness`: names the gate's real dimensions (CI on the merged
  result, reversible migrations, rollback target, flags, config/secrets,
  downstream breakage).
- `writing-plans`: "an alignment brief" → "requirements are agreed (a brief
  from interview-me or spec-it)".
- `refactor-architecture`: "a single change bounces across many files,
  modules are thin wrappers that add little, tests and callers couple to
  internals".
- `spec-it`: + "Skip when verifiable requirements are already written down."
- `feasibility-check`: constraints named (time, team, tech, budget), the
  prototype pointer folded into the trigger sentence, + a Skip clause.

## Re-measure — 10/10 ACTIVATED, all on the expected skill

One bare scenario per rewritten skill, both harnesses (this harness via
`run-activation.sh --working-tree`, Claude Code 2.1.216; the other adapter
via its own runner, Kimi Code CLI 0.28.1):

| Skill | This harness | Other adapter |
| --- | --- | --- |
| `release-readiness` | `using-augments → release-readiness` | `release-readiness → …` |
| `writing-plans` | `using-augments → writing-plans` | `writing-plans → using-augments` |
| `refactor-architecture` | direct | direct |
| `spec-it` | `using-augments → spec-it` | direct |
| `feasibility-check` | direct | `feasibility-check → …` |

No wrong-skill routing, no NONE verdicts, no errored runs.

## Honest limits

One run per skill per harness — this proves the rewrites did not break
routing on the standard scenarios; it does not quantify an improvement over
the old wording (the old wording also activated on these scenarios — the
motivation was reader clarity, with activation held as a no-regression
constraint), and it does not test run-to-run stability.
