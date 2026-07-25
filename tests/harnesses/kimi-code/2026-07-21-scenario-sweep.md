# Activation record — per-phase scenario sweep (2026-07-21)

## Problem

The adapter shipped (v4.1.0) with a single live activation scenario
(`maintenance/debugging`). The scenario tree was completed to the shared
per-phase set (31 openings, identical text to the other adapters'), and this
sweep is the first live evidence beyond one skill: one scenario per SDLC
phase, driven bare (no prompt suffix) through `run-activation.sh`, i.e. the
`sessionStart.skill` nudge alone does the routing.

## Method

Kimi Code CLI 0.28.1, isolated temporary `KIMI_CODE_HOME` per run, this
checkout installed as a managed plugin, 180s cap, detection = a `Skill` tool
call in an assistant event compared against the scenario's filename.

## Results — 8/8 ACTIVATED, all on the expected skill

| Scenario | Chain observed |
| --- | --- |
| `analysis/spec-it` | `spec-it` |
| `planning/scope-it` | `scope-it` |
| `design/data-model` | `data-model` |
| `implementation/test-driven-development` | `test-driven-development` |
| `testing/verifying-completion` | `verifying-completion → using-augments` |
| `deployment/release-readiness` | `release-readiness` |
| `maintenance/post-mortem` | `post-mortem` |
| `common/interview-me` | `interview-me` |

No run errored, none needed the timeout note, and no scenario routed to a
wrong skill. Seven of eight went straight to the target skill without an
explicit `using-augments` invocation first — on this harness the session-start
nudge content is enough for direct routing; `verifying-completion` invoked the
router as well, in reverse order.

## Honest limits

- One scenario per phase, one run each — this proves the routing path per
  phase, not per-skill coverage of all 30 or run-to-run stability.
- `maintenance/debugging` was already proven on 0.27.0
  (`2026-07-19-debugging-activation.md`); `post-mortem` stood in for that
  phase here.
- The TDD run's chain contained **only** `test-driven-development`: `yagni`
  never fired during an implementation opening. Activation of the paired
  scope discipline at implementation time is a known gap, not proven here.
