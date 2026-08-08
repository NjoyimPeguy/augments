#!/usr/bin/env bash
# Activation test — ONE runner for every harness.
#
# Observes whether a skill ACTUALLY activates, from a structured tool call in the
# harness's own stream — never a prose grep and never a self-report. A raw grep
# reports phantom activations: the SessionStart nudge and the init manifest both
# contain `sdlc-skills:` tokens that are not actions. The first version of this
# harness fell for exactly that.
#
# THE FILENAME IS THE CONTRACT. A scenario named after a real skill expects that
# skill anywhere in the routing chain (under routing-first the first call is
# `using-sdlc-skills`, the router — judge the whole chain, not the first call). Any
# other name expects NOTHING to fire; something firing there is a failure.
#
# Exit code is the verdict, so this is scriptable. An exploratory
# `--scenario TEXT` run with no `--expect` exits 0: there is no contract.
#
# Real API call per scenario. Manual tool, never CI.
#
# Usage:
#   tests/run-activation.sh --harness claude-code --scenario-file common/yagni
#   tests/run-activation.sh --harness codex --scenario "TEXT" --expect debugging
#   tests/run-activation.sh --harness kimi-code --scenario-file maintenance/debugging --keep
#   tests/run-activation.sh selftest            # offline detector check, no API

set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"; orig_pwd="$PWD"
cd "$scriptdir/.." || exit 2
repo="$PWD"

is_skill() { find "$repo/skills" -maxdepth 2 -type d -name "$1" 2>/dev/null | grep -q .; }

# --- offline detector selftest (no API) --------------------------------------
# The one part of an activation test that CAN be gated deterministically: does
# the detector read a stream correctly? Fixtures are inline so no .jsonl sits in
# the tree.
if [ "${1:-}" = "selftest" ]; then
  command -v jq >/dev/null 2>&1 || { echo "selftest needs jq" >&2; exit 3; }
  fx="$(mktemp -d)"; trap 'rm -rf "$fx"' EXIT
  . "$scriptdir/harnesses/claude-code.sh"
  cat > "$fx/fired.jsonl" <<'FX'
{"type":"system","subtype":"init","tools":["Skill"]}
{"type":"assistant","message":{"content":[{"type":"text","text":"routing first"},{"type":"tool_use","name":"Skill","input":{"skill":"sdlc-skills:using-sdlc-skills"}}]}}
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"sdlc-skills:debugging"}}]}}
FX
  cat > "$fx/none.jsonl" <<'FX'
{"type":"system","subtype":"init","tools":["Skill"]}
{"type":"assistant","message":{"content":[{"type":"text","text":"Sure — the answer is 4."}]}}
FX
  cat > "$fx/acted.jsonl" <<'FX'
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Read","input":{"file_path":"a.ts"}}]}}
FX
  f=0
  chk() { local got; got="$(adapter_chain "$fx/$1" | paste -sd' ' -)"
          [ "$got" = "$2" ] && printf 'ok    %-14s -> %s\n' "$1" "${got:-<none>}" \
                            || { printf 'FAIL  %-14s -> got "%s" want "%s"\n' "$1" "$got" "$2"; f=1; }; }
  chk fired.jsonl "sdlc-skills:using-sdlc-skills sdlc-skills:debugging"
  chk none.jsonl  ""
  chk acted.jsonl ""
  [ "$f" -eq 0 ] && echo "detection self-test: PASS" || echo "detection self-test: FAIL"
  exit "$f"
fi

# --- args ---------------------------------------------------------------------
harness=""; scenario=""; sfile=""; expect=""; expect_none=""
timeout_s=120; keep=""; verbose=""; maxturns="6"; fixture_git=""; wt="1"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --harness)          harness="$2"; shift 2;;
    --scenario)         scenario="$2"; shift 2;;
    --scenario-file)    sfile="$2"; shift 2;;
    --expect)           expect="$2"; shift 2;;
    --timeout)          timeout_s="$2"; shift 2;;
    --max-turns)        maxturns="$2"; shift 2;;
    --keep)             keep="1"; shift;;
    --verbose)          verbose="1"; shift;;
    --fixture-git-repo) fixture_git="1"; shift;;  # some skills need a real repo to be meaningful
    --installed)        wt=""; shift;;            # test the install cache, not this checkout
    *) echo "unknown argument: $1" >&2; exit 2;;
  esac
done
[ -n "$harness" ] || { echo "needs --harness claude-code|codex|kimi-code" >&2; exit 2; }
[ -f "$scriptdir/harnesses/$harness.sh" ] || { echo "no harness adapter: $harness" >&2; exit 2; }
. "$scriptdir/harnesses/$harness.sh"

if [ -n "$sfile" ]; then
  resolved=""
  for cand in "$sfile" "$orig_pwd/$sfile" \
              "$scriptdir/scenarios/activation/$sfile" "$scriptdir/scenarios/$sfile"; do
    [ -f "$cand" ] && { resolved="$cand"; break; }
  done
  [ -n "$resolved" ] || { echo "no such scenario file: $sfile" >&2; exit 2; }
  scenario="$(cat "$resolved")"
  if [ -z "$expect" ]; then
    b="$(basename "$resolved")"
    if is_skill "$b"; then expect="$b"; else expect_none="1"; fi
  fi
fi
[ -n "$scenario" ] || { echo "needs --scenario TEXT or --scenario-file FILE" >&2; exit 2; }
adapter_check || exit 3
command -v jq >/dev/null 2>&1 || { echo "needs \`jq\`" >&2; exit 3; }

# --- isolated workspace -------------------------------------------------------
# An empty temp dir is both safe (writes cannot reach this repo) and faithful
# (reproduces a brand-new project opening).
workdir="$(mktemp -d)"; stream="$(mktemp)"; errlog="$(mktemp)"; harness_home=""
cleanup() { [ -n "$harness_home" ] && rm -rf "$harness_home"
            if [ -n "$keep" ]; then echo "kept: stream=$stream errlog=$errlog"
            else rm -rf "$workdir"; rm -f "$stream" "$errlog"; fi; }
trap cleanup EXIT

if [ -n "$fixture_git" ]; then
  ( cd "$workdir" && git init -q -b main 2>/dev/null || { git init -q && git checkout -qb main; }
    printf '# Fixture\n\nA disposable repository for skill-routing probes.\n' > README.md
    git add README.md
    git -c user.name='SDLC skills Harness' -c user.email='harness@example.invalid' \
        commit -q -m 'fixture baseline' ) || { echo "fixture repo failed" >&2; exit 2; }
fi

[ -n "$wt" ] && { adapter_install "$repo" || exit 3; }
prompt="$scenario$(adapter_prompt_suffix 2>/dev/null || true)"
mapfile -t xflags < <(adapter_activation_flags 2>/dev/null || true)

# Stop as soon as the route RESOLVES: the wanted skill appears, or any non-router
# skill fires. A run that only ever fires the router is bounded by --max-turns.
( adapter_run_activation "$workdir" "$prompt" "$stream" ${xflags[@]+"${xflags[@]}"} ) &
cpid=$!
# Skills CHAIN: using-sdlc-skills routes, then task-branches, then TDD, then yagni.
# So stopping at the first non-router skill truncates a correct chain and scores
# it as a miss — that is exactly what happened to test-driven-development
# (killed at using-task-branches, which the router correctly sends you to first)
# and to finishing-a-branch (killed at verifying-completion). When a specific
# skill is expected, wait for THAT skill; --max-turns bounds a run that never
# reaches it. Only an exploratory run stops at the first non-router call.
router="sdlc-skills:using-sdlc-skills"; want=""; [ -n "$expect" ] && want="sdlc-skills:${expect}"
while kill -0 "$cpid" 2>/dev/null; do
  chain="$(adapter_chain "$stream")"
  if [ -n "$want" ]; then
    printf '%s\n' "$chain" | grep -qx "$want" && { kill "$cpid" 2>/dev/null; break; }
  else
    printf '%s\n' "$chain" | grep -vx "$router" | grep -q . && { kill "$cpid" 2>/dev/null; break; }
  fi
  sleep 2
done
wait "$cpid" 2>/dev/null; status=$?

# --- verdict ------------------------------------------------------------------
chain="$(adapter_chain "$stream" | awk '!seen[$0]++')"
chain_str="$(printf '%s' "$chain" | paste -sd' ' -)"
first="$(printf '%s\n' "$chain" | grep -v '^$' | head -n1)"
result=0
if [ -n "$want" ] && printf '%s\n' "$chain" | grep -qx "$want"; then
  verdict="ACTIVATED — chain: ${chain_str} (reached ${want})"
elif [ -n "$expect_none" ] && [ -z "$first" ]; then
  verdict="NONE as expected (filename is not a skill; nothing should fire)"
elif [ -n "$expect_none" ]; then
  verdict="UNEXPECTED ACTIVATION — chain: ${chain_str} (nothing should have fired)"; result=1
elif [ -z "$want" ] && [ -n "$first" ]; then
  verdict="ACTIVATED — chain: ${chain_str} (exploratory; not scored)"
elif [ -n "$first" ]; then
  verdict="ROUTED ELSEWHERE — chain: ${chain_str} (expected ${want})"; result=1
else
  verdict="NONE (no skill invoked in any assistant turn)"; [ -n "$want" ] && result=1
fi

echo "harness  : $harness"
echo "scenario : ${scenario}"
[ -n "$expect" ] && echo "expected : sdlc-skills:${expect}"
echo "verdict  : ${verdict}"
# This guard only catches the HARD refusal. An expiring session can degrade
# routing quality for several runs BEFORE it refuses outright — measured on
# Kimi: 0/3 misses minutes before `auth.login_required`, then 5/5 on the
# identical scenario after re-login. If a harness inexplicably goes red,
# re-authenticate and re-run before scoring it as a regression.
if grep -qiE 'usage limit|login_required|api_error: 4' "$stream" "$errlog" 2>/dev/null; then
  echo "note     : provider refused (quota/auth) — INCONCLUSIVE, not a skills result"
  result=1
fi
[ -n "$verbose" ] && { echo "--- stream ---"; cat "$stream"; }
exit "$result"
