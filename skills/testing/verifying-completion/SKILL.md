---
name: verifying-completion
description: Use before claiming work is complete, fixed, passing, or done — and before any commit or PR — by running the actual check and reading its output rather than asserting "should work." Especially when you feel the pull to declare success without running anything; if you can't run the check, say so rather than claim done.
---

# Verifying Completion

Evidence before claims. "Should work", "looks right", and "probably fine" are not verification — they're guesses in a confident voice. This is a discipline skill: you will be tempted to claim done without checking, especially when tired or rushed, and the point is not to.

## When to use

- Before any statement that work is complete, fixed, passing, or done — including paraphrases and expressions of satisfaction ("great, that's sorted").
- Before committing or opening a PR.
- This gate does **not** scale down with task size; only *which* check is appropriate does.

## The gate

1. **Identify** — what check would actually prove this claim?
2. **Run** it fresh and in full — not a cached result, not a similar run from before.
3. **Read** the real output: exit status, pass/fail counts, the actual values.
4. **Confirm** the output supports the *exact* claim — not a near neighbour.
5. **Only then** state it, with the evidence.

Skip any step and you have not verified — you have asserted.

## When no automated check exists

Some claims — visual output, real-browser flows, realtime UI, subjective usability — have no command that returns pass/fail. The gate is then human-run, but it is still a gate: structure it as a traceable acceptance matrix with evidence, never self-certify a step a human must judge, and treat an unrun row as pending, not passed. Automate everything that *can* be; this covers only what genuinely can't. See `manual-acceptance.md`.

## Hard stops

- Never claim a test passes without seeing it pass *this* run.
- Never claim a bug is fixed without reproducing it first, then confirming the fix removes it.
- Never claim done when the only evidence is a subagent's "success" report — read the actual diff and output yourself.
- A check that has never been seen to fail is suspect — see `hollow-verification.md`.
- A test known to fail intermittently is **not** verified by one green run — a flaky pass is unexplained nondeterminism, not proof. Root-cause it (`debugging`); don't build on it.
- Verified is not reviewed: the gate proves your claim about the checks, not that the change is right. At a feature-level done boundary — merging, opening a PR, or reporting a non-trivial change complete — green hands off to independent review (`requesting-code-review`); don't end the chain at "verified".

## When you are tempted to skip

| The thought | The reality |
| --- | --- |
| "It should work now" | Then running it costs seconds and makes it a fact. Run it. |
| "I'm confident" | Confidence is not evidence. The output is. |
| "The types check, so it works" | Types ≠ compiles ≠ tests pass ≠ requirement met. Each is a different claim. |
| "A partial check is enough" | Partial proves the part you checked and nothing else. |
| "I already ran something like it" | Stale or similar is not fresh and exact. Run this one. |
| "The agent said it succeeded" | Its report is a claim, not evidence. Check the diff and output. |
| "I'm tired / out of time" | Exhaustion does not make an unrun check pass. |
| "I said it a different way" | The rule covers implications and synonyms, not just trigger words. |
| "It's green right now" | A flaky test passing once is luck, not proof — the red you haven't explained is still there. Root-cause it. |
| "All gates are green, so it's done" | Green proves the checks pass, not that the change is right. A non-trivial change still owes fresh eyes before "done" — `requesting-code-review`. |

## Relationship to plans

A per-task **Evaluator** and a plan-level **Acceptance** name *which* check to run. This discipline is what makes sure that check is actually run fresh, its output read, and the claim made only after.

## Common mistakes

- Expressing satisfaction ("perfect!") before the check has run.
- Reporting a subagent's claim as your own evidence.
- Treating a green linter as a green test suite.
- Writing a regression test you never watched fail — see `hollow-verification.md`.
