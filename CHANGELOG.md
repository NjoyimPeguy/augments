# Changelog

Notable changes to augments, newest first. Versions follow semantic versioning; the narrative for each release lives on its release page — this file is the terse, cumulative record.

## [2.0.0] — 2026-06-24

### Changed

- **Activation moves from coercion to structure; Claude-Code-first.** The firing pressure v1.0.7 put in descriptions (`ALWAYS invoke…`) was a workaround for a SessionStart nudge that decays over a long session. v2.0 carries it structurally: a slim procedural SessionStart bootstrap **plus a per-turn `UserPromptSubmit` floor** so the routing check can't decay mid-session (`docs/augments/activation.md`). The four discipline descriptions drop `ALWAYS` → plain "Use when…"; re-measured on a real `claude -p` sweep of all 30 skills (28/30 fired first try, effectively 30/30 on fair scenarios), activation holds without the coercion.
- **Tests flip from harness-agnostic proxies to real per-harness runs.** The proxies measured a ceiling, not the floor, so an ignored skill shipped green. The real `claude -p` harness (`tests/harness/claude-code/`; `--working-tree`, an offline `selftest`, `--verbose`, `--max-turns`) is now the activation layer; `behavioral/` discipline-pressure tests move under it. Identity rewritten to **portable skills + per-harness real tests** (Codex frozen; its manifest-sync relaxed to a note while `.claude-plugin` stays strict).

### Added

- **`yagni`** — build only what's needed and make it work, guarding both over-engineering and its opposite, laziness dressed as simplicity (stubs, TODOs, the smallest diff in the wrong place). Ships with a `references/` folder; `using-augments` gains a phase-chaining cue.

### Removed

- **`caveman`** (terse-output mode) — the skill-surface change that makes this a major release.
- **The harness-agnostic proxy test layer** (`tests/triggering/`, `tests/invocation/`, `triggering-harness.sh`, `invocation-harness.sh`, `coverage.sh`) and the growing per-adapter record file — superseded by the real per-harness runs.

## [1.0.7] — 2026-06-21

### Changed

- **The four discipline triggers fire by default, not on invitation.** `debugging`, `test-driven-development`, `verifying-completion`, and `receiving-code-review` were rewritten from gentle "Use when…" descriptions to imperative "ALWAYS invoke…" ones. The driver was real use: gentle descriptions under-fire because the SessionStart nudge decays over a long session while the always-loaded catalogue does not — so the firing pressure belongs in the descriptions, the one surface that stays salient. Only the descriptions changed (discipline bodies untouched, so no behavioural re-prove owed); triggering re-measured at positive **3/3** each. The cost is real and **accepted**: the firm framing over-fires on trivial cases its own exception exempts (firm `debugging` routed a one-line error **3/3** vs a gentle baseline of **2/3 NONE**) — firing over ceremony-avoidance, recorded honestly in `tests/triggering/`.

### Added

- **An invocation proxy and a real-CLI activation layer.** `tests/invocation/` + `invocation-harness.sh` measure the *decision to invoke* — the step the triggering proxy presumes — with the shipped nudge on/off and "proceed" offered as a co-equal outcome (its over-measurement is noted in the records). `tests/harness/claude-code/` drives the real `claude -p` headless against the installed plugin and detects a structured `Skill` tool_use (`run-activation.sh` single-shot, `run-flow.sh` multi-turn resumed); scenarios live by filename under `scenarios/` mirroring `skills/` (phase folders plus `common/`). Records the first observed native activations for the Claude Code adapter, including the planning wing firing `define-goals → feasibility-check → scope-it` across one resumed session.

## [1.0.6] — 2026-06-18

### Changed

- **The proactive-use nudge states one action: invoke.** The Claude Code SessionStart nudge (`hooks/claude-code/context.md`) drops the v1.0.5 "say which … `Using augments:<name>`" announcement — it conflated *invoke* with *announce*, and only the announcement was fakeable (a field session named a skill, served the request another way, and never called `Skill`). The single action is now the invocation itself, whose tool call is the unfakeable trace. Also reworded "before you touch the code" → "before you start", which presupposed a pre-implementation phase and mis-framed maintenance work. Re-tested old-vs-new by transcript grep for a real `Skill` call: no activation regression, feature→`spec-it` 3/3 and maintenance→`debugging` 3/3 under the new wording, and 3/3 `debugging` against the real 172k-LoC `mobile-client`; the native-SessionStart confirmation is recorded as owed post-install. `tests/triggering/session-nudge.md`.

### Added

- **Triggering-record coverage is gated.** `tests/coverage.sh` checks that every skill has a `tests/triggering/<name>.md` record (and warns when one shows no skip scenario); the existence half is now enforced by `validate-skills.sh` — the check that would have caught a skill shipping with no record. The 12 skills that lacked a record are backfilled (routing measured 3/3 unanimous per skill, fire + skip). `tests/token-budget.sh` reports the approximate context cost (chars/4) of the always-loaded surface — every `SKILL.md` plus the nudge — making "earn every line" a measurable number.

### Fixed

- **Dispatch and review packets stop parking bulk in the costliest context.** `dispatching-parallel-agents` now passes bulky context (a diff, a spec, a log) as a file path the agent reads rather than pasted text, and names the tier explicitly (omitted, an agent inherits the session's costliest). `requesting-code-review` hands the reviewer the diff *range* to expand itself (not a pasted diff) and a review tier chosen to match the diff's risk. Watched before/after in `tests/behavioral/`: the file-handoff line moved behaviour 2/2 vs. inline paste; the review-tier rewording moved agents 0/2 → 3/3 from deferring to the session tier to choosing one by risk.

## [1.0.5] — 2026-06-14

### Changed

- **The proactive-use nudge makes invoking a skill the visible first act.** The Claude Code SessionStart nudge (`hooks/claude-code/context.md`) was reworded from a passive "check whether a skill fits … and invoke it" — which an agent can satisfy silently and skip — to "before you touch the code, invoke the skill that fits, and say which as you do it (`Using augments:<name> to <purpose>`)", with the no-skill escape now *spoken* rather than silent. The collaboration stance is unchanged: no coercion ("must / no choice"), no whole-skill injection, still ~800 tokens. Driven by a field session where the nudge reached context yet no skill was invoked; old-vs-new measured in `tests/triggering/session-nudge.md` — the announcement is adopted reliably (7/7, including 3/3 under the verbatim competing output-style injections that drowned the nudge in the field), with no activation regression and a live re-test recorded as owed.

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
