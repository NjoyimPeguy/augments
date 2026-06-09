# Changelog

Notable changes to augments, newest first. Versions follow semantic versioning; the narrative for each release lives on its release page — this file is the terse, cumulative record.

## [1.0.0] — 2026-06-09

First public release.

### Added

- **30 skills across all seven SDLC phases** — planning, analysis, design, implementation, testing, deployment, maintenance — plus the cross-cutting `common/` toolbox (orientation, skill-authoring, interviewing, prototyping, zoom-out, handoff, worktrees, parallel dispatch, terse output). Full index in the README.
- **The deterministic gate** (`tests/validate-skills.sh`): frontmatter shape, line budgets, no external references or vendor model names, skills-array sync across every harness manifest, and internal doc paths resolve — enforced by CI on every push and PR.
- **Dated evidence records** under `tests/`: `triggering/` (does a description route the right opening), `behavioral/` (does a discipline hold under pressure), `harness/` (does an adapter actually load and activate) — each entry stating the environment it was measured from, including honest nulls and stated gaps.
- **Harness adapters**: a Claude Code plugin with a session-start nudge (firm, not coercive), and a Codex manifest (provisional — not yet exercised in a live session).
- **The philosophy** (`docs/augments/philosophy.md`): every skill is a non-deterministic generator wrapped in a deterministic gate — truth comes from the gate, never from confidence — and skills work alongside model intelligence, never impeding it.
- **Contributor surface**: `CLAUDE.md` (shared via `AGENTS.md` and `GEMINI.md` symlinks), `CONTRIBUTING.md`, a PR template with authoring-environment disclosure, and a Code of Conduct.
