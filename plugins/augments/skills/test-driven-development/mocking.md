# Test-Driven Development — Mocking

Most worthless tests come from mocking the wrong thing. The rules:

## Mock only at the boundary

Mock where your code meets something you don't own and can't control in a test: external services, the database, the clock, randomness, the network, the filesystem. Everything inside that boundary — your own modules — runs for real.

**Never mock your own code.** If a unit is hard to test without mocking modules you wrote, the design is too coupled. Inject the dependency instead (pass it in) so the test supplies a simple stand-in only at the boundary.

## Test the behavior, not the mock

A test that asserts "the mock was called" proves only that you set up a mock. Assert the observable result your caller would see. If removing the real component still makes the test pass, you are testing the mock.

## Keep mocks honest

- **Mirror the real shape.** A stub returning only the fields you currently read breaks silently when the code later needs a field you omitted. Match the real response.
- **Don't mock away the behavior under test.** If the test depends on a side effect, mocking the method that produces it guts the test.
- **One seam, one shape.** Structure external calls as specific functions (one per operation), so each test injects one simple stand-in instead of a branching mock factory.

## Keep production code clean

Cleanup or inspection helpers that exist only for tests belong in test utilities, never on the production type.
