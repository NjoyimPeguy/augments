#!/usr/bin/env bash
# Behavioural test for the Codex CLI adapter.
#
# Shares everything harness-agnostic with the other adapters via
# ../lib/behavioral.sh — two arms, shared scenario, verdict as the probe's exit
# code. Only the three functions below are Codex-specific.
#
# `-s workspace-write` replaces the activation probe's `-s read-only` so the
# agent can actually produce artifacts.
#
# OPENING: uses ../../scenarios/behavioral/<name>/opening.codex when present.
# `codex exec` is single-turn, so an opening that invites a clarifying question
# ends the run with NO deliverable — the first spec-it arm died exactly that way,
# after routing correctly. Both arms share whichever opening is selected; that is
# what keeps RED vs GREEN a comparison.
#
# Real API calls, roughly a full task per arm. Manual tool, never CI.
#
# Usage: run-behavioral.sh --scenario spec-it --arm red|green [--base REF] [--keep]

set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"
cd "$scriptdir/../.." || exit 2
repo="$PWD"
BH_DEFAULT_TIMEOUT=2400
. "$scriptdir/../lib/behavioral.sh"
source_codex_home="${CODEX_HOME:-${HOME:-}/.codex}"

# --- the three harness-specific pieces --------------------------------------
bh_install() { # $1 plugin source — isolated CODEX_HOME + local marketplace install
  harness_home="$(mktemp -d)"
  for f in auth.json config.toml models_cache.json; do
    [ -f "$source_codex_home/$f" ] && cp "$source_codex_home/$f" "$harness_home/$f"
  done
  # A copied config.toml can already register `augments-dev` against the real
  # repo, which collides when this arm's source differs. Drop it in the ISOLATED
  # home only — the user's own CODEX_HOME is never touched.
  env CODEX_HOME="$harness_home" codex plugin remove augments >/dev/null 2>&1
  env CODEX_HOME="$harness_home" codex plugin marketplace remove augments-dev >/dev/null 2>&1
  env CODEX_HOME="$harness_home" codex plugin marketplace add "$1" --json >/dev/null 2>>"$errlog" || {
    echo "marketplace add failed (see $errlog)" >&2; return 3; }
  env CODEX_HOME="$harness_home" codex plugin add augments@augments-dev --json >/dev/null 2>>"$errlog" || {
    echo "plugin add failed (see $errlog)" >&2; return 3; }
}

bh_invoke() { # $1 workdir  $2 opening file  $3 stream
  local prompt; prompt="$(cat "$2")

Use the relevant Augments skill according to the skill instructions: read its SKILL.md completely before answering."
  ( cd "$1" && exec timeout "$timeout_s" env CODEX_HOME="$harness_home" \
      codex exec --json --skip-git-repo-check -s workspace-write -C "$1" "$prompt" ) \
      < /dev/null > "$3" 2>>"$errlog"
}

bh_chain() { # $1 stream — Codex reads skills as shell commands, so activation is
             # a command_execution that touches an installed SKILL.md
  jq -rc 'if (.type == "item.started" or .type == "item.completed")
             and .item.type == "command_execution" then
            (.item.command // "") as $cmd
            | ($cmd | scan("/skills/(?<skill>[A-Za-z0-9_-]+)/SKILL[.]md")? | .[0])
            | if . == "" then empty else "augments:" + . end
          else empty end' "$1" 2>/dev/null
}

# --- run ---------------------------------------------------------------------
bh_parse_args "$@" || exit 2
command -v codex >/dev/null 2>&1 || { echo "no \`codex\` CLI on PATH" >&2; exit 3; }
command -v jq    >/dev/null 2>&1 || { echo "needs \`jq\`" >&2; exit 3; }

stream="$(mktemp)"; errlog="$(mktemp)"; harness_home=""
trap bh_cleanup EXIT

bh_resolve_scenario codex || exit 2
bh_setup_arm || exit 2
bh_install "$plugin_src" || exit 3
bh_seed_fixture || exit 2

bh_invoke "$workdir" "$opening_file" "$stream"; status=$?
bh_report codex "$status"
