#!/usr/bin/env bash
# Real end-to-end activation test for the Claude Code adapter.
#
# This drives the actual `claude` CLI headless against the working tree and
# observes whether a skill ACTUALLY activates (a structured Skill tool_use), not
# what a subagent says it would do. Real harness, real SessionStart hook, real
# Skill tool, behaviour observed not self-reported.
#
# It is deliberately NOT portable and NOT in the core gate:
#   - it binds to one harness (the `claude` binary) — that is why it lives under
#     tests/harness/<adapter>/, not in the harness-agnostic core (tests/README.md);
#   - it makes a REAL API call — it costs tokens and is not free/deterministic,
#     so it is a manual/record tool, never a CI pass/fail.
#
# Safety + faithfulness: the nested session runs in an isolated empty temp dir,
# so (a) nothing it writes can touch this repo, and (b) it reproduces the
# "brand-new empty project" opening exactly. The user-level plugin install and
# the SessionStart hook apply regardless of cwd, so augments is live there.
# Permission gates are NOT bypassed — we pass an explicit allowlist of just the
# tool under test (`Skill`) plus read-only tools. Activation (the Skill tool_use)
# is allowed; any Write/Edit/Bash the skill might attempt is denied.
#
# DETECTION — only a structured `Skill` tool_use in an *assistant* event counts.
# The SessionStart nudge text and the init manifest both contain `augments:`
# tokens; a raw grep would match those and report a phantom activation. So the
# verdict is computed by jq over assistant events only. The run is killed the
# instant a real Skill tool_use is logged, so cost ≈ one turn.
#
# Usage:
#   run-activation.sh selftest        # offline detection check over fixtures (no API)
#   run-activation.sh --scenario-file scenarios/common/dispatching-parallel-agents [--keep]
#   run-activation.sh --scenario "TEXT" [--expect NAME] [--working-tree] [--verbose] [--max-turns N] [--timeout SECONDS] [--keep]
#   run-activation.sh --scenario-file scenarios/planning/define-goals --no-augments
# --working-tree loads THIS repo via --plugin-dir (tests live edits, not the install cache).

set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"; orig_pwd="$PWD"
cd "$scriptdir/../../.." || exit 2   # repo root (for output paths under tests/)
repo="$PWD"                          # working-tree root, for --plugin-dir

# A scenario file's name is its expected skill IF that skill exists; any other
# name (a filler, a negative) expects nothing. No marker char in the filename.
is_skill() { find "$repo/skills" -maxdepth 2 -type d -name "$1" 2>/dev/null | grep -q .; }

# jq filter: the skill name of the first real Skill tool_use in an ASSISTANT
# event. system/hook/init events are never consulted — they carry augments:
# tokens that are not actions. Shared by the live run and the offline selftest.
SKILL_FILTER='select(.type=="assistant") | .message.content[]?
  | select(.type=="tool_use" and .name=="Skill")
  | (.input.skill // .input.command // "?")'

# Offline, deterministic detection check over committed fixtures — NO API call.
# The gate the jq detector never had; safe to run anywhere jq exists.
if [ "${1:-}" = "selftest" ]; then
  command -v jq >/dev/null 2>&1 || { echo "selftest needs jq" >&2; exit 3; }
  cd "$scriptdir" || exit 2
  st_fail=0
  st_check() {  # $1 fixture, $2 expected (skill name, or "" for none)
    local got; got="$(jq -rc "$SKILL_FILTER" "fixtures/$1" 2>/dev/null | head -n1)"
    if [ "$got" = "$2" ]; then printf 'ok    %-26s -> %s\n' "$1" "${got:-<none>}"
    else printf 'FAIL  %-26s -> got "%s" want "%s"\n' "$1" "$got" "$2"; st_fail=1; fi
  }
  st_chain() {  # $1 fixture, $2 skill that must appear ANYWHERE in the chain (routing-first)
    if jq -rc "$SKILL_FILTER" "fixtures/$1" 2>/dev/null | grep -qx "$2"; then printf 'ok    %-26s chain has %s\n' "$1" "$2"
    else printf 'FAIL  %-26s chain lacks %s\n' "$1" "$2"; st_fail=1; fi
  }
  st_check fired-debugging.jsonl  "augments:debugging"
  st_check none.jsonl             ""
  st_check proceeded-acting.jsonl ""
  # Routing-first: the first call is the router; the route resolves onward to the skill.
  st_check routed-dpa.jsonl       "augments:using-augments"
  st_chain routed-dpa.jsonl       "augments:dispatching-parallel-agents"
  [ "$st_fail" -eq 0 ] && echo "detection self-test: PASS" || echo "detection self-test: FAIL"
  exit "$st_fail"
fi

scenario=""; sfile=""; expect=""; timeout_s=120; keep=""; bare=""; wt=""; verbose=""; maxturns="6"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --scenario)      scenario="$2"; shift 2;;
    --scenario-file) sfile="$2"; shift 2;;   # read the opening from a named file;
                                             # filename (sans ext) is the expected
                                             # skill unless --expect overrides it
    --expect)        expect="$2"; shift 2;;
    --timeout)       timeout_s="$2"; shift 2;;
    --keep)          keep="1"; shift;;
    --working-tree)  wt="1"; shift;;   # load the WORKING TREE via --plugin-dir
    --verbose)       verbose="1"; shift;;      # dump full assistant output after the run
    --max-turns)     maxturns="$2"; shift 2;;  # bound non-firing runs (default 6)
    --no-augments) bare="1"; shift;;   # auth-safe stand-in for "augments absent":
                                       # block the Skill tool so invocation is
                                       # impossible, and watch the fallback. (A
                                       # true absent run via `--bare` also strips
                                       # auth — "Not logged in" — so it can't be
                                       # used; the absent case is otherwise just a
                                       # vanilla model, trivially a non-invoke.)
    *) echo "unknown argument: $1" >&2; exit 2;;
  esac
done
if [ -n "$sfile" ]; then
  resolved=""
  for cand in "$sfile" "$orig_pwd/$sfile" "$scriptdir/$sfile"; do
    [ -f "$cand" ] && { resolved="$cand"; break; }
  done
  [ -n "$resolved" ] || { echo "no such scenario file: $sfile" >&2; exit 2; }
  scenario="$(cat "$resolved")"
  if [ -z "$expect" ]; then b="$(basename "$resolved")"; is_skill "$b" && expect="$b"; fi
fi
[ -z "$scenario" ] && { echo "needs --scenario \"TEXT\" or --scenario-file FILE" >&2; exit 2; }
command -v claude >/dev/null 2>&1 || { echo "no \`claude\` CLI on PATH" >&2; exit 3; }
command -v jq >/dev/null 2>&1 || { echo "this harness needs \`jq\` to parse stream-json" >&2; exit 3; }

workdir="$(mktemp -d)"; stream="$(mktemp)"
trap '[ -z "$keep" ] && rm -f "$stream"; rm -rf "$workdir"' EXIT

# (SKILL_FILTER is defined near the top — shared with `selftest`.)

# Launch the real harness headless, full stream to file (no lossy pipe). `exec`
# makes $cpid the timeout process, so killing it stops claude cleanly.
if [ -n "$bare" ]; then   # invocation blocked: real session, Skill tool denied
  flags=(--output-format stream-json --verbose --disallowedTools Skill --allowedTools Read Glob Grep)
else
  flags=(--output-format stream-json --verbose --allowedTools Skill Read Glob Grep)
fi
[ -n "$wt" ] && flags+=(--plugin-dir "$repo")   # --working-tree: live code, not cache
flags+=(--max-turns "$maxturns")                 # bound runaway / non-firing runs
( cd "$workdir" && exec timeout "$timeout_s" claude -p "$scenario" "${flags[@]}" ) > "$stream" 2>/dev/null &
cpid=$!

# Poll the growing transcript and stop once the route has RESOLVED. Under
# routing-first the model invokes `using-augments` (the router) before the
# specific skill, so the FIRST Skill call is the router, not the answer — we must
# follow the chain. Kill when: the --expect skill appears anywhere in the chain;
# OR (no --expect) any non-router skill fires; OR --expect IS the router and it
# fired. A run that only ever fires the router is bounded by --max-turns.
router="augments:using-augments"
want=""; [ -n "$expect" ] && want="augments:${expect}"
while kill -0 "$cpid" 2>/dev/null; do
  chain="$(jq -rc "$SKILL_FILTER" "$stream" 2>/dev/null)"
  if [ -n "$want" ]; then
    if printf '%s\n' "$chain" | grep -qx "$want" \
       || printf '%s\n' "$chain" | grep -vx "$router" | grep -q .; then
      kill "$cpid" 2>/dev/null; break
    fi
  else
    printf '%s\n' "$chain" | grep -vx "$router" | grep -q . && { kill "$cpid" 2>/dev/null; break; }
  fi
  sleep 2
done
wait "$cpid" 2>/dev/null

# Verdict from assistant events only — system/hook events are never consulted.
# The CHAIN is the ordered list of Skill calls; under routing-first it is
# typically `using-augments` -> the specific skill. Judge by the whole chain, not
# the first call (which is just the router).
chain="$(jq -rc "$SKILL_FILTER" "$stream" 2>/dev/null)"
chain_str="$(printf '%s' "$chain" | paste -sd' ' -)"
first_call="$(printf '%s\n' "$chain" | grep -v '^$' | head -n1)"
terminal="$(printf '%s\n' "$chain" | grep -vx "$router" | grep -v '^$' | head -n1)"
prose="$(jq -rc 'select(.type=="assistant") | .message.content[]?
  | select(.type=="text") | .text' "$stream" 2>/dev/null \
  | grep -oiE 'augments:[a-z0-9-]+' | head -n1)"

if [ -n "$want" ] && printf '%s\n' "$chain" | grep -qx "$want"; then
  verdict="ACTIVATED — chain: ${chain_str} (reached ${want})"
elif [ -z "$want" ] && [ -n "$first_call" ]; then
  verdict="ACTIVATED — chain: ${chain_str} (routed to ${terminal:-$first_call})"
elif [ -n "$first_call" ]; then
  verdict="ROUTED ELSEWHERE — chain: ${chain_str} (expected ${want})"
elif [ -n "$prose" ]; then
  verdict="MENTIONED in prose only, not invoked: ${prose}"
else
  verdict="NONE (no Skill tool_use, no mention in any assistant turn)"
fi

asst_events="$(jq -rc 'select(.type=="assistant")' "$stream" 2>/dev/null | grep -c . || echo 0)"
firstmove="$(jq -rc 'select(.type=="assistant") | .message.content[]?
  | select(.type=="text") | .text' "$stream" 2>/dev/null | head -n1 | tr '\n' ' ' | cut -c1-160)"
echo "scenario : ${scenario}"
[ -n "$bare" ] && echo "mode     : --no-augments (Skill tool blocked; nudge still fires)"
[ -n "$expect" ] && echo "expected : augments:${expect}"
echo "verdict  : ${verdict}"
[ -n "$firstmove" ] && echo "first move: ${firstmove}…"
if [ -n "$verbose" ]; then
  echo "--- full assistant output ---"
  jq -rc 'select(.type=="assistant") | .message.content[]?
    | if .type=="text" then .text
      elif .type=="tool_use" then "[tool_use " + .name + " " + (.input|tostring) + "]"
      else empty end' "$stream" 2>/dev/null
  echo "--- end output ---"
fi
echo "captured : $(grep -c . "$stream" 2>/dev/null || echo 0) stream events (${asst_events} assistant)"
if [ -n "$keep" ]; then
  out="tests/harness/claude-code/last-stream.jsonl"
  cp "$stream" "$out"; echo "stream   : ${out}"
fi
