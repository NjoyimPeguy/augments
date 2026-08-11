# tests/optimizing/

Measurements, not gates. Nothing here has a correct answer known in advance —
you get a number, compare it to the number the previous iteration got, and
exercise judgement. **A red sheet here is not a regression.** That is what
separates this directory from the gates beside it in `tests/`, where red does
mean something broke, and it is why the two do not share a runner.

What lives here is the Agent Skills standard's description-tuning loop: score a
description against a set of queries, revise it against the failures, score it
again, and keep the iteration that did best. The corpora are its input, not a
test suite that happens to be written in JSON.

## Layout

```
tests/optimizing/descriptions/
  test-triggering-on-queries.sh   scores a DESCRIPTION: queries x runs -> trigger rate
  <phase>/<skill>.json            20 scored queries: 10 positive, 10 near-miss
```

The runner is self-contained: it opens a session per query repetition, points it
at a seeded project from `tests/fixtures.sh`, and reads which skills fired from
the CLI's own stream through `tests/harnesses/<name>.sh`.

```bash
tests/optimizing/descriptions/test-triggering-on-queries.sh --harness codex --all --dry-run
tests/optimizing/descriptions/test-triggering-on-queries.sh --harness claude-code --skill yagni --split validation
```

`--help` covers the flags. This file covers what the flags cannot say.

## Anyone can run this, and it spends your own quota

**One skill at the defaults is 60 live calls** — 20 queries repeated 3 times —
billed to whatever account your harness CLI is logged into, and `--all` is
roughly 2,000. Nothing about it is free and nothing about it runs in CI.

Always price a selection with `--dry-run` first; it prints the exact call count
and calls nothing. The table further down has measured wall-clock figures.

## A trigger rate is not a pass mark

The standard describes three roles for query data, and this repository
implements two of them:

1. **train** — the failures you are allowed to revise against.
2. **validation** — the split that *selects* which iteration you keep.
3. **a fresh held-out set, written after selection** — the only one the standard
   calls a test.

Role 3 does not exist here. That is the honest limit, and it has a consequence
people get wrong: because validation is what selection is performed on, repeated
selection burns it too. Tune against train and the holdout stays meaningful for
a while; tune against validation and you have overfitted away the only thing
that was telling you the truth. Either way, **neither split is a held-out
result**, so no number produced here is evidence that a description generalises
to openings nobody wrote down.

What the numbers are good for is comparison between two iterations of the same
description, measured the same way. That is genuinely useful and it is all they
are.

Practical consequences:

- Revise on **train** failures only.
- Keep the iteration with the best **validation** rate, which is very often not
  the last one you tried.
- Report the real numbers, including inconclusive and failing ones, and say how
  many runs produced them.

## The query sets

Drop a JSON array at `descriptions/<phase>/<skill>.json`. The filename is the
contract — no registration, no code change. Each entry needs `query`,
`should_trigger`, and `split`; every negative also needs `expect`, naming the
route it should have taken instead (`"none"` if there isn't one).

**Nothing enforces the shape of a set — that is on the reader.** A set is only
worth the money it costs to run if it can actually decide something: at least
ten positives and ten near-miss negatives, no duplicates, a validation split
between a quarter and a half of the set, and the same positive-to-negative
proportion on both sides of it. Twenty happy-path positives will pass every eval
they are ever run through and prove nothing. Check the shape when you edit a set;
a live run cannot tell you the set was broken.

**The near-misses are the point.** A description firing on its own happy-path
opening proves nothing, because every description does that. A negative earns
its place by genuinely sharing vocabulary with the description while belonging
to a different skill. Negatives also carry `expect` — the route they *should*
have taken — so a greedy description and a real gap in the library stay
distinguishable in the report.

Each query is pinned to `train` or `validation` in the file itself, so the
holdout can never be quietly reshuffled into the training data.

**Ground the query in the fixture whenever the verb presupposes what it names.**
Asking to *add* `src/utils/money.ts` works whether or not that path exists;
asking to *delete* or *refactor* it does not — the agent answers that there is
no such file and routes nowhere, which is indistinguishable in the report from a
description that failed to fire. A query like that scores the fixture, not the
description. `tests/fixtures.sh` says what actually exists.

## What this costs, before you run it

Every call here hits a paid API, and the matrix multiplies fast. Measured on
this repository:

| Selection | API calls | Per call | Wall clock |
| --- | --- | --- | --- |
| One skill, validation split, 3 runs | 24 | ~1–2 min | ~25–50 min |
| One skill, every query, 3 runs | 60 | ~1–2 min | ~1–2 h |
| `--all`, validation only, 3 runs | 792 | ~1–2 min | **~20 h** |
| `--all`, every query, 3 runs | 1980 | ~1–2 min | **~50 h** |

`--dry-run` prints the exact call count for any selection before you spend it.
Neither full sweep is a routine run: a description is revised one skill at a
time, so measure the skill you touched.

The wall-clock column assumes `--jobs 1`. Repetitions of a single query are
independent, so `--jobs` fans them out and the default of 3 divides those times
by roughly three — measured at 123s for three concurrent negatives against 360s
of serial worst case, with no refusals. The call count does not change, only how
long you wait for it.

Negatives dominate that clock. A positive stops the moment the expected skill
fires; a negative has nothing to wait for and runs to `--max-turns` or the
timeout, so the back half of a set costs multiples of the front half.

**Keep `--jobs` equal across runs you intend to compare.** Concurrency does not
change what is measured, but it can change whether a call completes, and a
timeout scores as "did not fire" rather than being dropped from the denominator.
A before/after pair split across two concurrency levels is confounded, and the
artifact of that looks exactly like a description regression.

## The sibling loop, and why it is not here

The standard also describes an output-quality loop: run a skill on a task, judge
the artifact, revise, repeat. This repository measures that question in
`tests/run-behavioral.sh --arm none` instead, and deliberately did not build a
second implementation of it.

The reason is that the pieces already here are the stronger form. A `git
worktree` at `--base` gives a reproducible before-arm where a copied snapshot
does not, and an exit-code verdict is not written by the agent that wants it
green. What that loop offers beyond this is aggregation across repetitions —
worth taking — and an LLM judge, which is worth less than the mechanical check it
would replace. Building the rest would make the evaluator larger than the thing
evaluated, which the repository's proportionality rule forbids.

## Honest limits

Live runs cost tokens and are **not deterministic**: the same query fires and
does not fire across runs, and coverage is selective by design. So these are
manual tools, never CI, and no result is committed as a record — re-run for
current truth.

A single green run is weak evidence. Say how many runs you did and what the
spread was; the runner prints `(fired/valid)` beside every rate for exactly that
reason. A run the harness marks **inconclusive** is dropped from the
denominator rather than scored, because a provider that never answered is not
evidence about a description. An observed failure the harness cannot explain is
a finding, not a rerun.
