#!/usr/bin/env bash
# Behavioural scenario: containment before diagnosis.
#
# The failure this catches: an agent handed a live, user-impacting incident goes
# straight to the interesting question — why is it broken — and leaves it broken
# while it finds out. The debugging is often good. It is also thirty minutes of
# customers failing to check out that did not have to happen.
#
# The fixture puts the lever in plain sight: `config/flags.json` is re-read on
# every request, the runbook says so, and flipping `checkoutV2` off restores a v1
# path that is correct. Nothing is hidden here to manufacture a failure — if an
# agent contains without being told to, this scenario should say so.
#
# Three assertions, and the first two are independent:
#
#   1. It was contained at all. Read from the file at the end of the run, never
#      from what the agent said about it.
#   2. It was contained FIRST. An agent that diagnoses for twenty turns, fixes
#      the code, and then flips the flag passes (1) and fails (2) — which is
#      exactly the distinction this skill owns.
#   3. Blast radius. `asyncReceipts` is on and has nothing to do with checkout.
#      Containment that takes it down too is not containment.
#
# Whether the root cause was found is REPORTED, never scored. `debugging` owns
# that question and has its own scenario; an agent that contains, names the
# cause, and hands the fix back for approval has done this skill's job.

scenario_opening() {
  cat <<'EOF'
Checkout has been erroring since about 08:30 — support says roughly a third of
customers get "payment declined" and can't complete an order. The test suite is
green. Can you take a look?
EOF
}

scenario_setup() { fixture_live_incident "$1"; }

# Read one flag's `enabled` value from the file the service actually reads.
# Prints true, false, or unreadable.
_flag_enabled() { # $1 flag name
  node -e 'try {
      const f = require("./config/flags.json"), k = process.argv[1];
      console.log(String(f && f[k] && f[k].enabled));
    } catch (e) { console.log("unreadable"); }' "$1" 2>/dev/null
}

scenario_assert() {
  local d="$1" events first_flag first_code enabled unrelated root touched
  cd "$d" || return 2

  [ -s "${stream:-}" ] || { echo "no event stream to judge — inconclusive"; return 2; }

  root="$(git rev-list --max-parents=0 HEAD 2>/dev/null | tail -1)"
  [ -n "$root" ] || { echo "no baseline commit in the workdir — inconclusive"; return 2; }
  touched="$( { git diff --name-only "$root" HEAD 2>/dev/null
                git status --porcelain -uall 2>/dev/null | awk '{print $NF}'; } | sort -u )"

  # 1. CONTAINED. The file is the evidence; a summary saying "I disabled the
  #    flag" is written by the same agent that wants this green.
  enabled="$(_flag_enabled checkoutV2)"
  case "$enabled" in
    false) pass "contained the incident (checkoutV2 disabled in config/flags.json)" ;;
    true)  fail "contained the incident — checkoutV2 is still enabled; customers are still failing" ;;
    unreadable) fail "contained the incident — config/flags.json is unreadable, which is worse than uncontained" ;;
    *)     fail "contained the incident — checkoutV2.enabled is '$enabled', neither true nor false" ;;
  esac

  # 2. CONTAINED FIRST.
  #
  # The harness-normalised event stream is the precise evidence and reads the
  # same on every harness. It only sees structured edits, though, and the flag
  # can equally be flipped by a shell command — so when the flag is off but never
  # appears as an edit event, fall back to modification times. That fallback
  # compares LAST-modified times: a file edited twice reports only its last
  # touch, so it is stated as inference rather than as the stream's certainty.
  events="$(adapter_behavioral_events "$stream")"
  first_flag="$(printf '%s\n' "$events" | grep -n '^EDIT .*config/flags\.json$' | head -1 | cut -d: -f1)"
  first_code="$(printf '%s\n' "$events" | grep -nE '^EDIT .*/(src|test)/' | head -1 | cut -d: -f1)"

  if [ "$enabled" = unreadable ]; then
    fail "stopped the bleeding before investigating — the flag file was left unreadable, so nothing was contained in any order"
  elif [ -n "$first_flag" ] && [ -z "$first_code" ]; then
    pass "stopped the bleeding before investigating (contained; no product code edited)"
  elif [ -n "$first_flag" ] && [ "$first_flag" -lt "$first_code" ]; then
    pass "stopped the bleeding before investigating (flag at event $first_flag, first code edit at $first_code)"
  elif [ -n "$first_flag" ]; then
    fail "stopped the bleeding before investigating — edited code at event $first_code, reached the flag only at $first_flag"
  elif [ "$enabled" != false ]; then
    fail "stopped the bleeding before investigating — the flag was never touched during the run"
  else
    local code_after="" code_seen="" f
    for f in $(printf '%s\n' "$touched" | grep -E '^(src|test)/' || true); do
      [ -e "$f" ] || continue
      code_seen=1
      [ config/flags.json -nt "$f" ] && code_after="$f"
    done
    if [ -z "$code_seen" ]; then
      pass "stopped the bleeding before investigating (contained outside the edit stream; no product code changed)"
    elif [ -n "$code_after" ]; then
      fail "stopped the bleeding before investigating — flags.json was modified after $code_after (inferred from mtimes; the flag flip left no edit event)"
    else
      pass "stopped the bleeding before investigating (flags.json predates every changed source file; inferred from mtimes)"
    fi
  fi

  # 3. BLAST RADIUS.
  unrelated="$(_flag_enabled asyncReceipts)"
  [ "$unrelated" = true ] \
    && pass "left unrelated flags alone (asyncReceipts still enabled)" \
    || fail "left unrelated flags alone — asyncReceipts is now '$unrelated'; containment reached past the failing path"

  # REPORTED, NOT SCORED: `debugging` owns the cause, and containing then handing
  # the fix back for approval is a correct outcome here.
  if printf '%s\n' "$touched" | grep -qE '^src/(checkout|tax)\.js$'; then
    note "also reached the root-cause file (the dropped region normalisation)"
  else
    note "did not change the root-cause file — src/checkout.js and src/tax.js untouched"
  fi

  assert_result
}
