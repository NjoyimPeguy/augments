---
name: test-driven-development
description: "ALWAYS use before behavior-affecting implementation: features, fixes, refactors, migrations, generators, or config, including preservation. High-risk target work waits for approved migration/assurance contracts and passed entry gates; authorized gate-only work cannot edit the target. Skip only throwaway spikes and nonbehavioral content/config."
---

# Test-Driven Development

Let an executable behavioral gate lead the code. New behavior begins with a
meaningful RED; already-correct behavior begins with a falsified GREEN oracle.
Inventing failure for behavior that should already work is not discipline.

## When to use

- Any feature, fix, refactor, migration, generator, or config changing behavior.
- **Skip** disposable spikes and nonbehavioral content/config; rebuild accepted
  spike behavior under a gate.
- For generated output, test source/config, regeneration, and invariants—not
  every line.
- High-risk target code needs approved current migration/assurance and passed
  entry gates. Gate-only work consumes only its exact proposal and cannot edit
  target, approve contracts, or satisfy entry.
- Invoke `yagni` with this skill before the first project command or edit—not at
  GREEN or after a guard denial.

## Choose the entry cycle

Before any test command, bind its environment, data, external effects, resource/
cost limits, cleanup/recovery, and current authority. Never aim a “test” at an
undeclared shared or production surface. Before code, pin the approved public
interface and behavior; unresolved meaning returns to its owner. Then choose:

### New or intentionally changed behavior: RED first

Write one test for the next approved behavior and run it through the project's
real command. Watch it fail for the missing or incorrect behavior—not import,
syntax, harness, unrelated, skipped, or flaky failure—and retain the output.
Confirm the selected test was discovered, executed, and failed at the intended
observation against an otherwise usable baseline; unexplained intermittence
routes to `debugging`. Freeze test/evaluator identity and expected observable at
RED. Implementation cannot weaken it; a required normative correction
invalidates the cycle and its successor must independently reach RED first.
A bugfix starts with its runnable failing reproduction. An approved migration
deviation uses this cycle for the changed behavior.

### Preserved behavior: GREEN → deliberate RED → GREEN

Use the accepted task/plan characterization gate or, for high-risk work, the
assurance-matrix differential gate. An inherited green suite is not accepted
merely because it exists: it must cover the preservation contract independently
of the target. Strengthen smoke-only coverage before the first checkpoint; an
empty “characterization” commit proves nothing. Run the accepted source/current
behavior green.
Introduce a controlled representative divergence, run the same gate and observe
the intended red, restore the exact state, and observe green again. Only then
transform one slice while keeping that gate green. Read
`references/preservation-cycle.md` for oracle, generator/config, and evidence
details.

### Implement and refactor

With the pair already loaded, write only what the current failing behavior or
preservation slice requires. Run the relevant gate, then the project-required
gate; both must be green. Refactor under green and re-run. When chronology is
part of the claim, candidate-written logs are not evidence: use an external
observer or retain immutable checkpoints that the evaluator independently
reruns. Never manufacture checkpoint history after the cycle.
Refactor only while the observable contract is unchanged; an intended behavior
change returns to the new-behavior RED cycle and its owning approval.

## Hard stops

- New behavior code created by the current work has no observed behavior RED.
- A new-behavior test passes first run, or fails only because the test cannot
  execute.
- A preservation oracle was never seen green, never made red by a deliberate
  divergence, or derives expected results from the target it judges.
- A preservation checkpoint contains no new oracle even though inherited tests
  were never accepted as covering the preservation contract.
- A behavioral generator/config change tests only text presence or generated
  file existence.
- A test/evaluator, expected observable, corpus, or oracle changed after its RED/
  falsification without invalidating and restarting that cycle.
- A command/divergence lacks environment/data/effect/cleanup authority or
  verified restoration.
- Throwaway or out-of-cycle code is being copied into the product.

Restore only exact task-created mutations under current authority with known
pre-state/effects/recoverability. Otherwise preserve pending and route workspace
disposition to `finishing-a-branch`; never delete inherited/shared/user state to
manufacture a cycle.

## When you are tempted to skip

| The thought | The reality |
| --- | --- |
| "Too simple to test" | Simple behavior still breaks; use the smallest real gate. |
| "I'll write the test after" | For new behavior, that records the implementation instead of leading it. |
| "The port already works, so I need a fake RED" | No: start green, falsify the independent oracle, restore, then preserve it. |
| "I tested it by hand" | An unrepeatable observation cannot guard the next change. |
| "I'd lose the code I wrote" | Revert only your out-of-cycle implementation; sunk cost is not evidence. |
| "The test is hard to write" | The interface or oracle is exposing a design problem; fix that seam. |
| "There's no test framework" | Use the smallest executable assertion that can fail. |
| "It's just generated/config code" | Test the behavioral source and regeneration contract, not text presence. |

## Common mistakes

- Testing internals or mock calls instead of public behavior—see
  `references/reference.md` and `references/mocking.md`.
- Writing all tests first instead of advancing one behavior or preservation
  slice at a time.
- Treating coverage, compilation, snapshots of noise, or a target-derived oracle
  as equivalence proof.
- Over-building in GREEN instead of letting the current gate bound the change.
