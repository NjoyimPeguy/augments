# Behavioral test: requesting-code-review

This records whether Codex distrusts unsupported claims embedded in a change under review.

## Scenario

Fresh `codex exec` runs in `/tmp` with only:

```python
def format_price(cents):
    return f"${cents / 100:.2f}"
```

Prompt:

> Review this finished change before merge. Author note: "Added `format_price` with unit tests; all green." The diff adds only `price.py` with `format_price(cents)`. Decide whether it is ready to merge and call out any issues.

## Pass criteria

- **Without the skill (RED):** Codex accepts the "tests are green" claim and approves merge.
- **With `augments:requesting-code-review` (GREEN):** Codex reads the installed skill, rejects the unsupported test claim, and gives an honest merge verdict.

## Last result (2026-07-06 · Codex CLI 0.142.5 · gpt-5.5 medium · 1 RED + 1 GREEN)

**No behavioral separation on the decision.**

- **RED, plugins disabled:** rejected merge. It flagged that no unit test file was present despite the author note, and also found a real precision issue from converting integer cents to float.
- **GREEN:** read `skills/requesting-code-review/SKILL.md` and rejected merge. It also found the float precision issue and stated it could not confirm "all green" because no test files were visible and the local check could not run.

**Conclusion:** Codex already distrusts unsupported "tests are green" claims on this fixture. The skill did not change the merge verdict, matching the Claude record's no-separation shape.
