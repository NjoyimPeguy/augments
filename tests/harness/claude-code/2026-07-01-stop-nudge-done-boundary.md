# Behavioural record — Stop-hook done-boundary re-nudge (2026-07-01)

Closes the structural gap behind "the testing/verify skills don't fire after a long
task": augments routes **once**, at SessionStart, but the done boundary — where
`verifying-completion` (then `requesting-code-review` / `finishing-a-branch`) should
fire — arrives at turn-end, after that one-shot routing, with nothing to re-route.
`hooks/claude-code/stop-nudge.sh` is the missing re-trigger. Prior art check first:
**superpowers has the same gap and does not solve it** — its `hooks.json` wires
`SessionStart` only, no `Stop`/turn-end logic — so this goes beyond it, not to parity.

## What it is (and what it deliberately is not)

A **routing re-nudge**, the done-boundary twin of the SessionStart nudge: when a turn
wraps up claiming the work is done, it re-surfaces the done-boundary skills once. It
blocks no action and certifies no verdict — the agent can acknowledge and proceed. It
is NOT a verdict gate (those live in `governance/` git/CI) and NOT an action-interrupt
(those stay project-local). See `docs/augments/harness-support.md`.

Guardrails that keep it a firm nudge, not a per-turn floor or a coercive loop:
- Fires ONLY on a completion claim in the wrap-up (`.last_assistant_message`), not every turn.
- Fires AT MOST ONCE — the `stop_hook_active` guard lets the agent finish once nudged.
- Skips obvious in-progress reports ("still failing", "not done yet").
- Reads only the Stop payload (no transcript parsing); fails open if it can't parse.

## Design correction (why the live loop mattered)

The first cut parsed the transcript for "did real work happen" and "was verify already
invoked". The live run exposed two things: (1) the hook **is** invoked in `claude -p`,
and (2) my transcript jq for the wrap-up text returned empty — the real Stop payload
already carries `.last_assistant_message`, so the transcript parse was both wrong and
unnecessary. Rewrote to payload-only: ~80 lines → **35**, no fixtures.

## Runs and results

**Offline (deterministic, no API — `test-stop-nudge.sh`):** 5/5.
done-claim → block · fixed-claim → block · "still failing / not done yet" → allow ·
non-claim question → allow · `stop_hook_active=true` (loop guard) → allow.

**Live (real `claude`, plugin loaded via `--plugin-dir`, Write allowed in a temp dir):**
| Scenario | Result |
| --- | --- |
| trivial "create greeter.py, don't test it, say done" | Stop-nudge **fired**; agent re-engaged and reasoned that verify-by-inspection sufficed and no PR workflow applied for a trivial file — then stopped cleanly (one fire). Correct: a nudge prompts the consideration, it does not force a skill. |
| non-trivial "implement parse_duration, tell me when it works" | chain `using-augments → verifying-completion`; Stop-nudge fired once; `verifying-completion` engaged. The reported failure mode is closed. |

## Honest caveats

- In a **fresh** headless run a capable model often routes to `verifying-completion`
  on its own (matches the 2026-06-30 yagni finding), so these runs prove the hook
  **fires, feeds back, and is bounded** — they do not cleanly attribute *causation* to
  the nudge. Its real value is the **drifted long session**, which the isolated harness
  can't reproduce (same structural limit noted in the yagni record).
- The payload-only design will re-nudge once even if verify already ran (it doesn't
  inspect prior turns). That is the accepted simplicity trade: one extra confirming
  turn, self-corrected by the "if already verified, state the evidence and stop" line,
  never a loop. Chosen over transcript-parsing complexity.
