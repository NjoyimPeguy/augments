# Activation: routing and enforcement

SDLC Skills is useful only when the agent reaches the applicable skill and the
result then passes a real project gate. Those are different problems.

## Routing is probabilistic

The `using-sdlc-skills` router is injected at session start as **resident
context**, not as a pointer to it, and re-applied on the lifecycle events where a
harness reports that context was lost — start, resume, clear, compaction.

The distinction is the whole design. A pointer is cheap (~90 tokens) but it buys
only a *request*: that the agent spend a discretionary tool call loading the
router before working. That call is skippable, and it does get skipped — measured
on this repository, on exactly the task the router governs. Injecting the body
costs more per context epoch and removes the step that can be skipped: the
routing rules are simply present, so there is nothing left to forget.

This is still persuasion applied to a nondeterministic generator. Resident text
raises the odds that the right skill fires; it cannot prove one fired or that its
output is correct. A thin live harness smoke measures activation for a particular
run — nothing more.

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

Supported adapters may provide one narrow reminder: a pre-edit guard requiring
the TDD/YAGNI pair for recognized code edits. It fires on a real boundary — an
edit is about to happen — and stays silent otherwise.

It catches accidental skips on an observable tool path. It is not a security
boundary, cannot cover shell writes or every harness, and does not replace the
artifact-level gate.

A reminder that fires on a *cadence* rather than a boundary does not belong
here. A turn-end reminder keyed on completion wording re-spends its full text
every time the wording matches, in a session where the router body and the skill
descriptions are already resident — and where it blocks turn-end, it buys that
repetition with an extra model turn. Carry the routing in the always-loaded
surface instead, and re-apply it where context is actually lost.

## The honest line

Routing evidence says what one nondeterministic run did. A deterministic
structural check says whether packaging or script logic satisfies its exact
contract. Only the adopting project's real gates can establish whether generated
code is fit to advance.
