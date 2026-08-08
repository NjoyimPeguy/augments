# Harness Support

How one skill library runs on several coding agents without putting
harness-specific behavior into the skills.

## One skill tree, thin adapters

There is one canonical tree under `skills/`. Skills use capability tiers and
portable actions; each harness adapter binds those concepts to its own manifest,
tools, and lifecycle events.

| Harness | Adapter | Router injection | Re-applied after compaction |
| --- | --- | --- | --- |
| Claude Code | `.claude-plugin/` and `hooks/hooks.json` | `SessionStart` hook | Yes — `compact` is in the matcher |
| Codex | `plugins/sdlc-skills/` (manifest, `hooks/hooks.json`, mirrored injector) and `.agents/plugins/marketplace.json` | `SessionStart` hook | Yes — separate `PostCompact` event |
| Kimi Code | `.kimi-plugin/plugin.json` | `sessionStart.skill` | Declared via `PostCompact` (see below) |

The Codex plugin manifest carries the skill catalogue but has no session-start
field, so the router arrives through hooks the plugin itself bundles
(`"hooks": "./hooks/hooks.json"`). Bundling matters: the plugin is installed
standalone, so a hooks file at the repository root is outside the plugin root and
Codex never loads it — a repo-local config wires contributors and ships nothing.
Everything the hook touches therefore lives inside the plugin, and
`scripts/sh/sync-codex-plugin-skills.sh` mirrors it in.

Two consequences worth knowing before editing either side. The command resolves
the injector through `$PLUGIN_ROOT`, because hooks run with the *session* working
directory, not the plugin's. And the mirror is flat (`skills/<name>/`) where the
canonical tree is by phase (`skills/<phase>/<name>/`), so the injector resolves
the router from both layouts; hard-coding one path ships something that works in
this repository and nowhere anyone installs.

Every adapter injects the **full `using-sdlc-skills` body**, not a pointer to it.
A pointer costs ~90 tokens and buys a request that the agent spend a discretionary
tool call loading the router; that call is skippable and does get skipped. The
body costs ~1,500 approx tokens per context epoch and leaves nothing to skip.
`scripts/sh/token-budget.sh` reports the real figure by running the injector.

The text is **read from the canonical skill at runtime**, never copied into an
adapter, so editing the skill cannot silently stop shipping.
`tests/run-session-start.sh` asserts the injected context contains the canonical
body verbatim, in each harness's envelope.

No adapter ships a turn-end or per-prompt reminder. Routing that has to survive a
long session belongs in the resident surface, re-applied only where the harness
reports that context was actually lost.

The Claude manifest, Codex mirror, and Kimi skill paths must expose the same
canonical skill set. `scripts/sh/validate-skills.sh` checks that deterministic
packaging contract.

An earlier revision of this document recorded Kimi's post-compaction callback as
observation-only, and therefore recorded compaction survival as an unfixable
capability gap. That is no longer accurate: the harness documents `PreCompact`
and `PostCompact` among its hook events, both able to return context through the
same `hookSpecificOutput` envelope the other adapters use. The manifest now
declares a `PostCompact` re-injection on that basis. It is **documentation-based
and not verified live in this repository** — there is no Kimi CLI in the
environment that produced it. Treat the row above as a declaration to confirm,
not as measured support, and re-test it when a CLI is available.

## Dispatch capability

`dispatching-parallel-agents` and `executing-plans` hand work to a cold agent
through "the real callable action". The skills stay portable by never naming it;
each adapter binds it, and each harness decides whether it exists at all.

| Harness | Dispatch action | Notes |
| --- | --- | --- |
| Claude Code | `Agent` tool | Native; no configuration needed |
| Codex | `spawn_agent` / `wait_agent` / `list_agents` / `send_message` / `followup_task` / `interrupt_agent` | Present with no extra configuration on the build tested below |
| Kimi Code | `Agent` tool | Bound in `.kimi-plugin/plugin.json` `skillInstructions`, including `subagent_type` and the tier-in-prompt rule |

Availability is a property of the installed build and its configuration, not of
this library, and it changes between versions — some builds gate multi-agent
tools behind a config entry that is off by default. So the skill does not
hardcode a remedy. It requires the agent to treat an uncallable action as **not
dispatched**, and to name both the action it attempted and what this environment
would need to make it callable, rather than stopping mysteriously, narrating a
fan-out it holds no receipts for, or silently collapsing it to sequential work.

Check the harness's own configuration reference for the current form, and verify
by asking the installed CLI what tools it exposes rather than trusting a
second-hand snippet. Evidence for the row above: on `codex-cli 0.147.0`, a
read-only `codex exec` reported the six multi-agent tools both with and without
`multi_agent.enabled=true`, so no flag was required on that build.

## Repository instruction files

`AGENTS.md` and `GEMINI.md` are symlinks to `CLAUDE.md`. A harness that reads
its conventional repository instructions therefore receives the same contributor
rules from one source.

## Using SDLC skills elsewhere

The skills are Markdown invoked by name. On another harness:

1. Expose the canonical skill directories through the harness's normal skill
   mechanism.
2. Run `scripts/sh/session-start.sh` from the harness's session-start event and
   feed its `additionalContext` into the session, so the router arrives as
   resident context rather than as an errand the agent can skip. Re-run it on
   whatever event the harness fires when context is lost.
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

## No implementation guard

No adapter ships a hook that blocks edits. One did — a pre-edit guard requiring
`test-driven-development` and `yagni` before code edits — and it is retired.

It was built when the session-start injection was a skippable pointer, and it
was the only thing catching the skip. With the router's body resident, the pair
led the first code edit unaided in 2 of 3 measured runs of
`tests/scenarios/behavioral/implementation-entry-routing.sh`. A guard that
denies edits is too blunt to keep for the remaining margin, and it was never a
real boundary: a shell heredoc writes code without touching a Write/Edit tool.
A partial gate that reads as a total one is worse than a stated limit.

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
