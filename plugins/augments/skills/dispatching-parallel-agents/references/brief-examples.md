# Dispatch briefs in depth

Worked examples behind `../SKILL.md` — loaded on demand. Each pair shows a weak brief and the strong one for the same task. The difference is never length; it's that the strong one is self-contained: a subagent with zero shared session can start cold and finish to a reconcilable "done."

## The brief template

Fill every field. Delete a field only when it is genuinely empty for this task — and say so, so the agent knows the omission is deliberate.

```text
TASK: {{one sentence — the exact problem this agent owns}}
TIER: {{small | medium | large}}
OWNS: {{files/dirs it may edit}}
DO NOT TOUCH: {{files/dirs owned by other agents, or off-limits}}
START FROM: {{pasted verbatim: the task contract, the exact spec, the failing test name}}
READ: {{paths of bulky context — diffs, logs, large fixtures — read on demand, don't paste}}
DONE WHEN: {{the observable condition — a named test passes, a specific output exists}}
REPORT: {{exact shape to return — e.g. "root cause, files+lines changed, command run and its verdict, anything left out of scope"}}
ISOLATION: {{own workspace/port/db if it builds or runs anything; else "none needed"}}
```

Two rules behind the template:

- **Paste what defines the task, point at what informs it.** The failing assertion, the acceptance criterion — paste. The full log, the diff, the fixture — give a path.
- **Bound the agent's reach.** Without "DO NOT TOUCH" + "report out-of-scope rather than reaching," a helpful agent fixes the neighbouring thing too — and now two agents are editing the same file.

## Pair 1 — separate failing tests

Two failing tests in two test files. Independent: disjoint files, no shared state, no ordering.

**Weak:**

```text
Fix the failing tests in test/auth and test/billing. Run the suite when done.
```

Why it fails: the agent touches both — that was one agent doing two tasks serially, so the fan-out bought nothing; "the suite" runs the other agent's half-fixed code and muddies the verdict; no report shape, so you get prose you can't reconcile.

**Strong:**

```text
TASK: Make the failing test 'rejects an expired token' pass in tests/auth/expiry_test.go.
TIER: medium
OWNS: tests/auth/expiry_test.go, src/auth/expiry.go
DO NOT TOUCH: anything under tests/billing/ or src/billing/ — another agent owns it.
START FROM: failing assertion, verbatim:
  expected status 401, got 200 for a token expired 1 minute ago
READ: {{path to the token-lifetime docs}} — skim only if expiry.go isn't self-explanatory.
DONE WHEN: `go test ./tests/auth/ -run TestExpiredToken` exits 0. Run the command; read the output.
REPORT: root cause in one sentence; files+lines changed; the exact command run and its exit code; anything you saw but left alone as out of scope.
ISOLATION: none needed — tests are self-contained, no server, no db.
```

Dispatch the billing test as a second, symmetric brief. Note what the strong one carries that the weak one doesn't: the failing assertion pasted (the agent never runs a red suite to discover it), the exact verification command, and a boundary that keeps the two agents apart.

## Pair 2 — unrelated bugs

Two bug reports: a crash in export, a typo in a settings label. Independent: different subsystems.

**Weak:**

```text
Here's the session so far: [dumps session history]. Fix the export crash and the settings typo.
```

Why it fails: session history is not context — it carries your dead ends and misreadings, and the agent inherits them. Two bugs in one brief means the agent sequences them anyway and can half-finish both.

**Strong (export crash):**

```text
TASK: Find and fix the crash when exporting a project with zero images.
TIER: medium
OWNS: src/export/
DO NOT TOUCH: src/settings/ or anything UI-facing — another agent owns a separate fix there.
START FROM: reproduce: 1) new project, 2) delete all images, 3) Export → crash with
  "TypeError: cannot read 'width' of undefined" at export/render.ts:88
READ: src/export/render.ts, src/export/pipeline.ts
DONE WHEN: the reproduce steps complete and produce a valid export file; `npm test -- export` exits 0.
REPORT: root cause; the fix and its location; commands run and their verdicts; edge cases you checked (one image? image deleted mid-export?) and the result for each.
ISOLATION: run in your own workspace copy; the dev server port is 3000 — if you need one, take a distinct port in the 3xxx range and say which.
```

The typo gets its own brief at the small tier. Note the reproduce steps pasted verbatim — that's the defining snapshot — and the isolation line that prevents the classic collision: two agents both binding port 3000 and each debugging the other's failure.

## Pair 3 — parallel research

Compare three caching approaches for a read-heavy endpoint; recommend one. Research agents write no code, so the file-collision risk is nil — the real risk is three incompatible report shapes you can't reconcile.

**Weak:**

```text
Research caching options for the product list endpoint and tell me which is best.
```

Why it fails: "best" undefined — each agent optimises a different axis; no criteria, no report shape, so you get three essays that don't line up; no scope, so one agent reads the whole codebase for a week.

**Strong:**

```text
TASK: Evaluate {{approach}} as the cache for the product-list endpoint.
TIER: small
OWNS: nothing — read-only. Do not modify files.
READ: src/api/product_list.ts (the endpoint), src/api/README.md (current load profile).
JUDGE AGAINST, in order: 1) correctness under concurrent writes, 2) p95 read latency at the load in README, 3) operational cost (new infra? new failure modes?), 4) lines-of-code cost to adopt.
DONE WHEN: you can answer all four criteria from evidence you actually read — a file, a measurement, or the approach's documented semantics. No "it should be fine."
REPORT, exactly this shape:
  - Approach: {{approach}}
  - Per criterion: verdict (good/bad/risky) + one line of evidence + where you read it
  - Deal-breaker if any, else "none"
  - Unknowns: what you could not determine from the repo
ISOLATION: none — read-only.
```

One brief per approach, identical except `{{approach}}`. The shared report shape is what makes the coordinator's job mechanical: line the four criteria up side by side and the recommendation falls out. The weak version gives you three opinions; the strong one gives you one comparison table.

## Failure patterns to check before dispatching

- **The brief that needs the session.** Any reference to "the earlier discussion," "as we decided," or "the bug I showed you" — the agent has none of that. Paste it or point at a file.
- **Bulk pasted, definition pointed.** A 500-line log inline and "the spec is at {{path/to/spec}}" is backwards. The paste tax is paid on every turn of the subagent's run.
- **Missing tier.** Omitted, the agent inherits the session's model — usually the most expensive one running a task a small tier would do.
- **Verification by description.** "Make sure it works" is not DONE WHEN. Name the command; the exit code is the verdict.
- **Symmetric overlap.** Two briefs that each say "and tidy up anything nearby" touch the same files. Generosity is a race condition.
- **Report shapes that don't reconcile.** If you can't put the agents' outputs side by side, you didn't specify the shape — you specified an essay contest.
