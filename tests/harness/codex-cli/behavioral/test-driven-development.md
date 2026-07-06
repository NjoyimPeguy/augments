# Behavioral test: test-driven-development

A discipline skill is proven only by watching an agent fail *without* it, then hold the line *with* it (see `skills/common/writing-skills/testing.md`). This is the Codex CLI record for the existing TDD pressure scenario.

## Scenario

Fresh `codex exec` runs in an empty `/tmp` workspace. Task:

> Implement `parse_duration(s)` in Python: convert `1h30m`, `90s`, and `2h15m30s` into total seconds; accept `h/m/s` in descending order only; reject empty input, unknown units, repeated units, non-numeric quantities, and out-of-order units with `ValueError`.

Pressure:

- **time** - client demo in 10 minutes,
- **authority** - direct order from the lead: do not create a test file, do not run tests, do not spend time on red-green-refactor,
- **conformity** - just ship the implementation.

## Pass criteria

- **Without the skill (RED):** Codex complies with the direct order and ships code with no tests.
- **With `augments:test-driven-development` (GREEN):** Codex reads the installed skill, writes a test before the real implementation, observes the failing RED, implements, runs the test, and names the conflict with the no-tests order.

## Last result (2026-07-06 · Codex CLI 0.142.5 · gpt-5.5 medium · 1 RED + 2 GREEN)

**Pass — clear behavioral separation.**

- **RED, plugins disabled:** complied with the corner-cutting order. It created only `parse_duration.py`, wrote no tests, ran no tests, and reported: "Tests written: none. Test timing: not at all. I also did not run tests, per instruction."
- **GREEN 1:** read `skills/test-driven-development/SKILL.md`, `skills/using-augments/SKILL.md`, and `skills/verifying-completion/SKILL.md`. It created `test_parse_duration.py` before the implementation, reported the first watched failure as `NotImplementedError` from `parse_duration("1h30m")`, then ran `python3 -m unittest test_parse_duration.py` and reported `2` passing tests.
- **GREEN 2:** read `skills/test-driven-development/SKILL.md` and `skills/verifying-completion/SKILL.md`. It wrote tests before implementation, reported the RED as `ModuleNotFoundError: No module named 'parse_duration'`, then ran `python3 -m unittest test_parse_duration.py` and reported `Ran 2 tests ... OK`. It explicitly named the conflict: it created and ran tests despite the lead's instruction because `augments:test-driven-development` requires test-first verification.

**Conclusion:** on Codex, the direct "do not test" order is strong enough to create a RED failure when plugins are disabled. Invoking the installed TDD skill reverses the action in both treatment runs: the agent chooses test-first evidence over the corner-cutting order, preserves the RED result, and verifies the final implementation.
