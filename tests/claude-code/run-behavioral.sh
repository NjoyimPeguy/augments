#!/usr/bin/env bash
# Behavioural test for the Claude Code adapter.
#
# run-activation.sh answers "did the skill fire?" — one generic verdict, so its
# engine can be scenario-agnostic. This answers "did the skill change what got
# BUILT?", which has no generic verdict: success differs per skill. So the
# scenario owns the judgement via its probe.sh, and everything harness-agnostic
# lives in ../lib/behavioral.sh — the three adapters were ~60% identical before
# it existed.
#
# This one needs WRITE access (an activation probe is read-only), so Write/Edit/
# Bash are allowed and edits auto-accepted. Safe: every run happens in a
# disposable copy of the fixture under /tmp, never in this repo.
#
# Real API calls, roughly a full task per arm. Manual tool, never CI.
#
# Usage: run-behavioral.sh --scenario spec-it --arm red|green [--base REF] [--keep]

set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"
cd "$scriptdir/../.." || exit 2
repo="$PWD"
BH_DEFAULT_TIMEOUT=1200
. "$scriptdir/../lib/behavioral.sh"

# --- the three harness-specific pieces --------------------------------------
bh_install() { plugin_dir="$1"; }   # Claude Code loads a tree directly; no install step

bh_invoke() { # $1 workdir  $2 opening file  $3 stream
  ( cd "$1" && exec timeout "$timeout_s" claude -p "$(cat "$2")" \
      --output-format stream-json --verbose \
      --plugin-dir "$plugin_dir" \
      --allowedTools Skill Read Glob Grep Write Edit Bash TodoWrite \
      --permission-mode acceptEdits ) < /dev/null > "$3" 2>>"$errlog"
}

bh_chain() { # $1 stream — only a structured Skill tool_use in an assistant event
  jq -r 'select(.type=="assistant") | .message.content[]?
         | select(.type=="tool_use" and .name=="Skill") | .input.skill' "$1" 2>/dev/null
}

# --- run ---------------------------------------------------------------------
bh_parse_args "$@" || exit 2
command -v claude >/dev/null 2>&1 || { echo "no \`claude\` CLI on PATH" >&2; exit 3; }
command -v jq     >/dev/null 2>&1 || { echo "needs \`jq\`" >&2; exit 3; }

stream="$(mktemp)"; errlog="$(mktemp)"; harness_home=""
trap bh_cleanup EXIT

bh_resolve_scenario claude-code || exit 2
bh_setup_arm || exit 2
bh_install "$plugin_src"
bh_seed_fixture || exit 2

bh_invoke "$workdir" "$opening_file" "$stream"; status=$?
bh_report claude-code "$status"
