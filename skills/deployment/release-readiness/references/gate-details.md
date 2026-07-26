# Gate details

Expanded checks behind the readiness gate in `../SKILL.md`. Loaded on demand — when a gate item needs a concrete check, a template, or a failure pattern to rule out.

For each item: what *good* looks like, how to check it concretely from the repo, and the most common way it silently fails.

## 1. CI is green on the merged result

- **Good:** every integration check passed on the exact commit being shipped — after merge, not before.
- **Check:** look up the pipeline status for the merge commit (or the head of the release branch). Confirm the suite that ran is the full integration set, and that the run is newer than the last commit.
- **Silent failure:** the green badge is from a run *before* the last rebase or merge. The branch moved; the check didn't rerun. Another: a flaky test was retried until green, and the failure was never read.

## 2. Acceptance criteria verified

- **Good:** every criterion in the spec or issue maps to an observed result — a passing check, a reproduced behaviour, a screenshot — not to "the code looks right."
- **Check:** list the criteria verbatim, then name the evidence for each one. Any criterion whose evidence is "should" or "in theory" is unverified — run it now (see `verifying-completion`).
- **Silent failure:** the criteria were verified on a branch that then changed. A late "small fix" invalidated the earlier verification and nobody re-ran it.

## 3. Migrations are reversible

- **Good:** each schema or data migration has a down-path that was actually executed in a test, or — when a true down-path is impossible (a destructive data change) — a documented recovery procedure with a tested restore step.
- **Check:** run the migration up, then down, then up again against a scratch database. Confirm the down-path restores the prior schema *and* preserves data written while the new schema was live. Expand-and-contract beats a single destructive step: add the new shape, migrate, and only drop the old one in a later release.
- **Silent failure:** the down migration exists but was never run — it errors on first real use, exactly when you're rolling back under pressure. The runner-up: the down-path restores the schema but silently drops rows written in the new format.

## 4. Rollback target is named

- **Good:** an exact commit, tag, or artifact version is written down, along with the steps to revert to it — including what happens to migrations (item 3) and config (item 6) on the way back.
- **Check:** fill this in before deploy, and keep it where the on-call can find it:

```text
Rollback target: {{tag-or-commit}}
Revert by: {{command-or-deploy-step}}
Migrations to undo: {{migration-names-and-down-steps}}
Config to revert: {{variables-to-restore}}
Known gaps: {{what-rollback-does-not-undo}}
```

- **Silent failure:** "rollback" means reverting application code, but the migration already ran — the old code now runs against the new schema and fails differently than the new code did. If rollback and migrations disagree, the migration plan is the one to fix.

## 5. Risk is gated

- **Good:** non-trivial new behaviour ships behind a flag or a phased rollout, with the flag's default off (or the first phase small) and a named owner for flipping it.
- **Check:** for each risky behaviour, name the flag or rollout stage that controls it, its current state in the target environment, and the kill switch if it misbehaves. If there is no flag, the risk must be explicitly accepted by the human — that is a legitimate answer; silence is not.
- **Silent failure:** the flag exists in code but defaults to on, or the flag check sits *after* the risky work runs. Another: the flag guards the happy path but not the background job, migration, or event consumer that the same change introduced.

## 6. Config and secrets are present

- **Good:** every new or changed variable, secret, or setting the change reads is already set in the target environment — or the deploy ordering accounts for it — and each has a documented expected value or shape.
- **Check:** diff the change's config reads (environment lookups, config files, injected settings) against what the target environment actually defines. For secrets, verify *presence and shape*, never print the value.
- **Silent failure:** the variable is missing and the code falls back to a default — a local default. It "works," connected to the wrong thing, until it doesn't. Require explicit failure on missing config for anything that selects an environment (hosts, credentials, endpoints).

## 7. Changelog / release notes written

- **Good:** one honest line per user-visible or operator-visible change, written for the reader who wasn't in the room — what changed, what to do about it if anything.
- **Check:** the entry exists and a stranger could answer "do I need to act?" from it. A template that forces the point:

```text
{{version-or-date}} — {{what changed, in one line}}. Action needed: {{none | what, and by whom}}.
```

- **Silent failure:** the notes list commit messages — "fix bug," "update deps" — which describe the author's day, not the system's behaviour. The reader learns nothing and stops reading the notes entirely.

## 8. Breaking changes flagged to dependents

- **Good:** every change to a surface something downstream relies on — an API contract, an event schema, a data format, a CLI flag — is enumerated, and each dependent has been notified or the change is backwards-compatible by construction.
- **Check:** enumerate the public surfaces the diff touches. For each, answer: additive (safe), or changed/removed (breaking)? For breaking ones, name the dependents and how they were told — deprecation window, versioned endpoint, coordinated deploy.
- **Silent failure:** the change *looks* additive but isn't — a field renamed in the same payload, a value's type narrowed, an event's ordering changed. Dependents parse it fine and compute the wrong answer. Type and ordering changes are breaking even when the schema still validates.

## 9. Downtime is none, or scheduled

- **Good:** either the deploy is provably zero-downtime (compatible old/new running side by side), or a window is scheduled, communicated to the people affected, and sized with margin.
- **Check:** walk the deploy sequence in order and ask, at each step, what a request in flight sees. If any step answers "an error" or "the old code against the new schema," that's downtime or a compatibility bug — pick the window deliberately instead of discovering it.
- **Silent failure:** "rolling deploy, so no downtime" — but the deploy includes a migration the old version can't run against. Requests hitting the old instances during the roll fail one at a time, so the monitor stays green until the roll finishes.

## When the gate can't fully pass

A failed item is not always a cancelled release — it is an *owned* risk. Record it in one line: the item, the risk, who accepted it, and what would trigger the rollback. What the gate forbids is the third outcome: an item nobody looked at.
