#!/usr/bin/env bash
# Invocation harness for augments skills.
#
# The triggering harness answers a different question than it looks like it
# does. It hands a subagent a catalogue and *commands* "pick the SINGLE skill
# whose trigger best fits" — a forced classification that PRESUMES the agent has
# already decided to reach for a skill. It measures discrimination (given that
# you route, do you route correctly?), never the decision to route AT ALL.
#
# In a real session the binding step is the one triggering skips: a working
# agent sees a terse "build me X", and the path of least resistance is to just
# start building. Whether the nudge makes it PAUSE and invoke a skill first is
# the thing that actually fails in the field — and the thing this harness
# measures. It puts a fresh subagent in a real opening: the SHIPPED nudge (read
# live from the adapter), the skills framed as available tools (not a menu to
# pick from), a realistic terse opening, and "proceed without a skill" offered
# as a co-equal outcome. Then it observes the FIRST move.
#
# Two arms isolate the nudge's lift — the RED baseline the triggering records
# admit they lack:
#   --nudge on   the shipped nudge is present (measured firing rate)
#   --nudge off  no nudge, skills merely available (bypass baseline)
#
# Like triggering-harness.sh this is the MECHANICAL half only: it does NOT call
# a model and is NOT a deterministic gate. The judgment comes from fresh
# subagents you dispatch; the result is directional, model- and run-dependent,
# and belongs in a dated record under tests/invocation/ — never a CI pass/fail.
# Same portability reason as triggering (tests/README.md, philosophy.md): a
# deterministic "did it fire" test would have to drive one specific harness.
#
# Usage:
#   bash tests/invocation-harness.sh prompt --scenario "TEXT" [--nudge on|off]
#   bash tests/invocation-harness.sh prompt --scenario-file FILE [--nudge off]
#   bash tests/invocation-harness.sh tally [FILE...]      # else reads stdin
#
# Typical loop:
#   1. prompt --scenario "<terse opening>" --nudge on  > /tmp/on.txt
#      prompt --scenario "<terse opening>" --nudge off > /tmp/off.txt
#   2. Dispatch each to several FRESH subagents (no shared context); collect
#      their FIRST: lines.
#   3. tally /tmp/on-replies.txt   and   tally /tmp/off-replies.txt
#   4. Write the dated readings into tests/invocation/<skill>.md, naming the
#      harness and model tier that judged them.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

NUDGE_FILE="hooks/claude-code/context.md"

build_catalogue() {
  local f name desc
  while IFS= read -r f; do
    name=$(awk -F': ' '/^name:/{print $2; exit}' "$f")
    desc=$(awk '/^description:/{sub(/^description: *"?/,""); sub(/"[[:space:]]*$/,""); print; exit}' "$f")
    [ -z "$name" ] && continue
    printf -- '- %s :: %s\n' "$name" "$desc"
  done < <(find skills -name SKILL.md | sort)
}

emit_prompt() {
  # $1: scenario text, $2: nudge on|off
  local scenario="$1" nudge_on="$2" nudge_block=""
  if [ "$nudge_on" = "on" ]; then
    [ -f "$NUDGE_FILE" ] || { echo "missing nudge file: $NUDGE_FILE" >&2; exit 2; }
    nudge_block="The project injected this context at session start:

--- BEGIN PROJECT CONTEXT ---
$(cat "$NUDGE_FILE")
--- END PROJECT CONTEXT ---
"
  fi
  cat <<EOF
You are the coding assistant for a project. The text below is your ENTIRE
starting context for this session — ignore any other ambient instructions.
${nudge_block}
Augments skills are installed in this project and available to you via a Skill
tool (you invoke one as augments:<name>). These are tools you MAY use, not a
menu you must choose from:

$(build_catalogue)

The user's first message is below. Respond as you genuinely would — take your
real opening move. Do not actually perform the work; keep it to a few lines.
Then, on the LAST line, label the move you just took, in EXACTLY this format:

FIRST: <invoke augments:NAME | proceed>
WHY: <one sentence — if you proceeded, the real reason you didn't reach for a skill>

Proceeding without a skill is a completely normal, common answer — choose what
you would actually do, not what you think is expected.

User message:
"$scenario"
EOF
}

tally() {
  local input first proceed invoke total
  if [ "$#" -gt 0 ]; then input=$(cat "$@"); else input=$(cat); fi
  # Bucket each FIRST: line into proceed vs invoke-<name>.
  local norm
  norm=$(printf '%s\n' "$input" \
    | grep -ioE 'FIRST:[[:space:]]*(invoke[[:space:]]+[A-Za-z0-9:_-]+|proceed)' \
    | sed -E 's/FIRST:[[:space:]]*//I; s/invoke[[:space:]]+/invoke /I; s/augments://I')
  if [ -z "$norm" ]; then echo "no FIRST: lines found" >&2; return 1; fi
  total=$(printf '%s\n' "$norm" | grep -c .)
  invoke=$(printf '%s\n' "$norm" | grep -ic '^invoke ')
  proceed=$(printf '%s\n' "$norm" | grep -ic '^proceed')
  echo "invocation tally ($total replies): invoked=$invoke proceeded=$proceed"
  echo "  by first move:"
  printf '%s\n' "$norm" | sed -E 's/^invoke /invoke:/; s/^proceed.*/proceed/' \
    | sort | uniq -c | sort -rn | awk '{printf "    %3d  %s\n", $1, $2}'
}

cmd="${1:-}"; shift 2>/dev/null || true
scenario=""; scenario_file=""; nudge="on"

parse_opts() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --scenario)      scenario="$2"; shift 2;;
      --scenario-file) scenario_file="$2"; shift 2;;
      --nudge)         nudge="$2"; shift 2;;
      *) echo "unknown argument: $1" >&2; exit 2;;
    esac
  done
}

case "$cmd" in
  prompt)
    parse_opts "$@"
    [ -n "$scenario_file" ] && scenario=$(cat "$scenario_file")
    [ -z "$scenario" ] && { echo "prompt needs --scenario or --scenario-file" >&2; exit 2; }
    [ "$nudge" = "on" ] || [ "$nudge" = "off" ] || { echo "--nudge must be on|off" >&2; exit 2; }
    emit_prompt "$scenario" "$nudge"
    ;;
  tally)
    tally "$@"
    ;;
  *)
    sed -n '2,45p' "$0"
    exit 2
    ;;
esac
