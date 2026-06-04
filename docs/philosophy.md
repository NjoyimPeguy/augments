# The Generator and the Gate

*The design philosophy behind augments: how to do real engineering on a non-deterministic substrate.*

Every skill in this library is shaped by one problem: a language model is a powerful generator, but it is not a reliable engineer — and software engineering does not tolerate unverified correctness. This document explains how augments resolves that, and why the skills look the way they do.

## What real engineering guarantees

Engineering tolerates uncertainty, but only when it is **quantified and bounded** — a tolerance, a budget, an error bar. What it never tolerates is **unverified correctness**. A bridge may carry a safety factor; it may not be "probably standing".

So the non-negotiable is not that the process is certain. It is that **the verdict — "is this correct?" — is established by a deterministic check, not by the builder's confidence.**

## The two non-determinisms of a language model

A model is non-deterministic in two distinct places, and they are not equal.

- **In generation** — the same request yields different code each time. This is harmless. There are many correct implementations; the path need not be deterministic.
- **In its verdict** — it will report "this works", "tests pass", "done", confidently, when it is not true. This is fatal, because it is exactly the thing engineering forbids: an unverified correctness claim presented as fact.

And the verdict problem cannot be fixed by instruction. Telling a model "you must verify" only raises a probability; it can never reach certainty, because the substrate is probabilistic. Forcing compliance with ever-heavier instructions builds reliability on sand — the rule holds most of the time and fails silently the rest.

## The reconciliation: the generator and the gate

You do not make the model reliable. You make the **verdict** reliable, by surrounding a non-deterministic generator with **deterministic gates it cannot talk its way past.**

This is how all engineering produces reliable results from unreliable parts — not by trusting the worker, but by gating the output: inspection, tolerances, tests. The reliability lives in the gate, not the generator.

Stated as a rule:

> **A skill shifts the probability of good generation. A deterministic gate enforces the verdict — regardless of whether the generator complied.**

You need both. But the reliability comes from the gate. Effort spent forcing compliance is spent on the part that can never be guaranteed; effort spent on the gate is spent on the part that can.

## Every skill is a generator wrapped in a gate

This is the thread that runs through the whole library. None of these skills asks you to trust the model's word; each defines "done" as a deterministic check passing.

| Skill | The generator | The gate (where truth lives) |
|-------|---------------|------------------------------|
| `test-driven-development` | the model writing code | the test passing — watched to fail first |
| `verifying-completion` | the model claiming "done" | running the check and reading the output |
| `writing-plans` / `executing-plans` | the model doing a task | the per-task Evaluator and the plan Acceptance |
| `debugging` | the model's hypothesis | the reproduction loop |

## Instruction-injection is not a gate

A tempting mistake is to make the model reliable by injecting more instructions — an enforcer that says "you must, before everything, every time". That tries to change the generator's *behavior*: probabilistic, fragile, and tied to one tool.

The engineering-correct enforcement is the opposite — a deterministic gate on the **artifact**. A version-control or CI step that runs the tests and refuses the bad output does not care how confident the model was, does not vanish for a sub-agent, and is portable, because it lives in git and CI rather than in any one tool's session. Prefer a gate on the output over an instruction about behavior.

## Where there is proof, and where there is only process

Be honest about the limit. Some disciplines can be gated deterministically — a test, a check, a reproduction returns pass or fail. Others cannot: "explore the design first", "consider the architecture" have no command that returns a verdict. For those, compliance is only ever probabilistic, and the honest framing is to say so — they are best-effort nudges, not guarantees.

Real engineering is precise about where it has proof and where it has only process. A skill that dressed "you should brainstorm" in the same absolute language as "the tests pass" would be lying — the very hollow verification it warns against.

## What this means for the library

This is why `using-augments` is not a compliance enforcer. Its job is to install the mental model that makes every other skill cohere:

> You are a generator. These skills surround your work with deterministic gates. Truth comes from the gate — a test, a check, a reproduction — never from your confidence. "Done" means a check passed, not that you believe it is done.

The reliability of augments does not live in a bootstrap that tries to force you. It lives in the gates the skills define — and, where you want enforcement, in deterministic checks wired into git and CI, where enforcement is real and portable.
