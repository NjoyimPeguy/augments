#!/usr/bin/env bash
# Run every Claude Code activation scenario with its filename as the contract.
#
# The Codex sibling of this existed first; this one did not, because
# run-activation.sh used to print a verdict and always exit 0 — a sweep over it
# scored every run as a pass regardless of what happened. That is fixed (it now
# exits on the verdict), so a sweep is finally meaningful here.
#
# Scenario files named after a real skill expect that skill anywhere in the
# routing chain; any other name expects NOTHING to fire. `flow` files are lists,
# not scenarios — run those with run-flow.sh, which scores them as one resumed
# conversation.
#
# IMPORTANT: standalone and flow results are not interchangeable. `decay/` and
# `momentum/` scenarios are written to run INSIDE a resumed conversation; run
# alone they lack the context that makes them meaningful, and a miss there is not
# evidence of a routing failure. This sweep reports them separately for that
# reason.
#
# Costs one real API call per scenario. Manual/record tool, never CI.
#
# Usage:
#   run-all-activation.sh [--working-tree] [--skip-flow-members] [any run-activation.sh flag]

set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"

skip_members=""
passthru=()
for a in "$@"; do
  case "$a" in
    --skip-flow-members) skip_members="1";;
    *) passthru+=("$a");;
  esac
done

# Scenarios listed inside any `flow` file are flow members.
flow_members="$(cat "$scriptdir"/scenarios/*/flow 2>/dev/null | grep -vE '^\s*#|^\s*$' | sort -u)"
is_member() { printf '%s\n' "$flow_members" | grep -qx "$1"; }

fails=0; total=0; mfails=0; mtotal=0
while IFS= read -r scenario; do
  rel="${scenario#$scriptdir/}"
  name="$(basename "$scenario")"
  [ "$name" = "flow" ] && continue
  member=""; is_member "$name" && member="1"
  [ -n "$member" ] && [ -n "$skip_members" ] && continue

  printf '\n== %s%s ==\n' "$rel" "$([ -n "$member" ] && echo '  [flow member]')"
  if bash "$scriptdir/run-activation.sh" --scenario-file "$rel" ${passthru[@]+"${passthru[@]}"}; then
    rc=0
  else
    rc=1
  fi
  if [ -n "$member" ]; then
    mtotal=$((mtotal + 1)); [ "$rc" -ne 0 ] && mfails=$((mfails + 1))
  else
    total=$((total + 1)); [ "$rc" -ne 0 ] && fails=$((fails + 1))
  fi
done < <(find "$scriptdir/scenarios" -mindepth 2 -maxdepth 2 -type f | sort)

printf '\nstandalone   : %d/%d scenario(s) failed\n' "$fails" "$total"
if [ "$mtotal" -gt 0 ]; then
  printf 'flow members : %d/%d failed standalone — NOT a verdict; run run-flow.sh to score these\n' "$mfails" "$mtotal"
fi
# Only standalone scenarios gate the exit code.
[ "$fails" -eq 0 ]
