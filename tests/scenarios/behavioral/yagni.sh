#!/usr/bin/env bash
# Behavioural scenario: yagni.
#
# The failure this catches: an agent that reads "build the minimum" and writes
# minimal-but-cryptic code — single-letter names, no why-comment, style foreign
# to the file — or, overcorrecting the other way, gold-plates a two-tier
# discount into a rules engine. yagni holds BOTH: scope is minimised, craft
# and correctness never are.
#
# Asking the agent to *describe* that balance cannot catch it. So the checks are
# mechanical and hostile: a probe suite we inject proves the tiers actually work
# whatever shape the implementation took, greps prove the code is readable in
# the file's own idiom, and a dependency/file-count cap proves it stayed small.

scenario_opening() {
  cat <<'EOF'
Add volume discounting to the pricing module: orders of 100 units or more get
8% off the line total, orders of 500 units or more get 15% off. Apply the
discount inside `orderTotal()` in `src/pricing.js` — callers should not have to
know the tiers exist. Round to integer cents; we charge whole cents only.

Keep the suite green when you're done.
EOF
}

# A tiny pricing module with an established voice: descriptive camelCase names,
# integer cents, and a why-comment above every non-obvious rule. The agent's
# addition must read like the same author wrote it.
scenario_setup() {
  local d="$1"; mkdir -p "$d/src" "$d/test"
  cat > "$d/package.json" <<'EOF'
{ "name": "pricing-module", "version": "0.2.0", "scripts": { "test": "node --test" } }
EOF
  cat > "$d/src/pricing.js" <<'EOF'
// Unit prices are integer cents: multiplying by quantity stays exact,
// where floats would drift.
const catalogue = new Map([
  ['widget', 1999],
  ['gizmo', 4599],
]);

function unitPrice(item) {
  const price = catalogue.get(item);
  if (price === undefined) throw new Error(`unknown item: ${item}`);
  return price;
}

// Bulk orders ship in crates of ten; a partial crate still ships whole.
function cratesFor(quantity) {
  return Math.ceil(quantity / 10);
}

function orderTotal(item, quantity) {
  return unitPrice(item) * quantity;
}

module.exports = { unitPrice, cratesFor, orderTotal };
EOF
  cat > "$d/test/pricing.test.js" <<'EOF'
const { test } = require('node:test');
const assert = require('node:assert');
const { unitPrice, cratesFor, orderTotal } = require('../src/pricing');

test('unit price comes from the catalogue', () => {
  assert.strictEqual(unitPrice('widget'), 1999);
});
test('unknown items are rejected', () => {
  assert.throws(() => unitPrice('nope'));
});
test('crates round up to whole tens', () => {
  assert.strictEqual(cratesFor(11), 2);
});
test('total is unit price times quantity', () => {
  assert.strictEqual(orderTotal('widget', 3), 5997);
});
EOF
  cat > "$d/README.md" <<'EOF'
# pricing-module

Catalogue pricing in integer cents. Tests run with `npm test` (node:test).
EOF
}

scenario_assert() {
  local d="$1" probe_out
  cd "$d" || return 2
  local root; root="$(git rev-list --max-parents=0 HEAD 2>/dev/null | tail -1)"

  # --- Correctness: the tiers must actually work, whatever shape the code took.
  # THE REAL CHECK. We inject a probe suite the agent never saw; it cannot be
  # taught to, gamed, or satisfied by a stub that quiets the visible tests.
  cat > test/yagni-probe.test.js <<'EOF'
const { test } = require('node:test');
const assert = require('node:assert');
const { orderTotal } = require('../src/pricing');

test('below the first tier there is no discount', () => {
  assert.strictEqual(orderTotal('widget', 99), 1999 * 99);
});
test('100 units earns 8% off, in whole cents', () => {
  assert.strictEqual(orderTotal('widget', 100), Math.round(1999 * 100 * 0.92));
});
test('500 units earns 15% off, in whole cents', () => {
  assert.strictEqual(orderTotal('widget', 500), Math.round(1999 * 500 * 0.85));
});
test('tiers apply per order, not per item kind', () => {
  assert.strictEqual(orderTotal('gizmo', 100), Math.round(4599 * 100 * 0.92));
});
EOF
  probe_out="$(npm test 2>&1)"; local rc=$?
  rm -f test/yagni-probe.test.js
  if [ "$rc" -ne 0 ]; then
    if printf '%s' "$probe_out" | grep -qiE 'cannot find module|is not a function|SyntaxError'; then
      fail "discount tiers work — the module does not even load after the change"
    else
      fail "discount tiers work — probe suite red (wrong tier, rate, or rounding)"
    fi
  else
    pass "discount tiers work (injected probe suite green: 99/100/500 boundaries, both items)"
  fi

  # --- Craft: the addition must read like the file around it. The corpus is
  # what the agent ADDED only: diff-added lines for tracked files, full contents
  # for untracked ones. Catting modified files would pull the fixture's own
  # pre-existing comments into scope and make the comment check unfalsifiable.
  local untracked_src; untracked_src="$(git status --porcelain -uall -- src/ 2>/dev/null | awk '$1=="??"{print $2}')"
  local new_code; new_code="$( { git diff "$root" HEAD -- src/ 2>/dev/null | grep -E '^\+' | grep -v '^+++' || true; \
                                 for f in $untracked_src; do [ -f "$f" ] && cat "$f"; done; } )"
  if [ -z "${new_code// }" ]; then
    fail "touched the pricing code — no src change found at all"
  else
    pass "touched the pricing code"
    assert_not_contains "$new_code" '(const|let|var) [a-hk-z]( |,|=)' \
      "no single-letter variables in the new code"
    assert_not_contains "$new_code" '\(([a-z], *)+[a-z]\) *=>|\b[a-z] *=> ' \
      "no single-letter arrow parameters in the new code"
    assert_not_contains "$new_code" '\b[a-z]+_[a-z]' \
      "naming matches the file's camelCase idiom (no snake_case)"
    # A non-obvious business rule earns a why-comment: something in the added
    # lines explains, not just restates.
    if printf '%s\n' "$new_code" | grep -qE '//|/\*'; then
      pass "the non-obvious rule carries a comment"
    else
      fail "the non-obvious rule carries a comment — none anywhere in the new code"
    fi
  fi

  # --- Scope: minimal is still the discipline. No new dependency for a
  # two-tier discount, and no abstraction sprawl (factories, strategies,
  # config files) around one function's worth of logic.
  local new_deps; new_deps="$(git diff "$root" HEAD -- package.json 2>/dev/null | grep -E '^\+' | grep -E '"(dependencies|devDependencies)"|"[a-z@][^"]*": *"\^?[0-9]' || true)"
  [ -z "$new_deps" ] && pass "no new dependencies" \
                     || fail "no new dependencies — added: $(printf '%s' "$new_deps" | head -2 | tr '\n' ' ')"
  local added_count; added_count="$(added_since_baseline "$d" | grep -vc '^$')"
  [ "$added_count" -le 2 ] && pass "scope stayed minimal ($added_count file(s) added — implementation plus at most one test)" \
                           || fail "scope stayed minimal — $added_count files added for a two-tier discount"

  assert_result
}
