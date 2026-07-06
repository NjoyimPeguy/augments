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

Write it to a scratch location outside the workspace (the OS temp directory), so it doesn't pollute the repo. Include:

1. **The goal** — what this work is trying to achieve, in a line or two.
2. **State** — what's done, what's in flight, the current branch, and any uncommitted changes.
3. **Decisions** — the choices made and why, so they aren't relitigated.
4. **Gotchas** — traps discovered, with file and line references.
5. **The next step** — the single concrete thing to do next.
6. **Suggested skills** — which skills the next session should reach for. Put this *in the document*, not in passing chat.

## Rules

- **Reference, don't duplicate.** Point to existing artifacts (specs, plans, ADRs, issues, commits) by path or URL — don't copy their content in.
- **Redact secrets.** No keys, tokens, passwords, or personal data in the handoff.
- A handoff is a one-shot transfer of *current* state — not a durable project-lessons store.

## Common mistakes

- A summary of the conversation instead of the state to resume from.
- Duplicating a plan or spec that already exists — link it.
- Omitting the one concrete next step, leaving the next session to guess.
