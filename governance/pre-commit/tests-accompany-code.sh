#!/usr/bin/env bash
# Local shift-left of the tests-accompany-code gate, over STAGED files.
# Best-effort: `git commit --no-verify` bypasses it — the CI workflow is the real gate.
set -euo pipefail
TEST_RE='(^|/)(tests?|__tests__|spec)/|[._-](test|spec)\.|_test\.(go|py)$|\.test\.|\.spec\.'
IMPL_RE='\.(js|ts|jsx|tsx|py|go|rb|java|rs|php|c|cc|cpp|cs|kt|swift)$'

staged=$(git diff --cached --name-only)
impl=$(echo "$staged" | grep -E "$IMPL_RE" | grep -vE "$TEST_RE" || true)
tests=$(echo "$staged" | grep -E "$TEST_RE" || true)

if [ -n "$impl" ] && [ -z "$tests" ]; then
  echo "augments governance: implementation staged with no test change:"
  echo "$impl" | sed 's/^/  /'
  echo "Write the test (augments:test-driven-development), or stage it with the code."
  exit 1
fi
exit 0
