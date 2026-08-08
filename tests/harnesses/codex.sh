#!/usr/bin/env bash
# Codex CLI adapter. Sourced by the dispatchers in tests/; never executed.

adapter_name='codex'
source_codex_home="${CODEX_HOME:-${HOME:-}/.codex}"

adapter_check() {
  command -v codex >/dev/null 2>&1 || { echo "no \`codex\` CLI on PATH" >&2; return 3; }
}

# Isolated CODEX_HOME with this checkout installed from a local marketplace —
# the same path `codex plugin add` takes for a real user.
adapter_install() { # $1 plugin source
  harness_home="$(mktemp -d)"
  local f
  for f in auth.json config.toml models_cache.json; do
    [ -f "$source_codex_home/$f" ] && cp "$source_codex_home/$f" "$harness_home/$f"
  done
  # A copied config.toml can already register `augments-labs-dev` against the real
  # repo, which collides when this arm's source differs. Removed in the ISOLATED
  # home only — the user's own CODEX_HOME is never touched.
  env CODEX_HOME="$harness_home" codex plugin remove sdlc-skills >/dev/null 2>&1
  env CODEX_HOME="$harness_home" codex plugin marketplace remove augments-labs-dev >/dev/null 2>&1
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

# `-s workspace-write` replaces read-only so the agent can produce artifacts.
adapter_run_behavioral() { # $1 workdir  $2 opening file  $3 stream
  local prompt; prompt="$(cat "$2")$(adapter_prompt_suffix)"
  ( cd "$1" && exec timeout "$timeout_s" env CODEX_HOME="$harness_home" \
      codex exec --json --skip-git-repo-check -s workspace-write -C "$1" "$prompt" ) \
      < /dev/null > "$3" 2>>"$errlog"
}
