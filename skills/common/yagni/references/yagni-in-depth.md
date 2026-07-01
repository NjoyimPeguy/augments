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
