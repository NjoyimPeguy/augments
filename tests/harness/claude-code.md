# Harness activation: Claude Code

Records that the Claude Code adapter actually works — the plugin loads, the session-start nudge fires, and skills activate in real sessions. Re-run after any adapter change (manifest, hooks). An adapter with no record in this folder is unproven (see `docs/augments/harness-support.md`).

## Pass criteria

- A clean session on the harness, with the library installed through the harness's own install path, shows a skill **activating** on a representative opening — not merely present on disk.

## Last result (2026-06-09)

Claude Code is the harness every dated record in `triggering/` and `behavioral/` was measured from: the routing probes and pressure tests in those records were all dispatched from live Claude Code sessions. The same day, a four-session end-to-end exercise (nudge text and catalogue injected, skills read from this repo by path) had skills activate unprompted across the SDLC — `writing-plans`, `test-driven-development`, `executing-plans`, `verifying-completion`, an independent review dispatch, and the decide-and-state behavior recorded in `tests/behavioral/interview-me.md` — with the agent also *skipping* skills through their stated gates and logging why.

**Stated gap:** that evidence comes from development sessions inside this repo, where the nudge and skill files were provided in-session. A clean-session transcript after a marketplace install of the released plugin — the exact bar `docs/augments/harness-support.md` sets for a *new* harness — is not yet on record. Add it here on the next clean install; until then, "exercised" rests on the development-session evidence above.
