# YAGNI in depth

Expanded technique behind `../SKILL.md`. Loaded on demand.

## The ladder, with the reasoning

1. **Need at all?** Most "we might want X later" is a guess about the future. Build for the requirement in front of you; the future requirement, when it arrives, will be more specific than today's guess.
2. **Already here?** Search before you write. The single most common waste is re-implementing a helper that already lives a few files over — slightly differently, so now there are two.
3. **Standard library?** Battle-tested, zero dependency cost, familiar to the next reader.
4. **Native platform feature?** A platform primitive (a built-in control, a database constraint, a language feature) beats hand-rolled code you now own and must maintain.
5. **Installed dependency?** If it's already in the tree, use it. Adding a *new* dependency for what a few lines do imports a maintenance and supply-chain cost forever.
6. **One line?** Often the honest answer once you've climbed the ladder.
7. **Minimum that fully works** — and not a rung lower.

## A worked example: minimal vs bloated

Task: debounce one text input's change handler.

- **Bloated:** a generic debounce hook with configurable delay, leading/trailing options, cancellation, its own test suite, exported from a shared `utils` barrel — ~100 lines, serving one caller.
- **Minimal:** a few inline lines that clear and reset a timer. Promote it to a shared utility the day a *third* input needs it — not before.

The minimal version isn't "lazier" in the bad sense: it fully debounces the input. It just declines to build a library for a problem you have exactly once.

## Craft is not scope — the checklist

The ladder answers *how much* to build; this answers *how well* to write it. None of these add scope — they decide whether the minimal code stays minimal over its life.

- **Match the file you're in.** Its naming, structure, and idioms are the standard for this change; a diff that reads like a foreign author is a defect even when it's short. If the file's conventions are themselves the problem, say so — don't silently import a second style.
- **Name for the domain, not for brevity.** A two-letter variable inside twenty lines of logic isn't lean — it's encrypted. One concept, one name, taken from the codebase's own vocabulary; a synonym you introduce is a second concept the next reader must disprove.
- **Comment the *why*, never the *what*.** One line above logic whose reason isn't obvious from the code; nothing above the obvious — noise comments are bloat too, and stale comments are lies.
- **Simple beats clever.** A clever one-liner you must re-derive on every read is deferred work with the same cost curve as a stub. If the clever version needs a comment to be parseable, the plain version is the minimal one.
- **Handle the edges the task implies.** Empty input, failure paths, boundary values — robustness is correctness, and correctness is never the thing you minimise.

## A worked example: minimal vs cryptic

Task: parse a `key=value` config line, ignoring `#` comments.

- **Cryptic:** `const [k, v] = l.replace(/#.*$/, '').split('=').map(s => s.trim())` — one line, works, and every reader stops to re-derive the regex and the destructure.
- **Minimal and readable:** the same three steps with names (`stripComment`, `parsePair`) or a one-line *why* comment. Same size, no re-derivation cost.

The ladder doesn't reward compression. Between two solutions of equal scope, the one the next reader understands is the minimal one — measured over the code's life, not its line count.

## Comprehension first — why the smallest diff can be the wrong one

The lazy reflex says "smallest touch-point." But the smallest diff you don't *understand* is laziness dressed as efficiency. Trace the flow first:

- A bug reported on one path often lives in a shared helper several callers route through. Patch the named path and you've shipped a smaller diff that leaves the sibling callers broken — a second bug, and more total work once it's reported.
- Fixing the shared function once is both the *correct* fix and, counting the follow-ups you avoid, the *smaller* one. Correctness and laziness point the same way when you measure the whole cost.

## The carve-out list — never minimise these away

- Input validation at any trust boundary (user input, network responses, deserialization).
- Error handling that prevents data loss or corruption.
- Security controls (authorization checks, output escaping, secrets handling).
- Accessibility affordances the interface needs to be usable.
- Real-world calibration (timeouts, retries, limits tuned to how the system actually behaves).
- Anything the task explicitly asked for.

## Mark deliberate simplifications

When you knowingly take the simpler road, name its ceiling and the upgrade path in one line — "single global lock now; per-key locks if throughput becomes a problem" — so the next reader knows it was a decision, not an oversight.
