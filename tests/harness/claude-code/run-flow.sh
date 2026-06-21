#!/usr/bin/env bash
# Multi-turn activation FLOW engine for the Claude Code adapter.
#
# This script is a generic engine — it carries NO scenario text. The scenarios
# live as named files under scenarios/, mirroring skills/ (a phase folder per
# SDLC phase, plus common/). The FILENAME is the contract: scenarios/planning/
# define-goals.txt is the opening expected to activate augments:define-goals; a
# name starting with "_" (e.g. _negative.txt) expects NOTHING to fire. A phase's
# _flow.txt lists its scenario files in order; this engine runs them as one
# RESUMED `claude -p` conversation and checks each turn against its filename.
#
# Faithfulness/safety identical to run-activation.sh: real CLI, isolated empty
# temp dir, gates intact (allowlist Skill + read-only), real API calls — a
# manual/record tool, never CI. Detection: a structured `Skill` tool_use in an
# assistant event only (never a raw grep — that matches the nudge/init manifest;
# see ./README.md).
#
# Usage:
#   run-flow.sh --flow scenarios/planning/_flow.txt [--timeout N] [--keep] [--print]
#   run-flow.sh --turn "MSG" --turn "MSG" [--expect a,b] [--timeout N] [--keep]
#   --print  parse the flow and show the turns + per-turn expectations; no API call.

set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"
orig_pwd="$PWD"

flow=""; turns=(); exps=(); expect=""; timeout_s=120; keep=""; printonly=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --flow)    flow="$2"; shift 2;;
    --turn)    turns+=("$2"); exps+=("?"); shift 2;;   # "?" = no per-turn contract
    --expect)  expect="$2"; shift 2;;
    --timeout) timeout_s="$2"; shift 2;;
    --keep)    keep="1"; shift;;
    --print)   printonly="1"; shift;;
    *) echo "unknown argument: $1" >&2; exit 2;;
  esac
done

# Resolve a flow file into ordered (turn text, expected skill) pairs. Each listed
# scenario filename yields one turn; the expectation is derived from the name.
if [ -n "$flow" ]; then
  case "$flow" in /*) : ;; *) [ -f "$flow" ] || flow="$scriptdir/$flow";; esac
  [ -f "$flow" ] || { echo "no such flow file: $flow" >&2; exit 2; }
  flowdir="$(cd "$(dirname "$flow")" && pwd)"
  while IFS= read -r line; do
    line="${line%%$'\r'}"
    [ -z "${line// }" ] && continue
    case "$line" in \#*) continue;; esac
    sf="$flowdir/$line"
    [ -f "$sf" ] || { echo "flow references missing scenario: $sf" >&2; exit 2; }
    turns+=("$(cat "$sf")")
    base="$(basename "$line")"; base="${base%.*}"
    case "$base" in _*) exps+=("none");; *) exps+=("$base");; esac
  done < "$flow"
fi
[ "${#turns[@]}" -eq 0 ] && { echo "needs --flow FILE or at least one --turn \"TEXT\"" >&2; exit 2; }

if [ -n "$printonly" ]; then
  echo "flow: ${flow:-<ad-hoc --turn list>}"
  for i in "${!turns[@]}"; do
    printf 'turn %d  expect=%-22s  %s\n' "$((i+1))" "${exps[$i]}" "${turns[$i]:0:72}"
  done
  exit 0
fi

command -v claude >/dev/null 2>&1 || { echo "no \`claude\` CLI on PATH" >&2; exit 3; }
command -v jq     >/dev/null 2>&1 || { echo "needs \`jq\`" >&2; exit 3; }

workdir="$(mktemp -d)"; allstream="$(mktemp)"
trap '[ -z "$keep" ] && rm -f "$allstream"; rm -rf "$workdir"' EXIT

SKILL_FILTER='select(.type=="assistant") | .message.content[]?
  | select(.type=="tool_use" and .name=="Skill") | (.input.skill // .input.command // "?")'

sid=""; fails=0
for i in "${!turns[@]}"; do
  msg="${turns[$i]}"; want="${exps[$i]}"; turnstream="$(mktemp)"
  if [ -z "$sid" ]; then
    ( cd "$workdir" && exec timeout "$timeout_s" claude -p "$msg" \
        --output-format stream-json --verbose \
        --allowedTools Skill Read Glob Grep ) > "$turnstream" 2>/dev/null
  else
    ( cd "$workdir" && exec timeout "$timeout_s" claude -p "$msg" --resume "$sid" \
        --output-format stream-json --verbose \
        --allowedTools Skill Read Glob Grep ) > "$turnstream" 2>/dev/null
  fi
  cat "$turnstream" >> "$allstream"
  [ -z "$sid" ] && sid="$(jq -rc 'select(.session_id) | .session_id' "$turnstream" 2>/dev/null | head -n1)"
  hit="$(jq -rc "$SKILL_FILTER" "$turnstream" 2>/dev/null | head -n1)"; hit="${hit#augments:}"
  mark=""
  case "$want" in
    \?)   mark="(no contract)";;
    none) [ -z "$hit" ] && mark="ok (quiet)" || { mark="MISS (expected none)"; fails=$((fails+1)); };;
    *)    [ "$hit" = "$want" ] && mark="ok" || { mark="MISS (wanted $want)"; fails=$((fails+1)); };;
  esac
  printf 'turn %d -> %-26s %-20s | %s\n' "$((i+1))" "${hit:+augments:}${hit:-<none>}" "$mark" "${msg:0:48}"
  rm -f "$turnstream"
done

echo
seq="$(jq -rc "$SKILL_FILTER" "$allstream" 2>/dev/null | paste -sd'|' - | sed 's/|/ -> /g')"
echo "activation sequence : ${seq:-<none>}"
if [ -n "$flow" ]; then
  [ "$fails" -eq 0 ] && echo "result              : all turns matched their filename contract" \
                      || echo "result              : $fails turn(s) off contract"
elif [ -n "$expect" ]; then
  miss=""; IFS=',' read -ra want <<< "$expect"
  for w in "${want[@]}"; do jq -rc "$SKILL_FILTER" "$allstream" 2>/dev/null | grep -qiE "$w\$" || miss="${miss} $w"; done
  [ -z "$miss" ] && echo "all expected skills activated." || echo "MISSING:${miss}"
fi
if [ -n "$keep" ]; then cp "$allstream" "$scriptdir/last-flow.jsonl"; echo "stream              : tests/harness/claude-code/last-flow.jsonl"; fi
