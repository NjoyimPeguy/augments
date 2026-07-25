# Behavioral test: spec-it reference forms (Codex CLI)

The Codex arm of the 2026-07-25 `spec-it` change recorded for Claude Code in
`../../claude-code/behavioral/spec-it.md`. Same change, same fixture, different
harness — and a **different outcome**, recorded here because it is a finding, not
a formality.

Run after the change had already merged (PR #30), to close a gap: the original
PR ran only Claude Code and named only Kimi as unrun, while `codex-cli 0.145.0`
was installed and available.

## Scenario

Fixture identical to the Claude Code arm: a small committed Node repo
(`billing-api` — an 11-line dispatcher, an API-key resolver with `free`/`pro`/
`enterprise` tiers, one `node:test` suite, and a `package.json` whose `test`
script is subtly broken). Agent on task branch `feature/rate-limiting`.

Driven with `codex exec --json --skip-git-repo-check -s workspace-write` in an
isolated `CODEX_HOME`, plugin installed from a local marketplace — the
`run-activation.sh` mechanism with `-s read-only` swapped for `-s workspace-write`
so the agent can actually produce artifacts. RED installed from a
`git worktree` at `ad77c60` (pre-change); GREEN from the working tree.

**The opening differs from the Claude Code arm, deliberately.** `codex exec` is
single-turn, so a clarifying question *ends the run with no deliverable* — the
first RED attempt did exactly that, terminating on an `interview-me` question
about quota values after routing correctly through
`using-augments → spec-it → interview-me → using-task-branches → zoom-out`. The
re-run supplies the tier limits up front and instructs a non-interactive run.
**Both** Codex arms use that identical text, so RED vs GREEN remains controlled
*within* this harness; cross-harness comparison with the Claude Code record is
correspondingly weaker and should not be read as like-for-like.

## Result (2026-07-25, one run per arm)

- **RED:** a 211-line prose spec, **zero** test files. Its acceptance criteria
  are detailed procedural test recipes in English — *"Register two distinct keys
  for the same tenant and tier. Exhaust key A and verify that key B retains its
  full independent allowance."* All the information a test needs, in a form that
  cannot run and that the implementer must re-derive. A purer instance of the
  gap than the Claude Code RED, which at least *claimed* automated tests.

- **GREEN — partial, and the artifact never appeared.** `reference-forms.md` was
  read (3 command executions against it) and the prose changed: every acceptance
  criterion is now labelled an *"executable API acceptance test"*, NFR-2 carries
  a named security-review rubric, and the broken `npm test` was diagnosed
  correctly (`node --test test/` treating `test/` as a module path) — the same
  defect the Claude Code GREEN arm found.

  But **no test file was written**, and the refusal was explicit and reasoned:

  > No executable acceptance artifact is claimed by this requirements-only
  > change. Creating one now would select the public wire contract,
  > protected-request scope, window alignment, and integration seam that this
  > spec deliberately records as [open questions].

  It also routed the broken test runner to *"a separate prerequisite change"*
  rather than fixing it — where the Claude Code arm fixed it on the spot,
  citing step 6.

  Files produced: the spec (508 lines) and an unprompted
  `.augments/reviews/…-spec.md`. Chain read: `using-augments`, `spec-it`,
  `interview-me`, `using-task-branches`, `requesting-code-review`,
  `verifying-completion`, `debugging`, `security-audits`,
  `receiving-code-review`.

## Honest conclusion

**Step 6 ("build what you named, and confirm it runs") did not hold on this
harness.** The change transferred as *vocabulary and rubric use* but not as
artifacts. The record for Claude Code should not be read as covering Codex.

The failure is more interesting than a plain miss, and it is probably a wording
problem in the skill rather than harness weakness: the model argued the artifact
out of scope using reasoning that `spec-it` itself supplies. The body warns that
*"a failing test asserting observable behaviour is a requirement; one asserting
an internal call you haven't designed is not"* — and GREEN generalised that guard
into "the wire contract is undecided, therefore no test can be written yet."
That is a defensible reading of the current text.

Follow-up this suggests (not done here): `spec-it` needs to say what to do when
the contract a test would assert is itself open — assert at the level the
requirement actually fixes, or state the contract as an explicit assumption and
write the test against it. Until then, step 6 has a loophole that a careful agent
will find.

Limits: one run per arm, one scenario. The opening differs from the Claude Code
arm for the harness reason given above. The mockup and reference-implementation
forms remain untested here as well. Kimi Code was not run.

## Update (2026-07-25, later the same day): the follow-up was done

The loophole named above was fixed, and re-running GREEN found **two more**
behind it. Each fix removed exactly the failure it targeted and exposed the next
— recorded in order, because the sequence is the finding:

| GREEN run | Skills | Artifact produced | Why it still failed |
| --- | --- | --- | --- |
| #1 | pre-fix | **none** | refused: *"requirements-only… would select the wire contract"* |
| #2 | + open-contract fix | 342 lines, real assertions | **every test marked `todo`** → `npm test` exits 0 |
| #3 | + no-neutered-criterion fix | 328-line spec, 11 tests, **0 markers**, fails standalone | project's `npm test` left broken, so its own gate never runs it |

**Fix 1 — an open contract is not an exemption.** Step 6 now says an undecided
interface defers a test's *shape*, never its existence. Run #2 wrote a suite; the
refusal was gone.

**Fix 2 — a criterion that cannot go red is not a criterion.** Run #2's `todo`
markers were **the skill's own fault**: `reference-forms.md` said to leave tests
*"failing (or marked pending in the project's idiom)"* while step 6 demanded they
fail. The agent followed the sibling. Both places now say the same thing, and run
#3 produced zero markers.

**Fix 3 — confirm it runs through the project's own command.** Run #3's artifact
was valid and failed standalone for the right reason, but `npm test` still could
not load it and was left unfixed. Claude Code hit this **identically** (see
`../../claude-code/behavioral/spec-it.md`, runner run #1), so it was closed on
two-harness evidence.

**Not verified here:** Codex was **not** re-run after fix 3. It was verified on
Claude Code only (PASS). Whether run #4 on Codex would clear the probe is
unknown, and this record does not claim it.

Method notes for anyone re-running: run #2 hit the 1200s timeout (exit 124) and
was cut off mid-work — the timeout is now 2400s; run #3 completed at exit 0. All
three GREEN runs were scored with the Claude Code adapter's
`behavioral-scenarios/spec-it/probe.sh`, which is harness-agnostic (it reads a
finished workdir, not a stream), so the verdicts are directly comparable.
