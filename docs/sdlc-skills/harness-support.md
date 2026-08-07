# Harness Support

How one skill library runs on several coding agents without putting
harness-specific behavior into the skills.

## One skill tree, thin adapters

There is one canonical tree under `skills/`. Skills use capability tiers and
portable actions; each harness adapter binds those concepts to its own manifest,
tools, and lifecycle events.

| Harness | Adapter | Routing support |
| --- | --- | --- |
| Claude Code | `.claude-plugin/` and `hooks/hooks.json` | Session-start router, done-boundary Stop nudge, and a best-effort pre-edit TDD/YAGNI guard |
| Codex | `plugins/sdlc-skills/.codex-plugin/`, `.agents/plugins/marketplace.json`, and project-local `.codex/hooks.json` | Installed skill catalogue plus a project-local Stop nudge; durable repository guidance comes from `AGENTS.md`; no per-prompt reminder is shipped |
| Kimi Code | `.kimi-plugin/plugin.json` | Canonical skill paths, session-start router, tool bindings, Stop nudge, and a best-effort pre-edit TDD/YAGNI guard |

The Claude manifest, Codex mirror, and Kimi skill paths must expose the same
canonical skill set. `scripts/sh/validate-skills.sh` checks that deterministic
packaging contract.

Kimi's available post-compaction callback is observation-only. The plugin cannot
re-inject routing into a read-only turn after compaction. Its pre-edit and Stop
hooks still run, but they cannot reconstruct the missing router context. This is
a harness capability limit, not something a larger test harness can remove.

## Repository instruction files

`AGENTS.md` and `GEMINI.md` are symlinks to `CLAUDE.md`. A harness that reads
its conventional repository instructions therefore receives the same contributor
rules from one source.

## Using SDLC Skills elsewhere

The skills are Markdown invoked by name. On another harness:

1. Expose the canonical skill directories through the harness's normal skill
   mechanism.
2. Put the pointer from `scripts/sh/session-start.sh` in a durable instruction
   surface so the agent reaches for `using-sdlc-skills`.
3. Bind skill actions to the harness's real tools.
4. Exercise one representative activation through the real installed adapter
   before claiming support.

If the harness cannot re-apply instructions after compaction, state that limit.
Do not simulate support with copied transcript fixtures.

## What to test

Different claims need different evidence:

- **Packaging and structure:** deterministic validation of manifests, mirror
  equality, reference paths, frontmatter, and token budgets. These checks belong
  in CI.
- **Deterministic adapter scripts:** focused offline tests for meaningful parsing
  or hook branches. Keep the script small enough that its test does not become a
  second implementation.
- **Discovery and activation:** a thin live smoke through the real harness.
  Run the relevant opening when a trigger or adapter changes and before a
  release; report authentication, provider, or network failures as inconclusive
  rather than routing failures.
- **Skill behavior:** retain a behavioral regression only for a failure actually
  observed and a verdict that can be checked mechanically. Run it manually and
  report repeated results honestly.

A full skill-by-harness behavioral matrix is neither deterministic nor a useful
default. It consumes provider time, produces noisy results, and shifts maintenance
toward the evaluator instead of the skills.

The shared runners and scenarios are documented in
[`tests/README.md`](../../tests/README.md).

## Implementation guard

Where the harness exposes a blockable edit event, SDLC Skills keeps a small guard
that requires `test-driven-development` and `yagni` before code edits. It is a
best-effort process backstop, not a security boundary: shell writes and
unsupported tools can bypass it.

Wide migrations are routed by `using-sdlc-skills` to `migration-strategy` and
`verification-strategy`. Their durable enforcement belongs in the adopting
project's real compiler, test, CI, review, and promotion gates. A universal hook
cannot reliably infer project risk from prompt wording.

## Adding an adapter

1. Point the manifest at the canonical skills; do not fork their content.
2. Extend structural validation so missing, extra, or divergent skills fail.
3. Add the smallest install/activation smoke that drives the real CLI.
4. Add an offline test only for deterministic adapter logic introduced by the
   integration.
5. Document observed lifecycle limits and current live evidence without
   converting a nondeterministic run into a permanent guarantee.
