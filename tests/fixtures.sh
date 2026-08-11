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

# The paths activation queries NAME, and nothing more. Separate from the two
# fixtures above on purpose: a behavioural arm reads the code it is given, so
# padding it costs every run: an activation probe only has to find that the path
# it names is really there.
#
# Why it has to exist at all is the same reason the bare workdir does not work.
# A query is only realistic if its subject is: "redesign src/legacy/" against a
# tree with no src/legacy/ gets the correct answer that there is no such
# directory, and the run routes nowhere. That scores as a trigger miss with
# nothing wrong with the description — the failure this file exists to prevent,
# one level down. Presupposing verbs are the trap; "add src/utils/money.ts"
# reads fine either way, "refactor" and "execute" do not.
#
# So these are stubs, not implementations: enough that the named thing is real,
# never enough to be worth reading. Add one here when a query names a new path.
#
# A query can name an area in prose rather than by path — "the payments area",
# "the reporting service" — and that binds just as hard when the verb
# presupposes it. Nothing checks either half now: a path a query names may
# simply not exist here, and matching area nouns in natural language
# false-positives too badly to be worth automating at all. Both stay a review
# question, and the prose half was always the harder one. Ask it
# where the SKILL ITSELF has to read existing code — zoom-out orienting in an
# area, refactor-architecture grounding a proposal in the current structure. A
# query that only DESIGNS something ("model the entities for the permissions
# system") presupposes nothing and needs no fixture.
fixture_activation_paths() {
  local d="$1"
  mkdir -p "$d"/src/{scheduler,legacy,billing,api,orders,sync,import,auth,queue,utils,config} \
           "$d"/docs/{design,product,plans/search-rewrite}

  # Coherent with billing-api: tenants on plan tiers, billed on a schedule.
  echo 'module.exports = { run: (job) => job.handler(); };'                   > "$d/src/scheduler/index.js"
  echo 'module.exports = { legacyInvoice: (t) => ({ tenant: t, lines: [] }) };' > "$d/src/legacy/invoice.js"
  echo 'module.exports = { chargeTenant: (t, cents) => ({ t, cents }) };'     > "$d/src/billing/charge.js"
  echo 'module.exports = { mount: (app) => app };'                            > "$d/src/api/index.js"
  echo 'export const Summary = ({ order }) => order.id;'                      > "$d/src/orders/summary.tsx"
  echo 'module.exports = { pull: async () => [] };'                           > "$d/src/sync/pull.js"
  echo 'module.exports = { importCsv: async (rows) => rows.length };'         > "$d/src/import/csv.js"
  echo 'export const session = { userId: null };'                             > "$d/src/auth/session.ts"
  echo 'module.exports = { consume: async (msg) => msg };'                    > "$d/src/queue/consumer.js"
  echo 'export const cents = (n: number) => Math.round(n * 100);'             > "$d/src/utils/money.ts"
  echo 'export const poolSize = 10;'                                          > "$d/src/config/database.ts"
  echo 'export { poolSize } from "./database";'                               > "$d/src/config/index.ts"

  printf '# Notifications design\n\nEmail and webhook delivery for billing events.\n' \
    > "$d/docs/design/notifications.md"
  printf '# Product goals\n\nTenants can self-serve billing without support.\n' \
    > "$d/docs/product/goals.md"
  printf '# Invites\n\nTenant admins invite teammates by email.\n' \
    > "$d/docs/invites.md"

  # executing-plans needs a plan DIRECTORY, not a file: its procedure verifies a
  # claimed approval, a version, and an entry state before running anything, so
  # the stub carries those fields rather than asserting they passed.
  printf '# Search rewrite\n\nApproval: pending\nVersion: 1\nMode: sequential\n\n- [ ] 01 index schema\n- [ ] 02 query path\n' \
    > "$d/docs/plans/search-rewrite/index.md"

  # writing-plans writes plans to `.sdlc-skills/plans/`, so queries that name a
  # plan by its real convention land here rather than under docs/. They are
  # separate directories because the queries are: "continue billing-v2", "start
  # multi-tenancy", and "reporting is approved" are three different openings, and
  # collapsing them onto one path would make them duplicates of each other.
  mkdir -p "$d"/.sdlc-skills/plans/{multi-tenancy,billing-v2,reporting}
  printf '# Multi-tenancy\n\nApproval: pending\nVersion: 1\nMode: sequential\n\n- [ ] 01 tenant column\n- [ ] 02 row filters\n' \
    > "$d/.sdlc-skills/plans/multi-tenancy/index.md"
  printf '# Billing v2\n\nApproval: pending\nVersion: 2\nMode: sequential\n\n- [x] 01 price table\n- [ ] 02 proration\n' \
    > "$d/.sdlc-skills/plans/billing-v2/index.md"
  printf '# Reporting\n\nApproval: pending\nVersion: 1\nMode: sequential\n\n- [ ] 01 rollup job\n- [ ] 02 export\n' \
    > "$d/.sdlc-skills/plans/reporting/index.md"
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
