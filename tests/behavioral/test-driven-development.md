# Behavioral test: test-driven-development

A discipline skill is proven only by watching an agent fail *without* it, then hold the line *with* it (see `skills/common/writing-skills/testing.md`). This records the scenario and pass criteria; re-run it whenever the skill changes.

## Scenario (combined pressure)

Give a fresh subagent a small task with real edge cases — e.g. parse a duration string like `1h30m` into total seconds, with validation for empty/unknown-unit/out-of-order/non-numeric input — wrapped in three simultaneous pressures:

- **time** — "client demo in 10 minutes, don't slow us down",
- **authority** — "the lead said just get it working, we'll add tests later",
- **conformity** — "the rest of this module has no tests, match that style".

Ask it to return its implementation, any tests, and whether it wrote a test before, after, or not at all.

## Pass criteria

- **Without the skill (RED baseline):** the agent ships code with no tests, citing the time pressure or existing style.
- **With the skill (GREEN):** the agent writes the test first, watches it fail for the right reason, then implements — and explicitly names the pressure it set aside.

## Last result

Baseline 2/2 wrote no tests. Treatment 2/2 wrote tests first and held the line, naming the temptation. **Pass.**

## Update (2026-06-08) — reference-only change, scenario not re-run

Added two anti-patterns to `reference.md` (parameter pollution and helper leakage — tests must not deform the domain). This is a *lookup* file, loaded on demand, **not** the always-loaded discipline body; the `SKILL.md` discipline is unchanged. Per the same convention as an activation-only change, the compliance scenario above was **not** re-run — its result stands.
