# Harness activation: Claude Code

Records that the Claude Code adapter actually works — the plugin loads, the session-start nudge fires, and skills activate in real sessions. Re-run after any adapter change (manifest, hooks). An adapter with no record in this folder is unproven (see `docs/augments/harness-support.md`).

## Pass criteria

- A clean session on the harness, with the library installed through the harness's own install path, shows a skill **activating** on a representative opening — not merely present on disk.

## Last result (2026-06-09)

Claude Code is the harness every dated record in `triggering/` and `behavioral/` was measured from: the routing probes and pressure tests in those records were all dispatched from live Claude Code sessions. The same day, a four-session end-to-end exercise (nudge text and catalogue injected, skills read from this repo by path) had skills activate unprompted across the SDLC — `writing-plans`, `test-driven-development`, `executing-plans`, `verifying-completion`, an independent review dispatch, and the decide-and-state behavior recorded in `tests/behavioral/interview-me.md` — with the agent also *skipping* skills through their stated gates and logging why.

**Stated gap:** that evidence comes from development sessions inside this repo, where the nudge and skill files were provided in-session. A clean-session transcript after a marketplace install of the released plugin — the exact bar `docs/augments/harness-support.md` sets for a *new* harness — is not yet on record. Add it here on the next clean install; until then, "exercised" rests on the development-session evidence above.

## Last result (2026-06-21 · Claude Code 2.1.185 · real headless `claude -p`)

First **observed** activation through the real CLI, via `claude-code/run-activation.sh` — not a subagent proxy and not in-session file provision. A locally-installed augments 1.0.6; headless `claude -p` launched in an isolated empty temp dir (reproducing a brand-new project); permission gates intact (allowlist: `Skill` + read-only).

- **Scenario:** "Fresh repo, nothing in it yet. Let's build a customer-feedback portal."
- **Verdict:** `ACTIVATED via Skill tool: augments:define-goals` (12.5s). The SessionStart nudge fired (captured `system:hook_response`); the model reasoned *"before I scaffold anything, I should pin down what 'customer-feedback portal' actually means … the right starting skill here is `augments:define-goals`"* then issued a genuine `Skill` tool_use `{"skill":"augments:define-goals"}`.
- **Evidence:** `claude-code/2026-06-21-define-goals-activation.jsonl`.

This is the structured-activation signal the proxies cannot give: real harness, real hook, real Skill tool, no `FIRST:` scaffold manufacturing a pause — and the skill still fired on the terse empty-project opening. It corroborates `tests/invocation/define-goals.md` from the faithful side, and is direct evidence that "skills don't fire in an empty project" is an availability/install condition, not a routing failure.

**Gap (narrowed, not closed):** still a *locally-installed* plugin, not a from-scratch marketplace install — the clean-room bar in `docs/augments/harness-support.md` remains owed. But activation on a real headless run with the hook firing is now observed, not asserted.

## Phase coverage (2026-06-21 · Claude Code 2.1.185 · real headless)

Two follow-on runs, same faithful method (real `claude -p`, isolated empty dir, allowlist `Skill`+read-only, structured `Skill` tool_use detection).

**Planning wing — full sequence, one resumed conversation** (`claude-code/run-flow.sh`, three phase-shaped turns, `--resume` so context carries):

| turn | opening (shape) | activated |
| ---- | --------------- | --------- |
| 1 | brand-new project kickoff | `augments:define-goals` |
| 2 | should-we-green-light, with two named risks | `augments:feasibility-check` |
| 3 | goal set, draw the first cut | `augments:scope-it` |

Sequence `define-goals → feasibility-check → scope-it`, **all three expected skills activated**, all genuine `Skill` tool_use. One distinct `session_id` across the run → the turns truly resumed: `scope-it`'s tool args cite the CRM sync and two-sided portal raised in earlier turns, i.e. context accumulated. This is the separable, sequential planning wing (`docs/augments/skill-granularity.md`) exercised end-to-end, faithfully.

A re-run added a **trailing negative turn** ("Unrelated: bump the lodash dependency to the latest patch version"): turns 1–3 fired the three planning skills as above, **turn 4 activated nothing** — exactly 3 `Skill` calls total. So the wing both fires on phase-shaped openings *and* stays quiet on trivial work, even with three turns of planning context primed.

These turns are not inline — they live by filename under `scenarios/planning/` (one `.txt` per skill, `_negative.txt`, and `_flow.txt` listing the order), where the **filename is the expected skill** (`_`-prefix = expect-none). `run-flow.sh --flow scenarios/planning/_flow.txt` runs them as one resumed conversation and self-scores each turn against its filename contract — last run: **all four turns matched** (`define-goals → feasibility-check → scope-it`, then quiet). Evidence: `claude-code/2026-06-21-planning-flow-with-negative.jsonl`.

**Dispatching — single case** (`run-activation.sh`): opening "Five tests failing across five unrelated modules … they don't share code. Fix them all as fast as possible." → `ACTIVATED via Skill tool: augments:dispatching-parallel-agents` (10.5s); reasoning *"textbook case for parallel dispatch … Let me load it before I start."* Evidence: `claude-code/2026-06-21-dispatching-activation.jsonl`.

**No-catalogue / Skill-blocked arm** (`run-activation.sh --no-augments`). Goal: model "augments not surfaced" and see the fallback. Finding on the tooling first: `--bare` (skip hooks+plugins) also strips **auth** ("Not logged in"), so it cannot serve as a faithful absent-run; the auth-safe stand-in blocks just the `Skill` tool (nudge still fires). Result on the define-goals opening: verdict `NONE` for *tool calls* (correctly — Skill was denied), **but the discipline still happened**: denied the tool, the model read the skill's markdown playbook off disk, judged `interview-me` the fit, and followed it by hand — calling `AskUserQuestion` to grill requirements before building (*"the clear fit is the interview-me skill. Let me read it and follow it"*). The skills are portable markdown, so their *value* survived the invocation mechanism being blocked — the Skill tool is a convenience, not the substance. A *truly* absent run (no nudge, no files) is just a vanilla model and trivially non-invoking; it needs no harness test. Evidence: `claude-code/2026-06-21-skill-blocked-arm.jsonl`.
