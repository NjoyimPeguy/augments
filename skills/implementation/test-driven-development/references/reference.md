# Test-Driven Development — Reference

How to design tests worth keeping. (The discipline — when and why to test first — is in `SKILL.md`; this is the craft of the test itself.)

## Test behavior, not implementation

Assert what the unit does through its public interface — inputs and observable outputs — not how it does it. A test that reaches into private state or asserts on internal calls breaks every time you refactor, even when behavior is unchanged. If a behavior can't be reached through the public surface, that's a design signal, not a reason to test internals.

## One behavior, one reason to fail

Each test covers one behavior and should fail for exactly one reason. Name it for the behavior, not the method: `rejects an email with no @`, not `test_validate`. When it fails, the name alone should tell you what broke.

## Minimal assertions

Assert the one thing the test is about. Over-asserting couples the test to incidental details and turns every unrelated change into a failure.

## Tracer bullet for new capabilities

For something genuinely new, get one thin end-to-end slice green first — the smallest path from input to observable output — then drive the rest with more red-green cycles. It proves the pieces connect before you invest in depth.

## Bugfixes start RED

Reproduce the bug as a failing test first. That test both proves the bug is real and becomes the regression guard that stops it from coming back.

## Testable interfaces

When a test is hard to write, change the design, not the test:

- **Inject dependencies** — pass what a unit needs in, rather than constructing it inside. A test can then supply a stand-in without reaching into internals.
- **Return values over mutation** — a function that returns a result is trivial to assert; one that mutates hidden state is not.
- **Keep the surface small** — fewer methods and parameters (a small interface over a large implementation) means fewer ways to misuse it and fewer things to test.

## Don't let the test deform the domain

Making code testable should *improve* the design, not corrupt it. Two ways a test can deform the thing it tests:

- **Parameter pollution** — widening a domain signature with infrastructure (`createOrder(order, clock, idGenerator, random)`) purely so a test can pin those down. Injecting genuine collaborators is good design; but a clock or an id generator is ambient infrastructure — hide it behind the seam (a provider the unit holds, a wrapper you substitute in the test) rather than threading it through the public domain API.
- **Helper leakage** — promoting an internal (`isAmountValid`, `normalizeName`) to the public surface only so a unit test can reach it. If it has no standalone domain meaning and no production caller, asserting on it directly is testing an implementation detail. Exercise it through the public behavior, or extract it into its *own* unit with a real interface — don't expose it in place.

Same signal as a hard-to-write test: if the only reason a parameter or method is public is the test, the seam is in the wrong place. Move the seam, don't widen the API.

## Refactor targets

In REFACTOR, with tests green, look for: duplication, over-long functions, shallow modules (a wide interface with little behind it), feature envy (a function more interested in another type's data than its own), and primitive obsession (bare strings or ints where a small type belongs). When you extract private helpers, keep the tests on the public interface — don't let them couple to the new internals.
