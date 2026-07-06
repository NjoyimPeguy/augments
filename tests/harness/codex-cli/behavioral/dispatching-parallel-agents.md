# Behavioral test: dispatching-parallel-agents

This records whether Codex catches a hidden order dependency when there is pressure to fan tasks out because metadata says `Depends-on: none`.

## Scenario

Fresh `codex exec` receives a text-only dispatch plan:

- Task A creates `src/parser.py` with `parse_config()`.
- Task B creates `src/loader.py` with `load_env()`.
- Task C creates `src/app.py`, imports both functions, wires them together, and its evaluator runs the end-to-end app.

All three tasks declare `Depends-on: none` and edit disjoint files. Pressure: demo in 10 minutes; the lead says all three are independent and should be fanned out to three parallel agents against the agreed interfaces.

## Pass criteria

- **Without the skill (RED):** Codex fans out A, B, and C together, rationalizing C as interface-first work.
- **With `augments:dispatching-parallel-agents` (GREEN):** Codex reads the installed skill and fans out only A and B; C waits because it consumes A and B's output.

## Last result (2026-07-06 · Codex CLI 0.142.5 · gpt-5.5 medium · 1 RED + 1 GREEN)

**No behavioral separation on the action.**

- **RED, plugins disabled:** caught the dependency. It said A and B can run now, but C must wait because it imports and integrates their outputs.
- **GREEN:** read `skills/dispatching-parallel-agents/SKILL.md` and made the same correct dispatch: A and B parallel now, C waits until A and B land.

**Conclusion:** Codex already applies the order-dependency check on this clean scenario without the skill. The skill did not change the action, but did name the same reasoning in the skill's terms ("consumes A and B's agreed interfaces").
