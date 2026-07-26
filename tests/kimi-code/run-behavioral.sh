#!/usr/bin/env bash
# Behavioural test for the Kimi Code CLI adapter.
#
# Shares everything harness-agnostic with the other adapters via
# ../lib/behavioral.sh — two arms, shared scenario, verdict as the probe's exit
# code. Only the three functions below are Kimi-specific.
#
# NO permission flag is passed, and that is deliberate: `kimi -p` already
# auto-approves tool calls, so it can write. Both approval flags are in fact
# REJECTED in prompt mode ("Cannot combine --prompt with --auto" / "...--yolo"),
# so do not add one back thinking it grants write access — verified by having a
# throwaway `-p` run create a file with no flags at all.
#
# `-p` is single-shot, so a run that stops to ask ends with no deliverable. If
# that happens, give the scenario an `opening.kimi-code` that pre-empts the
# interview, the way `opening.codex` does.
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
source_kimi_home="${KIMI_CODE_HOME:-${HOME:-}/.kimi-code}"

# --- the three harness-specific pieces --------------------------------------
bh_install() { # $1 plugin source — isolated home + managed-plugin layout,
               # the same shape `kimi /plugins install` produces
  harness_home="$(mktemp -d)"
  for f in config.toml device_id; do
    [ -f "$source_kimi_home/$f" ] && cp "$source_kimi_home/$f" "$harness_home/$f"
  done
  for d in credentials oauth; do
    [ -d "$source_kimi_home/$d" ] && cp -r "$source_kimi_home/$d" "$harness_home/$d"
  done
  local managed="$harness_home/plugins/managed/augments"
  mkdir -p "$managed"
  ( cd "$1" && tar --exclude=.git --exclude=.augments -cf - . ) | tar -xf - -C "$managed"
  [ -f "$managed/.kimi-plugin/plugin.json" ] || {
    echo "no .kimi-plugin/plugin.json in $1 — does that ref carry the Kimi adapter?" >&2
    return 2; }
  local skills; skills="$(find "$managed/skills" -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')"
  jq -n --arg root "$managed" \
        --arg manifest_path "$managed/.kimi-plugin/plugin.json" \
        --arg original "$1" \
        --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --argjson skills "$skills" \
        --slurpfile manifest "$managed/.kimi-plugin/plugin.json" \
    '{version: 1, plugins: [{
       id: "augments", root: $root, source: "local-path", enabled: true,
       state: "ok", installedAt: $now, updatedAt: $now, originalSource: $original,
       skillCount: $skills, manifest: $manifest[0],
       manifestKind: "kimi-plugin-dir", manifestPath: $manifest_path,
       diagnostics: [], skillInstructions: $manifest[0].skillInstructions
     }]}' > "$harness_home/plugins/installed.json" || return 2
}

bh_invoke() { # $1 workdir  $2 opening file  $3 stream
  # No prompt suffix: the sessionStart nudge is part of what this exercises, so
  # the opening goes in bare, as a real user opening.
  ( cd "$1" && exec timeout "$timeout_s" env KIMI_CODE_HOME="$harness_home" \
      kimi -p "$(cat "$2")" --output-format stream-json ) < /dev/null > "$3" 2>>"$errlog"
}

bh_chain() { # $1 stream
  jq -rc 'select(.role == "assistant")
          | .tool_calls[]?
          | select(.function.name == "Skill")
          | (.function.arguments | try fromjson catch {} | .skill // empty)
          | "augments:" + .' "$1" 2>/dev/null
}

# --- run ---------------------------------------------------------------------
bh_parse_args "$@" || exit 2
command -v kimi >/dev/null 2>&1 || { echo "no \`kimi\` CLI on PATH" >&2; exit 3; }
command -v jq   >/dev/null 2>&1 || { echo "needs \`jq\`" >&2; exit 3; }

stream="$(mktemp)"; errlog="$(mktemp)"; harness_home=""
trap bh_cleanup EXIT

bh_resolve_scenario kimi-code || exit 2
bh_setup_arm || exit 2
bh_install "$plugin_src" || exit 2
bh_seed_fixture || exit 2

bh_invoke "$workdir" "$opening_file" "$stream"; status=$?
bh_report kimi-code "$status"
