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

**Kept anyway** (one line): it encodes the standard explicitly for weaker models and as documentation — the same rationale the discipline records carry. Like them, this is evidence for `docs/augments/philosophy.md`: an instruction shifts a probability that is already high for a capable model, so the guarantee must come from a gate (here, the change actually carrying its tests), not the reviewer's diligence alone.

## Last result (2026-06-09): general-reviewer edits + four specialist depth passes

Edited `code-reviewer.md` (three additive rules: enriched bug list; "stay on the diff, keep the bar high"; "breadth, not rabbit holes") and added four optional, loaded-on-demand specialist dispatch prompts — `silent-failures-reviewer.md`, `type-design-reviewer.md`, `test-coverage-reviewer.md`, `comment-accuracy-reviewer.md` — plus a menu in `SKILL.md` pointing to them. Each specialist is breadth-deferred: it opens by stating the general pass covers X and its job is the depth X only skims, so the passes don't duplicate each other.

**Proof obligation, per `../../CLAUDE.md` "Editing a skill":**

- *Trigger* (`description`) unchanged → no triggering re-run owed.
- The claim-distrust discipline this record tests was **not reworded** — the `code-reviewer.md` edits are additive and adjacent, not a change to the "Distrust the change's own claims" rule. That specific test (above) still holds; not re-run.
- The four specialists are reviewer prompts, not discipline-under-pressure bodies. Proven by *watching them work*, not by assertion.

**Watched it work (GREEN, directional — a single dispatch each, not a tally).** Fixture: a newly-added `chargeCard()` whose `catch` returns `{ ok: true, id: null }`, masking a gateway failure as success, with **no test file** in the diff.

- `silent-failures-reviewer.md` → flagged the masking fallback **Critical**: named the eaten failure (declines/timeouts/outages discarded), the three harmed parties, and the fix (re-throw, or `ok: false`). Stayed on the error-visibility axis.
- `test-coverage-reviewer.md` → flagged the untested failure path **Critical** with the specific cases that belong and where; added boundary/negative gaps (amount, `customerId`) and an over-mocking risk. Stayed on the coverage axis — it cited the same line, but as *why the missing test matters*, not as a duplicate bug report.

**All four now dispatched (gap closed, same day).** After the depth audit below, the remaining two were watched on planted fixtures too:

- `type-design-reviewer.md` → a `DateRange` with a comment-only `start ≤ end` invariant, no construction check, public mutable fields, and an unguarded `setEnd`. Flagged **Critical** and named *three* independent violation paths (bad constructor args, `setEnd`, direct field write that makes the setter moot) — the encapsulation and enforcement angles firing exactly as designed. No numeric score; verdict deferred.
- `comment-accuracy-reviewer.md` → a `hasDuplicate()` whose doc claims `O(n)` "single pass" over a nested-loop O(n²) body, with a `list`/`items` param-name drift. Flagged the false complexity claim and the drift **Critical**, added the missing `===`-semantics context, and recommended removing a redundant `@returns`. Advisory, cited, quoted comment against code.

Structural gate (`validate-skills.sh`) passes for all five files.

**Note (2026-06-09, portability wording — no re-run owed):** `SKILL.md` step 3 and `code-reviewer.md` named one harness's conventions file by its specific filename; replaced with harness-neutral wording ("the project's conventions file" / "its agent-instructions file") per the authoring rules. The claim-distrust rule this record tests, the verdict format, and all discipline content are untouched — a naming substitution, not a behaviour change.

**Depth audit (same day).** The first drafts were written from condensed source summaries, which had dropped real checks. Re-read the four source agents verbatim and added the behaviour-shaping checks that were missing: silent-failures — fallback-to-a-fake, skipped cleanup, silent give-up, unactionable surfacing, enumerate-what-a-broad-catch-hides; type-design — what counts as an invariant (cross-field, state transitions), immutability as enforcement, inconsistent enforcement; comment — false perf/edge claims; test-coverage — check existing/integration coverage before flagging, name the regression each gap catches. Deliberately *not* imported (principled, not omission): numeric rating scales (verdict-as-precision, per `../../docs/augments/philosophy.md`), one project's internal logging/error-id conventions (not portable), and frontmatter example blocks. Specialists run 32–44 lines — on-demand siblings, so unbudgeted; "earn every line" here means no padding, not brevity at the cost of a check.
