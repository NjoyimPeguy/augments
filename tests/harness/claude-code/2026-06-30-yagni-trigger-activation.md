# Activation record — yagni trigger retarget (2026-06-30)

Records the activation re-measurement after `skills/common/yagni`'s `description`
was retargeted (the skill was also relocated from `implementation/` to `common/` —
it is a cross-cutting discipline that applies to any change in any phase, not a
phase-specific one). Activation results are ephemeral (real API calls,
not CI) — re-run the scripts for current truth. This file states what changed and
what the runs showed on the day, **including the inconclusive part**.

## What changed (trigger only — discipline body untouched)

The reported symptom: *yagni never loads during implementation.* Hypothesis: the
old trigger — `"Use when about to write or change code for a feature or fix"` —
overlaps the exact moment `test-driven-development` owns (`"ALWAYS invoke before
writing implementation code"`), and TDD's imperative wins the routing race, so
yagni is never picked. The vague-trigger-that-shadows-a-stronger-skill is the
anti-pattern `writing-skills` warns against.

The edit replaces that with the **observable signals yagni uniquely owns** —
over-engineering (a new abstraction / interface / config knob / dependency, or
anything "for later") and under-delivery (a stub, a TODO, the smallest diff that
patches a symptom while a sibling caller stays broken) — plus a clause marking it
*distinct from* TDD ("yagni governs how much to build, so pair them"). The tuned
discipline **body** (rationalization table, hard stops) was not touched, so no
pressure re-run is owed; this is a pure **activation** change.

## Runs and results (real `claude` CLI; new = `--working-tree`, old = installed 2.1.1 cache)

| Run | Opening | Desc | Verdict |
| --- | --- | --- | --- |
| 1 | committed `scenarios/common/yagni` ("we only ever send email…") | new | **NONE — artifact.** The scenario implies an existing codebase; in the isolated empty temp dir the model ran `ls`/`git log`, found nothing, and reasoned about the contradiction instead of routing. Not a verdict on the wording. |
| A1 | greenfield over-engineering (pluggable `ConfigSource` + registry, only one JSON file needed) | new | ACTIVATED — `using-augments → yagni` |
| B1 | same | old | ACTIVATED — `using-augments → yagni` |
| A2 | build **+** over-engineer (`formatMoney` + speculative strategy/registry) | new | ACTIVATED — `using-augments → yagni → test-driven-development` |
| B2 | same | old | ACTIVATED — `using-augments → yagni` |
| C | pure test-first (`parseDuration`, **no** YAGNI signal) | new | **No interference** — `using-augments → test-driven-development`; yagni stayed quiet, no false hijack of a TDD-only task |

## The finding (inconclusive on the hypothesis, conclusive on the root cause)

**No measured activation separation between old and new.** On every opening where
the over-engineering signal is explicit, a capable (large-tier) model already
routes to yagni — old trigger or new. The wording is *not* the lever. This matches
the existing discipline record (`behavioral/yagni.md`, 2026-06-24), which found the
same parity on the behavioral axis.

**The real cause of "never loads during implementation" is structural, not lexical.**
Augments routes **once, at the start of the task** (the SessionStart nudge re-fires
only on resume/compact). The YAGNI moments — reaching for an abstraction, adding a
knob, stubbing a path — emerge **mid-implementation**, *after* that one-shot routing,
and nothing re-routes mid-build. So yagni is never reached *then*. This is the same
root cause as "long tasks forget the skills": single-shot start routing with no
mid-task re-trigger. A trigger reword cannot reach it.

## Disposition

Edit **kept** as a doctrine-aligned, **no-regression** improvement (sharper trigger
per `writing-skills`; removes the TDD-collision wording; still fires on every
explicit signal, in A2 even chained yagni→TDD, and in Run C did not hijack a pure
test-first task). It is **not** claimed to fix the symptom — the measurement says it
doesn't. The skill was also **relocated to `skills/common/`** as a cross-cutting
discipline (it governs any change in any phase, not just the implementation phase).
The real fix for the reported symptom is mid-task re-routing, tracked separately.

## Honest caveats

- Single runs, not N-of-N — these show the mechanism fires, not a hit-rate. The
  no-separation claim rests on 4/4 explicit-signal runs firing yagni regardless of
  wording, plus one empty-dir artifact miss.
- The isolated empty temp dir cannot manufacture the *mid-build emergence* where
  yagni's real value (and the real gap) lives — so the harness structurally can't
  test the symptom the user reported. That limitation is itself the finding.
- The committed `scenarios/common/yagni` opening is a good *discipline*
  scenario but a poor *activation* one in an empty dir (it implies code to explore);
  a greenfield phrasing is what isolated the trigger here.
