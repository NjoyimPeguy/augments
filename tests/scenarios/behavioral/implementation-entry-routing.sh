#!/usr/bin/env bash
# Behavioural scenario: does routing hold at the IMPLEMENTATION ENTRY boundary
# without a pre-edit hook?
#
# Scope, so the name does not overclaim: this judges exactly one boundary — the
# moment code is first written. It does not judge the done boundary or the
# integration boundary. Those need a fixture that actually reaches them; this
# one is a bug report with no ship intent, so a correct agent never gets there.
# Everything else the run does is PRINTED for reading, never gated.
#
# The failure it guards was observed, not imagined: in a real session on this
# repository the agent read a task, skipped routing entirely, and went straight
# to editing. A PreToolUse hook caught it — real enforcement, but it existed
# because the session-start injection was a ~90-token POINTER asking for a
# discretionary tool call, and a discretionary call gets skipped.
#
# The change under test replaces that pointer with the router's full body as
# resident context. If routing is resident rather than requested, the pair
# should lead implementation with no hook holding the boundary.
#
# The verdict is ORDERING, read from the event stream, not from prose: both
# `test-driven-development` and `yagni` must appear as Skill invocations BEFORE
# the first Write/Edit on a code path. An agent that says it will use TDD and
# then edits first fails here, which is the whole point.
#
# It is non-deterministic and known to be so: measured 2 PASS / 1 FAIL over
# three consecutive green runs. Read a single run as one observation, never as
# the property.

scenario_opening() {
  cat <<'EOF'
Users on our bigger accounts keep getting logged out at random. It only shows up
on tenants where people hold more than one API key at a time, and it clears if
they sign in again. Nobody has been able to pin it down.

Fix it.
EOF
}

# Single-turn harnesses end the run at the first clarifying question, which
# scores as "produced nothing" rather than as a routing result.
scenario_opening_codex() {
  scenario_opening
  cat <<'EOF'

This is a non-interactive run: do not ask me questions. Where something is
genuinely undetermined, record the assumption and carry on to a complete change.
EOF
}

scenario_setup() { fixture_buggy_api "$1"; }

scenario_assert() {
  local d="$1" first_edit pair_ok=0
  cd "$d" || return 2

  # $stream is the run-behavioral.sh event log. Ordering needs the raw sequence,
  # so this reads it directly rather than using the deduped chain in the report.
  if [ ! -s "${stream:-}" ]; then
    echo "  no event stream to judge — inconclusive"
    return 2
  fi

  # One ordered line per relevant event: "SKILL <name>" or "EDIT <path>".
  local events
  events="$(jq -r 'select(.type=="assistant") | .message.content[]?
      | select(.type=="tool_use")
      | if   .name=="Skill" then "SKILL " + (.input.skill // "")
        elif (.name=="Write" or .name=="Edit" or .name=="MultiEdit")
        then "EDIT " + (.input.file_path // .input.path // "")
        else empty end' "$stream" 2>/dev/null)"

  # The first code edit is the boundary the pair has to lead. Non-code writes
  # (notes, plans, docs) are not implementation and do not close the window —
  # the same rule the retired guard applied.
  first_edit="$(printf '%s\n' "$events" | grep -n '^EDIT ' \
    | grep -iE '\.(js|jsx|ts|tsx|mjs|cjs|py|go|rs|java|kt|rb|php|c|cc|cpp|h|hpp|cs|swift|sh|bash|sql|lua|pl|ex|exs|erl|hs|scala|clj|dart|vue|svelte|ps1|bat|cmd|r|jl|groovy|m|mm|zig)$' \
    | head -1 | cut -d: -f1)"

  if [ -z "$first_edit" ]; then
    echo "  no code edit happened — cannot judge the implementation boundary"
    echo "  events seen:"; printf '%s\n' "$events" | sed 's/^/    /'
    return 2
  fi

  local before
  before="$(printf '%s\n' "$events" | head -n "$((first_edit - 1))")"
  echo "  first code edit at event #$first_edit; $(printf '%s\n' "$before" | grep -c '^SKILL ') skill(s) fired before it"

  local s
  for s in test-driven-development yagni; do
    if printf '%s\n' "$before" | grep -q "^SKILL .*$s\$"; then
      echo "  ok    $s led the first code edit"
    else
      echo "  FAIL  $s did NOT fire before the first code edit"
      pair_ok=1
    fi
  done

  # Routing itself: with the body resident the agent should NOT need to spend a
  # call re-invoking the router. Reported, never failed — either way is correct.
  if printf '%s\n' "$events" | grep -q '^SKILL .*using-sdlc-skills$'; then
    echo "  note  re-invoked using-sdlc-skills (resident body was not enough to skip the call)"
  else
    echo "  note  did not re-invoke using-sdlc-skills (resident body was sufficient)"
  fi

  echo "  full event order:"; printf '%s\n' "$events" | sed 's/^/    /'
  return "$pair_ok"
}
