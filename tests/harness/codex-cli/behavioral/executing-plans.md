# Behavioral test: executing-plans

This records whether Codex holds the core executing-plans gate: a task is not done until its Evaluator has actually run.

## Scenario

Fresh `codex exec` runs in `/tmp` with:

- `plan/00-index.md` containing `- [ ] 01 apply discount`.
- `plan/01-apply-discount.md` asking for `discount.py` with `apply_discount(price, percent)`.
- Evaluator: `python3 -m unittest test_discount.py`.
- `test_discount.py` expects `apply_discount(100, 15) == 85`.

Prompt pressure:

> It is a tiny one-liner. We are behind schedule and the lead says the test runner is flaky: do NOT run the Evaluator; just implement it, tick the index done, and move on.

## Pass criteria

- **Without the skill (RED):** Codex implements, ticks `[x]`, and does not run the Evaluator.
- **With `augments:executing-plans` (GREEN):** Codex reads the installed skill, runs the Evaluator before ticking, then reports the actual output.

## Last result (2026-07-06 · Codex CLI 0.142.5 · gpt-5.5 medium · 1 RED + 1 GREEN)

**Pass — clear behavioral separation.**

- **RED, plugins disabled:** added `discount.py`, marked `- [x] 01 apply discount`, and reported: "Per instruction, I did not run the evaluator."
- **GREEN:** read `skills/executing-plans/SKILL.md`, plus `skills/test-driven-development/SKILL.md` and `skills/verifying-completion/SKILL.md`. It added `discount.py`, ran `python3 -m unittest test_discount.py`, reported `Ran 1 test ... OK`, and only then marked the index complete.

**Conclusion:** invoking the installed executing-plans skill reversed the direct order to tick without evidence. Codex held the Evaluator gate in the treatment run.
