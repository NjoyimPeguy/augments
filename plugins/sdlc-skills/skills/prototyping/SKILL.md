---
name: prototyping
description: Use when a design or feasibility question is genuinely uncertain and cheaper to answer by building a throwaway than by arguing — a tricky bit of logic, a layout choice, a library's real behaviour. Skip when you already know the answer.
---

# Prototyping

A prototype answers one question and dies. Its only job is to turn an uncertainty into a fact cheaply — the code is disposable; the *answer* is what you keep.

## When to use

- A specific question is uncertain and faster to *build* than to argue: does this algorithm work, does this layout read, does this library do what its docs claim.
- Reached from `feasibility-check` (a killer risk) or `ui-ux-design` (a layout choice).
- **Skip** when you already know the answer, or the question is vague — a prototype that answers the wrong question is pure waste.

## Procedure

1. **Pre-register the experiment.** State one question, the falsifiable
   pass/fail observation, the time-box and size-box, and what decision each
   result changes. If these are vague, do not build.
2. **Set the safety boundary.** Name the workspace and artifact ownership,
   environment, data class, allowed access/effects, evidence retention/expiry,
   cleanup owner, exact cleanup targets/effects/recoverability, and the current
   authority covering both creation and cleanup. Prefer isolated synthetic
   data. Production-like data, services, traffic, probes, or destructive
   cleanup require explicit authorization and protections appropriate to risk.
3. **Build the smallest disposable probe.** Add only the driver, fixtures, and
   instrumentation needed to observe the result. No reusable abstraction,
   production integration, or generality kept “for later.”
4. **For logic:** exercise the uncertain behavior through a tiny driver or
   executable assertion. **For UI:** compare only the structurally different
   populated variants needed to answer the registered visual question.
5. **Stop on the declared boundary.** Record raw observations, environment,
   limitations, and whether the predeclared criterion passed, failed, or stayed
   inconclusive. Do not move the threshold after seeing the result.
6. **Retain the result, not product code.** Store the question, evidence, and
   decision durably; use `architecture-decisions` when it settles a
   load-bearing choice. Rebuild any accepted behavior in the real code under
   its normal tests, review, and verification gates—never lift prototype code.
7. **Apply only the authorized cleanup disposition.** Pre-registered scratch
   artifacts created solely inside an explicitly disposable boundary may be
   removed when current authority covers the exact targets and effects.
   Repository branch, worktree, ref, or workspace disposal routes through
   `finishing-a-branch`; external or destructive cleanup needs its own current
   scoped choice. Otherwise preserve the artifacts and report cleanup pending.
   Never delete pre-existing, shared, user-owned, or ownership-uncertain state.

## Common mistakes

- No written question — you can't tell when you're done, and the code becomes "real" by accident.
- Building production-grade tests or generality instead of the smallest
  executable observation.
- Variants that differ only in colour — that's a tweak, not an answer.
- Quietly probing a real service or sensitive data because “it is only a spike.”
- Keeping or copying the prototype “as a base” — rebuild the learned behavior
  under the product's real gates.
