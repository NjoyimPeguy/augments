#!/usr/bin/env bash
# Run every Codex CLI activation scenario with its filename as the expected skill.

set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"

fails=0
total=0

while IFS= read -r scenario; do
  rel="${scenario#$scriptdir/../scenarios/activation/}"
  name="$(basename "$scenario")"
  total=$((total + 1))
  printf '\n== %s ==\n' "$rel"
  if bash "$scriptdir/run-activation.sh" --scenario-file "$rel" --expect "$name"; then
    :
  else
    fails=$((fails + 1))
  fi
done < <(find "$scriptdir/../scenarios/activation" -mindepth 2 -maxdepth 2 -type f | sort)

printf '\nresult: %d/%d scenario(s) failed\n' "$fails" "$total"
[ "$fails" -eq 0 ]
