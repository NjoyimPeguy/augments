#!/usr/bin/env bash
# Reusable project fixtures for behavioural scenarios. Sourced, never executed.
#
# A scenario needs a project that makes its skill's failure mode POSSIBLE. Most
# skills need one of a few shapes, so they live here instead of being re-typed in
# every scenario.
#
# Each is small on purpose: an agent that must read 2,000 lines before it can act
# spends the run reading. These give it enough to be wrong in an interesting way,
# and nothing more.

# A tiny HTTP API with a real test suite and a DELIBERATELY BROKEN `npm test`
# (`node --test test/` treats the dir as a module path on modern Node). A skill
# that claims something is verified has to notice its gate does not run.
fixture_node_api() {
  local d="$1"; mkdir -p "$d/src" "$d/test"
  cat > "$d/package.json" <<'EOF'
{ "name": "billing-api", "version": "0.3.0", "scripts": { "test": "node --test test/" } }
EOF
  cat > "$d/src/server.js" <<'EOF'
const routes = new Map();
function route(method, path, handler) { routes.set(`${method} ${path}`, handler); }
async function handle(req) {
  const handler = routes.get(`${req.method} ${req.path}`);
  if (!handler) return { status: 404, body: { error: 'not_found' } };
  return handler(req);
}
module.exports = { route, handle, routes };
EOF
  cat > "$d/src/apikeys.js" <<'EOF'
// Each API key belongs to a tenant and carries a plan tier:
// 'free' | 'pro' | 'enterprise'.
const keys = new Map();
function register(key, tenantId, tier) { keys.set(key, { tenantId, tier }); }
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
  assert.strictEqual((await handle({ method: 'GET', path: '/nope' })).status, 404);
});
test('registered route is dispatched', async () => {
  route('GET', '/ping', () => ({ status: 200, body: { ok: true } }));
  assert.deepStrictEqual((await handle({ method: 'GET', path: '/ping' })).body, { ok: true });
});
EOF
  cat > "$d/README.md" <<'EOF'
# billing-api

Minimal HTTP API for tenant billing. Routes are registered with `route()` and
dispatched by `handle()`. Tests run with `npm test` (node:test).
EOF
}

# The same API plus a REAL bug with a non-obvious cause: the session cache is
# keyed by tenant, not by key, so a second key for one tenant evicts the first.
# The symptom ("random logouts") does not name the cause, so a guess-and-patch
# lands in the wrong file and still makes the symptom go away.
fixture_buggy_api() {
  local d="$1"; fixture_node_api "$d"
  cat > "$d/src/session.js" <<'EOF'
// Sessions are cached to avoid re-resolving the key on every request.
const cache = new Map();

function put(apiKey, tenantId, session) {
  cache.set(tenantId, { apiKey, session });
}

function get(apiKey, tenantId) {
  const hit = cache.get(tenantId);
  if (!hit) return null;
  return hit.apiKey === apiKey ? hit.session : null;
}

module.exports = { put, get, cache };
EOF
  cat > "$d/test/session.test.js" <<'EOF'
const { test } = require('node:test');
const assert = require('node:assert');
const { put, get } = require('../src/session');
test('a stored session is returned', () => {
  put('k1', 't1', { user: 'a' });
  assert.deepStrictEqual(get('k1', 't1'), { user: 'a' });
});
EOF
}
