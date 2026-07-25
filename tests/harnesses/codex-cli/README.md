# tests/harnesses/codex-cli/ - Codex plugin adapter checks

This folder is the Codex CLI adapter test layer. It has four scopes:

- `run-plugin-smoke.sh` is a no-model smoke test. It creates an isolated
  `CODEX_HOME` under `/tmp`, registers this checkout as a local marketplace,
  verifies that `augments` is listed from `augments-dev`, and installs it.
- `run-activation.sh selftest` is an offline detector check over fixture JSONL.
- `run-activation.sh --scenario-file scenarios/maintenance/debugging --keep`
  drives a real read-only `codex exec --json` run and observes activation as
  command events that read an installed Augments `SKILL.md` from the plugin
  cache.
- `test-stop-nudge.sh` is an offline payload test for the Codex Stop hook
  wrapper. It invokes the shared done-boundary detector in
  `hooks/stop-nudge.sh`.
- `behavioral-records/` records pressure tests where a discipline is invoked on Codex
  and the outcome is compared with a plugins-disabled baseline.

The plugin itself lives under `plugins/augments/` because Codex expects a flat
plugin `skills/` directory. That directory is a generated mirror of the
canonical phase-organized `skills/<phase>/<name>/` tree, rebuilt with
`scripts/sync-codex-plugin-skills.sh` and checked by `tests/validate-codex-plugin.sh`.

## Run it

```bash
bash tests/validate-codex-plugin.sh
bash tests/harnesses/codex-cli/run-plugin-smoke.sh
bash tests/harnesses/codex-cli/run-activation.sh selftest
bash tests/harnesses/codex-cli/test-stop-nudge.sh
bash tests/harnesses/codex-cli/run-activation.sh \
  --scenario-file scenarios/maintenance/debugging --keep
bash tests/harnesses/codex-cli/run-activation.sh \
  --scenario-file scenarios/implementation/using-task-branches \
  --expect using-task-branches --working-tree --fixture-git-repo --keep
```

These checks are adapter-specific. They do not replace the portable structural
gate in `tests/validate-skills.sh`.

Use `--working-tree` when a live Codex activation probe should install this
checkout into a temporary `CODEX_HOME` instead of reading the user's installed
plugin cache; the runner copies the user's Codex auth/config into that temporary
home so the model call can authenticate without mutating the real plugin setup.
Use `--fixture-git-repo` when the scenario needs a disposable git repo on `main`
rather than an empty temp directory.

Behavioral records are not automated pass/fail gates. They are dated evidence:
the prompt, the pressure, the observed RED/GREEN behavior, and any inconclusive
or partial result.

## Detection

Codex exposes plugin skills in the model-visible skills list with file locators.
In `codex exec --json`, the stable activation evidence observed so far is not a
`Skill` tool call; it is a `command_execution` item whose command reads
`.../skills/{{skill}}/SKILL.md` from the installed plugin cache. The detector
counts that file read as activation and ignores prose mentions. A single command
may read several skill files, so the detector scans every matching path in the
command, not just the first one.

## Result Notes

2026-07-06: the first install used symlinked skill directories under
`plugins/augments/skills/`. Codex installed the plugin but its cache contained
only `.codex-plugin/plugin.json` and assets, so no Augments skills were visible
to the model. Replacing the symlink view with a generated flat mirror fixed the
cache: all 30 `SKILL.md` files appeared under the installed plugin, and a
debugging scenario read both `using-augments/SKILL.md` and
`debugging/SKILL.md`.

2026-07-06: Codex plugin hooks were not observed firing from the plugin
manifest in the CLI probe, and a project-level `SessionStart` probe did not
fire under `codex exec`. The repo therefore ships Codex Stop hook files as
project-level configuration (`.codex/hooks.json` mirrored from
`hooks/hooks-codex.json`) and
tests the wrapper offline rather than claiming plugin-level hook installation.
