# Harness Support

How one skill library runs on several coding agents without putting
harness-specific behavior into the skills.

## One skill tree, thin adapters

There is one canonical tree under `skills/`. Skills use capability tiers and
portable actions; each harness adapter binds those concepts to its own manifest,
tools, and lifecycle events.

| Harness | Adapter | Router injection | Re-applied after compaction | Structured code-edit guard |
| --- | --- | --- | --- | --- |
| Claude Code | `.claude-plugin/` and `hooks/hooks.json` | `SessionStart` hook | Yes — `compact` is in the matcher | `Write`, `Edit`, `MultiEdit` |
| Codex | `plugins/sdlc-skills/` (manifest, `hooks/hooks.json`, mirrored injector) and `.agents/plugins/marketplace.json` | `SessionStart` hook | Yes — `SessionStart` with `source=compact` | None — no authoritative skill receipt |
| Kimi Code | `.kimi-plugin/plugin.json` | `sessionStart.skill` | `PostCompact` hook | `Write`, `Edit`, `MultiEdit` |

The Codex plugin manifest carries the skill catalogue but has no session-start
field, so the router arrives through hooks the plugin itself bundles
(`"hooks": "./hooks/hooks.json"`). Bundling matters: the plugin is installed
standalone, so a hooks file at the repository root is outside the plugin root and
Codex never loads it — a repo-local config wires contributors and ships nothing.
Everything the hook touches therefore lives inside the plugin, and
`scripts/sh/sync-codex-plugin-skills.sh` mirrors it in.

Codex reports compaction through a `SessionStart` event whose source is
`compact`. Its separate `PostCompact` output cannot carry additional context,
so the adapter keeps router injection on the contextual `SessionStart` path.

Two consequences worth knowing before editing either side. The command resolves
the injector through `$PLUGIN_ROOT`, because hooks run with the *session* working
directory, not the plugin's. And the mirror is flat (`skills/<name>/`) where the
canonical tree is by phase (`skills/<phase>/<name>/`), so the injector resolves
the router from both layouts; hard-coding one path ships something that works in
this repository and nowhere anyone installs.

Every adapter injects the **full `using-sdlc-skills` body**, not a pointer to it.
A pointer asks the agent to spend a discretionary tool call loading the router;
the body makes the routing rules resident instead. `scripts/sh/token-budget.sh`
reports the current context cost by running the injector.

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

Kimi's manifest declares `PostCompact` re-injection through the same
`hookSpecificOutput` context envelope used by its other lifecycle hooks.

## Dispatch capability

`dispatching-parallel-agents` and `executing-plans` hand work to a cold agent
through "the real callable action". The skills stay portable by never naming it;
each adapter binds it, and each harness decides whether it exists at all.

| Harness | Dispatch action | Notes |
| --- | --- | --- |
| Claude Code | `Agent` tool | Native; no configuration needed |
| Codex | `spawn_agent` / `wait_agent` / `list_agents` / `send_message` / `followup_task` / `interrupt_agent` | Availability depends on the installed build and configuration |
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
second-hand snippet.

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

The adapter contract is documented in
[`tests/harnesses/README.md`](../tests/harnesses/README.md). What consumes it
splits by whether the correct answer is known in advance: gates in
[`tests/README.md`](../tests/README.md), measurements in
[`tests/optimizing/README.md`](../tests/optimizing/README.md).

## Scoped implementation guard

Claude Code and Kimi Code run `scripts/sh/implementation-guard.sh` at their
structured code-edit boundary. It requires current-session loading evidence for
both implementation disciplines before a covered edit. Claude Code reads native
skill calls from the transcript, and Kimi Code records its native Skill calls.

Codex deliberately has no implementation guard. It exposes no authoritative
skill invocation receipt to the adapter, and a missing side-channel receipt is
not evidence that the skill did not load. Its router still requires the pair;
the adopting project's real gates decide whether the resulting artifact can
advance.

The hook is not a universal write boundary. Shell commands and other mutation
paths do not pass through structured edit-class hooks, and unsupported harnesses
do not gain enforcement from prose. The hook reports that limitation when it
denies an edit.

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
5. Document the adapter's current lifecycle and support boundaries. Keep run
   transcripts and evaluation results in the test workflow, not this website
   documentation.
