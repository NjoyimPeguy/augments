# Harness Support

How one skill library runs on many coding agents — and how to extend it to a new one.

## The model: agnostic skills, thin adapters

There is exactly **one** set of skills, and they are harness- and model-agnostic by rule (see [`../../CLAUDE.md`](../../CLAUDE.md)): a skill never names a vendor model (it refers to capability *tiers* — small / medium / large) and never assumes a specific harness's tooling or paths. Everything harness-specific lives *outside* the skills, in a thin **adapter** — a small manifest that registers the `skills/<phase>/<name>/` directories with the harness. Each harness binds the two open ends itself: capability **tier → model**, and **action → command**. The skill stays identical; only the binding differs.

## Install adapters (using the skills)

| Harness | Adapter | Proactive-use nudge | Status |
| ------- | ------- | ------------------- | ------ |
| Claude Code | `.claude-plugin/` (plugin manifest + `marketplace.json`) | SessionStart hook → `hooks/claude-code/context.md` | Exercised — evidence in `tests/harness/claude-code.md` |
| Codex | `.codex-plugin/` (plugin manifest) | — | Manifest present, **not yet exercised** — no activation record under `tests/harness/`; provisional until one lands (see *Be honest about status* below) |

Both manifests list the **same** skills array; `tests/validate-skills.sh` fails CI if a manifest drifts from the skill directories on disk, so the two cannot silently diverge.

## Repo-instruction files

`AGENTS.md` and `GEMINI.md` are **symlinks to `CLAUDE.md`**. A harness that auto-reads its own conventional instructions file therefore picks up the same contributor guidance from a single source — no parallel copies to drift. (This is about an agent working *in this repo*; it is independent of installing the skills elsewhere.)

## Using augments on an unlisted harness

The skills need no runtime — they are plain Markdown invoked by **name** (the phase folder is organization, not part of the address). On any harness:

1. Make this library available to the agent (install it however the harness loads external skills, or point the agent at this repo).
2. Copy the proactive-use nudge from `hooks/claude-code/context.md` into your project's own instructions file (your `AGENTS.md`, `CLAUDE.md`, or the harness equivalent), so the agent reaches for the right skill at the right moment instead of overlooking the library.
3. Invoke a skill by name — open `skills/common/using-augments/SKILL.md` for the map, then the chosen skill's `SKILL.md` for the procedure.

## Adding a harness adapter

For a contributor wiring up a new harness:

1. Create the harness's manifest pointing at the **same** `skills/<phase>/<name>/` leaf directories — never fork or edit skill content for a harness; that breaks the portability the library is built on.
2. Keep the skills array **identical** to `.claude-plugin/plugin.json`'s, and extend `tests/validate-skills.sh` to check the new manifest's sync too, so it can't drift.
3. If the harness has a session or instructions mechanism, wire in the nudge (reuse `hooks/claude-code/context.md`'s wording — firm, not coercive, with one escape).
4. **Be honest about status.** List a harness as supported only once its adapter has actually been exercised on it, and record the proof — a clean-session activation transcript — as a dated file under `tests/harness/`. Shipping an untested "works on X" install flow is the unverified-correctness failure the library's [philosophy](philosophy.md) exists to prevent — an honest "invoke by name" beats a confident, broken install guide.
