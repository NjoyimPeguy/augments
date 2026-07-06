#!/usr/bin/env bash
# Real activation probe for the Codex CLI adapter.

set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"
orig_pwd="$PWD"
repo="$(cd "$scriptdir/../../.." && pwd)"

SKILL_FILTER='
  if (.type == "item.started" or .type == "item.completed")
     and .item.type == "command_execution" then
    (.item.command // "") as $cmd
    | (($cmd | capture("/skills/(?<skill>[A-Za-z0-9_-]+)/SKILL[.]md")? | .skill) // empty)
    | if . == "" then empty else "augments:" + . end
  else
    empty
  end'

is_skill() { find "$repo/skills" -maxdepth 2 -type d -name "$1" 2>/dev/null | grep -q .; }

if [ "${1:-}" = "selftest" ]; then
  command -v jq >/dev/null 2>&1 || { echo "selftest needs jq" >&2; exit 3; }
  cd "$scriptdir" || exit 2
  fail=0
  check() {
    fixture="$1"
    want="$2"
    got="$(jq -rc "$SKILL_FILTER" "fixtures/$fixture" 2>/dev/null | head -n1)"
    if [ "$got" = "$want" ]; then
      printf 'ok    %-24s -> %s\n' "$fixture" "${got:-<none>}"
    else
      printf 'FAIL  %-24s -> got "%s" want "%s"\n' "$fixture" "$got" "$want"
      fail=1
    fi
  }
  check fired-debugging.jsonl "augments:debugging"
  check none.jsonl ""
  [ "$fail" -eq 0 ] && echo "Codex activation detector self-test: PASS" || echo "Codex activation detector self-test: FAIL"
  exit "$fail"
fi

scenario=""
sfile=""
expect=""
timeout_s=180
keep=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --scenario) scenario="$2"; shift 2;;
    --scenario-file) sfile="$2"; shift 2;;
    --expect) expect="$2"; shift 2;;
    --timeout) timeout_s="$2"; shift 2;;
    --keep) keep="1"; shift;;
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
  if [ -z "$expect" ]; then
    b="$(basename "$resolved")"
    is_skill "$b" && expect="$b"
  fi
fi

[ -z "$scenario" ] && { echo "needs --scenario TEXT or --scenario-file FILE" >&2; exit 2; }
command -v codex >/dev/null 2>&1 || { echo "no \`codex\` CLI on PATH" >&2; exit 3; }
command -v jq >/dev/null 2>&1 || { echo "needs \`jq\`" >&2; exit 3; }

workdir="$(mktemp -d)"
stream="$(mktemp)"
errlog="$(mktemp)"
trap '[ -z "$keep" ] && rm -f "$stream" "$errlog"; rm -rf "$workdir"' EXIT

prompt="$scenario

Use the relevant Augments skill according to the skill instructions: read its SKILL.md completely before answering. Do not edit files."

( cd "$workdir" && exec timeout "$timeout_s" codex exec --json --ephemeral --skip-git-repo-check -s read-only -C "$workdir" "$prompt" ) < /dev/null >"$stream" 2>"$errlog"
status=$?

chain="$(jq -rc "$SKILL_FILTER" "$stream" 2>/dev/null | awk '!seen[$0]++')"
chain_str="$(printf '%s' "$chain" | paste -sd' ' -)"
want=""
[ -n "$expect" ] && want="augments:$expect"

if [ -n "$want" ] && printf '%s\n' "$chain" | grep -qx "$want"; then
  verdict="ACTIVATED — chain: ${chain_str} (read ${want})"
  result=0
elif [ -z "$want" ] && [ -n "$chain" ]; then
  verdict="ACTIVATED — chain: ${chain_str}"
  result=0
elif [ "$status" -ne 0 ]; then
  verdict="ERROR — codex exec exited $status"
  result=1
else
  verdict="NONE (no installed Augments SKILL.md read)"
  result=1
fi

echo "scenario : ${scenario}"
[ -n "$expect" ] && echo "expected : augments:${expect}"
echo "verdict  : ${verdict}"
echo "captured : $(grep -c . "$stream" 2>/dev/null || echo 0) JSON events"
if [ -s "$errlog" ]; then
  echo "stderr   : $(grep -c . "$errlog" 2>/dev/null || echo 0) lines"
fi
if [ -n "$keep" ]; then
  cp "$stream" "$scriptdir/last-stream.jsonl"
  cp "$errlog" "$scriptdir/last-stderr.log"
  echo "stream   : tests/harness/codex-cli/last-stream.jsonl"
  echo "stderr   : tests/harness/codex-cli/last-stderr.log"
fi
exit "$result"
