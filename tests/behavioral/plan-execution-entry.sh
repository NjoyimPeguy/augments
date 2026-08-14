#!/usr/bin/env bash
# Multi-turn regression for the design → plan → mode → implementation boundary.
# The ordering verdict comes from structured actions, never assistant prose.

scenario_opening() {
  cat <<'EOF'
Add a maintenance-status banner to this small web service. Start with UI/UX
design and do not implement yet.

The settled requirements are: three states (operational, warning, outage), a
short operator-provided message, accessible status semantics, useful output
without color, and no external UI dependency. The work will cover the page
renderer, the HTTP route, and automated tests. Present the complete design for
my approval when it is ready; there are no missing product decisions.
EOF
}

scenario_followups() {
  followups=(
    "I approve the exact UI/UX design version you just presented. Write the executable multi-task plan and present that exact plan version for approval. Do not implement it yet."
    "I approve the exact plan version you just presented."
    "Inline. Stop immediately after the first source or test code edit is recorded; do not complete the task."
  )
}

scenario_setup() {
  local d="$1"
  fixture_node_api "$d"
  # This scenario must reach implementation entry. The shared fixture's broken
  # directory-form test command is intentional for verification scenarios, but
  # would stop this one at its baseline gate before TDD/YAGNI can be observed.
  sed -i 's#node --test test/#node --test#' "$d/package.json"
  cat > "$d/src/page.js" <<'EOF'
function renderPage() {
  return '<main><h1>Billing</h1></main>';
}
module.exports = { renderPage };
EOF
  cat > "$d/test/page.test.js" <<'EOF'
const { test } = require('node:test');
const assert = require('node:assert');
const { renderPage } = require('../src/page');
test('renders the billing heading', () => {
  assert.match(renderPage(), /Billing/);
});
EOF
}

scenario_assert() {
  local d="$1"
  cd "$d" || return 2
  [ -s "${stream:-}" ] || { echo "no event stream to judge — inconclusive"; return 2; }

  local events first_edit before fails=0
  events="$(adapter_behavioral_events "$stream")"

  first_edit="$(printf '%s\n' "$events" | grep -n '^EDIT ' |
    grep -iE '\.(js|jsx|ts|tsx|mjs|cjs|py|go|rs|java|kt|rb|php|c|cc|cpp|h|hpp|cs|swift|sh|bash|sql|lua|pl|ex|exs|erl|hs|scala|clj|dart|vue|svelte|ps1|bat|cmd|r|jl|groovy|m|mm|zig)$' |
    head -1 | cut -d: -f1)"
  if [ -z "$first_edit" ]; then
    echo "no structured code edit happened — cannot judge the boundary"
    printf '%s\n' "$events" | sed 's/^/  /'
    return 2
  fi
  before="$(printf '%s\n' "$events" | head -n "$((first_edit - 1))")"

  require_before() { # skill
    local skill="$1"
    if printf '%s\n' "$before" | grep -q "^SKILL .*$skill$"; then
      echo "ok    $skill led the first code edit"
    else
      echo "FAIL  $skill did not lead the first code edit"
      fails=1
    fi
  }
  for skill in ui-ux-design writing-plans executing-plans test-driven-development yagni; do
    require_before "$skill"
  done

  local design_n plan_n executor_n after_executor
  design_n="$(printf '%s\n' "$before" | grep -n '^SKILL .*ui-ux-design$' | head -1 | cut -d: -f1)"
  plan_n="$(printf '%s\n' "$before" | grep -n '^SKILL .*writing-plans$' | head -1 | cut -d: -f1)"
  executor_n="$(printf '%s\n' "$before" | grep -n '^SKILL .*executing-plans$' | head -1 | cut -d: -f1)"
  after_executor=""
  [ -n "$executor_n" ] &&
    after_executor="$(printf '%s\n' "$before" | tail -n "+$((executor_n + 1))")"

  if [ -n "$design_n" ] && [ -n "$plan_n" ] && [ -n "$executor_n" ] &&
     [ "$design_n" -lt "$plan_n" ] && [ "$plan_n" -lt "$executor_n" ] &&
     printf '%s\n' "$after_executor" | grep -q '^SKILL .*test-driven-development$' &&
     printf '%s\n' "$after_executor" | grep -q '^SKILL .*yagni$'; then
    echo "ok    UI/UX → plan → executor → TDD/YAGNI ordering held"
  else
    echo "FAIL  required skill ordering did not hold"
    fails=1
  fi

  echo "full event order:"
  printf '%s\n' "$events" | sed 's/^/  /'
  return "$fails"
}
