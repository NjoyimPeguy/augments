# Post-Mortem Template

Fill-in structure for the analysis from `../SKILL.md`. Copy it, then replace every `{{placeholder}}`. Keep it blameless: name gates, never people. A section that stays empty is a finding — say so; do not delete the section.

## The template

```markdown
# Post-mortem: {{one-line description of the incident}}

## Summary
- What broke: {{user-visible symptom}}
- Impact: {{who was affected, how badly, for how long — state it in observable terms, not adjectives}}
- Introduced: {{commit / release / change that carried the defect}}
- Detected: {{when and how — alert, user report, later test run}}
- Resolved: {{fix or rollback, and when}}

## Timeline
Reconstructed from artifacts only — commits, CI runs, logs, deploy records, review history. Every entry carries its source; no entry from memory.
- {{timestamp}} — {{event}} (source: {{artifact}})
- {{timestamp}} — {{event}} (source: {{artifact}})
- {{timestamp}} — {{event}} (source: {{artifact}})

## What broke (one paragraph)
{{The code-level cause, in brief. This is debugging's output, summarized — the post-mortem does not redo it.}}

## Process gaps
Each gate the change passed through, judged on evidence: missing, present-but-too-weak, or skipped. For each gap, keep asking "why did that get through?" until the answer is structural.
- Gate: {{spec / review / tests / CI / release / monitoring}}
  - Judgment: {{missing / too weak / skipped}}
  - Evidence: {{what the artifact shows}}
  - Structural cause: {{the check that does not exist, the assumption never stated, the path nothing exercises}}

## Preventative actions
One action per structural cause, ranked: a deterministic gate first, a process change second, a promise last. Each action names its owner-equivalent (a file, a check, a script — not a person) and passes the self-challenge below.
- [ ] {{action}} — addresses: {{structural cause}} — gate: {{what fails if the failure recurs}}

## Action self-challenge
For each action above: would it have caught THIS incident, had it existed? If no, cut or replace it — record the verdict here so a weaker action can't slip back in later.
- {{action}} → {{yes, because the gate would fail on this exact input / no, replaced by {{stronger action}}}}

## What held (optional)
{{Gates that did catch something, mitigations that limited blast radius — worth naming so the fix doesn't break them.}}
```

## Rules the template enforces

- **Every timeline entry has a source.** If you cannot point to the artifact, the entry is memory — cut it or go find the artifact. Memory entries are how the real sequence gets laundered into a tidy story.
- **"Too weak" needs evidence, not vibes.** The gate existed and ran; show what it checked and why that wasn't enough (a test that asserts on a mocked dependency, a review checklist that doesn't cover this class).
- **One action per cause, never several per cause and never zero.** Two actions on one cause usually means neither is the gate. Zero means the analysis stopped at a symptom.
- **The self-challenge is not optional.** Action items that wouldn't have stopped the incident are the main way a post-mortem fails quietly.

## Worked example: why depth looks like this

Incident: after a deploy, every write to the order queue started failing in production; 40 minutes of lost writes.

**Shallow version (reject it):** "A config key was renamed in the service but not in the deploy manifest. Reviewer missed it. Action: reviewers will double-check config renames." That names a person, stops at the symptom, and ends in a promise.

**The same incident, driven to structure:**

- Timeline from artifacts: the rename landed in commit `a1b2c3`; the unit suite passed (it reads config from a test fixture, not the manifest); CI passed; deploy at 14:02; first alert 14:07; rollback 14:42.
- The gate that failed was **tests**: present but too weak. Nothing loads the real deploy manifest in any test, so a manifest/code mismatch cannot fail before production.
- Why did *that* get through? The suite was built around the fixture early on, and no check asserts fixture and manifest agree — an unstated assumption, not a careless reviewer.
- Actions, ranked:
  1. A test that loads the production manifest and asserts every key the service reads exists — fails deterministically on the next rename. Self-challenge: yes, it would have failed on this exact commit.
  2. Cut: "reviewers watch for config renames" — a promise that would not have caught it; the reviewer had no signal the manifest was involved.
- What held: monitoring paged within 5 minutes and rollback was clean — keep both out of scope of the fix.

The depth is in step three: the bug is the renamed key, but the *escape* is that the test suite's fixture was never checked against reality. Fixing the key fixes nothing; the next rename escapes the same way. The test in action 1 makes the whole class impossible.

## Common failure patterns to check against

- **The timeline exonerates everyone.** If the reconstructed sequence makes the outcome look inevitable, suspect memory entries — pull the raw artifacts again.
- **All actions land on one gate.** Real escapes usually pass several weak gates; if only one appears, the others weren't examined.
- **The retrospective variant degrades into feelings.** For a unit-of-work retrospective the same structure holds: timeline of the work, gates that should have caught the drift (spec review, mid-course demos), structural cause, one gate-producing action.
