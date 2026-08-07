#!/usr/bin/env bash
# Multi-turn activation FLOW engine for the Claude Code adapter.
#
# This script is a generic engine — it carries NO scenario text. The scenarios
# live as named files under scenarios/, mirroring skills/ (a phase folder per
# SDLC phase, plus common/). The FILENAME is the contract: scenarios/planning/
# define-goals is the opening expected to activate sdlc-skills:define-goals; a
# name starting with "_" (e.g. _negative) expects NOTHING to fire. A phase's
# _flow lists its scenario files in order; this engine runs them as one
# RESUMED `claude -p` conversation and checks each turn against its filename.
#
# Faithfulness/safety identical to run-activation.sh: real CLI, isolated empty
# temp dir, gates intact (allowlist Skill + read-only), real API calls — a
# manual/record tool, never CI. Detection: a structured `Skill` tool_use in an
# assistant event only (never a raw grep — that matches the nudge/init manifest;
# see ./README.md).
#
# Usage:
#   run-flow.sh --flow scenarios/planning/_flow [--working-tree] [--timeout N] [--keep] [--print]
#   run-flow.sh --turn "MSG" --turn "MSG" [--expect a,b] [--working-tree] [--timeout N] [--keep]
#   --print         parse the flow and show the turns + per-turn expectations; no API call.
#   --working-tree  load THIS repo via --plugin-dir (tests live edits, not the install cache).

set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"
orig_pwd="$PWD"
repo="$(cd "$scriptdir/.." && pwd)"   # working-tree root, for --plugin-dir

# A turn's filename is its expected skill IF that skill exists; any other name
# (a filler, a negative) expects nothing. No marker char needed in the filename.
is_skill() { find "$repo/skills" -maxdepth 2 -type d -name "$1" 2>/dev/null | grep -q .; }

flow=""; turns=(); exps=(); expect=""; timeout_s=120; keep=""; printonly=""; wt=""; verbose=""; maxturns="6"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --flow)    flow="$2"; shift 2;;
    --turn)    turns+=("$2"); exps+=("?"); shift 2;;   # "?" = no per-turn contract
    --expect)  expect="$2"; shift 2;;
    --timeout) timeout_s="$2"; shift 2;;
    --keep)    keep="1"; shift;;
    --working-tree) wt="1"; shift;;   # load the WORKING TREE via --plugin-dir
    --verbose) verbose="1"; shift;;   # dump each turn's full assistant output
    --max-turns) maxturns="$2"; shift 2;;
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
    base="$(basename "$line")"
    if is_skill "$base"; then exps+=("$base"); else exps+=("none"); fi
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

cflags=(--output-format stream-json --verbose --allowedTools Skill Read Glob Grep --max-turns "$maxturns")
[ -n "$wt" ] && cflags+=(--plugin-dir "$repo")   # --working-tree: live code, not cache

sid=""; fails=0
for i in "${!turns[@]}"; do
  msg="${turns[$i]}"; want="${exps[$i]}"; turnstream="$(mktemp)"
  if [ -z "$sid" ]; then
    ( cd "$workdir" && exec timeout "$timeout_s" claude -p "$msg" "${cflags[@]}" ) > "$turnstream" 2>/dev/null
  else
    ( cd "$workdir" && exec timeout "$timeout_s" claude -p "$msg" --resume "$sid" "${cflags[@]}" ) > "$turnstream" 2>/dev/null
  fi
  cat "$turnstream" >> "$allstream"
  [ -z "$sid" ] && sid="$(jq -rc 'select(.session_id) | .session_id' "$turnstream" 2>/dev/null | head -n1)"
  # Routing-first: the model invokes `using-sdlc-skills` (router) before the specific
  # skill, so judge the whole turn's chain, not the first call. The "terminal" is
  # the first non-router skill the route resolved to.
  chain="$(jq -rc "$SKILL_FILTER" "$turnstream" 2>/dev/null | sed 's/^sdlc-skills://')"
  terminal="$(printf '%s\n' "$chain" | grep -vx 'using-sdlc-skills' | grep -v '^$' | head -n1)"
  routed=""; printf '%s\n' "$chain" | grep -qx 'using-sdlc-skills' && routed="using-sdlc-skills"
  mark=""
  case "$want" in
    \?)   mark="(no contract)";;
    none) [ -z "$terminal" ] && mark="ok (no specific skill)" || { mark="MISS (fired $terminal)"; fails=$((fails+1)); };;
    using-sdlc-skills) [ -n "$routed" ] && mark="ok" || { mark="MISS (wanted using-sdlc-skills)"; fails=$((fails+1)); };;
    *)    if printf '%s\n' "$chain" | grep -qx "$want"; then mark="ok"; else mark="MISS (wanted $want)"; fails=$((fails+1)); fi;;
  esac
  if [ -n "$terminal" ]; then shown="sdlc-skills:$terminal"
  elif [ -n "$routed" ]; then shown="sdlc-skills:using-sdlc-skills (router only)"
  else shown="<none>"; fi
  printf 'turn %d -> %-34s %-22s | %s\n' "$((i+1))" "$shown" "$mark" "${msg:0:48}"
  if [ -n "$verbose" ]; then
    jq -rc 'select(.type=="assistant") | .message.content[]?
      | if .type=="text" then "  | " + .text
        elif .type=="tool_use" then "  | [tool_use " + .name + " " + (.input|tostring) + "]"
        else empty end' "$turnstream" 2>/dev/null
  fi
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
if [ -n "$keep" ]; then cp "$allstream" "$scriptdir/last-flow.jsonl"; echo "stream              : tests/last-flow.jsonl"; fi
