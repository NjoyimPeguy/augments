#!/usr/bin/env bash
# Behavioural test — ONE runner for every harness.
#
# Activation asks "did the skill fire?" — one generic verdict. This asks "did the
# skill change what got BUILT?", which has no generic verdict: success differs
# per skill. So the scenario owns the judgement (`scenario_assert`, exit code)
# and the harness owns only how its CLI is driven (`harnesses/<harness>.sh`).
#
# The plumbing below was briefly a separate lib; with one runner
# instead of three it had a single consumer, so it lives here. assert.sh
# stays split — every scenario uses it.
#
# TWO ARMS, because a behavioural claim is a comparison:
#   --arm green   loads the skills from the working tree (your edit)
#   --arm red     loads them from a throwaway `git worktree` at --base, so the
#                 before-arm stays reproducible AFTER the change is committed.
#                 Running RED by hand before editing works exactly once.
#
# Real API calls, roughly a full agent task per arm. Manual tool, never CI.
#
# Usage:
#   tests/run-behavioral.sh --harness claude-code --scenario spec-it --arm green
#   tests/run-behavioral.sh --harness codex --scenario spec-it --arm red --base origin/dev

set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"
cd "$scriptdir/.." || exit 2
repo="$PWD"

harness=""; args=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --harness) harness="$2"; shift 2;;
    *) args+=("$1"); shift;;
  esac
done
[ -n "$harness" ] || { echo "needs --harness claude-code|codex|kimi-code" >&2; exit 2; }
[ -f "$scriptdir/harnesses/$harness.sh" ] || { echo "no harness adapter: $harness" >&2; exit 2; }

. "$scriptdir/harnesses/$harness.sh"

# --- harness-agnostic plumbing ------------------------------------------------
. "$scriptdir/assert.sh"
. "$scriptdir/fixtures.sh"

# Fills: scenario arm base timeout_s keep
bh_parse_args() {
  scenario=""; arm=""; base="origin/dev"; timeout_s="${BH_DEFAULT_TIMEOUT:-1800}"; keep=""
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --scenario) scenario="$2"; shift 2;;
      --arm)      arm="$2"; shift 2;;
      --base)     base="$2"; shift 2;;   # RED arm: ref holding the pre-change skills
      --timeout)  timeout_s="$2"; shift 2;;
      --keep)     keep="1"; shift;;
      *) echo "unknown argument: $1" >&2; return 2;;
    esac
  done
  [ -n "$scenario" ] || { echo "needs --scenario NAME" >&2; return 2; }
  case "$arm" in red|green) ;; *) echo "needs --arm red|green" >&2; return 2;; esac
}

# Sources the scenario (one file: fixture, opening, assertions) and picks the
# opening and setup for this adapter. Fills: opening_file opening_kind setup_kind
bh_resolve_scenario() {
  local adapter="$1" f="$scriptdir/scenarios/behavioral/$scenario.sh"
  [ -f "$f" ] || { echo "no scenario at $f" >&2; return 2; }
  # assert helpers already sourced above
  . "$f"
  for fn in scenario_opening scenario_setup scenario_assert; do
    command -v "$fn" >/dev/null 2>&1 || { echo "$scenario.sh defines no $fn()" >&2; return 2; }
  done
  # Per-adapter overrides exist only for a real harness constraint.
  local override="scenario_opening_${adapter//-/_}"
  if command -v "$override" >/dev/null 2>&1; then opening_kind="$override"; else opening_kind="scenario_opening"; fi
  opening_file="$(mktemp)"; "$opening_kind" > "$opening_file"
  local setup_override="scenario_setup_${adapter//-/_}"
  if command -v "$setup_override" >/dev/null 2>&1; then setup_kind="$setup_override"; else setup_kind="scenario_setup"; fi
}

# Fills: plugin_src redtree.  RED builds a throwaway worktree at $base so the
# before-arm stays reproducible AFTER the change is committed — running it by
# hand before editing works exactly once.
bh_setup_arm() {
  redtree=""
  if [ "$arm" = "red" ]; then
    git -C "$repo" rev-parse --verify "$base" >/dev/null 2>&1 || {
      echo "--base '$base' is not a valid ref (fetch first?)" >&2; return 2; }
    redtree="$(mktemp -d)"; rm -rf "$redtree"
    git -C "$repo" worktree add --detach "$redtree" "$base" >/dev/null 2>&1 || {
      echo "could not create worktree at $base" >&2; redtree=""; return 2; }
    plugin_src="$redtree"
  else
    plugin_src="$repo"
  fi
}

# Fills: workdir — a disposable copy of the fixture, committed on a task branch
# so branch-discipline skills see a settled repo.
bh_seed_fixture() {
  workdir="$(mktemp -d)"
  "$setup_kind" "$workdir" || return 2
  (
    cd "$workdir" || exit 2
    git init -q . 2>/dev/null || exit 2
    git add -A
    git -c user.name='Augments Harness' -c user.email='harness@example.invalid' \
        commit -q -m 'scenario baseline'
    git switch -qc task/behavioral-probe
  ) || { echo "failed to seed fixture repo" >&2; return 2; }
}

bh_cleanup() {
  [ -n "${redtree:-}" ] && git -C "$repo" worktree remove --force "$redtree" >/dev/null 2>&1
  [ -n "${harness_home:-}" ] && rm -rf "$harness_home"
  if [ -n "${keep:-}" ]; then
    echo "kept: workdir=$workdir stream=$stream errlog=$errlog"
  else
    rm -rf "${workdir:-}"; rm -f "${stream:-}" "${errlog:-}"
  fi
}

# Committed AND uncommitted. An agent that wraps its branch commits its work, and
# a status-only view then shows a clean tree and reads as "produced nothing" —
# that scored a real PASS as absence once.
bh_show_artifacts() {
  ( cd "$workdir" && {
      local root; root="$(git rev-list --max-parents=0 HEAD 2>/dev/null | tail -1)"
      [ -n "$root" ] && git diff --name-status --diff-filter=A "$root" HEAD 2>/dev/null \
        | sed 's/^/  committed /'
      git status --porcelain -uall | sed 's/^/  /'
    } )
}

# $1 = adapter, $2 = CLI exit status. Prints the report, runs the probe, and
# returns the verdict as THIS script's exit code — prose in a summary is written
# by the same agent that wants it green; an exit code is not.
bh_report() {
  local adapter="$1" status="$2" chain
  chain="$(bh_chain "$stream" 2>/dev/null | awk '!seen[$0]++' | paste -sd' ' -)"
  echo "scenario   : $scenario"
  echo "adapter    : $adapter"
  echo "arm        : $arm  (skills from: $([ "$arm" = red ] && echo "$base" || echo 'working tree'))"
  echo "opening    : $opening_kind"
  echo "setup      : $setup_kind"
  echo "exit       : $status"
  echo "skill chain: ${chain:-(none)}"
  echo "artifacts  :"
  bh_show_artifacts

  if [ "$status" -eq 124 ]; then
    echo "verdict    : TIMEOUT after ${timeout_s}s — cut off, treat as inconclusive"; return 1
  elif [ "$status" -ne 0 ]; then
    echo "verdict    : ERROR — $adapter exited $status (see $errlog)"; return 1
  fi
  if grep -qiE 'usage limit|login_required|api_error: 4' "$stream" "$errlog" 2>/dev/null; then
    echo "verdict    : BLOCKED — provider refused (quota/auth); not a behavioural result"; return 1
  fi

  echo "assertions :"
  ( scenario_assert "$workdir" ) 2>&1 | sed 's/^/  /'
  local pstat="${PIPESTATUS[0]}"
  [ "$pstat" -eq 0 ] && echo "verdict    : PASS" || echo "verdict    : FAIL"
  return "$pstat"
}


bh_parse_args ${args[@]+"${args[@]}"} || exit 2
adapter_check || exit 3
command -v jq >/dev/null 2>&1 || { echo "needs \`jq\`" >&2; exit 3; }

stream="$(mktemp)"; errlog="$(mktemp)"; harness_home=""
trap bh_cleanup EXIT

bh_resolve_scenario "$harness" || exit 2
bh_setup_arm || exit 2
adapter_install "$plugin_src" || exit 3
bh_seed_fixture || exit 2

adapter_run_behavioral "$workdir" "$opening_file" "$stream"; status=$?
bh_chain() { adapter_chain "$1"; }
bh_report "$harness" "$status"
