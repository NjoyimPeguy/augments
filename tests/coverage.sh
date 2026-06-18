#!/usr/bin/env bash
# Coverage check for triggering records — deterministic, file-inspection only.
#
# tests/README.md: every shipped skill owes a triggering record (does its
# description route the right opening?). This script does NOT judge routing —
# the judgment is a model-judged proxy that can only live in a dated record.
# It checks the one thing that IS deterministic: that the record FILE exists
# for every skill, and warns (heuristic) when a record shows no skip/negative
# scenario — a record should also prove the description STAYS QUIET on a
# trivial opening, not only that it fires.
#
# This is the deterministic half the model-judged corpus cannot cover. It is
# the check that would have caught requesting-code-review shipping with no
# record at all.
#
# Exit: non-zero if any skill lacks a triggering record (so it CAN become a
# gate). It is deliberately NOT wired into validate-skills.sh / CI yet — several
# skills still lack records; fold it into the gate once those are backfilled.
#
# Usage: bash tests/coverage.sh

set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

missing=()
no_skip=()
total=0
have=0

while IFS= read -r f; do
  name=$(awk -F': ' '/^name:/{print $2; exit}' "$f")
  [ -z "$name" ] && continue
  total=$((total + 1))
  rec="tests/triggering/${name}.md"
  if [ -f "$rec" ]; then
    have=$((have + 1))
    # Heuristic only: does the record exercise a negative/skip scenario at all?
    if ! grep -qiE 'does not route|stay (quiet|silent)|skip gate|\bNONE\b|trivial' "$rec"; then
      no_skip+=("$name")
    fi
  else
    missing+=("$name")
  fi
done < <(find skills -name SKILL.md | sort)

echo "coverage: triggering records"
echo "  ${total} skills · ${have} with a record · ${#missing[@]} missing"
echo

if [ "${#missing[@]}" -gt 0 ]; then
  echo "MISSING a triggering record (owed by every skill — tests/README.md):"
  printf '  - %s\n' "${missing[@]}"
  echo
fi

if [ "${#no_skip[@]}" -gt 0 ]; then
  echo "WARN (heuristic) record present but no visible skip/negative scenario:"
  printf '  - %s\n' "${no_skip[@]}"
  echo "  a record should prove the trigger STAYS QUIET on a trivial opening, not only that it fires"
  echo
fi

if [ "${#missing[@]}" -gt 0 ]; then
  echo "✗ ${#missing[@]} skill(s) missing a triggering record"
  exit 1
fi
echo "✓ every skill has a triggering record"
exit 0
