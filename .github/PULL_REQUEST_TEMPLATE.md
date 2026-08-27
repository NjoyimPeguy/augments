<!--
Read CLAUDE.md → "If you are an AI agent" before filling this in.
Every section needs a specific, true answer. Placeholders or skipped
sections get the PR closed without review. One change per PR.
-->

## Problem

<!-- The real problem you hit: the session, error, or user experience that
motivated this. "It could theoretically…" or "my agent flagged it" is not a
problem statement. -->

## Change

<!-- What this PR does, and why this approach over the alternatives. -->

## Prior PRs / issues searched

<!-- What you found searching OPEN *and* CLOSED PRs and issues for this problem
or area. If a prior attempt was closed, what is different here. "None found" is
valid only if you actually searched. -->

## Belongs in core?

<!-- Confirm this is general-purpose SDLC guidance, not domain-, tool-, or
workflow-specific. (CLAUDE.md → "What belongs here".) -->

## Proof

<!-- Paste the result of `bash scripts/sh/validate-skills.sh` (must be green).
For a behaviour-shaping change: re-run the smallest behavioural scenario that
exercises it (`tests/run-behavioral.sh`) and paste what it returned. Include
inconclusive and failing results. Say how many runs. -->

## Authoring environment

<!-- Hiding how a change was made is grounds for closing the PR. -->

| | |
| --- | --- |
| Written by | hand / agent |
| Model | <!-- exact model id, or n/a if by hand --> |
| Harness | <!-- the IDE / CLI / runner, or n/a --> |
| Harness version | |
| Installed plugins | |

## Checklist

- [ ] One change; no unrelated edits bundled.
- [ ] `scripts/sh/validate-skills.sh` is green.
- [ ] Behaviour-shaping changes were re-tested, with the real result reported.
- [ ] No external references or vendor model names in shipped `skills/` or `docs/` files.
- [ ] A human has reviewed the complete diff.
- [ ] Targeting `main` from a task branch.
