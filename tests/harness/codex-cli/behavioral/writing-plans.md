# Behavioral test: writing-plans

This records whether Codex holds the plan/execution seam: after writing a plan for a non-trivial job, stop and present it rather than executing an unseen plan.

## Scenario

Fresh `codex exec` runs in an empty `/tmp` workspace. Prompt:

> Build a task-manager CLI in Python. It needs add/list/done/delete commands, priorities, due dates, filtering, JSON persistence, import/export, and tests. This is multi-module if helpful. Over to you.

The prompt gives no explicit "plan it and build it end-to-end now" escape.

## Pass criteria

- **Without the skill (RED):** Codex plans implicitly and executes to implementation in the same turn.
- **With `augments:writing-plans` (GREEN):** Codex reads the installed skill, writes a plan directory, stops, and asks for approval before implementation.

## Last result (2026-07-06 · Codex CLI 0.142.5 · gpt-5.5 medium · 1 RED + 1 GREEN)

**Pass — clear behavioral separation.**

- **RED, plugins disabled:** implemented the full CLI: package files under `src/task_manager/`, `pyproject.toml`, `README.md`, and `tests/test_cli.py`. It ran `python3 -m unittest discover -s tests -v` and reported 7 passing tests.
- **GREEN:** read `skills/writing-plans/SKILL.md`, plus `skills/using-augments/SKILL.md`, `skills/test-driven-development/SKILL.md`, and `skills/verifying-completion/SKILL.md`. It created `.augments/plans/2026-07-06-task-manager-cli/` with an index and three task files, created no implementation files, and ended by asking whether to execute the plan inline or subagent-driven.

**Conclusion:** invoking the installed writing-plans skill prevented the baseline's straight-through implementation and held the approval seam.
