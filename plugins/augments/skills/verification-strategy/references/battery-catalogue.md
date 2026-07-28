# The Battery Catalogue

Per layer: what it proves, what it can never prove, and how to recognize the
capability in any ecosystem. Named tools deliberately absent — ecosystems
rotate; the capabilities do not. Ask "what does this project already have that
does this?" before adding anything.

## 1. Unit layer

**Proves:** small pieces behave as specified, in isolation, fast.
**Never proves:** that the pieces are wired together, or that the specification
was right.
**Recognize it:** the project's own test runner and its `test` command. That is
the whole decision — the discipline of writing them first belongs to
`test-driven-development`.

## 2. Behaviour/acceptance layer

**Proves:** the running system does what was asked, end to end, in terms a
non-author can read.
**Never proves:** internal quality — a system can pass every scenario and be
unmaintainable inside.
**Recognize it:** executable scenario runners (Given/When/Then style is the
common spelling) or plain end-to-end tests driven through the system's real
entry points — HTTP, CLI, queue — never through its internals. The requirement
is *observable behaviour*: the scenario survives a rewrite of the
implementation, because it never names one.

## 3. Falsifiability audit

**Proves:** the other gates can fail — that they are gates at all.
**Never proves:** anything about the code directly; it audits the *tests*.
**Two moves, no tooling required:**

- **Name the change.** For each gate, state the production change that would
  make it fail. Cannot name one? The gate proves nothing.
- **Closing mutation check.** Break the code on purpose — invert a condition,
  delete a branch, empty a handler — run the battery, and watch it go red.
  Restore, watch it go green. A battery that stays green under a deliberate
  break is decoration; find which layer should have caught it and fix that
  layer.

**Where the ecosystem has a mutation-testing tool** (a runner that applies
small semantics-preserving-looking changes to the code and reports which ones
the suite failed to catch): set its kill-rate floor in CI. The manual check
above is the same idea without a tool; the tool only automates it.

## 4. Metric floors

**Proves:** the change did not drag the project below its own stated minimums.
**Never proves:** the tests are good — a suite can hit any coverage number and
catch nothing (that is what layer 3 is for).
**The one rule:** floors fail the build; targets do not exist. A coverage
*target* is gamed on day one — tests written for the number, assertions
optional. A coverage *floor* only refuses to ship below it, which is the
correct relationship between a metric and a gate. Set floors from what the
project already achieves, then ratchet up only when the suite earns it.

## 5. CI wiring

**Proves:** the gates ran, on this change, on a machine nobody controls.
**Never proves:** anything about a change that never went through CI.
**The one rule:** every gate runs in CI on every change. A gate that only runs
locally decays silently — skipped under deadline, absent on a fresh machine,
gone in a month. If a gate cannot run in CI, say so plainly and treat it as a
manual procedure, not a gate.

## The two traps

- **String-presence tests.** Asserting that output or a file *contains some
  text*. The text can be right while the behaviour is wrong, and the assertion
  survives any refactor that keeps the wording. The observable is behaviour,
  never text.
- **Change-detector tests.** Assertions that can fail yet protect nothing —
  a constant echoed back, a snapshot of noise, a mock asserted to have been
  called. They fail when the code changes, not when the behaviour breaks, so
  the suite goes red for the wrong reason and green for no reason. If removing
  the behaviour does not fail the test, delete the test — it is decoration
  with a runtime cost.

## Reading the battery a year later

A healthy battery: every layer runs from one command, each gate has been seen
to fail, the floors sit just below current reality, and nobody remembers the
last time they were tempted to skip it. An unhealthy one: prose about testing,
a suite nobody runs, and a coverage badge.
