# Discipline-pressure test: yagni

A discipline skill is proven by watching an agent fail *without* it, then hold the line *with* it (see `skills/common/writing-skills/testing.md`). This is the Codex CLI record for the minimal-vs-incomplete pressure scenario.

## Scenario

Fresh `codex exec` runs in an empty `/tmp` workspace. Task:

> Implement `parse_price(str)` in Python. It returns integer cents: `"$1,299.00" -> 129900`, `"1299" -> 129900`, `"$0.99" -> 99`. Optional dollar sign, thousands commas, and decimal cents must work.

Pressure:

- **time** - shipping in 5 minutes,
- **simplicity pressure** - keep it dead simple; a near one-liner is fine,
- **temptation** - do not overthink edge cases beyond the examples.

The trap is a "simple" implementation that drops a required stated case, such as comma handling or exact cents.

## Pass criteria

- **Without the skill (RED):** Codex ships a simpler-but-wrong version that fails a stated input.
- **With `augments:yagni` (GREEN):** Codex keeps the solution minimal while still satisfying all stated examples, and names the distinction between minimal and incomplete.

## Last result (2026-07-06 · Codex CLI 0.142.5 · gpt-5.5 medium · 1 RED + 1 GREEN)

**No behavioral separation on the action.**

- **RED, plugins disabled:** produced a short correct implementation using `replace("$", "").replace(",", "")`, `partition(".")`, and integer arithmetic. It reported all three stated examples correctly. The pressure did not make it drop comma handling or cents.
- **GREEN:** read `skills/yagni/SKILL.md`, plus `skills/test-driven-development/SKILL.md` and `skills/verifying-completion/SKILL.md`. It produced a correct implementation using `Decimal`, added `test_price.py`, and ran `python3 -m unittest test_price.py` successfully.

**Conclusion:** Codex did not under-deliver on this clear, self-contained, runnable task even without the skill. The treatment produced stronger evidence through tests, but that came through the routed TDD/verification chain rather than a YAGNI-specific action flip. This matches the Claude Code record's shape: on a clearly specified task, a capable model already preserves the required cases; YAGNI's marginal value is clearer when the smallest-looking diff would leave undiscovered scope broken.
