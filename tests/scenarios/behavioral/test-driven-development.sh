#!/usr/bin/env bash
# Behavioural scenario: test-driven-development.
#
# The failure this catches: code that ships with a test written AFTER it, which
# records what the code does instead of what it should do. That test passes on
# day one and never fails, so it is decoration.
#
# Asking the agent to *describe* TDD cannot catch it — a model recites red/green
# perfectly and still writes the implementation first. So the check is mechanical
# and hostile: take the implementation away and the test MUST go red. A test that
# still passes without the feature never tested the feature.

scenario_opening() {
  cat <<'EOF'
Add per-tenant request counting to this API: a `count(tenantId)` function in a
new `src/usage.js` that records one unit per accepted request and reports the
running total for a tenant. Wire it into `handle()` so every dispatched request
is counted.

Build it properly, and make sure the suite is green when you're done.
EOF
}

scenario_setup() { fixture_node_api "$1"; }

scenario_assert() {
  local d="$1" added new_tests impl out rc
  cd "$d" || return 2
  added="$(added_since_baseline "$d")"

  new_tests="$(printf '%s\n' "$added" | grep -E '\.(test|spec)\.[jt]s$|(^|/)test/' \
               | grep -v 'test/server\.test\.js' || true)"
  [ -n "$new_tests" ] && pass "wrote a test for the new behaviour ($(printf '%s' "$new_tests" | tr '\n' ' '))" \
                      || fail "wrote a test for the new behaviour — none added"

  impl="$(printf '%s\n' "$added" | grep -E '(^|/)src/.*\.[jt]s$' || true)"
  [ -n "$impl" ] && pass "wrote the implementation ($(printf '%s' "$impl" | tr '\n' ' '))" \
                 || fail "wrote the implementation — no new src file"

  # The suite must be green: TDD ends at green, not at red.
  out="$(npm test 2>&1)"; rc=$?
  if [ "$rc" -eq 0 ]; then
    pass "suite is green"
  elif printf '%s' "$out" | grep -qiE 'cannot find module|no test files found'; then
    fail "suite is green — it does not even load (project test command left broken)"
  else
    fail "suite is green — still failing at the end (exit $rc)"
  fi

  # THE REAL CHECK. Remove the implementation and the new test must go RED.
  # A test that survives its subject's removal is not testing it. This is the one
  # assertion a description-recall test can never make.
  if [ -n "$new_tests" ] && [ -n "$impl" ] && [ "$rc" -eq 0 ]; then
    local first_impl; first_impl="$(printf '%s' "$impl" | head -1)"
    cp "$first_impl" "$first_impl.bak"
    printf 'module.exports = {};\n' > "$first_impl"
    npm test >/dev/null 2>&1
    local without=$?
    mv "$first_impl.bak" "$first_impl"
    [ "$without" -ne 0 ] \
      && pass "the test actually exercises the feature (red without $first_impl)" \
      || fail "the test actually exercises the feature — it still passes with $first_impl gutted, so it tests nothing"
    # Restoring must put the suite back to green, or the check corrupted the run.
    npm test >/dev/null 2>&1 \
      && note "restored cleanly" \
      || fail "restore left the suite red — assertion damaged the workdir"
  fi

  assert_result
}
