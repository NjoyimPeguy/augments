#!/usr/bin/env bash
# Shared plumbing for every adapter's run-behavioral.sh.
#
# A behavioural run is the same experiment everywhere: seed a disposable copy of
# a shared scenario, load the skills for one arm, let the agent work with write
# access, then let the scenario's probe.sh decide the verdict. Only three things
# are harness-specific, and each adapter supplies them as a function:
#
#   bh_install   $1=plugin_source  — put the skills where this CLI will find them
#   bh_invoke    $1=workdir $2=opening_file $3=stream — run the CLI, return its exit
#   bh_chain     $1=stream         — print the skills invoked, one per line
#
# Everything else lives here so the three runners cannot drift apart. This file
# is sourced, never executed.

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

# Fills: sdir opening_file   ($1 = adapter name, for the opening override)
bh_resolve_scenario() {
  local adapter="$1"
  sdir="$scriptdir/../scenarios/behavioral/$scenario"
  [ -d "$sdir/fixture" ] || { echo "no fixture at $sdir/fixture" >&2; return 2; }
  # A per-adapter opening exists only for a real harness constraint (codex exec is
  # single-turn, so an opening that invites a question ends the run with nothing).
  opening_file="$sdir/opening.$adapter"
  [ -f "$opening_file" ] || opening_file="$sdir/opening.default"
  [ -f "$opening_file" ] || { echo "no opening in $sdir" >&2; return 2; }
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
  cp -r "$sdir/fixture/." "$workdir/" || return 2
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
  echo "opening    : $(basename "$opening_file")"
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

  if [ -x "$sdir/probe.sh" ]; then
    echo "probe      :"
    "$sdir/probe.sh" "$workdir" 2>&1 | sed 's/^/  /'
    local pstat="${PIPESTATUS[0]}"
    [ "$pstat" -eq 0 ] && echo "verdict    : PASS" || echo "verdict    : FAIL (probe exit $pstat)"
    return "$pstat"
  fi
  echo "verdict    : UNSCORED — no executable probe.sh in $sdir"
  return 0
}
