# Harness Support

How one skill library runs on many coding agents — and how to extend it to a new one.

## The model: agnostic skills, thin adapters

There is exactly **one** set of skills, and they are harness- and model-agnostic by rule (see [`../../CLAUDE.md`](../../CLAUDE.md)): a skill never names a vendor model (it refers to capability *tiers* — small / medium / large) and never assumes a specific harness's tooling or paths. Everything harness-specific lives *outside* the skills, in a thin **adapter** — a small manifest that registers the `skills/<phase>/<name>/` directories with the harness. Each harness binds the two open ends itself: capability **tier → model**, and **action → command**. The skill stays identical; only the binding differs.

## Install adapters (using the skills)

| Harness | Adapter | Proactive-use nudge | Status |
| ------- | ------- | ------------------- | ------ |
| Claude Code | `.claude-plugin/` (plugin manifest + `marketplace.json`) | SessionStart hook -> `scripts/sh/session-start.sh` (self-contained inline nudge) in the harness's JSON context envelope (matcher `startup\|resume\|clear\|compact`, so the nudge survives **resume** and **compaction**); plus a **Stop** re-nudge -> `scripts/sh/stop-nudge.sh` when a turn wraps up claiming done (fires once); plus a **PreToolUse implementation guard** -> `scripts/sh/implementation-guard.sh` that denies the session's first code edit until `test-driven-development` and `yagni` have fired | Exercised| Exercised — runnable tests in `tests/` (`run-activation.sh`, `run-flow.sh`, `test-stop-nudge.sh`) |
| Codex CLI / app | `plugins/augments/.codex-plugin/` + `.agents/plugins/marketplace.json` | Codex loads the same skills through the plugin adapter. This repo also ships project-level Stop hook config (`.codex/hooks.json`, mirrored from `hooks/hooks-codex.json`) that invokes `scripts/sh/stop-nudge.sh`, plus a **UserPromptSubmit** reminder -> `scripts/sh/implementation-remind.sh` that re-injects the pair on every prompt. Measured on codex-cli 0.145.0 in `codex exec`: **no project-level hook event fires at all** — PreToolUse, UserPromptSubmit, and Stop were all inert in headless probes (trust bypass included), so a blocking guard is impossible there and the reminder only helps interactive sessions; current Codex builds do not auto-install plugin hooks from the plugin manifest, and a SessionStart hook was not observed firing in the CLI probe. Durable repo guidance still comes from `AGENTS.md`. |(fires once); plus a **PreToolUse implementation guard** -> `scripts/sh/implementation-guard.sh` that denies the session's first code edit until `test-driven-development` and `yagni` have fired | Exercised — install smoke in `tests/run-plugin-smoke.sh`; live activation in `tests/run-activation.sh --harness codex`; offline Stop wrapper test in `tests/run-stop-nudge.sh --harness codex` |
| Kimi Code CLI | `.kimi-plugin/plugin.json` (multi-path `skills` array pointing at the canonical phase directories — no mirror) | `sessionStart.skill: using-augments` loads the router at session start (new and resumed sessions), `skillInstructions` binds the skills' tool language to the harness's real tool names whenever a plugin skill loads, and a manifest-declared **Stop** hook -> `scripts/sh/stop-nudge-kimi.sh` re-nudges at the done boundary (shared policy in `scripts/sh/stop-nudge-detect.sh`); plus manifest-declared **PreToolUse/PostToolUse** hooks -> `scripts/sh/implementation-guard.sh` (ledger-based: Skill invocations are recorded per session and the first code edit is denied until the pair fired). Known gap: the session-start nudge does **not** survive mid-session **compaction** (the compaction hook events are observation-only). |(fires once); plus a **PreToolUse implementation guard** -> `scripts/sh/implementation-guard.sh` that denies the session's first code edit until `test-driven-development` and `yagni` have fired | Exercised — live activation in `tests/run-activation.sh --harness kimi-code`; offline Stop test in `tests/run-stop-nudge.sh --harness kimi-code`; offline detector selftest via `run-activation.sh selftest` |

The Claude manifest must list every skill on disk, the Codex adapter must expose a flat generated mirror for every canonical skill, and the Kimi manifest's `skills` paths must resolve to exactly the canonical set. The gate fails CI if any adapter drifts (see *Adding a harness adapter*).

## Repo-instruction files

`AGENTS.md` and `GEMINI.md` are **symlinks to `CLAUDE.md`**. A harness that auto-reads its own conventional instructions file therefore picks up the same contributor guidance from a single source — no parallel copies to drift. (This is about an agent working *in this repo*; it is independent of installing the skills elsewhere.)

## Using augments on an unlisted harness

The skills need no runtime — they are plain Markdown invoked by **name** (the phase folder is organization, not part of the address). On any harness:

1. Make this library available to the agent (install it however the harness loads external skills, or point the agent at this repo).
2. Copy the proactive-use nudge from `scripts/sh/session-start.sh` (the inline nudge text) into your project's own instructions file (your `AGENTS.md`, `CLAUDE.md`, or the harness equivalent), so the agent reaches for the right skill at the right moment instead of overlooking the library. An instructions file the harness re-applies every session also survives **context compaction** — which a one-shot injection does not (see step 3 below).
3. Invoke a skill by name — open `skills/common/using-augments/SKILL.md` for the map, then the chosen skill's `SKILL.md` for the procedure.

## Enforcement at the implementation boundary

augments ships one **action-blocking** hook: the implementation guard (`scripts/sh/implementation-guard.sh`), wired as a PreToolUse hook in the Claude Code and Kimi adapters. It denies a session's first code Write/Edit until `test-driven-development` and `yagni` have been invoked — the pair comes first, the code after. (Codex ships a per-prompt reminder instead: in headless `codex exec` no project-level hook event was measured to fire at all, so neither blocking nor reminder hooks operate there — the durable Codex channel is the project's own instructions file.)

This is a deliberate exception to the nudge-only rule, made on measured evidence: NON-NEGOTIABLE-strength prompt wording was shipped and it *failed* — behavioural runs showed implementation skills skipped on exactly the tasks they govern, on every harness, until a hook made the routing non-optional. Prompt text is input to the same generator that decides whether to follow it; a hook runs outside the model. Where a harness offers a blockable pre-tool event, the implementation boundary is enforced there.

Two honesty rules from the older policy survive unchanged:

- **Be honest about what a hook is.** The guard guards the Write/Edit-class *tools*, not the act of writing code — a shell write bypasses it by construction, and an agent determined to route around it can. It catches *unintentional* skips, which is the common case; it is not a security boundary, and truth still comes from the checks the discipline points at, never from the hook.
- **Verdict interrupts stay local.** Pausing a *commit or merge* until a diff has been independently reviewed is a different animal — it binds one project's workflow. Build it as *project-local configuration in your repository* (a pre-tool hook, a git hook, or your harness's equivalent), dependency-free and scoped to the project. If it grows genuinely reusable, publish it as its own plugin rather than proposing it for core ([`../../CLAUDE.md`](../../CLAUDE.md), *What won't be accepted*).

## Adding a harness adapter

For a contributor wiring up a new harness:

1. Create the harness's manifest pointing at the **same** `skills/<phase>/<name>/` leaf directories — never fork or edit skill content for a harness; that breaks the portability the library is built on.
2. Keep the adapter's exposed skills identical to the canonical `skills/<phase>/<name>/` set, and extend `scripts/sh/validate-skills.sh` to check the new manifest or adapter view, so it can't drift.
3. If the harness has a session or instructions mechanism, wire in the nudge (reuse the inline nudge wording in `scripts/sh/session-start.sh`). **And make it survive compaction:** when a long session's context is compacted, a nudge injected only at session start is summarized away — mid-task, the agent silently loses the very text that points it at the library, and a skill workflow half-followed is forgotten without anyone noticing. Mechanisms rank: something the harness re-applies every turn (a pinned instructions file, a system-prompt transform) is immune; an event hook that re-fires on compaction is covered (the Claude Code adapter's SessionStart matcher includes `resume` and `compact`); session-start-only injection is a known gap — if that is all the harness offers, ship it, but state the gap in the adapter's `tests/` record.
4. **Be honest about status.** List a harness as supported only once its adapter has actually been exercised on it, and record the proof — a clean-session activation transcript — as a dated file under `tests/`. Shipping an untested "works on X" install flow is the unverified-correctness failure the library's [philosophy](philosophy.md) exists to prevent — an honest "invoke by name" beats a confident, broken install guide.
