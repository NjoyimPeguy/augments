# Verifying Completion — Hollow Verification

A check can pass and still prove nothing. The ways that happens, and how to catch them.

## A test that never failed

If you never watched a test fail, you don't know it tests anything — it may assert nothing, or exercise code that already existed. For a regression test, prove it bites: with the test written, undo the fix and run it — it **must** fail — then restore the fix and run again — it passes. A regression test you can't make fail is not a regression test.

## A subagent's word

A subagent reporting "done" or "tests pass" is giving you a claim, not evidence. Verify it independently: read the actual diff (did the files really change?) and the actual check output. Treat the report as a hypothesis to confirm, never as the proof itself.

## Inherited premises

A conclusion is only as verified as what it rests on. Before stating one, list the facts it depends on and mark each: confirmed *this session*, or inherited from earlier or elsewhere. If the conclusion would change should an inherited fact be wrong, re-verify that fact first. Stale string matches and untested assumptions are the usual culprits.

## Evidence is not all equal

Strongest to weakest: a log of the check actually running > a rubric or checklist you ticked > a bare assertion. When the right check can't be run deterministically (visual or subjective behavior), a written rubric is the fallback — and flag it as the weaker evidence it is.
