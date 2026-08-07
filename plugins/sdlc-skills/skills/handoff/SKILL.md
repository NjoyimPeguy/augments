---
name: handoff
description: Use when a session is ending or work is passing to a fresh session or another agent — so the next one resumes without re-deriving goal, state, decisions, and the next step. Skip for a finished, self-contained task that needs no continuation.
---

# Handoff

Write down what the next session needs to continue, so it doesn't reconstruct it from scratch. A good handoff is *resumable*: someone reads it and knows exactly where to pick up.

## When to use

- A conversation is ending mid-work, or work is passing to a fresh session or a different agent.
- **Skip** when the task is finished and self-contained — there's nothing to resume.

## What to capture

Use the harness/user's durable handoff store only when current disclosure
authority covers its recipient and storage boundary. Otherwise leave transfer
pending and report the missing authority. For a named scratch path outside the
workspace, record data class, allowed access, retention/expiry, exact cleanup
targets/effects/recoverability, cleanup owner, authority, and pending/completed
state. Do not pollute the repository or infer future cleanup. Include:

1. **Handoff identity** — stable ID/content identity, created-at time, sender,
   intended recipient/scope, and predecessor when this replaces a prior record.
   Keep records append-only; a successor never silently overwrites its source.
2. **The goal** — what this work is trying to achieve, in a line or two.
3. **State identity** — plan/artifact version, branch, commit, workspace, full
   relevant dirty/ignored/generated inventory, external gate inputs, done/in-flight work.
4. **Decisions and authority** — exact choice, scope, direct answer or standing
   default that authorized it, and every decision still pending. A handoff never
   upgrades an assumption into approval.
5. **Evidence** — command/action, cwd, environment, tree/artifact, timestamp, and
   result for gates being relied on; mark stale or unrun evidence plainly.
6. **Gotchas and permissions** — traps with file/line evidence, unavailable
   access, and external or destructive actions still awaiting permission.
7. **Resume first action** — refresh repository/artifact/external state and
   invalidate evidence changed since the handoff; only then name the next mutation.
8. **Suggested skills** — advisory candidates for the next session's contextual
   route, never proof of invocation or a fixed sequence.

## Rules

- **Reference, don't duplicate.** Point to existing artifacts (specs, plans, ADRs, issues, commits) by path or URL — don't copy their content in.
- **Redact secrets.** No keys, tokens, passwords, or personal data in the handoff.
- A handoff is a one-shot transfer of *current* state — not a durable project-lessons store.
- If multiple terminal successors exist or content identity does not verify,
  stop and resolve the handoff lineage instead of guessing which record wins.
- **Refresh before mutation.** The next session verifies identity, status,
  approvals, and time-sensitive external state; it never executes the recorded
  next step merely because the handoff says so.

## Common mistakes

- A summary of the conversation instead of the state to resume from.
- Duplicating a plan or spec that already exists — link it.
- Omitting the one concrete next step, leaving the next session to guess.

For a fill-in template, a worked bad-vs-good example, and what to leave out, see `references/handoff-template.md`.
