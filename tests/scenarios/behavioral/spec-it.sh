#!/usr/bin/env bash
# Behavioural scenario: spec-it.
#
# One file: the fixture, the opening, and the assertions. Sourced by any
# adapter's run-behavioral.sh, which supplies the harness plumbing.
#
# What this proves that an activation test cannot: `spec-it` says a behavioural
# requirement's acceptance criterion should take an EXECUTABLE form, and that
# what you name must actually be built and RUN. A test that asks the agent to
# *describe* spec-it would pass an agent that recites it perfectly and still
# ships a spec promising verification it never wrote. This runs the skill and
# reads the artifact.
#
# Contract for a scenario file — define these three:
#   scenario_opening        prints the prompt (optionally scenario_opening_<adapter>)
#   scenario_setup   $1=dir seeds the fixture
#   scenario_assert  $1=dir asserts on the finished workdir; exit code is the verdict

scenario_opening() {
  cat <<'EOF'
We're adding per-API-key rate limiting to this billing API. Plan tiers get
different limits (free/pro/enterprise), and clients need to be able to tell how
much budget they have left.

Before anyone designs or builds it, I want the requirements spec: what it must
do, and how each requirement gets verified. Write it up.
EOF
}

# `codex exec` is single-turn: an opening that invites a clarifying question ends
# the run with NO deliverable — the first Codex arm died exactly that way, after
# routing correctly. Pre-empt the interview. Used for BOTH Codex arms, so RED vs
# GREEN stays a controlled comparison within that harness.
scenario_opening_codex() {
  cat <<'EOF'
We're adding per-API-key rate limiting to this billing API. The limits are
settled product policy: free = 10 requests/minute, pro = 60/minute,
enterprise = 600/minute, each a fixed 60-second window per API key. Clients need
to be able to tell how much budget they have left.

Before anyone designs or builds it, I want the requirements spec: what it must
do, and how each requirement gets verified. Write it up.

This is a non-interactive run: do not ask me questions. Where something is
genuinely undetermined, record it as an assumption or open question in the spec
and carry on to a complete deliverable.
EOF
}

# A small real project: something to spec against, an existing test idiom to
# match, and a deliberately broken `npm test` — the skill says to confirm the
# criterion runs through the PROJECT's own command, so the fixture must have one
# that is wrong until fixed.
scenario_setup() {
  local d="$1"
  mkdir -p "$d/src" "$d/test"
  cat > "$d/package.json" <<'EOF'
{
  "name": "billing-api",
  "version": "0.3.0",
  "scripts": { "test": "node --test test/" }
}
EOF
  cat > "$d/src/server.js" <<'EOF'
const routes = new Map();

function route(method, path, handler) {
  routes.set(`${method} ${path}`, handler);
}

async function handle(req) {
  const handler = routes.get(`${req.method} ${req.path}`);
  if (!handler) return { status: 404, body: { error: 'not_found' } };
  return handler(req);
}

module.exports = { route, handle, routes };
EOF
  cat > "$d/src/apikeys.js" <<'EOF'
// API keys are resolved from the Authorization header. Each key belongs to a
// tenant and carries a plan tier: 'free' | 'pro' | 'enterprise'.
const keys = new Map();

function register(key, tenantId, tier) {
  keys.set(key, { tenantId, tier });
}

function resolve(authHeader) {
  if (!authHeader?.startsWith('Bearer ')) return null;
  return keys.get(authHeader.slice(7)) ?? null;
}

module.exports = { register, resolve, keys };
EOF
  cat > "$d/test/server.test.js" <<'EOF'
const { test } = require('node:test');
const assert = require('node:assert');
const { route, handle } = require('../src/server');

test('unknown route returns 404', async () => {
  const res = await handle({ method: 'GET', path: '/nope' });
  assert.strictEqual(res.status, 404);
});

test('registered route is dispatched', async () => {
  route('GET', '/ping', () => ({ status: 200, body: { ok: true } }));
  const res = await handle({ method: 'GET', path: '/ping' });
  assert.deepStrictEqual(res.body, { ok: true });
});
EOF
  cat > "$d/README.md" <<'EOF'
# billing-api

Minimal HTTP API for tenant billing. Routes are registered with `route()` and
dispatched by `handle()`. Tests run with `npm test` (node:test).
EOF
}

scenario_assert() {
  local d="$1" added new_tests out rc
  cd "$d" || return 2
  added="$(added_since_baseline "$d")"

  assert_file '.augments/specs/*.md' 'wrote a spec'
  local spec="$ASSERT_MATCH"

  new_tests="$(printf '%s\n' "$added" \
    | grep -E '(^|/)(test|tests|spec|__tests__)/|\.(test|spec)\.[jt]sx?$' \
    | grep -v 'test/server\.test\.js' || true)"
  if [ -n "$new_tests" ]; then
    pass "wrote an executable criterion ($(printf '%s' "$new_tests" | tr '\n' ' '))"
  else
    fail "wrote an executable criterion — prose only, no runnable artifact"
  fi

  # The criterion must be able to go RED, through the project's own command.
  # A suite that passes, errors on import, or sits `todo` is not a gate — each
  # of those was a real observed failure, not a hypothetical.
  if [ -n "$new_tests" ]; then
    out="$(npm test 2>&1)"; rc=$?
    if [ "$rc" -eq 0 ]; then
      fail "criterion can go red — suite passes; unbuilt behaviour must fail"
    elif printf '%s' "$out" | grep -qiE 'cannot find module|module_not_found|err_module|syntaxerror|no test files found'; then
      fail "criterion runs via \`npm test\` — suite does not load, and the project command was left broken"
    elif printf '%s' "$out" | grep -qiE 'assert|expected|fail'; then
      pass "criterion runs and fails on missing behaviour (exit $rc)"
    else
      fail "criterion runs — exit $rc with no recognisable assertion output"
    fi
  fi

  # The spec must get a reader from requirement to check in one hop. Assert the
  # LINK, not a phrasing: an earlier version grepped "Verified by:" and failed a
  # spec that pointed at the same file with different wording.
  if [ -n "$spec" ] && [ -n "$new_tests" ]; then
    local first_test; first_test="$(printf '%s' "$new_tests" | head -1)"
    assert_contains "$(cat "$spec")" "$(basename "$first_test")" \
      'spec names the artifact that verifies it'
  fi

  assert_result
}
