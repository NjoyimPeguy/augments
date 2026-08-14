---
name: handoff
description: "Use when a session is ending or work is passing to a fresh session or another agent, so the next one resumes without re-deriving the goal, the state, the decisions, and the next step. Fires on I'm heading out, wrapping up for the day, context is getting full, and someone else is taking this over, even if nobody says handoff. Skip a finished, self-contained task that needs no continuation."
---

# Handoff

Write down what the next session needs to continue, so it doesn't reconstruct it from scratch. A good handoff is *resumable*: someone reads it and knows exactly where to pick up.

## When to use

- A conversation is ending mid-work, or work is passing to a fresh session or a different agent.
- **Skip** when the task is finished and self-contained — there's nothing to resume.

## Where it may be written

A handoff moves state to a recipient, so writing one is a disclosure. Where an
instruction or standing authority already names the destination, write it there
and do not ask. Otherwise the destination is the user's choice and not a default
to pick. Ask one conversational question offering: the durable handoff store
(naming who can read it), a path the user names, or this reply only with no
write. Recommend the least-disclosing option that still reaches the intended
recipient, with one sentence of reasoning, then stop.

Nothing is written until one of the three arrives; "wherever is easiest",
approval of the *content*, and silence are not a destination.

Writing to a named scratch path outside the workspace also creates a cleanup
obligation: record its data class, who may read it, how long it lives, the exact
cleanup target and owner, and whether cleanup is still pending. Never pollute
the repository, and never assume someone will clean it up later.

## What to capture

Fill `assets/handoff-template.md`. It carries every section a resumable handoff
owes — the identity block, the goal, state identity, decisions and authority,
evidence, gotchas and permissions, the resume action, and suggested skills.

Four judgements the template cannot make for you:

**Records are append-only.** A successor names its predecessor; it never silently
overwrites the source. Where several terminal successors exist, or the content
identity does not verify, stop and resolve the lineage rather than guessing which
record wins.

**A handoff never upgrades an assumption into approval.** For every decision,
record the direct answer or the standing default that actually authorized it, and
leave every still-open decision listed as open.

**Weak evidence gets marked, not omitted.** For each gate you are relying on,
record the command, where it ran, the tree it ran against, when, and the result —
and say plainly when something is stale or was never run. Leaving a weak result
out is how the next session inherits a claim nobody checked.

**Suggested skills are advisory.** They are candidates for the next session's
route, never proof that anything was invoked, and never a fixed sequence.

## Rules

- **Reference, don't duplicate.** Point to existing artifacts (specs, plans, ADRs, issues, commits) by path or URL — don't copy their content in.
- **Redact secrets.** No keys, tokens, passwords, or personal data in the handoff.
- A handoff is a one-shot transfer of *current* state — not a durable project-lessons store.
- **Refresh before mutation.** The next session verifies identity, status,
  approvals, and time-sensitive external state; it never executes the recorded
  next step merely because the handoff says so.

## Common mistakes

- A summary of the conversation instead of the state to resume from.
- Duplicating a plan or spec that already exists — link it.
- Omitting the one concrete next step, leaving the next session to guess.

`assets/handoff-template.md` also carries a worked bad-versus-good example and
what to leave out.
