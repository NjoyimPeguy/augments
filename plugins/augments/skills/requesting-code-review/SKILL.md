---
name: requesting-code-review
description: Use when a non-trivial change reaches a done boundary — before calling it complete, committing, merging, or opening a PR, not only when you already want fresh eyes. Skip a trivial mechanical diff (rename, version bump, config one-liner) — self-review instead.
---

# Requesting Code Review

Get a change reviewed by fresh eyes before it merges. The reviewer sees the diff, not your reasoning — so its judgement is independent of the story you told yourself while writing it.

## When to use

- A change is finished and about to be merged, shipped, or called done — and it carries real risk: logic, a boundary, anything a reader could misread.
- **Skip** for a trivial mechanical diff (a rename, a version bump); a quick self-review against the checklist below is enough. Not every change earns a full dispatch.

## Review depth — decide before you dispatch

Depth scales with the change's risk and blast radius, not wall-clock time; the user can also name it ("quick look" vs "full review"):

- **Shallow** — a small, low-risk, or mechanical diff: the self-review checklist below, no dispatch.
- **Standard** (default) — real logic or a boundary: the breadth pass (`code-reviewer.md`) plus the specialists the diff actually touches.
- **Deep** — wide blast radius, hard to reverse, or a security surface (or the user asks for exhaustive): the breadth pass, *every* relevant specialist, `security-audits` if it crosses a trust boundary, plus an **adversarial pass** — independent reviewers prompted to *refute* the "ready to merge" verdict, so a confident-but-wrong review doesn't slip through.

Unsure? Default to Standard; escalate to Deep the moment the change is hard to undo.

## Procedure

1. **Pin the scope.** Establish the review range as a diff, `base..HEAD`. The diff is the unit — the reviewer reads what changed, not the whole repo.
2. **Dispatch a fresh-context reviewer.** Hand it `code-reviewer.md`, the diff *range* (`base..HEAD` for it to expand itself — not a pasted diff, which parks the whole change in the costliest context), the originating requirement (issue, spec, or plan), and the tier from *Review depth* above. It must not inherit your session — independence is the whole point.
3. **Review on two axes, kept separate** (the reviewer can run them as parallel passes):
   - **Standards** — does it match the project's conventions, style, and quality bar? Read the project's conventions file and linter/formatter config, not memory.
   - **Spec** — does it actually do what was asked? Code can be clean and still build the wrong thing.
4. **Read the verdict.** The reviewer returns severity-tiered findings (Critical / Important / Minor), each with a disposition (blocking / advisory) and its evidence, then an explicit *Ready to merge? Yes / No / With fixes* — never a bare "looks good". The return is the actionable part only; the full report (including what was verified clean) is a file the reviewer names, so re-checks and fix dispatches read the file, not a re-pasted worklog.
5. **Act on the verdict via `receiving-code-review`** — verify each finding against the code and respond on the merits, never by deference. That skill owns the responding discipline.

## Specialist depth passes (optional)

`code-reviewer.md` is the breadth pass — dispatch it every time. For a higher-risk diff, run one or more specialists *in parallel* alongside it (see `dispatching-parallel-agents`): each goes deep on one axis the breadth pass only skims and folds severity-grouped findings into that single merge verdict. Pick by what the diff touches — don't run all four by reflex.

- `silent-failures-reviewer.md` — error handling: swallowed or over-broad catches, masking fallbacks, lost propagation.
- `type-design-reviewer.md` — encapsulation and invariants: can a caller construct an illegal state?
- `test-coverage-reviewer.md` — behavioural gaps in the diff (error paths, boundaries, negative cases) and tests over-coupled to implementation.
- `comment-accuracy-reviewer.md` — comments that no longer match the code, or explain "what" instead of "why".

If the diff touches a **trust boundary** — auth, attacker-controlled input, secrets, data exposure — run `security-audits` alongside the breadth pass; that axis is its own skill, not one of the reviewer files above.

## Self-review checklist (for diffs too small to dispatch)

- Does it do what was asked, and only that?
- Any value read before it's set, any error swallowed, any edge unhandled?
- Would a stranger read it the way you intend?

## Common mistakes

- Reviewing the whole repo instead of the diff — slow, off-target, scope creep.
- Passing the reviewer your reasoning — it then inherits your blind spots instead of catching them.
- Accepting a vague verdict ("looks good") — no severity, no decision, no value.
- Letting the reviewer return its whole worklog — the orchestrator's context is the costliest; actionable findings in the return, the full report in a file.
