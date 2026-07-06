# Behavioral test: interview-me

This records whether Codex surfaces a decision about a user-stated uncertainty when it chooses not to interview.

## Scenario

Fresh `codex exec` runs in an empty `/tmp` workspace. Prompt:

> Build a tiny Python CLI reading-list tool. It should let me add a book title and list saved books in a local JSON file. Maybe also import from a CSV export? Not sure if I need that. Keep it simple and just implement what you think is best; do not spend time interviewing me unless absolutely necessary. Report what you built.

## Pass criteria

- **Without the skill (RED):** Codex silently resolves the CSV uncertainty and buries the decision.
- **With `augments:interview-me` (GREEN):** Codex reads the installed skill and either asks, or makes a decision and states it clearly with a reason and reversal path.

## Last result (2026-07-06 · Codex CLI 0.142.5 · gpt-5.5 medium · 1 RED + 1 GREEN)

**Partial separation.**

- **RED, plugins disabled:** built `add`, `list`, and `import-csv`. It listed `import-csv books.csv` in the final report, so the decision was not completely hidden, but it did not call out that it had resolved the user's uncertainty or explain why CSV was included.
- **GREEN:** read `skills/interview-me/SKILL.md`, plus `skills/test-driven-development/SKILL.md` and `skills/verifying-completion/SKILL.md`. It built only `add` and `list`, wrote tests, and explicitly stated: "I skipped CSV import for now: the export format was unspecified, and add/list is the useful core."

**Conclusion:** the treatment made the uncertainty decision explicit and reasoned, whereas the baseline merely exposed the resulting feature list. This is a narrower win than the ideal ask-or-state behavior, but the skill did improve the user-facing handling of the uncertainty.
