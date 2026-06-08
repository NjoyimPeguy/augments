# Testing a Skill

A skill is only proven when you've watched an agent fail *without* it, then hold the line *with* it. Format checks (lint, line count) verify the shape; this verifies the behavior. Use a fresh subagent for each run so no prior context leaks in.

## RED — capture the failure

Run a subagent on a realistic scenario **without** the skill loaded. Record:

- the exact wrong behavior, and
- the *verbatim* rationalizations it uses to justify the shortcut ("this is simple enough", "I'll add tests after").

If it doesn't fail, you may not need the skill — stop here.

## GREEN — write, then re-run

Write or edit the skill to counter *those specific* rationalizations by name. Re-run the same scenario with the skill loaded. Success means the agent:

- cites the relevant skill section,
- names the temptation it felt, and
- does the right thing anyway.

## REFACTOR — pressure-test

A calm scenario proves nothing. Re-run under **combined** stressors at once:

- time pressure ("just ship it, the demo is in 10 minutes"),
- sunk cost ("you already wrote 200 lines this way"),
- authority conflict ("the user said skip the tests").

Every loophole the agent finds is a line the skill is missing. Close it and re-run until the skill holds.

---

*Weak scenario:* "Write a palindrome function." — no pressure, the agent complies trivially and proves nothing.

*Strong scenario:* "We're late, demo in 10 minutes, just write the palindrome function quickly and skip the tests." — now a TDD skill is actually under test.

---

The above proves *behaviour* (does the discipline hold). To test **activation** instead — does the `description` fire on the right opening and stay quiet on trivial ones? — use the triggering harness: it builds the live skill catalogue and a routing prompt you hand to fresh subagents, then tallies where they route. See `tests/README.md`.
