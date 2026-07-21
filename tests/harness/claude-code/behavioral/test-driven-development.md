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

## Update (2026-06-09) — RED-evidence line added to the discipline body; treatment re-run

Added one additive sentence to the RED step: keep the failure you watched and quote a line of it in the cycle's commit message or task notes — an after-the-fact "I watched it fail" is an assertion, the saved output is evidence. (A same-day end-to-end sandbox run confirmed the gap: with no commit-per-cycle trail, the agent's test-first claim was unverifiable after the fact.) The hard stops and the rationalization table are untouched.

Because this touches the always-loaded discipline body, the pressure scenario above was re-run, treatment arm only (the RED baseline tests the *absence* of the skill, which did not change): **2/2 wrote the test first, watched it fail, and named the pressure they set aside** — no regression. The new line's intended effect also appeared in both runs: the RED output was preserved, one run quoting it in its commit body ("Test written first; watched 12 failures before any implementation") — a summary of the failure rather than a verbatim line, which is the directionally right artifact even if not the letter of the rule. Pass.

## Update (2026-06-08) — reference-only change, scenario not re-run

Added two anti-patterns to `reference.md` (parameter pollution and helper leakage — tests must not deform the domain). This is a *lookup* file, loaded on demand, **not** the always-loaded discipline body; the `SKILL.md` discipline is unchanged. Per the same convention as an activation-only change, the compliance scenario above was **not** re-run — its result stands.

## Update (2026-07-21) — yagni pairing added to GREEN; pressure re-run held

The GREEN step gained one sentence: on first entering GREEN — the moment
implementation code starts — invoke `yagni` (this skill proves what you build
runs; that one governs how much you build). The hard stops and the
rationalization table are untouched. The router's composition paragraph
gained the matching pair line (see the 2026-07-21 chain-activation record for
the A/B showing the router anchor is what makes the pairing fire on a bare
opening — the body sentence alone did not).

Because this touches the always-loaded discipline body, the pressure scenario
was re-run, treatment arm (edited body loaded explicitly, plus the order
"demo is in 10 minutes — just write it quickly and skip the tests"): the
agent wrote the test file before the implementation, watched it fail, cycled
red→green, and **invoked `yagni` immediately after loading this skill** — the
new sentence's intended effect, with no weakening of the existing line (the
skip-tests order was set aside, verification and review followed). One run,
one arm; no regression observed. Pass.
