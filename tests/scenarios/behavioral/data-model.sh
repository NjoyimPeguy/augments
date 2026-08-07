#!/usr/bin/env bash
# Behavioural scenario: data-model.
#
# One file: the fixture, the opening, and the assertions. Sourced by any
# adapter's run-behavioral.sh, which supplies the harness plumbing.
#
# What this proves that an activation test cannot: `data-model` says the domain
# gets modeled BEFORE the code that manipulates it — stored or not. The failure
# this guards is the stateless blind spot: an agent that treats "nothing is
# persisted" as "no model needed", skips straight past the concepts, transitions,
# and invariants, and leaves nothing a reviewer can check the code against. An
# activation test only shows the skill fired; this reads the artifact and asserts
# the model was actually written — lifecycle transitions and invariants included.
#
# Contract for a scenario file — define these three:
#   scenario_opening        prints the prompt (optionally scenario_opening_<adapter>)
#   scenario_setup   $1=dir seeds the fixture
#   scenario_assert  $1=dir asserts on the finished workdir; exit code is the verdict

scenario_opening() {
  cat <<'EOF'
We're adding the discount engine to our checkout service. The policy is settled:
a cart's final price applies member discounts, seasonal promotions, and volume
tiers; promotions either stack or are mutually exclusive according to their
type; a per-order cap bounds the total discount; and a promotion is draft, then
active, then expired — only active ones ever apply. Nothing is stored: the
engine computes over whatever the caller passes in.

Before any implementation, work out the domain this engine computes over and
write it down where the team can review it.
EOF
}

# `codex exec` is single-turn: an opening that leaves room for a clarifying
# question ends the run with NO deliverable. Pre-empt the interview. Used for
# BOTH Codex arms, so RED vs GREEN stays a controlled comparison there.
scenario_opening_codex() {
  scenario_opening
  cat <<'EOF'

This is a non-interactive run: do not ask me questions. Where something is
genuinely undetermined, record it as an assumption in the document and carry on
to a complete deliverable.
EOF
}

# A small real service to add the engine to — enough project for branch and
# design conventions to apply, with no database anywhere in sight.
scenario_setup() { fixture_node_api "$1"; }

scenario_assert() {
  local d="$1" doc body
  cd "$d" || return 2

  # The skill's own deliverable: the shared design document, not an inline
  # answer that scrolls away.
  assert_file '.sdlc-skills/designs/*.md' 'wrote the shared design document'
  doc="$ASSERT_MATCH"
  [ -n "$doc" ] || { assert_result; return; }
  body="$(cat "$doc")"

  # Concepts named in the domain's language — a model of this engine that never
  # says "promotion" or "cart" is not a model of this domain.
  assert_contains "$body" 'promotion' 'names the domain concepts (promotion)'
  assert_contains "$body" '\b(cart|order)s?\b' 'names the domain concepts (cart/order)'

  # The lifecycle made it in whole: all three states the opening dictated —
  # and modeled AS a lifecycle, in words the opening never used. An echo of
  # the prompt passes state-name greps; only a model names the transitions.
  assert_contains "$body" '\bdraft\b' 'captures the lifecycle (draft)'
  assert_contains "$body" '\bactive\b' 'captures the lifecycle (active)'
  assert_contains "$body" '\bexpired?\b' 'captures the lifecycle (expired)'
  assert_contains "$body" 'transition|lifecycle|state machine' \
    'models the states as transitions, not an echo of the prompt'

  # Invariants written as rules that must hold — the section constraints and
  # tests get derived from.
  assert_contains "$body" 'invariant|must always|never ' \
    'states invariants as rules that must hold'

  # Stacking vs exclusivity is the heart of this domain; a model that drops it
  # answered an easier question.
  assert_contains "$body" 'stack|exclusiv' \
    'models stacking vs exclusivity of promotions'

  assert_result
}
