---
name: verification-strategy
description: "Use to establish or repair a project's correctness battery, or before high-risk work whose assurance is absent, stale, or unfalsifiable. Fires on how should we test this project, our tests don't catch anything, and what should CI run, even if nobody says strategy. Revisit on changed risk, an escaped defect, or a hollow gate. Skip a bounded feature, and skip merely writing or running an already-defined gate."
---

# Verification Strategy

Build a correctness battery that matches the project's real risks, and prove
each gate by watching it fail. Confidence comes from a gate observed failing and
wired to block the promotion it protects — never from reading the code, from a
coverage number, or from the builder's opinion.

## When to use

- The project floor is absent, stale, or cannot catch a real defect.
- A high-risk initiative introduces preservation, platform, data, security,
  concurrency, resource, or rollout risks the current battery does not cover.
- **Skip** a bounded feature — its plan evaluators and TDD own the local proof.
  A missing project floor is separate scope.

## Procedure

### Map the risks before writing any gate

1. **Inventory what the project promises and what could break it.** That means
   the behaviour it commits to, the platforms and build modes it ships on, the
   data and operations it touches, the commands and CI that already run, the
   tests that exist, and any defects that escaped.

   A transformation consumes more: its migration facts, its invariants, and the
   deviations already approved.

2. **Build the risk-to-gate matrix, before any gate code exists.** Read
   `assets/assurance-matrix.md` now and instantiate it; do not rebuild the
   format from memory. It owns the required cells, the gate-establishment
   contract, the self-protection classes, and the receipt rules.

   Authoring the matrix alongside the gates, or after them, fails this
   transition — the matrix is what decides which gates are worth writing.

3. **Disposition every category in `references/battery-catalogue.md`,** reading
   it while you select gates. Each category is either covered, or carries an
   accountable approval that expires plus a compensating gate. N/A is a decision
   with evidence and an owner, not a shorthand.

### Make each gate real

4. **Set each gate's cadence from its cost and its consequence.** Cheap gates
   block every change; expensive ones may protect a phase, a trial, a cutover,
   or a release instead.

   A gate marked "manual" is still a gate. It needs a procedure, evidence, an
   owner, and a promotion it blocks.

5. **Calibrate in isolation you are authorized to use.** Bind what the gate
   touches, and your authority to mutate, recover, and clean up. Then watch the
   whole cycle: green → red on an introduced divergence → complete restoration →
   green again. Keep the raw results outside the candidate.

   Where calibrating for real would be unsafe, use a known-bad fixture, or mark
   the gate `uncalibrated` and say so.

6. **Report gate state honestly.** Externally a gate is `executable`, `planned`,
   or `blocked`, and only `executable` satisfies an entry condition — a planned
   command is not evidence. TDD implements a single bounded gate; multi-step
   work belongs to a plan.

### Protect the battery from its own erosion

7. **Make the loss of a control, an oracle, or a test turn the suite red.** A
   battery that cannot detect its own erosion is not a battery. Instantiate the
   applicable self-protection cells from `assets/assurance-matrix.md`, which
   owns the attack classes and the tiny-inventory floor.

   Two rules decide the rest:

   - Keep the inventory, the validator, and the wiring *outside* the tests they
     protect. A check that lives inside what it guards dies with it.
   - A mutable plane cannot protect its own invocation. Without external
     enforcement, its promotion stays `planned` or `blocked`.

### Challenge it, then hand over the decision

8. **Challenge the matrix independently, while approval is still pending.** Read
   `references/assurance-challenger.md` and invoke `requesting-code-review` with
   the broad prompt — a generic review cannot produce that reference's verdict.
   Keep the candidate read-only.

   A blocker closes only the candidate it was raised against. Correct a
   successor, reverify, and rechallenge until it comes back clear or is
   concretely blocked.

9. **Present the matrix for decision.** Authority to draft or implement gates is
   not authority to approve unseen risks, thresholds, omissions, or exceptions.
   Print exactly this, then stop:

   ```text
   Assurance matrix ready for your decision — {{matrix-path}}

   Gates:      {{executable}} executable · {{planned}} planned · {{absent}} absent
   Thresholds: {{thresholds}}
   Omitted:    {{omissions-with-rationale}}
   Cadence:    {{what-blocks-what}}

   1. Approve — this is the correctness battery
   2. Request changes — tell me what to revise
   3. Reject — wrong strategy
   4. Cancel — stop this work

   Which?
   ```

   Only approved advances; keep lifecycle external and the normative file
   immutable `proposed`. A normative change creates an exact-delta successor,
   and only an approved replacement supersedes.

## Hard stops

**Calling a control executable when it is not**

- It is only planned, or only prose.
- It has never been run.
- It has never been watched fail.

**Writing gate code before the matrix and catalogue dispositions exist** — including when the gate is small enough to stay inline.

**A gate that cannot fail for the right reason**

- A presence or change detector: it goes red without any behaviour being protected.
- An aggregate green that hides a platform, a build mode, a shard, a test, or a cadence that never ran.
- A wildcard match, a file's presence, a set or count comparison, a named receipt, a success marker, or an outer timeout, presented as proof that an exact case or action occurred.

**Calling the battery established** before removing, skipping, duplicating, or hollowing a test turns the project command red under an independent guard — and restoring it returns green.

**Self-protection that protects nothing**

- A validator living only inside the tree it discovers.
- A mutable command asked to guard its own invocation. Without external wiring, that promotion stays `planned` or `blocked`.

**Taking authority you were not given**

- Deferring the independent challenge until after approval.
- Granting yourself an exception.
- Approving work the decision owner has not seen.
- Writing lifecycle state into a normative candidate.

**Lowering a threshold, deleting a test, or accepting a deviation to make the matrix green.**
