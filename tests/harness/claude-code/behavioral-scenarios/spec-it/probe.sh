#!/usr/bin/env bash
# Verdict for the spec-it behavioural scenario. $1 = finished workdir.
#
# What is being tested: `spec-it` step 5/6 say a behavioural requirement's
# acceptance criterion should take an EXECUTABLE form where one is cheapest, and
# that what you name must actually be built and run. The failure this catches is
# a spec that *reads* verified — criteria labelled "executable acceptance test",
# forms named, a rubric cited — while shipping no artifact that can run. Prose in
# a record cannot distinguish those two outcomes; this exit code can.
#
# Checks, in order of what they prove:
#   1. a spec file exists at all
#   2. a NEW executable test artifact exists (not just the fixture's own suite)
#   3. that artifact RUNS and fails because behaviour is missing — not because it
#      failed to load. A suite that errors on import is not a criterion.
#   4. the spec points at it, so a reader gets requirement -> check in one hop
#
# Check 3 matters most: "wrote a file that doesn't load" is the easiest way to
# fake this and the hardest to see in a transcript.
set -uo pipefail
work="${1:?usage: probe.sh <workdir>}"
cd "$work" || exit 2
fail=0
note() { printf '%s\n' "$*"; }

# 1 — a spec exists
spec="$(find .augments/specs -name '*.md' -type f 2>/dev/null | head -1)"
if [ -n "$spec" ]; then
  note "spec              : $spec ($(wc -l < "$spec" | tr -d ' ') lines)"
else
  note "spec              : MISSING — no .augments/specs/*.md"; fail=1
fi

# 2 — a NEW executable artifact, not the fixture's pre-existing suite
new_tests="$(git status --porcelain -uall 2>/dev/null | awk '$1=="??"{print $2}' \
             | grep -E '(^|/)(test|tests|spec|__tests__)/|\.(test|spec)\.[jt]sx?$' || true)"
if [ -n "$new_tests" ]; then
  note "executable spec   : $(printf '%s' "$new_tests" | tr '\n' ' ')"
else
  note "executable spec   : NONE — no new test artifact was written"; fail=1
fi

# 3 — it runs, and fails for the RIGHT reason
if [ -n "$new_tests" ]; then
  out="$(npm test 2>&1)"; rc=$?
  if [ "$rc" -eq 0 ]; then
    note "runs              : NO — suite passes; a spec for unbuilt behaviour must fail"; fail=1
  elif printf '%s' "$out" | grep -qiE "cannot find module|module_not_found|err_module|syntaxerror|no test files found"; then
    note "runs              : NO — suite did not load (module/syntax error), so it is not a criterion"; fail=1
  elif printf '%s' "$out" | grep -qiE "assert|expected|fail"; then
    note "runs              : YES — fails on missing behaviour (exit $rc)"
  else
    note "runs              : UNCLEAR — exit $rc with no recognisable assertion output"; fail=1
  fi
fi

# 4 — the spec points at the artifact
if [ -n "$spec" ]; then
  hops="$(grep -ciE 'verified by|verification:' "$spec" || true)"
  if [ "${hops:-0}" -gt 0 ]; then
    note "requirement->check: $hops pointer(s) in the spec"
  else
    note "requirement->check: NONE — spec never names what verifies each requirement"; fail=1
  fi
fi

[ "$fail" -eq 0 ] && note "RESULT            : behaviour present" \
                  || note "RESULT            : behaviour ABSENT"
exit "$fail"
