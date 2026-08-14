#!/usr/bin/env bash
# Codex CLI adapter. Sourced by the runners under tests/ — behavioural,
# plugin-smoke, and trigger-eval — never executed directly.

adapter_name='codex'
source_codex_home="${CODEX_HOME:-${HOME:-}/.codex}"

adapter_check() {
  command -v codex >/dev/null 2>&1 || { echo "no \`codex\` CLI on PATH" >&2; return 3; }
}

# Isolated CODEX_HOME with this checkout installed from a local marketplace —
# the same path `codex plugin add` takes for a real user.
adapter_install() { # $1 plugin source ("" = NONE arm, install nothing)
  harness_home="$(mktemp -d)"
  local f
  for f in auth.json config.toml models_cache.json; do
    [ -f "$source_codex_home/$f" ] && cp "$source_codex_home/$f" "$harness_home/$f"
  done
  # A copied config.toml can already register `augments-labs-dev` against the real
  # repo, which collides when this arm's source differs. Removed in the ISOLATED
  # home only — the user's own CODEX_HOME is never touched. On the NONE arm this
  # is the whole job: an isolated home with credentials and no plugin.
  env CODEX_HOME="$harness_home" codex plugin remove sdlc-skills >/dev/null 2>&1
  env CODEX_HOME="$harness_home" codex plugin marketplace remove augments-labs-dev >/dev/null 2>&1
  [ -n "$1" ] || return 0
  env CODEX_HOME="$harness_home" codex plugin marketplace add "$1" --json >/dev/null 2>>"$errlog" || {
    echo "marketplace add failed (see $errlog)" >&2; return 3; }
  env CODEX_HOME="$harness_home" codex plugin add sdlc-skills@augments-labs-dev --json >/dev/null 2>>"$errlog" || {
    echo "plugin add failed (see $errlog)" >&2; return 3; }
}

# Codex reads a skill as a shell command, so an activation is a command_execution
# that touches an installed SKILL.md.
adapter_chain() {
  jq -rc 'if (.type == "item.started" or .type == "item.completed")
             and .item.type == "command_execution" then
            (.item.command // "") as $cmd
            | ($cmd | scan("/skills/(?<skill>[A-Za-z0-9_-]+)/SKILL[.]md")? | .[0])
            | if . == "" then empty else "sdlc-skills:" + . end
          else empty end' "$1" 2>/dev/null
}

adapter_behavioral_events() {
  jq -r 'if .type == "item.completed" and .item.type == "command_execution" then
           (.item.command // "") as $cmd
           | (($cmd | scan("/skills/(?<skill>[A-Za-z0-9_-]+)/SKILL[.]md")? | .[0]) // "") as $skill
           | if $skill != "" then "SKILL sdlc-skills:" + $skill else empty end
         elif .type == "item.completed" and .item.type == "file_change" then
           .item.changes[]? | "EDIT " + (.path // "")
         else empty end' "$1" 2>/dev/null |
    awk '$0 != previous { print } { previous=$0 }'
}

# This harness needs the skill-instructions suffix to reach for a skill at all.
adapter_prompt_suffix() {
  printf '\n\nUse the relevant skill according to the skill instructions: read its SKILL.md completely before answering.'
}

adapter_run_activation() { # $1 workdir  $2 prompt  $3 stream
  ( cd "$1" && exec timeout "$timeout_s" env CODEX_HOME="$harness_home" \
      codex exec --json --ephemeral --skip-git-repo-check -s read-only -C "$1" "$2" ) \
      < /dev/null > "$3" 2>>"$errlog"
}

adapter_activation_flags() { :; }

# COST: one `turn.completed` closes a `codex exec` and carries the whole run's
# totals — 48k input tokens across several tool round-trips in the stream this
# was read from, not one model call's worth. Take the last such event.
#
# Add ONLY input + output. `cached_input_tokens` and `reasoning_output_tokens`
# are breakdowns *inside* those two, not extra charges: the probe reported 77
# reasoning tokens within 84 output tokens for a two-word reply. Summing all
# five fields would roughly double the number and quietly overstate what every
# skill costs.
adapter_usage() {
  jq -s 'map(select(.type == "turn.completed") | .usage) | last | select(. != null)
         | (.input_tokens // 0) + (.output_tokens // 0)' "$1" 2>/dev/null
}

# `-s workspace-write` replaces read-only so the agent can produce artifacts.
# Codex intentionally protects `.git` inside writable roots. Behavioural
# fixtures are disposable task branches whose local checkpoints are authorized,
# so automatic review supplies the supported, command-scoped path through that
# protection without removing the workspace sandbox.
adapter_run_behavioral() { # $1 workdir  $2 opening file  $3 stream
  local prompt
  prompt="$(cat "$2")$(adapter_prompt_suffix)

This disposable behavioural run authorizes task-local Git checkpoint commits.
If the workspace sandbox protects Git metadata, request native permission
escalation for the exact Git command; that protection is not a denial of
checkpoint authority."
  ( cd "$1" && exec timeout "$timeout_s" env CODEX_HOME="$harness_home" \
      codex exec --json --approve-for-me --skip-git-repo-check \
        -C "$1" "$prompt" ) \
      < /dev/null > "$3" 2>>"$errlog"
}

# Continue through the structured thread id emitted by `codex exec`. Resume
# inherits the original workspace and sandbox, but Codex does not retain the
# automatic approval reviewer across `exec resume`; bind it on every turn so
# protected Git checkpoints keep the same command-scoped review path.
adapter_continue_behavioral() { # $1 workdir  $2 prompt  $3 new stream  $4 prior stream
  local wd="$1" prompt="$2" out="$3" prior="$4" thread_id
  thread_id="$(jq -r 'select(.type == "thread.started") | .thread_id // empty' \
               "$prior" 2>/dev/null | head -1)"
  [ -n "$thread_id" ] || { echo "Codex stream contains no resumable thread id" >&2; return 2; }
  ( cd "$wd" && exec timeout "$timeout_s" env CODEX_HOME="$harness_home" \
      codex exec resume --json --skip-git-repo-check \
        -c 'approval_policy="on-request"' \
        -c 'approvals_reviewer="auto_review"' \
        "$thread_id" "$prompt" \
    ) < /dev/null > "$out" 2>>"$errlog"
}
