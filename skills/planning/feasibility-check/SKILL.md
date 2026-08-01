---
name: feasibility-check
description: Use before an accountable owner commits to a project or initiative when achievability under real technical, delivery, operational, security, data, or dependency constraints is uncertain. Produces an evidence-based recommendation, not an autonomous commitment decision. Skip proven or trivially reversible approaches.
---

# Feasibility Check

Optimism is not a plan. Before commitment, assess the killer risks honestly and
put an evidence-bound recommendation to the accountable owner.

## When to use

- Before committing to a project or initiative (the go/no-go moment).
- When feasibility is genuinely uncertain — new tech, hard constraints, unknown data.
- **Skip** when the path is well-trodden and the risk is obviously low.

## Procedure

1. **Assess the whole commitment:** technical, delivery/team/budget, operations
   and recovery, security/compliance, data, and external dependencies with their
   accountable owners. “Technically possible” is not “operable and deliverable.”
2. **Find the killer risks:** assumptions that, if false, sink the goal. Rank
   likelihood × impact and name the evidence source, freshness, and confidence
   for each; unknown is a valid confidence.
3. **Reduce the top unknowns cheaply** — usually a bounded `prototyping` question,
   not more discussion. Do not let one successful spike answer other dimensions.
4. **Compare Option Zero and smaller alternatives.** Record evidence for whether
   do not build, an existing tool/configuration/process, or a smaller initiative
   can meet the goal and guardrails; recommendation convenience is not evidence.
5. **Recommend:** go / no-go / go-if. Bind the exact recommendation version. Give
   every go-if condition a stable ID, evaluator/evidence, owner, freshness/expiry,
   state (`pending / satisfied / failed`), and failure/abort response. This is
   advice to the accountable decision maker, not authority to commit the project.
6. **Write an immutable proposed `## Feasibility` section**, preserving other
   approved sections, at
   `.augments/briefs/{{YYYY-MM-DD}}-{{topic}}.md` (or the user-set path):
   dimensions, constraints, risks/evidence/confidence, recommendation, condition
   contracts, expiry, aborts, owner, normative identity, predecessor, and external
   condition/decision-ledger location.
7. **Obtain the direct decision.** Record the exact outcome and scope. A go-if
   decision does not satisfy conditions: only named evidence/owner moves their
   external `pending / satisfied / failed` state. Expiry or any bound input,
   evaluator, evidence, owner, or freshness change invalidates affected condition
   evidence and reopens the decision. Only current decided-go or decided-go-if
   with every condition satisfied hands off.
   Once normative identity is issued, never mutate it: every normative change
   creates a proposed successor. An approved successor records the downstream
   artifact inventory bound to its predecessor, invalidates stale bindings
   externally, and blocks use until owners revalidate or reconcile them.

After a direct go/go-if whose conditions are met, route to the actual next need;
use `scope-it` when the project boundary remains to be drawn.

## Common mistakes

- Greenlighting on optimism — no named risks means you didn't look.
- Treating "we'll figure it out" as feasibility — name what would make it *infeasible*.
- Endless analysis instead of a cheap spike to kill the biggest unknown.
- Treating a technical proof as delivery, operational, compliance, or recovery
  proof.
- Skipping Option Zero — the cheapest path is sometimes to not build it: an existing tool, a config change, or a smaller change to the problem. Rule it out before greenlighting a build.
