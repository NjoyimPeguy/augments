# Activation record - task-branch routing (2026-07-07)

## Problem

Agents were still starting implementation work without first creating or entering
a meaningful branch/workspace unless the user explicitly asked for isolation.
The existing branch/workspace body had a main-branch guard, but its trigger
focused on risky, multi-task, and parallel work, so ordinary "implement this"
requests could route only to implementation skills.

Prior-art check: Superpowers puts its worktree skill in the basic workflow after
design approval and prefers native worktree support before a git fallback. Its
Codex plugin manifest does not force branch creation through hooks, so the useful
piece here is trigger/routing pressure, not a harness-level branch enforcer.

## Change

- Renamed the skill to `using-task-branches`, because the discipline is task
  branch/workspace setup, not always a git worktree.
- Broadened `using-task-branches` to fire before repo edits or implementation,
  with a meaningful task branch as the ordinary single-task path.
- Added pressure points for the shortcuts that lead to edits before branch setup.
- Made branch-vs-worktree choice explicit: user/project preference wins; absent a
  preference, use a plain branch for normal single-task work and a worktree only
  when separate files/runtime state are needed.
- Added a `using-augments` chain rule: edit/fix/refactor/plan-execution requests
  route to `using-task-branches` before repo exploration or implementation,
  because that skill owns the branch/status check.
- Added `scenarios/implementation/using-task-branches` for Claude Code and Codex.
- Added `--fixture-git-repo` to the activation runners so branch-start scenarios
  run in a disposable git repo on `main` instead of an empty temp directory.
- Added Codex `--working-tree` activation mode so live Codex probes can install
  this checkout into a temporary `CODEX_HOME` rather than using a stale cache.

## Evidence

Claude Code live activation, current checkout, disposable git repo fixture:

```bash
bash tests/harnesses/claude-code/run-activation.sh \
  --scenario-file tests/harnesses/claude-code/scenarios/implementation/using-task-branches \
  --expect using-task-branches --working-tree --fixture-git-repo \
  --timeout 120 --max-turns 4 --verbose --keep
```

Result:

```text
verdict  : ACTIVATED - chain: augments:using-augments augments:using-task-branches (reached augments:using-task-branches)
```

Earlier runs in the empty-temp-dir harness were inconclusive or failed for the
wrong reason: the model found no repo and asked for the real path before branch
setup. That exposed a harness gap, not a useful branch-routing result.

No-model checks:

```bash
bash tests/harnesses/claude-code/run-activation.sh selftest
bash tests/harnesses/codex-cli/run-activation.sh selftest
bash tests/harnesses/codex-cli/run-plugin-smoke.sh
```

All passed. The Codex detector self-test includes a combined-command fixture so
commands that read several `SKILL.md` files still count every skill path.

Codex live activation, current checkout installed into a temporary authenticated
`CODEX_HOME`, disposable git repo fixture:

```bash
bash tests/harnesses/codex-cli/run-activation.sh \
  --scenario-file tests/harnesses/codex-cli/scenarios/implementation/using-task-branches \
  --expect using-task-branches --working-tree --fixture-git-repo \
  --timeout 75 --keep
```

Result:

```text
verdict  : ACTIVATED - chain: augments:using-augments augments:using-task-branches augments:zoom-out augments:test-driven-development augments:interview-me augments:verifying-completion (read augments:using-task-branches)
```

The first Codex live run failed with `401 Unauthorized` because the temporary
`CODEX_HOME` had no auth. The runner now copies auth/config into the temporary
home before installing this checkout. A later run read `using-task-branches` in a
combined command, but the detector only captured the first skill path; the
detector now scans all skill paths per command.

## Honest limit

This proves activation in Claude Code and Codex for a fresh implementation
request in a real git-shaped fixture. It does not prove the agent will
successfully create a branch in every harness, nor does it make branch creation
deterministic. The enforcement remains a routing nudge; branch-protection or
project-local hooks would be the deterministic layer.
