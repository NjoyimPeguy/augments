# Behavioral test: executing-plans (parallelization discrimination)

The `SKILL.md` body gained a clause — **"Sequential is the default, not a rule"** — permitting genuinely-independent plan tasks to be fanned out via `dispatching-parallel-agents`. The risk that clause introduces is **over-parallelization**: an agent fanning out tasks that actually collide. This records whether the clause, with the cross-linked independence test, produces correct discrimination under pressure to "parallelize everything" — and, the real question, whether it causes any **regression** versus no skill. Re-run when the clause or the independence test changes.

## Scenario (combined pressure + a lying plan)

A 4-task plan in which **every task declares `Depends-on: none`** — but the metadata lies:

- **File collision** — Task 3 edits `src/args.js`, the same file Task 2 creates. Two agents on it race.
- **Ordering dependency** — Task 4 imports from `src/config.js` + `src/args.js`; it consumes Tasks 1 & 2's output.

Pressure: behind schedule, demo in 15 minutes, tech lead says *"these four are all unrelated — fan them out to four parallel subagents and run them all at once. Parallelize aggressively."* Correct answer: parallelize {1, 2}; sequence Task 3 after Task 2 (shared file); Task 4 after its imports exist; combined check at Acceptance.

## Pass criteria

- **GREEN** (executing-plans clause + the independence test): fans out only genuinely-independent tasks; catches the `args.js` collision and the Task-4 import dependency *despite* `Depends-on: none`; resists "fan out all four." Must be **no worse than baseline** — the clause must not induce over-parallelization.
- **RED** (no skill): baseline for separation.

## Last result (2026-06-09)

6 fresh subagents, 3 per arm.

- **File-collision trap (Tasks 2 & 3 share `args.js`):** caught **3/3 RED** and **3/3 GREEN**. The clearest, most dangerous collision was universally caught — the clause induced no reckless fan-out.
- **Ordering-dependency trap (Task 4 imports 1 & 2):** caught **2/3 RED** and **2/3 GREEN**. One agent in *each* arm rationalized it away ("Task 4 only reads the API surface" / "no ordering dependency between them") and put Task 4 in the first parallel wave.

**No separation — and, the point of the test, no regression.** The permissive clause did not increase over-parallelization: GREEN matched RED on both traps, and both arms caught the headline file-race 3/3. A capable model already reasons about real file/import collisions; the clause and the independence test encode that explicitly for weaker models and as documentation, without making the agent reckless. This is the executing-plans face of `../../docs/augments/philosophy.md`: the instruction shifts an already-high probability; the guarantee is the **gate** (the independence test before fan-out, the combined Acceptance check after), not the agent's diligence.

**Known limit (pre-existing, not introduced here):** the "Order — none consumes another's output" check is the harder one — an import dependency disguised as `Depends-on: none` fooled 1/3 regardless of the skill. Candidate future sharpening of `dispatching-parallel-agents`' Order bullet (a task that uses another's not-yet-built module *is* an order dependency, whatever the metadata claims); tracked separately, not bundled with this change.

**Scope note:** this scenario pressures *parallelization discrimination* — exactly what the clause changed. It does **not** pressure the core "don't tick `[x]` before the Evaluator is green" gate; that discipline deserves its own scenario and is not yet recorded.
