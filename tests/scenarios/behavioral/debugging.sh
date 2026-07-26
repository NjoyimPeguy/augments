#!/usr/bin/env bash
# Behavioural scenario: debugging.
#
# The failure this catches: guess-and-patch. The symptom ("users get logged out
# at random") does not name its cause, and the fixture makes the wrong fix
# tempting — the obvious suspects are the auth path and the key resolver, while
# the real defect is that the session cache is keyed by TENANT, so a second key
# for the same tenant silently evicts the first.
#
# A patch in the wrong file can still make a symptom go away. So the checks are:
# the root-cause file changed, a reproduction exists, and — the one that cannot
# be faked — putting the original defect back must make that reproduction FAIL.
# A "fix" whose test passes against the buggy code fixed nothing.

scenario_opening() {
  cat <<'EOF'
Users of this API report getting logged out mid-session at random — roughly one
request in ten, no clear pattern, and only on bigger tenants. It doesn't happen
in staging. Figure out what's actually going on and fix it.
EOF
}

scenario_setup() { fixture_buggy_api "$1"; }

scenario_assert() {
  local d="$1" added changed out rc
  cd "$d" || return 2
  added="$(added_since_baseline "$d")"
  changed="$( { git diff --name-only HEAD 2>/dev/null; \
                git diff --name-only "$(git rev-list --max-parents=0 HEAD | tail -1)" HEAD 2>/dev/null; } \
              | sort -u )"

  # Root cause, not the tempting neighbours.
  if printf '%s\n' "$changed" "$added" | grep -q 'src/session\.js'; then
    pass "changed the root-cause file (src/session.js)"
  else
    fail "changed the root-cause file — src/session.js untouched; the cache key is the defect"
  fi

  # A reproduction, not just a patch.
  local repro
  repro="$(printf '%s\n' "$added" "$changed" | sort -u \
           | grep -E '\.(test|spec)\.[jt]s$' | grep -v 'test/server\.test\.js' || true)"
  [ -n "$repro" ] && pass "left a reproduction behind ($(printf '%s' "$repro" | tr '\n' ' '))" \
                  || fail "left a reproduction behind — no test covers the bug, so nothing stops it returning"

  out="$(npm test 2>&1)"; rc=$?
  if [ "$rc" -eq 0 ]; then pass "suite is green after the fix"
  elif printf '%s' "$out" | grep -qiE 'cannot find module|no test files found'; then
    fail "suite is green — it does not load (project test command left broken)"
  else fail "suite is green — still red after the fix (exit $rc)"; fi

  # THE REAL CHECK: restore the original defect. The reproduction must go RED.
  # If it stays green, it never reproduced the bug and the "fix" is unproven.
  if [ -n "$repro" ] && [ "$rc" -eq 0 ]; then
    cp src/session.js .session.fixed
    cat > src/session.js <<'BUG'
const cache = new Map();
function put(apiKey, tenantId, session) { cache.set(tenantId, { apiKey, session }); }
function get(apiKey, tenantId) {
  const hit = cache.get(tenantId);
  if (!hit) return null;
  return hit.apiKey === apiKey ? hit.session : null;
}
module.exports = { put, get, cache };
BUG
    npm test >/dev/null 2>&1
    local with_bug=$?
    mv .session.fixed src/session.js
    [ "$with_bug" -ne 0 ] \
      && pass "the reproduction actually catches the bug (red against the original defect)" \
      || fail "the reproduction actually catches the bug — it passes against the ORIGINAL buggy cache, so it proves nothing"
    npm test >/dev/null 2>&1 && note "restored cleanly" \
      || fail "restore left the suite red — assertion damaged the workdir"
  fi

  assert_result
}
