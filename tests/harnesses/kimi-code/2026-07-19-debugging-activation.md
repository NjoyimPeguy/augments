# Activation record - debugging (2026-07-19)

## Problem

The library supported Claude Code and Codex CLI, but had no Kimi Code CLI
adapter: no plugin manifest, no discovery proof, no nudge mechanism, no
runnable harness layer. AGENTS.md requires a harness to ship with a runner
that shows a skill *actually activating* on a representative opening.

## Change

- Added `.kimi-plugin/plugin.json`: multi-path `skills` array pointing at the
  eight canonical phase directories (no mirror), `sessionStart.skill:
  using-augments` as the proactive-use nudge, and `skillInstructions` binding
  harness-agnostic skill language to Kimi's real tool names.
- Added `tests/validate-kimi-plugin.sh` (wired into `tests/validate-skills.sh`,
  whose version-agreement check now covers the third manifest).
- Added this harness layer: `run-activation.sh` (live probe + offline
  selftest), `fixtures/`, `scenarios/maintenance/debugging`.

## Detector evidence

```bash
bash tests/harnesses/kimi-code/run-activation.sh selftest
```

```text
ok    fired-debugging.jsonl    -> augments:debugging
ok    none.jsonl               -> <none>
ok    builtin-skill.jsonl      -> augments:check-kimi-code-docs
Kimi activation detector self-test: PASS
```

`fired-debugging.jsonl` is a trimmed real capture from the spike run, not a
hand-written fixture.

## Live probe - activation (Kimi Code CLI 0.27.0)

```bash
bash tests/harnesses/kimi-code/run-activation.sh \
  --scenario-file scenarios/maintenance/debugging --timeout 150 --keep
```

```text
scenario : There's a bug — users intermittently get logged out mid-session,
           maybe 1 request in 10, no clear pattern. Figure out what's going on
           and fix it.
expected : augments:debugging
verdict  : ACTIVATED — chain: augments:debugging (invoked augments:debugging)
captured : 5 JSON events
```

The scenario went in bare — no "use a skill" suffix. The first assistant event
in the retained stream (`last-stream.jsonl`) is a `Skill` tool call with
`{"skill":"debugging"}` followed by the tool result `Skill "debugging" loaded
inline.`, so routing came from the plugin's own session-start nudge, not from
prompt wording.

## Session-start nudge evidence (wire level)

During the spike, a clean session in an isolated `KIMI_CODE_HOME` with only
this plugin installed was inspected at the wire log
(`sessions/<wd>/<session>/agents/main/wire.jsonl`). The system prompt contained
the `using-augments` skill content (via `sessionStart.skill`) and the
`<kimi-plugin-instructions plugin="augments">` wrapper (via
`skillInstructions`). A discovery listing in that session returned all 30
canonical skills.

## Portable verification

```bash
bash tests/validate-skills.sh
```

Passed, including the new Kimi adapter section and three-manifest version
agreement (all 4.0.0).

## Honest limits

- Proves discovery, the session-start nudge, and routing-to-skill on one
  maintenance scenario with one model configuration. It does not prove routing
  quality across the catalogue; more scenarios can be added the same way.
- The nudge does not survive mid-session compaction (see this folder's
  README); no Stop-hook parity yet.
- `skillInstructions` tool bindings are injected and visible in the wire log,
  but their *effect* (e.g. subagent dispatch via `Agent` with the right
  `subagent_type`) is not yet exercised by a dedicated scenario.
