#!/usr/bin/env bash
# Run every activation scenario for one harness. The filename is the contract, so
# no per-scenario config exists: a name matching a real skill expects that skill,
# any other name expects nothing.
#
# Flow scenarios are NOT included. tests/scenarios/flows/ holds multi-turn
# reproductions meant to run as one resumed conversation; a standalone miss there
# is not a verdict. Use run-flow.sh for those.
#
# Usage: tests/run-all-activation.sh --harness claude-code [--fixture-git-repo ...]
set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"
harness=""; passthru=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --harness) harness="$2"; shift 2;;
    *) passthru+=("$1"); shift;;
  esac
done
[ -n "$harness" ] || { echo "needs --harness claude-code|codex|kimi-code" >&2; exit 2; }

fails=0; total=0; failed=()
while IFS= read -r s; do
  rel="${s#"$scriptdir/scenarios/activation/"}"
  total=$((total + 1))
  printf '\n== %s ==\n' "$rel"
  if bash "$scriptdir/run-activation.sh" --harness "$harness" --scenario-file "$rel" \
       ${passthru[@]+"${passthru[@]}"}; then :; else fails=$((fails + 1)); failed+=("$rel"); fi
done < <(find "$scriptdir/scenarios/activation" -mindepth 2 -maxdepth 2 -type f | sort)

printf '\n%s: %d/%d scenario(s) failed\n' "$harness" "$fails" "$total"
[ "$fails" -gt 0 ] && printf '  %s\n' "${failed[@]}"
# Live, non-deterministic runs: a single failure is weak evidence. Re-run before
# concluding a skill regressed.
[ "$fails" -eq 0 ]
