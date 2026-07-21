# Activation record — the TDD → yagni implementation chain (2026-07-21)

## Problem

`yagni` reliably fails to load at the moment it matters: while implementation
code is being written. Measured 2026-06-30 ("yagni never loads in
implementation") and re-confirmed today on the other adapter's live sweep —
a bare implementation opening routed to `test-driven-development` and the
chain ended there. Description tuning was already A/B'd (2026-06-30, no
activation separation), so the lever here is **chaining**, not the trigger.

## Change (two anchors, one moment)

1. `test-driven-development` GREEN step: on first entering GREEN — the moment
   implementation code starts — invoke `yagni`; TDD proves what you build
   *runs*, yagni governs *how much* you build.
2. `using-augments` composition paragraph: `test-driven-development` runs
   **paired with `yagni`** — the moment implementation starts, invoke both.

## Evidence — the A/B that found the load-bearing anchor

Probe: the bare `implementation/test-driven-development` opening
(parseDuration), full run to completion, working tree loaded via
`--plugin-dir`, chain = every `Skill` tool_use in assistant events.
Claude Code 2.1.216; the other adapter probed with its own runner the same
way.

**Round 1 — GREEN sentence only (router unchanged):**

- This harness: `using-augments → test-driven-development →
  verifying-completion → requesting-code-review → receiving-code-review` —
  **no yagni**, even though the served skill body contained the new sentence
  (verified in the stream).
- Other adapter: `test-driven-development` only — **no yagni**.
- Compliance arm (body loaded with an explicit "follow it"): yagni invoked
  immediately — the sentence works when the body is *followed*, but a
  mid-cycle sentence alone loses to momentum on a bare opening.

**Round 2 — both anchors:**

- This harness: `using-augments → test-driven-development → **yagni** →
  verifying-completion → requesting-code-review → receiving-code-review`,
  with the yagni invocation landing **before the first Write** — test first,
  then implementation, scope discipline loaded at the exact moment.
- Other adapter: `test-driven-development → **yagni**`.

So the router pairing is what makes the chain fire on a bare opening; the
GREEN sentence anchors *when*. Both kept.

## Round 3 — description clarity rewrite, re-measured

Same day, `yagni`'s description was rewritten for clarity (maintainer found
the double-arm sentence vague): it now leads with the WHEN (implementation
starting, as `test-driven-development`'s pair) and names the two arms as
building MORE than asked vs delivering LESS than asked — "build exactly what
the task needs — no more, no less". Both arms, the pairing, and the skip
clause are retained; the "distinct from TDD" explainer moved fully into the
pairing framing. Re-probed bare on both harnesses: the chain held unchanged
(this harness: `using-augments → test-driven-development → yagni` before the
first Write; the other adapter: `using-task-branches →
test-driven-development → yagni → using-augments → verifying-completion →
requesting-code-review`). One run per harness.

## Discipline safety

The TDD body change was pressure-re-run (skip-tests order): held, no
regression — see `behavioral/test-driven-development.md`, update 2026-07-21.

## Honest limits

- One run per arm per harness — direction is consistent across two harnesses
  and an ablation, but run-to-run stability is not established.
- The chain is proven for a fresh-session implementation opening. A long
  session that reaches implementation after many turns is the decay regime
  (`scenarios/decay/`) and is not covered by these probes.
