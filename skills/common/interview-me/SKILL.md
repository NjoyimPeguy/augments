---
name: interview-me
description: "Use when material intent has several plausible readings that no owning phase skill can safely settle, or when a pending material decision got neither an explicit answer nor an explicit cancellation — praise, constraints, silence, or a partial reply instead. Fires on a reply that approves of the work without choosing among the options put to the user, even if nobody asks for questions or clarification. Do not displace a skill merely because inputs its own procedure elicits are still open."
---

# Interview Me

Close the gap between what was asked and what is actually wanted — *before* you
build on it. This is a cross-cutting clarification technique, not a universal
first phase. Use it when the unknown controls which artifact or procedure is
needed, or whether that procedure can proceed safely. Do not displace a selected
skill that owns eliciting the still-open inputs.

## When to use

- A request is vague ("add auth", "make it faster") or has more than one reasonable reading.
- Assumptions are piling up before a plan or feature.
- A pending named decision received information but no accepted answer.
- **Skip** when the current phase skill owns the uncertainty: new-initiative
  outcomes and measures belong to `define-goals`; open interface flow, state,
  hierarchy, accessibility, and visual direction belong to `ui-ux-design`.
  A missing product requirement that blocks either procedure is still a genuine
  clarification or specification gap.
- **Skip** when the task is trivial or already fully specified — interrogating wastes turns.
- **Skip** when the task is clear and what blocks it is an obstacle, not a
  decision — a failing command, an error, a missing piece you can find or
  build. Fix it and continue to completion. Stopping to report a fixable
  obstacle and wait for instructions spends the user's turn on work that
  was already yours.
- **Skipping never licenses a silent decision.** State a reversible, low-impact
  assumption and its reason so the user can redirect. Material product, scope,
  architecture, execution, destructive, or external-state choices stay pending
  until the user decides them directly.

## Procedure

**1. Scan before you ask.** Read the request, then explore the codebase and context for what is already decided: conventions, similar features, libraries in use, naming. Never ask what the code already answers.

**2. Ask ONE question at a time.** For each open decision, in one short message:
- state what you found ("you already use Zod for validation"),
- name the exact artifact or operation the decision controls,
- recommend a default with one line of reasoning.

Prefer yes/no or a small multiple choice and name the accepted answers. Present
them conversationally: state what you found, recommend a default with one line
of reasoning, then offer two or three short answers including “something else”
when free-form input is valid. Wait for a direct answer — see *What closes a
decision* — before the next material one.

**3. Use each answer to prune.** An answer often settles later questions — drop them. Aim for ~3–6 questions total. If you need more, say why first.

**4. Stop when another question would not change the outcome** and every still-live
material decision has a direct answer. Do not turn a general “go” into answers to unnamed choices.

**5. Write an immutable proposed alignment brief** — a brief, not a spec. Fill
`assets/brief-template.md`; it carries the goal, the decisions and their
rationale, the non-goals, the open risks, and the identity and ledger fields.

Write it to `.sdlc-skills/briefs/{{YYYY-MM-DD}}-{{topic}}.md`, or the path the
user set, preserving the sections already approved around it. A tiny brief may
stay inline alongside its decision record instead.

**6. Present it for direct decision.** Record pending/changes-requested/approved/
rejected/cancelled/superseded-by-approved identity externally; never mutate the
proposed brief to mirror state. Only approval re-routes from the precondition this
brief satisfied—draft authority is not approval and planning is not assumed.

## What closes a decision

**Information is not authorization.** Praise, agreement with the reasoning, new
constraints, a partial answer, silence, or discussion of a neighboring choice
updates the context but leaves the question open. Incorporate it, say the
decision is still pending, and re-ask.

Only an explicit answer, named option, or standing default the user granted for
this decision class closes it. Approval covers only the visible version and named
next step; a material revision reopens it. Changes requested, rejection,
cancellation, or abandonment closes that exact decision without approval.
Supersession requires an approved replacement.

## When an artifact carries the pending decision

Write supplied facts or constraints into it only when current mutation authority
covers it. Before identity is issued, update the draft; once issued, never mutate
it — every normative change creates a new proposed successor naming its
predecessor. Without mutation authority, present the proposed update and keep the
artifact and decision pending.

The current user-role answer supplies authority for the current transition. A
persisted `Approval:` field is only a process record: in a fresh context it
cannot authenticate itself. Require the live answer or a project/harness receipt
that binds user origin to the exact version; otherwise refresh the decision.

## Common mistakes

- Asking what a 30-second code search would answer.
- Dumping many questions at once instead of adapting to answers.
- Producing a heavy spec — the brief is a short paragraph plus a few bullets.
- Interviewing trivial tasks.
