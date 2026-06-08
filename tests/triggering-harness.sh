#!/usr/bin/env bash
# Triggering harness for augments skills.
#
# Automates the MECHANICAL part of the model-judged triggering proxy: it builds
# the live `name :: description` catalogue from skill frontmatter, emits a
# ready-to-run routing prompt, and tallies routing verdicts.
#
# It deliberately does NOT call any model and is NOT a deterministic gate. The
# routing *judgment* comes from fresh subagents you dispatch in your own harness
# (each sees only the catalogue + one scenario, no skill bodies); the result is
# directional, model- and run-dependent, and belongs in a dated record under
# tests/triggering/ — never a CI pass/fail. See tests/README.md and
# docs/augments/philosophy.md for why this line can't be crossed portably.
#
# Usage:
#   bash tests/triggering-harness.sh catalogue [--exclude NAME]...
#   bash tests/triggering-harness.sh prompt (--scenario "TEXT" | --scenario-file FILE) [--exclude NAME]...
#   bash tests/triggering-harness.sh tally [FILE...]      # else reads stdin
#
# Typical loop when re-running a record:
#   1. bash tests/triggering-harness.sh prompt --scenario "<scenario from the record>" > /tmp/p.txt
#      (add --exclude <new-skill> to reproduce a RED baseline without it)
#   2. Dispatch /tmp/p.txt to several FRESH subagents; collect their `CHOICE:` lines.
#   3. bash tests/triggering-harness.sh tally /tmp/verdicts.txt
#   4. Write the dated tally into tests/triggering/<skill>.md.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

build_catalogue() {
  # $1: newline-delimited names to exclude (may be empty)
  local excl="$1" f name desc
  while IFS= read -r f; do
    name=$(awk -F': ' '/^name:/{print $2; exit}' "$f")
    desc=$(awk '/^description:/{sub(/^description: *"?/,""); sub(/"[[:space:]]*$/,""); print; exit}' "$f")
    [ -z "$name" ] && continue
    printf '%s\n' "$excl" | grep -qxF "$name" && continue
    printf -- '- %s :: %s\n' "$name" "$desc"
  done < <(find skills -name SKILL.md | sort)
}

emit_prompt() {
  # $1: scenario text, $2: newline-delimited excludes
  local scenario="$1" excl="$2"
  cat <<EOF
You are routing a user's opening message to exactly ONE engineering skill from a
catalogue. You see only each skill's name and its description (its trigger) — not
its contents. Read the message, pick the SINGLE skill whose trigger best fits the
user's FIRST action, and answer in EXACTLY this format, nothing else:

CHOICE: <skill-name or NONE>
WHY: <one sentence quoting the trigger language that matched>

Catalogue:
$(build_catalogue "$excl")

User message:
"$scenario"
EOF
}

tally() {
  local input
  if [ "$#" -gt 0 ]; then input=$(cat "$@"); else input=$(cat); fi
  local counts
  counts=$(printf '%s\n' "$input" | grep -ioE 'CHOICE:[[:space:]]*[A-Za-z0-9_-]+' \
            | sed -E 's/CHOICE:[[:space:]]*//I' | sort | uniq -c | sort -rn)
  if [ -z "$counts" ]; then echo "no CHOICE: lines found" >&2; return 1; fi
  local total; total=$(printf '%s\n' "$counts" | awk '{s+=$1} END{print s}')
  echo "routing tally ($total verdicts):"
  printf '%s\n' "$counts" | awk '{printf "  %3d  %s\n", $1, $2}'
}

cmd="${1:-}"; shift 2>/dev/null || true
excludes=""; scenario=""; scenario_file=""

parse_opts() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --exclude)       excludes=$(printf '%s\n%s' "$excludes" "$2"); shift 2;;
      --scenario)      scenario="$2"; shift 2;;
      --scenario-file) scenario_file="$2"; shift 2;;
      *) echo "unknown argument: $1" >&2; exit 2;;
    esac
  done
}

case "$cmd" in
  catalogue)
    parse_opts "$@"
    build_catalogue "$excludes"
    ;;
  prompt)
    parse_opts "$@"
    [ -n "$scenario_file" ] && scenario=$(cat "$scenario_file")
    [ -z "$scenario" ] && { echo "prompt needs --scenario or --scenario-file" >&2; exit 2; }
    emit_prompt "$scenario" "$excludes"
    ;;
  tally)
    tally "$@"
    ;;
  *)
    sed -n '2,33p' "$0"   # print the header/usage comment
    exit 2
    ;;
esac
