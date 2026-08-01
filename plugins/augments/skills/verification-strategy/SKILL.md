---
name: verification-strategy
description: "ALWAYS use to establish/repair a project's correctness battery, or before high-risk work with absent, stale, or unfalsifiable assurance. Owns risk-specific gates, thresholds, environments, cadence, evidence, promotion wiring, and failure response. Revisit on changed risk, escaped defect, or hollow gate. Skip a bounded feature or merely writing/running an already-defined gate."
---

# Verification Strategy

Build an executable risk-specific gauntlet. Confidence comes from gates observed
failing and wired to block their promotion—not line reading, coverage, or builder
opinion. A battery is established only after its project command turns red for
representative divergence, oracle hollowing, and required inventory loss while
an independent guard remains, then restores green. The matrix reference owns
the exact loss attacks, controller independence, and receipt contract.

## When to use

- The project floor is absent, stale, or cannot catch a real defect.
- A high-risk initiative introduces preservation, platform, data, security,
  concurrency, resource, or rollout risks the current battery does not cover.
- **Skip** a bounded feature; plan evaluators/TDD own its local proof. A missing
  project floor is separate scope.
- Define risks/floors here before TDD implements authorized gate code.
- Scale to risk: compact/inline for one bounded gate, `writing-plans` for
  multi-step work. Completion runs gates; release consumes promotion evidence.

## Procedure

1. **Inventory commitments and risks.** Record behavior, platforms/build modes,
   data/operations, commands/CI, tests, escaped defects, and evidence. A
   transformation consumes migration facts, invariants, and approved deviations.
2. **Build the risk-to-gate matrix.** Read and instantiate
   `references/assurance-matrix.md` before the first matrix write; do not rebuild
   it from memory. Bind exact inputs, stable IDs/delta, approval/successor impact.
   Map each inventoried risk to threshold, action, environment, cadence,
   evidence/owner, promotion, response, and external ledger.
3. **Disposition the gate catalogue.** Read
   `references/battery-catalogue.md` and select by risk. Every omitted category
   needs expiring accountable approval and compensation. Cover/disposition
   equivalence, behavior, static/dynamic safety, property/fuzz/stress/concurrency,
   performance/resources, security, parity, falsifiability/metrics, and test loss.
4. **Set cadence by cost/consequence.** Fast gates block changes; expensive ones
   may protect phase/schedule/trial/cutover/release. “Manual” still has a
   procedure, evidence, owner, and blocking promotion.
5. **Calibrate safely.** In authorized isolation bind data/effects/resources,
   mutation/recovery/cleanup authority and pre-state; observe green, divergence
   red, complete restoration, green. Store raw results externally. If unsafe,
   use a known-bad fixture or mark `uncalibrated`.
6. **Expose missing gates.** External state is `executable`, `planned`, or
   `blocked`; only executable satisfies entry. Matrix/dispositions precede gate
   edits, even inline. TDD implements a bounded gate; plans own multi-step work.
7. **Make control/oracle/inventory loss red.** Before gate code, instantiate
   every applicable self-protection cell from the matrix reference. Keep
   inventory/validator/wiring outside protected tests; reconcile required,
   discovered, and eligible receipts as exact multisets. Every identity needs
   one executed non-skip receipt or exact approved disposition. For a tiny
   suite, default to one path/count assertion in the existing project command;
   losing its sole protected test/layer must turn that command red. A new
   controller, launcher, parser, manifest, or dependency is material verification
   surface: require a named risk the simple check cannot cover and `yagni`'s
   pre-edit challenge. Risk-select the smallest falsifications that decide the
   real claim: removal, skip/focus/todo,
   case/cell loss/duplication/hollowing, and narrowing; add controller hollowing
   or escaping-process-tree probes only when actual launchers create that risk.
   Record inapplicable classes and restore every probe exactly.
   A mutable plane cannot protect its own invocation: without external
   enforcement its promotion remains `planned`/`blocked`.
8. **Challenge independently.** Even while approval is pending, read
   `references/assurance-challenger.md` and invoke `requesting-code-review` with
   the broad prompt. Generic review cannot replace its explicit verdict. Use
   retained evidence/reviewer copy; keep candidate read-only and evidence
   external/version-bound. A blocker closes only that candidate: correct a
   successor draft, issue it when complete, reverify/rechallenge, and continue
   until clear or concretely blocked. Smaller topology needs an exception.
9. **Decide the exact version.** Draft/gate implementation authority does not
   approve unseen risks, thresholds, omissions, or exceptions. Present the exact
   matrix for direct outcome/standing default; keep lifecycle external and the
   normative file immutable `proposed`. Only approved advances. Normative change
   creates an exact-delta successor; only an approved replacement supersedes.

## Hard stops

- Planned/prose/never-run/never-falsified control presented as executable.
- Gate code before matrix/catalogue dispositions—even when inline.
- Presence/change-detector tests that can fail without protecting behavior.
- Aggregate green hiding a platform/mode/shard/test/cadence.
- “Established” before removal/skip/duplication/hollowing turns the project
  command red under an independent guard and restores green.
- Validator only inside its discovered tree, or mutable command self-protection;
  without external wiring the promotion stays planned/blocked.
- Wildcard, file presence, set/count, named receipt, success marker, or outer
  timeout presented as exact case/action proof.
- Deferring challenge pending approval; self-granting exceptions; approving
  unseen work; or writing lifecycle state into a normative candidate.
- Lowering a threshold, deleting a test, or accepting a deviation to make the matrix green.
