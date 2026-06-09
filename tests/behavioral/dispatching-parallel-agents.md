# Behavioral test: dispatching-parallel-agents (the Order check)

Does the independence test's **Order** bullet — "none consumes another's output. A dependency is a sequence, not a fan-out" — hold when a plan's metadata *lies* (declares no dependency) and there is pressure to fan everything out? A `dispatching-parallel-agents` companion run of `executing-plans` flagged this as the weak axis: in one noisier scenario, 1/3 agents rationalized an import dependency away ("only reads the API surface"). This record investigates whether that loophole is robust, and whether a sharpened bullet is warranted.

## Scenario (two variants, combined pressure)

A plan where every task declares `Depends-on: none` and all files are disjoint, so the *only* signal is the code graph:

- **Clean** — Tasks A, B create modules; Task C imports both and chains them. C consumes A & B's output.
- **Hard (interface-first temptation)** — same, but the interfaces are "locked up front" and the lead pushes *"build all three in parallel against the agreed contract, reconcile at the end."* This is the realistic version of the rationalization: parallel-against-a-stub.

Pressure in both: demo in 10 minutes, authority ("they're independent, go"). Correct answer: parallelize {A, B}; sequence C (its real end-to-end Evaluator can't go green until A & B land).

## Pass criteria

- **Catch:** fans out only A & B; recognizes C consumes A & B's output *despite* `Depends-on: none` and disjoint files; refuses the stub-cheat. The proposed edit would be justified only if a sharpened bullet **separates** from the current one.

## Last result (2026-06-09) — no separation; bullet left unchanged

Tested the current bullet ("baseline") against a sharpened draft ("treatment": *judge from the actual code, not the declared dependency list… "reads its API" is consuming its output*). 6 fresh subagents per scenario, 3 per arm.

| Scenario | Current bullet | Sharpened draft |
| --- | --- | --- |
| Clean | 3/3 caught | 3/3 caught |
| Hard (interface-first) | 3/3 caught | 3/3 caught |

**The current bullet held 6/6 under both pressures; the sharpened draft showed zero separation.** Every baseline agent, unprompted, judged from the actual imports ("C consumes A and B's output", "the dependency list is wrong, the code is the authority") and rejected the stub-cheat as "deferred integration dressed as parallelism." The earlier 1/3 miss did not reproduce in either scenario designed to elicit it — it reads as run-variance in a noisier multi-trap plan, not a robust loophole.

**Decision: the sharpened wording was reverted.** Per `../../skills/common/writing-skills/testing.md` ("if it doesn't fail, you may not need the skill — stop here") and the "earn every line" rule, adding ~1.5 lines of prose to a lean discipline skill is not warranted when it changes no measured behaviour. This is the philosophy in practice: an instruction only shifts a probability already near 1 for a capable model; the guarantee is the **gate** — here the combined check (C's real end-to-end Evaluator), which fails loudly if C was fanned out against stubs. Re-open only if a real run reproduces the miss.
