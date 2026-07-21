# Behavioral test: checkpoint commits (using-task-branches + verifying-completion)

Records the 2026-07-21 additions protecting against work loss: a maintainer
field concern — an agent accumulates hours of verified work in the working
tree, and a power cut, crashed session, or bad command loses all of it,
because nothing tells it to commit before the end.

The rule was added at two homes that load at the right moments:

- `using-task-branches` (*Checkpoint while you work*): after each coherent
  unit passes its check — and whenever more uncommitted work has accumulated
  than you would willingly redo — commit on the task branch; what counts as
  a unit is the agent's judgment, WIP messages are fine,
  `finishing-a-branch` tidies history.
- `verifying-completion` (*Verified, then banked*): a state that just passed
  its check exists only in the working tree until committed — checkpoint
  before moving on.

## Scenario

A small git repo (one existing utility + test, committed on `main`), agent
on task branch `feature/more-utils`, asked to implement three more
utilities with tests (slugify, clamp, chunk). Fresh headless session per
arm, working-tree plugin, full tool access in a disposable fixture copy.
RED ran against the unedited skills; GREEN against the edited ones.

## Result (2026-07-21, one run per arm, large tier)

- **RED:** all three utilities built and verified with everything sitting
  uncommitted until one commit at tool call 23 of 41 — the exposure pattern
  the rule targets, reproduced. A later fix was folded in with
  `git commit --amend`. Final state: 1 new commit, clean tree, 12/12 tests.
- **GREEN:** first commit at tool call 22 of 41 banking the verified suite;
  the post-review fix then got **its own immediate commit** (no amend, no
  dirty accumulation). Final state: 2 new commits, clean tree, 15/15 tests.
  The full discipline chain ran (TDD → verifying-completion →
  requesting-code-review → receiving-code-review → finishing-a-branch).

## Honest conclusion

**Separation on this fixture is weak — inconclusive for necessity, positive
for direction.** The task is ~10 minutes of work, so "commit before the end"
and "commit at the end" nearly coincide; and the task-branch framing already
licensed RED to commit once. What the fixture cannot reproduce is the real
target regime: an hours-long task where the first bank point arriving only
at the end is the whole loss surface. The additions were kept: they are two
short additive paragraphs (no tuned content reworded), grounded in a real
maintainer-reported concern, and GREEN's observable behavior (a checkpoint
at each verified boundary, no amend-accumulation) is exactly the intended
shape. The GREEN run doubles as the treatment-arm re-run owed for the
`verifying-completion` body addition (its gate ran fresh and held). If a
long-session probe ever reproduces the end-only bank point with the rule
loaded, that is the RED to upgrade this record with.

## Cross-harness note

The edited bodies are shared content, and both skills' *activation* on the
other adapter was live-proven the same day (per-phase sweep + chain
records). A checkpoint-behavior probe on that adapter has not been run —
this record claims nothing about it.
