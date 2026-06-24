---
name: receiving-code-review
description: ALWAYS invoke when review feedback arrives — from a human or another agent — on code you wrote, before you respond or act on any finding. Verifying each finding against the code first is mandatory; agreeing or editing without checking is the mistake. Push back with evidence when a finding is wrong; refuse performative agreement.
---

# Receiving Code Review

Review feedback is input to verify — not orders to obey, and not applause to return. Each finding is a *claim* about your code; your job is to confirm it against the code, then act on the merits. A reviewer can be wrong; so can you. Technical correctness over social comfort.

## When to use

- Any review feedback has arrived on code you wrote — a human reviewer, an AI reviewer, a PR comment thread.
- **Not** a step you skip because the feedback "looks obviously right". Obvious-looking findings are exactly where unverified agreement ships a wrong change.

## The discipline

1. **Gather all of it first.** Collect every comment — top-level, inline, per-file — before acting. Items relate; acting on a subset misimplements the whole.
2. **Understand each item.** If any is unclear, STOP — ask, don't guess. Partial understanding produces the wrong fix.
3. **Verify against the code.** For each *finding*, confirm the problem is real before changing anything. For each *suggestion*, check it's actually needed here (grep for the usage) before adopting it.
4. **Respond on the merits.** Agree where verified; push back with evidence where not. "Checked X — it already handles Y, leaving as is" is a complete, correct response.
5. **Acknowledge substantively, not socially.** "Verified — fixing." / "You're right, confirmed Z." No "absolutely right!", no thanks, no over-explaining. State it and move.

## Red flags — these thoughts mean STOP

| Thought | Reality |
| ------- | ------- |
| "You're absolutely right!" | You haven't checked yet. Verify first, then respond. |
| "The reviewer said so, just do it" | Reviewers are fallible. Confirm the problem is real before changing code. |
| "I'll make it more robust while I'm here" | A suggested feature still has to be needed. Grep for the use; YAGNI otherwise. |
| "I'll fix the ones I get and skip the unclear ones" | Partial understanding = wrong fix. Items relate — clarify before acting. |
| "Easier to just agree and move on" | Social comfort over correctness. The reviewer and you both serve the code. |

## Common mistakes

- Implementing a finding without reproducing the problem it claims to find.
- Adding "proper" machinery a reviewer suggested that nothing in the codebase needs.
- Performative agreement that commits you to a change you never verified.
