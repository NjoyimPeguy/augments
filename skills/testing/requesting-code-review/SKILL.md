---
name: requesting-code-review
description: Use when a change is complete and you want fresh eyes before calling it done or merging — dispatches an independent reviewer scoped to the diff, checking both convention-conformance and whether the change does what was asked. Skip for a trivial mechanical diff (self-review instead).
---

# Requesting Code Review

Get a change reviewed by fresh eyes before it merges. The reviewer sees the diff, not your reasoning — so its judgement is independent of the story you told yourself while writing it.

## When to use

- A change is finished and about to be merged, shipped, or called done — and it carries real risk: logic, a boundary, anything a reader could misread.
- **Skip** for a trivial mechanical diff (a rename, a version bump); a quick self-review against the checklist below is enough. Not every change earns a full dispatch.

## Procedure

1. **Pin the scope.** Establish the review range as a diff, `base..HEAD`. The diff is the unit — the reviewer reads what changed, not the whole repo.
2. **Dispatch a fresh-context reviewer.** Hand it `code-reviewer.md` with the diff range and the originating requirement (issue, spec, or plan). It must NOT inherit your session — independence is the whole point.
3. **Review on two axes, kept separate** (the reviewer can run them as parallel passes):
   - **Standards** — does it match the project's conventions, style, and quality bar? Read `CLAUDE.md` / config, not memory.
   - **Spec** — does it actually do what was asked? Code can be clean and still build the wrong thing.
4. **Read the verdict.** The reviewer returns severity-tiered findings (Critical / Important / Minor) and an explicit *Ready to merge? Yes / No / With fixes* — never a bare "looks good".
5. **Act on it with judgement, not deference.** Verify each finding against the code before you change anything — one you can refute with evidence you close, not obey. A reviewer can be wrong; so can you. Resolve it on the merits — `receiving-code-review` is that responding discipline.

## Specialist depth passes (optional)

`code-reviewer.md` is the breadth pass — dispatch it every time. For a higher-risk diff, run one or more specialists *in parallel* alongside it (see `dispatching-parallel-agents`): each goes deep on one axis the breadth pass only skims and folds severity-grouped findings into that single merge verdict. Pick by what the diff touches — don't run all four by reflex.

- `silent-failures-reviewer.md` — error handling: swallowed or over-broad catches, masking fallbacks, lost propagation.
- `type-design-reviewer.md` — encapsulation and invariants: can a caller construct an illegal state?
- `test-coverage-reviewer.md` — behavioural gaps in the diff (error paths, boundaries, negative cases) and tests over-coupled to implementation.
- `comment-accuracy-reviewer.md` — comments that no longer match the code, or explain "what" instead of "why".

## Self-review checklist (for diffs too small to dispatch)

- Does it do what was asked, and only that?
- Any value read before it's set, any error swallowed, any edge unhandled?
- Would a stranger read it the way you intend?

## Common mistakes

- Reviewing the whole repo instead of the diff — slow, off-target, scope creep.
- Passing the reviewer your reasoning — it then inherits your blind spots instead of catching them.
- Accepting a vague verdict ("looks good") — no severity, no decision, no value.
