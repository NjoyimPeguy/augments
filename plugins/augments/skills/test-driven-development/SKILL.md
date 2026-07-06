---
name: test-driven-development
description: "ALWAYS invoke before writing implementation code for any feature or bugfix with real logic or behavior — the failing test comes first, and writing code before the test is the mistake. Fires hardest whenever you feel the pull to skip the test \"just this once.\" The ONE exception: throwaway spikes, pure config, or content with no logic."
---

# Test-Driven Development

Write the test before the code. The test is how you find out the code works — and "should work" is not "works". This is a discipline skill: you *will* feel pressure to skip it, and the whole point is not to.

## When to use

- Any feature or bugfix with logic or behavior.
- A bugfix: start with a failing test that reproduces the bug, then fix it.
- **Skip** for throwaway spikes (then delete the spike and rebuild under a test), pure config or content with no logic, or generated code.

## The cycle

Before the first test, pin down the public interface — what goes in, what comes out, the named behaviors. If you can't yet name the test, the interface isn't decided yet.

**RED — write a failing test.** One small test for the next behavior. Run it. Watch it fail, and read the failure: it must fail because the behavior is missing, not because of a typo or an import error. A test you never saw fail proves nothing. Keep the failure you watched — quote a line of it in the cycle's commit message or task notes: an after-the-fact "I watched it fail" is an assertion, the saved output is evidence.

**GREEN — make it pass, minimally.** Write the least code that turns the test green. No extra cases, no speculative generality. Run it; confirm green.

**REFACTOR — clean up under green.** With the test passing, remove duplication and fix names and structure. Re-run; it stays green. Commit. Then the next RED.

## Hard stops

Each of these means **stop, delete the unverified code, and restart the cycle** — no exceptions:

- Production code exists with no failing test behind it.
- A new test passes on its first run — you never saw it fail, so you don't know what it checks.
- You are adapting code you wrote "just to explore" instead of re-deriving it under a test.
- You hear yourself say "just this once" or "this one is different".

## When you are tempted to skip

| The thought | The reality |
| --- | --- |
| "Too simple to test" | Simple code still breaks, and the test costs seconds. Simplicity argues *for* a quick test, not against it. |
| "I'll write the test after" | A test written after passes immediately — it records what the code *does*, not what it *should* do, and silently skips the cases the code already gets wrong. |
| "I already tested it by hand" | Manual checks aren't repeatable and leave no record. The next change re-breaks it and no one notices. |
| "Test-first slows me down" | Debugging untested code is the slow path. Test-first is faster, not merely safer. |
| "I'd lose the code I wrote" | Sunk cost. Unverified code is a liability, not an asset. Delete it and re-derive it under a test in minutes. |
| "The test is hard to write" | That is the design telling you the interface is hard to use. Fix the interface, not the test. |
| "There's no test framework here" | Add one, or write the smallest assertion that can fail. "No framework" is not "no verification". |
| "It's just a refactor" | Refactoring without a green test is editing blind. Get a test green first, then refactor under it. |

## Common mistakes

- Testing implementation details instead of behavior — such tests break on every refactor. See `reference.md`.
- Asserting that a mock was called instead of the real result — see `mocking.md`.
- Writing all the tests for a feature before any code — they end up asserting imagined behavior. Keep it to one failing test at a time.
- Over-building in GREEN — write only what the current test demands.
- Skipping the "watch it fail" step, so a test that asserts nothing looks like it passed.

See `reference.md` for tests that survive refactors, and `mocking.md` for where (and where not) to mock.
