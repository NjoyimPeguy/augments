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
