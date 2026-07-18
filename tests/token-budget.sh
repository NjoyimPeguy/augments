#!/usr/bin/env bash
# Token-budget report for the always-loaded context — deterministic, files only.
#
# "Earn every line" is enforced as a LINE budget by validate-skills.sh. This is
# its companion: it reports the actual CONTEXT COST of the always-loaded
# surface — every SKILL.md body, plus the SessionStart nudge that loads on every
# session. It turns "lean" from a line-count proxy into a number you can watch.
#
# No model is called (the library is harness- and model-agnostic), so tokens are
# APPROXIMATED as chars/4 — a portable rough proxy, not an exact count. Use it
# for relative comparison and drift, not as a billing figure.
#
# Usage:
#   bash tests/token-budget.sh             # report only, exit 0
#   bash tests/token-budget.sh --max 700   # also flag any body over 700 approx-tokens; exit 1 if exceeded
#                                           # (discipline skills legitimately run large — see writing-skills)
#
# CI runs this with --max 1600 (see .github/workflows/validate.yml): the largest
# body today is ~1550, so the gate catches bloat while leaving discipline skills
# their headroom. Exceeding it means tighten the skill — or raise the budget in
# the workflow deliberately, in the same diff, where a reviewer can see it.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

max=0
[ "${1:-}" = "--max" ] && max="${2:-0}"

approx() { local c; c=$(wc -m <"$1"); echo $(((c + 3) / 4)); }

nudge="hooks/context.md"

echo "token-budget: always-loaded context  (approx tokens ≈ chars/4, not exact)"
echo

nudge_t=0
[ -f "$nudge" ] && nudge_t=$(approx "$nudge")
printf 'SessionStart nudge (loaded EVERY session): %d approx tokens  [%s]\n\n' "$nudge_t" "$nudge"

# Collect per-skill costs.
names=()
toks=()
while IFS= read -r f; do
  name=$(awk -F': ' '/^name:/{print $2; exit}' "$f")
  [ -z "$name" ] && continue
  names+=("$name")
  toks+=("$(approx "$f")")
done < <(find skills -name SKILL.md | sort)

n=${#toks[@]}
total=0
mn=9999999
mx=0
for t in "${toks[@]}"; do
  total=$((total + t))
  ((t < mn)) && mn=$t
  ((t > mx)) && mx=$t
done
mean=$((total / (n > 0 ? n : 1)))

echo "Per-skill body (one loads when its skill fires), largest first:"
paste <(printf '%s\n' "${toks[@]}") <(printf '%s\n' "${names[@]}") |
  sort -k1,1 -rn |
  while IFS=$'\t' read -r t name; do
    flag=""
    { [ "$max" -gt 0 ] && [ "$t" -gt "$max" ]; } && flag="  ← over ${max}"
    printf '  %5d  %s%s\n' "$t" "$name" "$flag"
  done

echo
echo "Totals (approx tokens):"
printf '  nudge, every session ............. %d\n' "$nudge_t"
printf '  per-skill body ................... min %d · mean %d · max %d\n' "$mn" "$mean" "$mx"
printf '  typical session (nudge + 1 body) . %d–%d\n' "$((nudge_t + mn))" "$((nudge_t + mx))"
printf '  whole catalogue (%d bodies) ...... %d  (only if every skill fired)\n' "$n" "$total"

# --max enforcement in a non-piped loop so the exit code is reliable.
if [ "$max" -gt 0 ]; then
  over=()
  for i in "${!toks[@]}"; do
    [ "${toks[$i]}" -gt "$max" ] && over+=("${names[$i]}")
  done
  if [ "${#over[@]}" -gt 0 ]; then
    echo
    echo "✗ ${#over[@]} body(ies) over --max ${max}: ${over[*]}"
    exit 1
  fi
fi
exit 0
