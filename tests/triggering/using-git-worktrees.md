# Triggering test: using-git-worktrees

Activation depends solely on the `description` (see `skills/common/writing-skills/reference.md`). A record, not an automated gate (`README.md`); re-run when the description changes.

**Method.** Fresh subagents see only the catalogue of `name :: description` (no bodies) and one opening message, and list every skill whose trigger matches. LLM-judge proxy. Several fresh trials.

## Scenario

- **Positive (isolation needed):** "I'm about to start a risky database migration refactor — several commits over a while — and I do not want it touching my main working tree until it's proven."
- **Negative (over-trigger guard):** "Fix the typo in the README's top heading."

## Pass criteria

- **GREEN:** the isolation request routes to `using-git-worktrees`; the trivial one-liner does not (no ceremony on tiny tasks).

## Last result (2026-06-05)

New skill. Isolation request → `using-git-worktrees` **3/3** ("the user explicitly wants isolation from the main working tree for a multi-commit risky change — the exact scenario"). Trivial typo → **0/2** (both returned no skill: "a trivial one-liner with no matching trigger"). Fires when isolation is needed, silent when it isn't.
