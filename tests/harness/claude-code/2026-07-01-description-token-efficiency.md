# Activation record — description token-efficiency pass (2026-07-01)

Records an always-loaded-surface trim: 26 skill `description`s were shortened by
cutting the middle *what-it-does* clause (e.g. "Produces the X section…",
"Dispatches an independent reviewer…", "Sets up a worktree with its own branch,
ports, and data…") while keeping the `Use when…` trigger, the `Skip…` clause, and
any genuine this-vs-that disambiguation. Rationale is doctrinal: `writing-skills`
warns that a description summarizing the workflow makes the model follow the
summary and skip the skill body. Net ~620 tokens off the per-session Skill
manifest. Activation results are ephemeral (real API calls, not CI) — re-run the
scripts for current truth. This file states what changed and what the runs showed,
including the part where I was initially wrong.

## What changed

- **24 capability descriptions** trimmed (spec-it, dispatching-parallel-agents,
  handoff, interview-me, prototyping, using-augments, using-task-branches,
  writing-skills, zoom-out, finishing-a-branch, release-readiness,
  architecture-decisions, coding-standards, data-model, system-architecture,
  ui-ux, writing-plans, executing-plans, post-mortem, refactor-architecture,
  define-goals, feasibility-check, scope-it, security-audits).
- **requesting-code-review** (the flagged one): 503 → 259 chars — dropped an
  embedded rationale ("Green gates don't substitute…") and a what-it-does summary.
- **yagni** (a discipline): 665 → 527 — dropped only the pure-rationale sentence
  "Guards both directions…"; both bidirectional triggers, the TDD deconfliction,
  and the skip were kept.
- The **four ALWAYS discipline triggers** (test-driven-development, debugging,
  receiving-code-review, verifying-completion) were **left untouched** — pure
  forceful trigger with no what-it-does fat; trimming them buys little and owes a
  pressure re-proof.

## Runs and results (real `claude` CLI, `--working-tree` = live edits)

| Skill | Opening | Verdict |
| --- | --- | --- |
| requesting-code-review | committed scenario ("finished the rate-limiter… get it reviewed") | ACTIVATED — `using-augments → requesting-code-review` |
| release-readiness | committed scenario ("about to deploy… make sure we're ready") | ACTIVATED — `using-augments → release-readiness` |
| yagni | committed scenario ("we only ever send email…") | old 665 → ACTIVATED; trimmed 527 → **NONE** |
| yagni | **greenfield** re-run ("brand-new empty project… don't over-engineer it") | trimmed 527 → **ACTIVATED 3/3**; old 665 → 1/2 (miss → interview-me) |

## The part I got wrong, then corrected

On the *committed* yagni scenario the single-shot A/B (665 ACT, 527 NONE) looked
like a regression from dropping the word "over-engineering", and I nearly reverted
on that basis. But `2026-06-30-yagni-trigger-activation.md` already documents that
this committed scenario is a **poor activation signal in the isolated empty temp
dir** — it implies an existing codebase to explore, and returns NONE even with a
good trigger. Re-running on a **greenfield** opening that keeps the "over-engineer"
keyword removed the artifact: the trimmed 527 fired yagni **3/3**, the original 665
only **1/2**. So the trim fires at least as reliably — **527 kept**. The lesson is
recorded: never judge a discipline trigger from one run of a flaky scenario.

## Bodies

Bodies load on demand, not per-session, so they are not the always-loaded win. A
conservative scan of all 24 capability bodies found them already lean — tuned to
the intro → procedure → `Common mistakes` recall structure — with exactly one safe
cut (a `spec-it` line that restated the Evaluator/Acceptance mapping already stated
in step 5). Applied that; left everything else rather than manufacture cuts.
`requesting-code-review`'s body also lost a self-introduced redundancy (step 2 was
re-explaining the tier-by-risk that the new "Review depth" section now owns).

## Honest caveats

- Single/low-N runs — these show the mechanism fires, not a hit-rate. The yagni
  "no regression" claim rests on 3/3 greenfield trimmed vs 1/2 original, plus the
  documented empty-dir artifact on the committed scenario.
- A/B on capable (large-tier) models generally shows leanness helps the token
  budget more than it changes activation — the win here is the ~620 always-loaded
  tokens, not a claimed activation lift.
