# Changelog

Notable changes to augments, newest first. Versions follow semantic versioning; the narrative for each release lives on its release page — this file is the terse, cumulative record.

## [4.2.2] — 2026-07-27

### Fixed

- **`data-model` no longer disqualifies itself on stateless domains.** The trigger read "the data a system stores / skip when no persistent state", so a realistic stateless-but-domain-rich opening (a workflow engine holding no state) never routed to the skill — measured 0/2, landing on `interview-me`. The description now fires on concepts a system stores *or merely computes over* (3/3 post-fix, storage opening 2/2, 7/7 neighbors unaffected); the body gains a state-transitions step and makes the storage step conditional. Known gap, reported not hidden: the Kimi router still misses the stateless opening (0/3), so its activation sweep shows `design/data-model` red.

### Added

- **`data-model` behavioural scenario** — asserts the shared design document names the concepts, models the lifecycle in words the opening never uses (an echo of the prompt fails it), and states invariants; the activation scenario now carries the opening that actually failed pre-fix.

## [4.2.1] — 2026-07-26

### Fixed

- **`writing-plans` body back under the CI token budget.** The `references/` pointer prefixes from the sibling uniformization pushed it to 1603/1600 approx-tokens and failed the token-budget step on main; three surgical trims (no behaviour change) bring it to 1587.

## [4.2.0] — 2026-07-26

### Added

- **Implementation-time enforcement.** A PreToolUse guard (`scripts/sh/implementation-guard.sh`) denies a session's first code edit until `test-driven-development` and `yagni` have fired — transcript-based on Claude Code, ledger-based on Kimi (whose hook payloads carry no transcript). Codex ships a per-prompt reminder instead: no project-level hook event fires in headless `codex exec` (measured), and the codex arm of the `yagni` behavioural scenario carries the pair rule as an `AGENTS.md` — the one channel Codex always reads. Fail-open everywhere; 25-case offline suite in `tests/run-implementation-guard.sh`.
- **On-demand references for eight thin skills** — ADR and coding-standards templates, security-audit checklists, release-gate details, handoff and post-mortem templates, dispatch-brief examples, and a data-model worked example.
- **`yagni` behavioural scenario** with assertions a description-recall test cannot make: an injected probe suite for correctness, naming/idiom/why-comment greps for craft, and a dependency/file-count cap for scope.
- **Craft discipline in `yagni`** — minimal ≠ unreadable: match the file, name for the domain, comment the why, simple over clever; the SessionStart nudge now names the TDD+yagni pair.

### Changed

- **All skill siblings live under `references/`** — one convention; pointer lines, cross-references, and `writing-skills` updated.
- **Hook scripts moved to `scripts/sh/`** (hook configs stay in `hooks/`); the nudge text is inline in `session-start.sh`.
- **`harness-support.md`:** the implementation boundary is now enforced in core — a deliberate, evidence-driven change to the former nudge-only policy, with the hook-honesty rules preserved.

## [4.1.3] — 2026-07-26

### Added

- **`spec-it` reference forms.** A requirement's acceptance criterion now takes the cheapest form that makes it checkable — a failing test, a mockup page, a reference implementation plus deltas, or a rubric — with prose as the fallback rather than the starting point. New sibling `reference-forms.md`; `spec-review.md` gains a sixth check that every referenced artifact resolves and runs.
- **Behavioural tests.** `tests/run-behavioral.sh` runs a two-arm comparison (RED loads the skills from a `git worktree` at `--base`, GREEN from the working tree) and the scenario's own assertions return the verdict as an exit code. Scenarios for `spec-it`, `test-driven-development` and `debugging`, each using a check a description-recall test cannot make: remove the subject and the test must go red.

### Changed

- **`test-driven-development`:** RED must run through the project's *own* command, and a broken project command must be fixed or named — a test the project's gate cannot execute is not a gate.
- **`spec-it`:** three step-6 loopholes closed, each found by running it — an open contract is not an exemption; a criterion that cannot go red is not a criterion; confirm it runs through the project's own command.
- **`tests/` rebuilt around one runner per test kind.** Scenarios were byte-identical across three harness copies (93 files → 44) and `run-behavioral.sh` was ~60% duplicated in each. Now one dispatcher per kind taking `--harness`, with `tests/harnesses/<name>.sh` holding only what differs per CLI. The deterministic gate moved to `scripts/sh/`.
- **Activation runner no longer truncates skill chains.** It killed the run at the first non-router skill, so a correct chain (`using-augments → using-task-branches → test-driven-development → yagni`) was cut short and scored as a miss.

### Removed

- **`governance/`** — the adoptable deterministic-gate templates, with their references.
- **Dated evidence records.** `CLAUDE.md`, `CONTRIBUTING.md` and the PR template now ask for a re-run and the real numbers instead of a committed record.

## [4.1.2] — 2026-07-21

### Changed

- **Selftest fixtures inlined.** The three activation-detector selftests now write their fixture streams from inline heredocs to a temp dir per run; the committed `fixtures/*.jsonl` dirs are gone, leaving zero `.jsonl`/`.log` files under `tests/`. Identical content, identical checks, all three selftests pass.

## [4.1.1] — 2026-07-21

### Fixed

- **Duplicate hooks load in Claude Code.** `.claude-plugin/plugin.json` named `hooks/hooks.json` in a `hooks` key while the harness auto-loads that file, so every session logged `Hook load failed: Duplicate hooks file detected`. The key is dropped; a live probe confirms the SessionStart nudge still routes.
- **`writing-plans` body back under the CI token cap** after the trigger rewrite pushed it to 1610 (now 1598).

### Changed

- **`yagni` now chains from `test-driven-development` at the implementation moment.** TDD's GREEN step invokes it, and `using-augments` names the pair — the router line is the load-bearing anchor (live A/B on both harnesses; the body sentence alone did not fire). `yagni`'s trigger rewritten: build MORE than asked vs deliver LESS than asked, no more, no less.
- **Five triggers de-vagued**, rewritten from their own bodies' vocabulary: `release-readiness` (names its real gate signals), `writing-plans` ("alignment brief" → a brief from `interview-me`/`spec-it`), `refactor-architecture` (concrete friction symptoms), `spec-it` and `feasibility-check` (Skip clauses added). Re-measured 10/10 on both harnesses.
- **Checkpoint commits.** `using-task-branches` and `verifying-completion` now tell an agent to bank verified work on the task branch as it goes — uncommitted work is one power cut from gone.

### Added

- **v4.1.0 live-verification debt closed on Claude Code** (account newly available): working-tree activation probes, the owed `ui-ux-design` probe, a RED/GREEN re-run of the 2026-07-19 `debugging` additions, and honest records under `tests/harness/claude-code/`.
- **Kimi Code scenario tree completed** (1 → 31 openings) with a live per-phase sweep record (8/8 activated, CLI 0.28.1); committed run artifacts purged and ignored.

## [4.1.0] — 2026-07-19

### Added

- **Kimi Code CLI adapter.** `.kimi-plugin/plugin.json` exposes the canonical skills directly (no mirror), loads `using-augments` at session start, binds skill language to the harness's real tools, and re-nudges at the done boundary via a manifest-declared Stop hook. Live activation and Stop-hook proofs recorded under `tests/harness/kimi-code/`; the session-start nudge does not survive mid-session compaction (recorded gap).
- **Stop-nudge policy shared across harnesses.** `hooks/stop-nudge-detect.sh` holds the single done-boundary detector; Claude/Codex and Kimi wrappers only adapt payload and block format.
- **Token budget enforced in CI.** `token-budget.sh --max 1600` gates the always-loaded surface.

### Changed

- **Field-report skill improvements.** `finishing-a-branch` checks repo PR templates first; `writing-plans` writes plan files incrementally; `requesting-code-review` returns actionable findings with blocking/advisory dispositions and files the full report; `executing-plans` stops fix loops after three failed attempts; `debugging` greps the literal error string first and requires intermittent-bug tests to replay the observed failure.

## [4.0.0] — 2026-07-15

### Changed

- **`ui-ux` is now `ui-ux-design`.** The renamed invocation address reflects a broader interface-design workflow and is a breaking surface change for callers of `augments:ui-ux`.
- **UI/UX design starts from project evidence.** Existing routes, components, tokens, content, previews, responsive conventions, accessibility rules, and tests constrain flows and directions before any new setup is proposed.

### Added

- **Portable visual decisions.** Progressive guides cover intentional design quality, 2–4 controlled alternatives, safe visualization fallbacks without a bundled server, and explicit human decision records. Codex activation and project-evidence behavior are recorded; live Claude activation remains unverified until account access is available.

## [3.0.0] — 2026-07-07

### Changed

- **`using-git-worktrees` is now `using-task-branches`.** The skill surface now reflects the actual workflow: start repo edits on a meaningful task branch or harness workspace, and use a worktree only when user/project preference or runtime isolation calls for one. This is a breaking invocation-address change for callers of `augments:using-git-worktrees`.
- **Repo-edit routing starts with branch/status discipline.** `using-augments` now routes edit, fix, refactor, and plan-execution requests through `using-task-branches` before repo exploration or implementation, with activation evidence recorded for Claude Code and Codex.

### Added

- **Branch-start activation fixtures.** The Claude Code and Codex activation harnesses can run scenarios inside a disposable git repo on `main`; Codex can also install the current checkout into a temporary authenticated `CODEX_HOME` for live working-tree probes.

## [2.3.0] — 2026-07-06

### Added

- **Codex plugin adapter.** New `plugins/augments/.codex-plugin/` manifest, local `.agents/plugins/marketplace.json`, generated flat skill mirror, and `scripts/sync-codex-plugin-skills.sh` make the same 30 canonical skills installable in Codex without forking skill content. The structural gate now validates the Codex mirror and manifest versions.
- **Codex CLI harness evidence.** New `tests/harness/codex-cli/` covers install smoke, activation fixture selftests, 30 real activation scenarios, Stop-hook wrapper tests, and Codex-specific behavioral records for the discipline skills.

### Changed

- **Hooks are shared at the root `hooks/` layer.** The Claude Code hook manifest now points to `hooks/hooks.json`, while Codex project-hook config mirrors `hooks/hooks-codex.json`; both use the shared `hooks/context.md` and `hooks/stop-nudge.sh` where their event models allow it.
- **Docs no longer frame augments as Claude-only.** Harness-support docs, README status, and activation notes now describe Claude Code and Codex as exercised adapters, with Codex hook limitations stated explicitly.

## [2.2.0] — 2026-07-01

### Added

- **Done-boundary `Stop` re-nudge.** New `hooks/claude-code/stop-nudge.sh`, wired as a `Stop` hook, closes the long-standing "the verify/review skills don't fire after a long task" gap: augments routes once at SessionStart, but the done boundary arrives at turn-end with nothing to re-route. When a turn wraps up claiming the work is done, the hook re-routes **once** to `using-augments` → `verifying-completion` (and, at a feature boundary, `requesting-code-review` / `finishing-a-branch`). It is a *routing* re-nudge, not a gate: it blocks no action, certifies no verdict, fires at most once (`stop_hook_active` guard), reads only the Stop payload, and fails open. Disable by removing the `Stop` entry from `hooks/claude-code/hooks.json`. Proof: offline `tests/harness/claude-code/test-stop-nudge.sh` + `2026-07-01-stop-nudge-done-boundary.md`.
- **Review-depth ladder in `requesting-code-review`.** Shallow / Standard / Deep tiers keyed to a change's risk and blast radius (not wall-clock), with an adversarial refute-pass at the Deep tier.
- **Plan-as-contract in `writing-plans`.** Per-task Consumes/Produces interface blocks, an index-level Constraints block, reviewer-gate task sizing, and an Execution Handoff (inline vs subagent-driven) at the present-and-pause.

### Changed

- **Leaner skill triggers (~620 always-loaded tokens).** 26 skill `description`s drop the embedded what-it-does summary that buried the trigger — which, per `writing-skills` doctrine, made the model follow the summary and skip the body; the `Use when…` trigger, the `Skip…` clause, and genuine this-vs-that disambiguation stay. Re-measured on the harness; the four ALWAYS discipline triggers were left untouched (trimming `yagni` measurably dropped its activation, so it was reverted). Record: `2026-07-01-description-token-efficiency.md`.
- **Explicit gap handoffs between adjacent skills** — `verifying-completion` → `requesting-code-review`, `spec-it` → design, `finishing-a-branch` → `release-readiness`, and others — so a chain does not stall half-done.
- **`executing-plans` de-serialized.** Three execution modes (inline / sequential offload / parallel fan-out), user-posture honoring, and per-task gate cadence clarified (sequential default; independent tasks fan out).
- **`yagni` relocated** `skills/implementation/` → `skills/common/` as a cross-cutting discipline — the invocation address `augments:yagni` is unchanged — plus a consent-based never-work-on-`main` guard in `using-git-worktrees`, and a slimmer `using-augments` router.

## [2.1.1] — 2026-06-26

### Changed

- **Routing-first delivery: a thin pointer to the `using-augments` router.** The SessionStart bootstrap (`hooks/claude-code/context.md`) slims to a one-line pointer that re-fires on compaction; the routing discipline it used to carry — red-flags, the rationalization table, a deterministic-engineer mental-model graph — moves into the `using-augments` body, removing the duplication between them. The philosophy is reconciled, not softened: a firm floor where there is only process, a deterministic gate where there is proof, never one dressed as the other (`docs/augments/philosophy.md`).
- **The dispatch skills activate at the right moment.** `dispatching-parallel-agents`' trigger moves from a burden-of-proof description ("provably independent… quick enough inline") to a positive, observable one; the independence check stays in the body. `subagent-dispatch.md` drops the "optional" framing, points to the shared dispatch packet instead of duplicating it, and resolves a paste-vs-path contradiction.
- **The `.augments/` output location is mandatory.** Across the nine writing skills the artifact path stops being an optional "default" and becomes the standard location, overridable only by the user, with one canonical phrasing; the five design skills write sections of one shared dated design doc. A validator assertion keeps it from drifting back.
- **The activation runners are routing-first aware.** Both harness runners judge the whole `using-augments → X` chain (route-then-fire) instead of the first Skill call, with an offline fixture + selftest for the chain.

### Removed

- **The Codex adapter.** `.codex-plugin/` and the Codex references in the docs are removed — augments is Claude-Code-only for now; a real Codex harness returns when it is exercised and proven. (Past release history in this file is unchanged.)

## [2.1.0] — 2026-06-24

### Added

- **`governance/` — deterministic gate templates.** Adoptable CI / branch-protection / pre-commit templates that make the production-critical skills non-skippable at the commit/PR/CI boundary, where persuasion can't — branch-protection (CI-green + review + conversation-resolution, bulletproof), `tests-accompany-code`, `release-readiness`, `trust-boundary-flag` (heuristics, honestly labelled). Each maps to the skill it enforces; dogfooded on augments itself.

### Changed

- **Routing is firm and non-negotiable; the per-turn floor is gone.** The field test of v2.0's gentle/per-turn approach failed — the model skipped the loaded skill under momentum. The SessionStart bootstrap is rewritten firm (skip-rationalizations named, no easy-out); the `UserPromptSubmit` per-turn floor is removed (re-asserting a line every turn didn't stop the skip and cost tokens per turn); the four discipline descriptions return to firm `ALWAYS invoke`. Persuasion is the firm-but-leaky floor; the gates are the wall. Honest limit recorded: the execution-momentum regime that failed isn't reproducible in the headless harness — which is precisely why the gates exist.

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
