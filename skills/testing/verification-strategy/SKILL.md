---
name: verification-strategy
description: Use when the question is how a project will prove its code correct — which tests, which quality bars, which CI gates every change must pass. Sets the verification battery once, before features are built, and revisits it whenever the proof comes into question (a defect escapes a green suite, a suite that never fails) — acceptance behaviour tests, a falsifiability audit, metric floors, CI wiring. Skip for a single feature (its gates are the plan's Evaluators), for writing the tests (test-driven-development), for running the checks (verifying-completion), and for conventions rather than proof (coding-standards).
---

# Verification Strategy

Decide once, up front, how the project will *know* its code is correct — so trust comes from a designed battery of gates, never from reading every line or from the builder's confidence. A gate that exists only in someone's head is not a gate.

## When to use

- The project's proof of correctness is undefined or unstated — set the strategy once, before the first feature, not after the first escape.
- The battery proves weak: a defect escapes a green suite, or a suite turns out to never fail.
- A feature crosses ground the battery wasn't designed for — a new surface, a new risk class. Features it already covers don't refire it: it runs on every change without this skill.
- **Skip** for a single feature's own checks — those are the plan's per-task Evaluators (`writing-plans`).
- **Skip** when writing the tests — that is `test-driven-development`. This skill designs the gates; other skills execute under them.

## The battery

Five layers. Each is one decision recorded as executable configuration — never prose.

1. **Unit layer** — name it and hand it to `test-driven-development`; that discipline owns the how. Nothing more is decided here.
2. **Behaviour/acceptance layer** — executable scenarios against the *observable behaviour* of the running system (Given/When/Then is one spelling; the requirement is behaviour-level, executable, and independent of internals).
3. **Falsifiability audit** — for every gate, name the production change that would make it fail; a gate nobody can break proves nothing. Close with a mutation check: break the code on purpose, watch the battery catch it. Where the ecosystem has a mutation-testing tool, set its score floor.
4. **Metric floors** — coverage and quality thresholds as floors that *fail the build*, never targets. A target invites gaming; a floor refuses to ship below itself.
5. **CI wiring** — every gate runs in CI on every change. A gate that only runs locally is a wish.

## Hard stops

- **String-presence tests** — assertions that grep output or files for text counterfeit falsifiability. The observable is behaviour, never text.
- **Change-detector tests** — an assertion that can fail yet protects nothing (constants echoed back, snapshots of noise). If removing the behaviour doesn't fail the test, the test is decoration.

## Procedure

1. Inventory what already runs — the project's test command, its CI, its suites. The battery extends what exists; it never duplicates it.
2. Design the five layers against *this* project's risks: what must be true for the software to be correct, and which layer proves each.
3. Wire every gate into the project's own commands and CI, then run the whole battery once and watch each gate able to fail — the closing mutation check.
4. Hand the battery forward: per-feature gates become plan Evaluators (`writing-plans`), the unit discipline runs via `test-driven-development`, and claims about it run via `verifying-completion`.

## Common mistakes

- Teaching test mechanics here → this skill decides *what the gates are*; `test-driven-development` owns how to write them.
- A coverage number as a goal → floors that fail the build, never targets to hit.
- A battery documented but wired nowhere → if no command runs it, it does not exist.
- Re-designing the battery per feature → per-feature gates are plan Evaluators; this skill sets the project floor once.
- Asserting on text because it is easy → assert on behaviour; text-presence is the first trap.

See `references/battery-catalogue.md` for what each layer proves — and what it can never prove.
