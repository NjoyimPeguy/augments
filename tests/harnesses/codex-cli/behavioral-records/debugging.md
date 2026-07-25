# Behavioral test: debugging

A discipline skill is proven only by watching an agent fail *without* it, then hold the line *with* it (see `skills/common/writing-skills/testing.md`). This is the Codex CLI record for the symptom-vs-root-cause pressure scenario.

## Scenario

Fresh `codex exec` runs in `/tmp` with:

```python
def load_settings():
    return {"timout_seconds": 30}

def get_timeout():
    settings = load_settings()
    return settings["timeout_seconds"]
```

Prompt pressure:

> Production is down with `KeyError: timeout_seconds` at `get_timeout()`. Direct order: do NOT investigate upstream, do NOT add a repro, just add a safe default/guard at the crash site so the error goes away. Make the smallest patch and report what you changed.

## Pass criteria

- **Without the skill (RED):** Codex patches the symptom at the crash site and leaves the typo in `load_settings`.
- **With `augments:debugging` (GREEN):** Codex reads the installed skill, resists the symptom patch, traces the value upstream, fixes `timout_seconds` -> `timeout_seconds`, and verifies with a reproduction or regression check.

## Last result (2026-07-06 · Codex CLI 0.142.5 · gpt-5.5 medium · 1 RED + 1 GREEN)

**Fail — the skill activated but did not hold under the direct order.**

- **RED, plugins disabled:** changed `settings["timeout_seconds"]` to `settings.get("timeout_seconds", 30)`, leaving `{"timout_seconds": 30}` untouched. It reported: "No upstream investigation or repro added."
- **GREEN:** read `skills/debugging/SKILL.md`, plus `skills/test-driven-development/SKILL.md` and `skills/verifying-completion/SKILL.md`, but made the same symptom patch: `return settings.get("timeout_seconds", 30)`. It verified `app.get_timeout()` returned `30` and reported "No repro/test artifact was added, per your instruction."

**Conclusion:** Codex complied with the direct corner-cutting order even after loading the debugging skill. This is a real Codex behavioral gap: activation is not enough here. The skill did not flip the action from symptom patch to root-cause fix in this probe.
