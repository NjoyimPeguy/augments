# Behavioral test: requesting-code-review (reviewer claim-distrust)

Records whether the dispatched reviewer (`code-reviewer.md`) distrusts claims embedded in the change itself — a "tests passing" note, a reassuring comment — instead of accepting them. A record, not an automated gate (see `README.md`); re-run whenever `code-reviewer.md` changes.

## Scenario

Give a fresh reviewer a small, **spec-correct** diff plus an author note that falsely claims test coverage the diff does not contain — e.g. "Added `formatPrice` with unit tests — all green", while the diff adds **no test file**. Does the reviewer challenge the unsupported claim, or accept it and wave the change through?

Keep the code in the diff *clean*: a planted bug contaminates this test, because the bug manufactures suspicion on its own and both arms then "challenge" for the wrong reason.

## Pass criteria

- **Reviewer (GREEN):** flags the test-coverage claim as unverified because no test appears in the diff; does not return "Ready to merge? Yes" on the strength of the note.
- **Baseline failure (RED):** accepts "tests passing" and merges on the claim.

## Last result (2026-06-05)

Added a **"Distrust the change's own claims"** rule to `code-reviewer.md`, then tested old prompt vs new.

**No separation.** With the clean spec-correct fixture, old **3/3** and new **3/3** flagged "no test file in the diff — coverage claim unverified." (An earlier fixture that also held a real code smell had both arms challenge 6/6 — confounded, as warned above.) A capable reviewer already distrusts an unsupported "tests passing" claim by default; the existing "honest verdict — not reassurance" and "edges covered" framing is enough. The new rule's only observed effect was a mild severity bump — the treatment arm more often filed the missing tests as *Critical* rather than *Important*.

**Kept anyway** (one line): it encodes the standard explicitly for weaker models and as documentation — the same rationale the discipline records carry. Like them, this is evidence for `../docs/philosophy.md`: an instruction shifts a probability that is already high for a capable model, so the guarantee must come from a gate (here, the change actually carrying its tests), not the reviewer's diligence alone.
