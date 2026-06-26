# Activation record — routing-first pivot (2026-06-26)

Records the activation re-measurement after the routing surface was re-architected.
Activation results are ephemeral (real API calls, not CI) — re-run the scripts for
current truth. This file states what was changed and what the runs showed on the day.

## What changed (the always-loaded routing surface)

- **`hooks/claude-code/context.md`** slimmed from a full routing procedure to a thin
  **pointer**: "before any non-trivial request, invoke `using-augments` to route." It
  re-fires on resume/compact, so it is the durable re-trigger.
- **`skills/common/using-augments/SKILL.md`** now carries the routing *discipline* the
  bootstrap used to hold: a deterministic-engineer mental-model graph, a red-flags list,
  and a rationalization table. The pointer and the skill no longer duplicate each other.
- **`skills/common/dispatching-parallel-agents`** description de-hedged from a
  burden-of-proof trigger ("genuinely / provably independent… share no files, no state,
  no ordering" + "quick enough inline") to a **positive, observable** trigger ("more than
  one piece of work that don't touch the same files"); the independence *check* stays in
  the body.

These are **activation** changes (triggers + the always-loaded body), so activation was
re-measured on the real `claude` CLI against the working tree (`--working-tree`).

## Runs and results

| Run | Command | Result |
| --- | --- | --- |
| Router fires | `run-activation.sh --scenario-file scenarios/common/using-augments --working-tree` | **ACTIVATED** `augments:using-augments` |
| DPA via the router | `run-activation.sh --scenario-file scenarios/common/dispatching-parallel-agents --working-tree` | **ACTIVATED** — chain reaches `augments:dispatching-parallel-agents`; the body's independence-check held; on an empty tmp dir it **refused to invent work** rather than hallucinate |
| Momentum holds | `run-flow.sh --flow scenarios/momentum/flow --working-tree` | turns 1–4 (conceptual Q&A) fired **no** skill (no over-routing); turn 5 (a real bug) fired `augments:debugging` — **routing survived the four-turn "just answer" groove** |
| Detector | `run-activation.sh selftest` | **PASS**, incl. the new routing-first chain fixture |

## The routing-first finding (and the runner fix it forced)

Because the pointer names `using-augments`, the model routes **through the router first**
on a non-trivial task — the first `Skill` call is the router, not the answer. The runners
detected only the *first* call, so every per-skill scenario read as `using-augments`
(a false mismatch). Both runners were made **chain-aware**: they now judge whether the
expected skill appears anywhere in the `using-augments → X` chain (route-then-fire), and
report the whole chain. A committed offline fixture (`fixtures/routed-dpa.jsonl`) plus a
`selftest` assertion lock this in without an API call.

## Honest caveats

- Single runs, not N-of-N — these confirm the mechanism fires, not a hit-rate.
- Scenarios run in an isolated empty temp dir (faithful to a brand-new-project opening,
  but no real code to act on — the value observed is *routing*, not task completion).
- Headless `claude -p` resume may not induce the same context decay as a long live
  session; the momentum flow is *conversational* momentum, not execution momentum.
- No deterministic gate proves routing — per `docs/augments/philosophy.md`, routing is
  firm persuasion; the reliability lives in the gates the skills define.
