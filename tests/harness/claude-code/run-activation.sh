#!/usr/bin/env bash
# Real end-to-end activation test for the Claude Code adapter.
#
# Unlike the portable proxies in tests/triggering/ and tests/invocation/ — which
# ask a fresh SUBAGENT what it WOULD do — this drives the actual `claude` CLI
# headless against the really-installed plugin and observes whether a skill
# ACTUALLY activates. It is the faithful layer: real harness, real SessionStart
# hook, real Skill tool, behaviour observed not self-reported.
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
#   run-activation.sh --scenario-file scenarios/common/dispatching-parallel-agents.txt [--keep]
#   run-activation.sh --scenario "TEXT" [--expect NAME] [--timeout SECONDS] [--keep]
#   run-activation.sh --scenario-file scenarios/planning/define-goals.txt --no-augments

set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"; orig_pwd="$PWD"
cd "$scriptdir/../../.." || exit 2   # repo root (for output paths under tests/)

scenario=""; sfile=""; expect=""; timeout_s=120; keep=""; bare=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --scenario)      scenario="$2"; shift 2;;
    --scenario-file) sfile="$2"; shift 2;;   # read the opening from a named file;
                                             # filename (sans ext) is the expected
                                             # skill unless --expect overrides it
    --expect)        expect="$2"; shift 2;;
    --timeout)       timeout_s="$2"; shift 2;;
    --keep)          keep="1"; shift;;
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
  if [ -z "$expect" ]; then b="$(basename "$resolved")"; b="${b%.*}"; case "$b" in _*) : ;; *) expect="$b";; esac; fi
fi
[ -z "$scenario" ] && { echo "needs --scenario \"TEXT\" or --scenario-file FILE" >&2; exit 2; }
command -v claude >/dev/null 2>&1 || { echo "no \`claude\` CLI on PATH" >&2; exit 3; }
command -v jq >/dev/null 2>&1 || { echo "this harness needs \`jq\` to parse stream-json" >&2; exit 3; }

workdir="$(mktemp -d)"; stream="$(mktemp)"
trap '[ -z "$keep" ] && rm -f "$stream"; rm -rf "$workdir"' EXIT

# jq filter: emit the skill name of the first real Skill tool_use, if any.
SKILL_FILTER='select(.type=="assistant") | .message.content[]?
  | select(.type=="tool_use" and .name=="Skill")
  | (.input.skill // .input.command // "?")'

# Launch the real harness headless, full stream to file (no lossy pipe). `exec`
# makes $cpid the timeout process, so killing it stops claude cleanly.
if [ -n "$bare" ]; then   # invocation blocked: real session, Skill tool denied
  flags=(--output-format stream-json --verbose --disallowedTools Skill --allowedTools Read Glob Grep)
else
  flags=(--output-format stream-json --verbose --allowedTools Skill Read Glob Grep)
fi
( cd "$workdir" && exec timeout "$timeout_s" claude -p "$scenario" "${flags[@]}" ) > "$stream" 2>/dev/null &
cpid=$!

# Poll the growing transcript; kill the run the moment a real Skill tool_use
# lands (jq -e succeeds). A partial trailing line just makes jq fail this tick.
while kill -0 "$cpid" 2>/dev/null; do
  if jq -e "$SKILL_FILTER" "$stream" >/dev/null 2>&1; then
    kill "$cpid" 2>/dev/null; break
  fi
  sleep 2
done
wait "$cpid" 2>/dev/null

# Verdict from assistant events only — system/hook events are never consulted.
skill_call="$(jq -rc "$SKILL_FILTER" "$stream" 2>/dev/null | head -n1)"
prose="$(jq -rc 'select(.type=="assistant") | .message.content[]?
  | select(.type=="text") | .text' "$stream" 2>/dev/null \
  | grep -oiE 'augments:[a-z0-9-]+' | head -n1)"

if [ -n "$skill_call" ]; then
  verdict="ACTIVATED via Skill tool: ${skill_call}"
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
echo "captured : $(grep -c . "$stream" 2>/dev/null || echo 0) stream events (${asst_events} assistant)"
if [ -n "$keep" ]; then
  out="tests/harness/claude-code/last-stream.jsonl"
  cp "$stream" "$out"; echo "stream   : ${out}"
fi
