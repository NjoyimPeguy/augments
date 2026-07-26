# Spec Review (optional)

A fresh-context subagent catches what the spec's author can't — you're anchored to your own assumptions. Use for a high-stakes spec (wide blast radius, ambiguous domain, or one many tasks will depend on). **Single pass, not a loop.**

This reviews the **requirements** — before anyone designs or builds against them.

Dispatch a subagent with the spec and the codebase, and this brief:

> Review the requirements spec at `{{spec file}}`. Flag **only** issues that would lead to building the wrong thing or make a requirement impossible to test — skip prose style and detail-level variation. Check six things:
>
> 1. **Testable** — every functional requirement is a behaviour that can pass or fail, not a wish ("rejects an expired token with a 401", not "good auth").
> 2. **Acceptance criteria** — every requirement has at least one, and it is a real check, not a restatement of the requirement.
> 3. **What, not how** — no design or implementation smuggled into the requirements (a named cache, a specific endpoint). Flag it; don't fix it.
> 4. **Complete vs the goal** — every part of the stated goal has a requirement, and every requirement traces back to the goal (no gaps, no orphans).
> 5. **No contradictions** — no two requirements, or a requirement and its criterion, that can't both hold.
> 6. **The form is honest and it exists** — every artifact the spec references (test file, mockup, reference implementation, rubric) resolves to a real path, and every executable one runs and fails for the right reason. Flag any claim of verification with nothing behind it, and any behavioural requirement left as prose that a failing test would have pinned exactly.
>
> Return a short list, one line each: `requirement — issue — fix`. If nothing blocks correct, testable implementation, say so in one line.

Apply the fixes to the spec yourself. Don't re-dispatch unless the spec changed substantially.
