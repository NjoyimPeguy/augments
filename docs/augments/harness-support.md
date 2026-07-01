# Harness Support

How one skill library runs on many coding agents — and how to extend it to a new one.

## The model: agnostic skills, thin adapters

There is exactly **one** set of skills, and they are harness- and model-agnostic by rule (see [`../../CLAUDE.md`](../../CLAUDE.md)): a skill never names a vendor model (it refers to capability *tiers* — small / medium / large) and never assumes a specific harness's tooling or paths. Everything harness-specific lives *outside* the skills, in a thin **adapter** — a small manifest that registers the `skills/<phase>/<name>/` directories with the harness. Each harness binds the two open ends itself: capability **tier → model**, and **action → command**. The skill stays identical; only the binding differs.

## Install adapters (using the skills)

| Harness | Adapter | Proactive-use nudge | Status |
| ------- | ------- | ------------------- | ------ |
| Claude Code | `.claude-plugin/` (plugin manifest + `marketplace.json`) | SessionStart hook → `hooks/claude-code/session-start.sh` wraps `hooks/claude-code/context.md` in the harness's JSON context envelope (matcher `startup\|resume\|clear\|compact`, so the nudge survives **resume** and **compaction**); plus a **Stop** re-nudge → `hooks/claude-code/stop-nudge.sh` re-routes to the done-boundary skills when a turn wraps up claiming done (fires once) | Exercised — runnable tests in `tests/harness/claude-code/` (`run-activation.sh`, `run-flow.sh`, `test-stop-nudge.sh`) |

The `.claude-plugin` manifest must list every skill on disk — the gate fails CI if it drifts. Claude Code is the only adapter today; a new harness's manifest is added alongside it and the gate extended to check its sync too (see *Adding a harness adapter*).

## Repo-instruction files

`AGENTS.md` and `GEMINI.md` are **symlinks to `CLAUDE.md`**. A harness that auto-reads its own conventional instructions file therefore picks up the same contributor guidance from a single source — no parallel copies to drift. (This is about an agent working *in this repo*; it is independent of installing the skills elsewhere.)

## Using augments on an unlisted harness

The skills need no runtime — they are plain Markdown invoked by **name** (the phase folder is organization, not part of the address). On any harness:

1. Make this library available to the agent (install it however the harness loads external skills, or point the agent at this repo).
2. Copy the proactive-use nudge from `hooks/claude-code/context.md` into your project's own instructions file (your `AGENTS.md`, `CLAUDE.md`, or the harness equivalent), so the agent reaches for the right skill at the right moment instead of overlooking the library. An instructions file the harness re-applies every session also survives **context compaction** — which a one-shot injection does not (see step 3 below).
3. Invoke a skill by name — open `skills/common/using-augments/SKILL.md` for the map, then the chosen skill's `SKILL.md` for the procedure.

## Hardening a boundary locally (optional)

augments ships its routing nudge at two boundaries — **session start** (the SessionStart injection above) and the **done boundary** (a `Stop` re-nudge that, when a turn wraps up claiming the work is done, re-surfaces `verifying-completion` and the review/wrap skills once, then steps aside). Both are *routing* reminders: they re-point the agent at the right skill, block no action, certify no verdict, and fire with an escape — persuasion at the moment of need, honestly labelled, never a gate (see the [philosophy](philosophy.md)). A **verdict interrupt** is a different animal and stays out of core. If you want to pause a commit or merge until the diff has been independently reviewed, build it as *project-local configuration in your repository* (a pre-tool hook, a git hook, or your harness's equivalent):

- **It binds to one harness's mechanism.** A hook written for one runner's event model is inert everywhere else; the skills must stay portable, so enforcement glue stays out of them and out of the shipped adapters.
- **It changes the contract.** Shipping an *action-blocking* hook to every installer turns an opt-in library into an enforcer — the inverse of a nudge's "firm, not coercive, with one escape." (The done-boundary re-nudge stays on the nudge side of that line: it blocks no action and fires at most once.)
- **It usually isn't the gate it looks like.** If the same agent that skipped the discipline can acknowledge or bypass the interrupt, you have built a deterministic *reminder*, not a deterministic *gate*. That can still be worth having — an interrupt at the boundary is an event-conditioned trigger, useful belt-and-suspenders — but be honest that the truth still comes from the review or check it points at, not from the hook.

Keep such a hook dependency-free and scoped to your project. If it grows genuinely reusable, publish it as its own plugin rather than proposing it for core ([`../../CLAUDE.md`](../../CLAUDE.md), *What won't be accepted*).

## Adding a harness adapter

For a contributor wiring up a new harness:

1. Create the harness's manifest pointing at the **same** `skills/<phase>/<name>/` leaf directories — never fork or edit skill content for a harness; that breaks the portability the library is built on.
2. Keep the skills array **identical** to `.claude-plugin/plugin.json`'s, and extend `tests/validate-skills.sh` to check the new manifest's sync too, so it can't drift.
3. If the harness has a session or instructions mechanism, wire in the nudge (reuse `hooks/claude-code/context.md`'s wording). **And make it survive compaction:** when a long session's context is compacted, a nudge injected only at session start is summarized away — mid-task, the agent silently loses the very text that points it at the library, and a skill workflow half-followed is forgotten without anyone noticing. Mechanisms rank: something the harness re-applies every turn (a pinned instructions file, a system-prompt transform) is immune; an event hook that re-fires on compaction is covered (the Claude Code adapter's SessionStart matcher includes `resume` and `compact`); session-start-only injection is a known gap — if that is all the harness offers, ship it, but state the gap in the adapter's `tests/harness/` record.
4. **Be honest about status.** List a harness as supported only once its adapter has actually been exercised on it, and record the proof — a clean-session activation transcript — as a dated file under `tests/harness/`. Shipping an untested "works on X" install flow is the unverified-correctness failure the library's [philosophy](philosophy.md) exists to prevent — an honest "invoke by name" beats a confident, broken install guide.
