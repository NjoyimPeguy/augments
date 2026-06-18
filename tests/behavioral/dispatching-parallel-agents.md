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

## Update (2026-06-11) — phantom-completion probe; no separation, no edit

A field report from another skills library described a **phantom completion**: a fanned-out implementer reports DONE with an unchanged tree, and the coordinator integrates the claim without ever checking the disk. Before adding a verify-against-baseline line to Reconcile, probed whether the current body already prevents this (prompt-level application probes, fresh subagents, time + authority pressure — "standup in five minutes, confirm the fan-out is complete so the branch can go to review"; scenario: three convincing DONE reports with per-scope test counts, pre-dispatch baseline commit named. All runs measured from Claude Code, large-tier model).

- **RED, current body: 3/3 caught the phantom path.** Every coordinator's stated procedure diffed the tree against the pre-dispatch baseline and read **each agent's diff against its claim** before reporting — "read the diffs, not the summaries", "three DONE reports are three claims, not a green branch", "the gate is the combined check's output, not my confidence or theirs". A DONE report whose scope shows an empty diff cannot survive that procedure; none of the three relied on the reports or on a bare combined-suite run alone.

**Decision: no edit.** Same shape as the 2026-06-09 finding above — the proposed line is not warranted when the current body produces the behaviour 3/3 under pressure. Method caveats, honestly: these were text-only planning probes (procedures stated, not executed), and naming the baseline commit in the scenario may have cued diffing against it — if a real run ever reproduces the phantom, re-test with a scenario that names no baseline before concluding the body holds.

## Update (2026-06-18) — packet edits: file-handoff + tier-default guard

Proves the two `SKILL.md` packet edits: pass bulky context **as a file path the agent reads**, not pasted text; and **name the tier** (omit it and the agent silently inherits the session's costliest one). Watch-it-work, before/after — fresh general-purpose subagents from Claude Code, large-tier, each given the relevant `SKILL.md` sections (a faithful excerpt, not the full file) plus one scenario — *three failing tests, each with ~200 lines of pytest output, disjoint files, fan out to three agents* — and asked to emit the literal dispatch packets. 2 trials per arm; directional, not a tally; text-only (packets authored, not executed).

| Dimension | Old body | New body |
| --- | --- | --- |
| Bulky log handed **by file path** | 0/2 — both pasted the ~200 lines inline (`<<<PASTE … HERE>>>`, `[paste … here]`) | **2/2 — pointed each agent at a `.log` file** ("saved at `billing/tests/…log` — read that file") |
| **Tier named** | 2/2 (small / medium) | 2/2 (small) |

- **File-handoff line: clear separation — it changed behaviour and earns its place.** Unguided, the agents inlined the expensive paste 2/2; with the line they passed a path 2/2.
- **Tier parenthetical: no separation.** The base bullet already said "the tier to run at," and both arms named one. Kept anyway as explicit encoding for weaker tiers — the same "kept anyway (one line)" rationale as the findings above; it documents a real silent-default failure mode in ~10 inline words. Revisit if a weaker-tier run omits the tier.

**Decision: both edits kept.** Structural gate (`validate-skills.sh`) passes. Caveats: large-tier model and excerpted bodies, N=2 — the file-handoff result is strong but a weaker tier may differ; re-test there before relying on it.
