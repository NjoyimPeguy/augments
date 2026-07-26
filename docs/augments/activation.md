# Activation: routing and enforcement

augments' skills are only useful if the agent actually reaches for them at the right moment. That happens through two layers, matched to two kinds of constraint.

## The routing layer — firm persuasion (every skill)

A **SessionStart bootstrap** wraps the shared pointer text (`hooks/context.md`) in each harness's context format. It is injected at the start of every session where the harness supports it (and on resume / clear / compact where the harness exposes those events). It is a thin **pointer**: before any non-trivial request, invoke the `using-augments` skill to route to the one that fits. The routing *discipline* itself — the rationalizations named as signals to *check* not skip, the red-flags, the procedure — lives in `using-augments`, not the bootstrap. The split is deliberate: where the pointer re-fires on compaction, it is the durable re-trigger; the skill body (loaded only when it fires) carries the weight but decays between compactions. The skill **descriptions** — always loaded in the Skill catalogue, which does not decay — carry firm triggers.

This is **persuasion**: strong, but an instruction the model can still skip — measured skill-invocation runs well under 100% across the industry. So it is the floor, not a guarantee. There is deliberately **no per-turn re-injection** (a v2.0 experiment, since removed): re-asserting a line every turn did not stop the model skipping under momentum, and it cost tokens per turn. Firmness lives in the bootstrap and the descriptions; the decay between compactions is the accepted price of leanness.

## The enforcement layer — deterministic gates (the production-critical subset)

Where a procedure has a deterministic signal (tests pass, review done, release checklist met), persuasion is backed by a **gate the agent cannot route around** — CI / pre-commit / branch-protection (airtight), plus best-effort in-session blocks. These carry the procedures whose skip causes production incidents (verification, review, release-readiness, security, tests-with-code). They ship as adoptable templates a team wires into its repo.

## The honest line

Persuasion is firm-but-leaky; gates are airtight only at the artifact/CI layer. augments hard-gates where a real signal *and* production risk both exist, and firm-persuades everywhere else — and never paints a wall where there is nothing to check. The non-negotiable *stance* is "don't skip"; the enforcement is as strong as the signal allows.
