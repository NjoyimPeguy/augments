# Activation: routing and enforcement

SDLC Skills is useful only when the agent reaches the applicable skill and the
result then passes a real project gate. Those are different problems.

## Routing is probabilistic

A session-start pointer sends the agent to `using-sdlc-skills`, whose descriptions
and procedure route from the current request and project state. The pointer is
re-applied on lifecycle events where a harness supports that behavior.

This is persuasion applied to a nondeterministic generator. Strong wording can
improve activation; it cannot prove that a skill fired or that its output is
correct. A thin live harness smoke measures activation for a particular run.

For a wide or preservation-sensitive transformation, the router sends the work
through `migration-strategy` and `verification-strategy` before ordinary
feature implementation. That boundary belongs in the skill contracts. A generic
prompt classifier cannot reliably decide project risk.

## Gates decide whether artifacts advance

Tests, compilers, static analysis, review verdicts, coverage thresholds,
differential checks, release checks, and rollback criteria operate on artifacts
or promotion state. Projects wire the applicable gates into CI, protected
integration paths, and release controls.

SDLC Skills does not ship a universal project CI template. The commands, platforms,
thresholds, and failure responses are properties of the adopting project.

## Small in-session backstops

Supported adapters may provide two narrow reminders:

- a pre-edit guard requiring the TDD/YAGNI pair for recognized code edits; and
- a Stop nudge when the assistant explicitly claims completion.

These catch accidental skips on observable tool paths. They are not security
boundaries, cannot cover shell writes or every harness, and do not replace the
artifact-level gate.

## The honest line

Routing evidence says what one nondeterministic run did. A deterministic
structural check says whether packaging or script logic satisfies its exact
contract. Only the adopting project's real gates can establish whether generated
code is fit to advance.
