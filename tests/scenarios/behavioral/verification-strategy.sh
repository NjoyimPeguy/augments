#!/usr/bin/env bash
# Behavioural scenario: verification-strategy.
#
# The failure this catches: an agent that can *describe* a verification battery
# perfectly and still walks away leaving a project whose tests cannot fail — no
# acceptance layer over real behaviour, no floor that bites, a suite that is
# decoration. Asking it to describe the battery proves nothing.
#
# So every assertion executes the artifact: the battery must exist, must load,
# and — the checks a description can never fake — must GO RED when real
# behaviour is gutted, and must REFUSE to stay green when the acceptance layer
# is taken away.

scenario_opening() {
  cat <<'EOF'
This tiny billing API will soon be extended by coding agents, and nobody will
read every line they write. Before any feature work starts, make it so we can
trust their changes without reading them: a single project command that proves
the existing behaviour still works — routing, the 404 path, and API-key
resolution — and that keeps proving it as the codebase grows. I don't want to
discover six months from now that the tests can't actually fail. Leave
everything green when you're done.
EOF
}

scenario_setup() { fixture_node_api "$1"; }

scenario_assert() {
  local d="$1" added new_tests out rc
  cd "$d" || return 2
  added="$(added_since_baseline "$d")"

  # 1. An acceptance layer exists — new test files beyond the fixture's own.
  new_tests="$(printf '%s\n' "$added" | grep -E '\.(test|spec)\.[jt]s$|(^|/)test/' \
               | grep -v 'test/server\.test\.js' || true)"
  [ -n "$new_tests" ] && pass "acceptance layer added ($(printf '%s' "$new_tests" | tr '\n' ' '))" \
                      || fail "acceptance layer added — no new test files"

  # 2. The battery loads and is green via the project's own command. (The
  #    fixture's `npm test` is deliberately broken; leaving it broken fails here.)
  out="$(npm test 2>&1)"; rc=$?
  if [ "$rc" -eq 0 ]; then
    pass "battery runs green via the project's own command"
  elif printf '%s' "$out" | grep -qiE 'cannot find module|no test files found'; then
    fail "battery runs green — the project's test command does not even load"
  else
    fail "battery runs green — suite red at the end (exit $rc)"
  fi

  # 3. THE REAL CHECK. Gut API-key resolution and the battery MUST go red.
  #    A suite that stays green while the behaviour is broken is decoration.
  #    Guard: an agent that renamed the fixture module skips the gut (note, not
  #    fail) — a missing file must not become a spurious verdict.
  if [ "$rc" -eq 0 ] && [ -f src/apikeys.js ]; then
    cp src/apikeys.js src/apikeys.js.bak
    printf 'module.exports = { register() {}, resolve() { return null; }, keys: new Map() };\n' > src/apikeys.js
    npm test >/dev/null 2>&1
    local gut=$?
    mv src/apikeys.js.bak src/apikeys.js
    [ "$gut" -ne 0 ] \
      && pass "the battery catches broken behaviour (red with resolve() gutted)" \
      || fail "the battery catches broken behaviour — still green with resolve() gutted, so it tests nothing"
    npm test >/dev/null 2>&1 \
      && note "restored cleanly" \
      || fail "restore left the suite red — assertion damaged the workdir"
  elif [ "$rc" -eq 0 ]; then
    note "gut check skipped — src/apikeys.js renamed or removed by the agent"
  fi

  # 4. The battery refuses to lose a layer silently. Move each new test file
  #    aside ONE AT A TIME: at least one removal alone must break the gate —
  #    otherwise every test matters only to itself and nothing notices when
  #    protection walks out the door. (All-at-once removal would prove nothing:
  #    the floor may itself live in a test file and leave with the others.)
  if [ -n "$new_tests" ] && [ "$rc" -eq 0 ]; then
    local f bit="" one out4
    while IFS= read -r f; do
      [ -n "$f" ] || continue
      mv "$f" "$f.bak"
      out4="$(npm test 2>&1)"; one=$?
      mv "$f.bak" "$f"
      # Red counts only when the surviving suite failed — not when a survivor
      # merely imports the removed file (that is coupling, not a floor).
      if [ "$one" -ne 0 ] && ! printf '%s' "$out4" | grep -qE "Cannot find module|ERR_MODULE_NOT_FOUND"; then
        bit="$f"; break
      fi
    done <<< "$new_tests"
    [ -n "$bit" ] \
      && pass "the floor bites (removing $bit alone breaks the gate)" \
      || fail "the floor bites — every new test file could be removed alone without breaking the gate; the floor is written down, not enforced"
    npm test >/dev/null 2>&1 \
      && note "restored cleanly" \
      || fail "restore left the suite red — assertion damaged the workdir"
  fi

  assert_result
}
