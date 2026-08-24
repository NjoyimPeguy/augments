# Activation: routing and enforcement

SDLC skills is useful only when the agent reaches the applicable skill and the
result then passes a real project gate. Those are different problems.

## Routing is probabilistic

The `using-sdlc-skills` router is injected at session start as **resident
context**, not as a pointer to it, and re-applied on the lifecycle events where a
harness reports that context was lost — start, resume, clear, compaction.

The distinction is the whole design. A pointer buys only a *request*: that the
agent spend a discretionary tool call loading the router before working.
Injecting the body costs more per context epoch and removes that discretionary
step: the routing rules are already present.

The router body is one of two resident surfaces, and they do different jobs. The
other is the descriptions: whichever skill fires, fires because its description
matched the opening, so a description carries the vocabulary of the situation and
nothing else. Emphasis has no work to do there — it does not make a trigger match
— and every character it spends is one not spent on a context that would. Firm
language goes in the body, which is read only once the skill has been reached.

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

SDLC skills does not ship a universal project CI template. The commands, platforms,
thresholds, and failure responses are properties of the adopting project.

## Scoped implementation-entry backstop

Claude Code and Kimi Code run a pre-tool guard on their structured edit-class
actions for code paths. Claude Code checks native skill invocations in its
transcript, and Kimi Code records native skill invocations through its post-tool
lifecycle event. The edit is allowed only after the current session has loaded
both `test-driven-development` and `yagni`.

Codex does not run this guard. Its adapter has no authoritative skill invocation
receipt, and absence of an auxiliary file-read receipt cannot prove that a skill
was skipped. Treating that missing evidence as a denial can deadlock a valid
session, so routing and project gates carry the discipline there.

This is deliberately a narrow backstop. It covers the named structured edit
actions and common code extensions. It does not cover shell commands, generated
files written by another action, every programming language, or harnesses that
do not expose the required lifecycle evidence. Its denial message states that
scope. Project tests and promotion gates remain responsible for the artifact.

A reminder that fires on a *cadence* rather than a boundary does not belong
here. Carry routing in the always-loaded surface, re-apply it where context is
actually lost, and reserve hook denials for an observable action boundary.

## The honest line

Routing evidence says what one nondeterministic run did. A deterministic
structural check says whether packaging or script logic satisfies its exact
contract. Only the adopting project's real gates can establish whether generated
code is fit to advance.
