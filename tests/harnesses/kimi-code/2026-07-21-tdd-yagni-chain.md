# Activation record — the TDD → yagni implementation chain (2026-07-21)

Companion to the Claude Code record of the same date (the full A/B and the
rationale live there). This is the Kimi Code half of the evidence, Kimi Code
CLI 0.28.1, bare parseDuration implementation opening through
`run-activation.sh --scenario`.

- **Baseline** (same-day per-phase sweep, pre-change): chain
  `test-driven-development` only — yagni never fired during implementation.
- **Round 1** (GREEN-step sentence only): chain `test-driven-development`
  only — the mid-cycle sentence alone did not fire on a bare opening here
  either.
- **Round 2** (plus the `using-augments` pairing line): chain
  `test-driven-development → yagni` — verdict ACTIVATED, the pairing fires
  from the session-start nudge content alone.

Honest limit: one run per arm; direction agrees with the Claude Code A/B but
run-to-run stability is not established on this adapter.
