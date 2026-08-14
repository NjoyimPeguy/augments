#!/usr/bin/env bash
# Offline contract for the approved-plan → executor → implementation boundary.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

case "${1-}" in
  -h|--help)
    cat <<'EOF'
tests/run-plan-execution-contract.sh — validate plan-to-implementation routing.

Takes no arguments. Checks the plan assets, planner handoff, executor triggers,
and explicit implementation-discipline ordering without calling a model.

Exit codes: 0 every check passed · 1 at least one failed · 2 bad repository state
EOF
    exit 0;;
esac

fails=0
check() { # description file extended-regexp
  local description="$1" file="$2" expression="$3"
  if tr '\n' ' ' < "$file" | grep -Eqi "$expression"; then
    echo "  ok    $description"
  else
    echo "  FAIL  $description ($file)"
    fails=1
  fi
}

index=skills/design/writing-plans/assets/index-template.md
task=skills/design/writing-plans/assets/task-template.md
planner=skills/design/writing-plans/SKILL.md
executor=skills/implementation/executing-plans/SKILL.md

check "plan index names the required executor" "$index" \
  'Required executor.*executing-plans'
check "plan index renders every task as a checkbox" "$index" \
  '## Tasks.*- \[ \] `T-001`.*`todo`.*- \[ \] `T-002`.*`todo`.*- \[ \] `T-003`.*`todo`'
check "all ledger states have an honest checklist projection" "$index" \
  '\[x\] done.*\[x\] done with concerns.*\[ \] done with concerns.*\[ \] todo.*\[ \] in progress.*\[ \] blocked.*\[ \] needs context.*\[ \] cancelled.*\[ \] superseded'
check "checkbox progress cannot alter the approved plan version" "$index" \
  'checkbox marker and status normalized to.*\[ \].*todo.*external ledger wins'
check "plan index marks TDD and YAGNI before implementation" "$index" \
  'test-driven-development.*yagni.*before.*first project command or code'
check "task template carries implementation disciplines" "$task" \
  'Implementation disciplines.*test-driven-development.*yagni'
check "mode reply invokes the executor before workspace action" "$planner" \
  'mode answer.*Immediately invoke.*executing-plans.*before any workspace'
check "executor recognizes terse post-approval replies" "$executor" \
  'inline.*delegated.*option 1.*option 2'
check "executor invokes both disciplines before the first change" "$executor" \
  'behavior-affecting task.*invoke.*test-driven-development.*yagni.*before[[:space:]]+the first project command or code edit'

[ "$fails" -eq 0 ] && { echo "plan execution contract: PASS"; exit 0; }
echo "plan execution contract: FAIL"
exit 1
