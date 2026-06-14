# Changelog

Notable changes to augments, newest first. Versions follow semantic versioning; the narrative for each release lives on its release page — this file is the terse, cumulative record.

## [1.0.4] — 2026-06-14

### Fixed

- **The proactive-use nudge reaches more sessions, more reliably.** The Claude Code SessionStart matcher gained `resume`, so the nudge fires on resumed sessions (`--continue`/`--resume`/`/resume`), not just fresh starts; and the hook now wraps `context.md` in the harness's JSON context envelope via `hooks/claude-code/session-start.sh` instead of relying on raw stdout being read as context. Delivery only — the nudge text is byte-identical, so activation is unchanged; recorded in `tests/triggering/session-nudge.md`.

## [1.0.3] — 2026-06-11

### Added

- **Versioning policy** (`RELEASING.md`): semver mapped to the skill surface, who bumps and when, and the release checklist; the gate now fails a half-done version bump across the three manifests.
- **ADRs carry a status lifecycle.** `architecture-decisions` marks each record proposed / in force / superseded, so a later session can't read an unbuilt plan as the current architecture.
- **Harness-collision checks in the gate**: shipped text is linted for harness scanner trigger-words, and a skill name that shadows a common built-in slash command is rejected.
- **Compaction-survival requirement for adapters** (`docs/augments/harness-support.md`): the proactive-use nudge must outlive context compaction; mechanisms ranked, session-start-only declared a gap.
- **Record-staleness rule** (`tests/README.md`): a model-generation change makes existing verdicts the previous generation's data; every dated entry names the harness and tier it was measured from.

### Fixed

- **Reviewer subagents are read-only.** All five `requesting-code-review` dispatch prompts now forbid mutating the shared checkout — no edits, branch switches, or checkouts during a review; a comparison needing one is reported, not performed.

## [1.0.2] — 2026-06-10

### Fixed

- **Code review now reaches the "done" boundary.** A field failure showed work being reported complete with every gate green but the diff unreviewed. `requesting-code-review`'s trigger is now event-conditioned (fires at the done boundary — complete/commit/merge/PR — not only when you already want fresh eyes), and `verifying-completion` hands off to independent review once its gate passes instead of ending the chain at "verified". Proven old-vs-new in `tests/triggering/requesting-code-review.md` (the skill's first activation record) and `tests/behavioral/verifying-completion.md` (0/2 → 3/3 on the handoff; flaky-green hard-stop unregressed).
- **Docs: deterministic boundary interrupts stay project-local.** New `harness-support.md` section on why blocking commit/merge hooks belong in your own project config, not in augments core.

## [1.0.1] — 2026-06-10

### Fixed

- **The plan→execution seam now pauses for the user.** `writing-plans` ends by presenting the plan index for the user's go, and `executing-plans` confirms the user has seen the plan before starting — pause-by-default, with explicit escapes ("plan it and build it, don't stop" or an explicitly requested unattended run). A pre-plan "go ahead" no longer counts as approval of the unseen plan, and a non-interactive session means presenting the plan at turn end, not skipping the pause. Driven by a captured field failure; proven RED → loopholes closed → GREEN in `tests/behavioral/writing-plans.md`.

## [1.0.0] — 2026-06-09

First public release.

### Added

- **30 skills across all seven SDLC phases** — planning, analysis, design, implementation, testing, deployment, maintenance — plus the cross-cutting `common/` toolbox (orientation, skill-authoring, interviewing, prototyping, zoom-out, handoff, worktrees, parallel dispatch, terse output). Full index in the README.
- **The deterministic gate** (`tests/validate-skills.sh`): frontmatter shape, line budgets, no external references or vendor model names, skills-array sync across every harness manifest, and internal doc paths resolve — enforced by CI on every push and PR.
- **Dated evidence records** under `tests/`: `triggering/` (does a description route the right opening), `behavioral/` (does a discipline hold under pressure), `harness/` (does an adapter actually load and activate) — each entry stating the environment it was measured from, including honest nulls and stated gaps.
- **Harness adapters**: a Claude Code plugin with a session-start nudge (firm, not coercive), and a Codex manifest (provisional — not yet exercised in a live session).
- **The philosophy** (`docs/augments/philosophy.md`): every skill is a non-deterministic generator wrapped in a deterministic gate — truth comes from the gate, never from confidence — and skills work alongside model intelligence, never impeding it.
- **Contributor surface**: `CLAUDE.md` (shared via `AGENTS.md` and `GEMINI.md` symlinks), `CONTRIBUTING.md`, a PR template with authoring-environment disclosure, and a Code of Conduct.
