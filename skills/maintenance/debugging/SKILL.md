---
name: debugging
description: Use when encountering any bug, test failure, or unexpected behavior — including a test that passes only intermittently (a flaky test is an unexplained bug to root-cause, not a green to trust) — before proposing or applying a fix, and whenever you feel the pull to guess-and-patch. Finds the root cause through a reproduction you can run. Skip only for a one-line error you can see and fully explain.
---

# Debugging

Root cause before fix. A patch you can't explain isn't a fix — it's a guess that happened to quiet the symptom. This is a discipline skill: under pressure you'll want to try something and see if it helps, and the point is not to.

## The method

**1. Build the feedback loop — this is the skill; the rest is mechanical.** Get a fast, deterministic, runnable pass/fail signal for the bug, and spend disproportionate effort here. If you can't build one, *stop and say so* — list what you tried and ask for access or a captured artifact; don't debug on vibes. Once you have a loop, sharpen it (faster, more deterministic). A flaky bug isn't exempt — raise its reproduction rate (loop it, add stress, narrow the timing) until it's debuggable. See `feedback-loop-options.md`.

**2. Reproduce.** Confirm the loop triggers *this* bug, not something near it.

**3. Hypothesize — 3 to 5, ranked, falsifiable.** Each needs a prediction: "if X is the cause, changing Y kills it." No prediction means it's a vibe — discard it. One hypothesis anchors you on the first plausible idea; generate several. And check each one's evidence was observed *this* session, not inherited from earlier context — an unverified claim is an assumption, not a fact.

**4. Instrument — read evidence, don't assume.** Probe to confirm or kill the top hypothesis. In a multi-layer system, add a probe at *every* boundary, run **once** to see where it breaks, then investigate that layer. Tag every debug log with a unique prefix so cleanup is one grep.

**5. Fix the root cause — Option Zero first.** The cause is often *outside* the application code: a config value, an env var, a dependency version, a feature flag. Rule those out before reaching for a code change or a migration — the smallest correct fix wins, not the most ambitious one. Then turn the reproduction into a failing test at the correct seam — one that exercises the real bug at the real call site — and fix it (use `test-driven-development`). If no correct seam exists, that *is* the finding: name it as architectural debt and fix without the regression test.

**6. Clean up and learn.** Remove the tagged logs. In the commit, note which hypothesis was right and what would have prevented the bug.

## After three failed fixes, stop

Three failures is a signal: the problem is the architecture, not the bug. The tells — each fix reveals new coupling, each needs a big refactor, or each creates a new symptom elsewhere. Stop and discuss before attempt four.

## Hard stops

- Never patch a symptom you can't trace to its cause.
- Never apply a fix you can't explain.
- Never declare it fixed without re-running the loop and seeing the bug gone (use `verifying-completion`).

## When you are tempted to guess

| The thought | The reality |
| --- | --- |
| "I think I know the fix" | Then you can predict what proves it. Predict, then check. |
| "No time to reproduce" | Guess-and-check is the slow path. The reproduction is the fast one. |
| "It's probably the X" | "Probably" is a hypothesis, not a diagnosis. Test it. |
| "One more attempt" (after three) | Three failures means wrong layer. Question the architecture, don't fix again. |
| "The log looks fine" | Read every line. The bug is in the one you skimmed. |
| "It works on my machine" | Then the difference between the machines is the bug. Find it. |
