#!/usr/bin/env bash
# Real end-to-end BEHAVIOURAL test for the Kimi Code CLI adapter.
#
# The Kimi sibling of ../claude-code/run-behavioral.sh: same two-arm shape, same
# shared scenarios (../../behavioral-scenarios/), same rule that the verdict is the
# scenario probe's EXIT CODE, not prose in a record. Only the plumbing is
# harness-specific — an isolated KIMI_CODE_HOME with this checkout installed as a
# managed plugin (plugins/managed/augments plus a plugins/installed.json record),
# the layout `kimi /plugins install` produces, exactly as run-activation.sh does.
#
# NO permission flag is passed, and that is deliberate — `kimi -p` already
# auto-approves tool calls, so it can write. Both approval flags are in fact
# REJECTED in prompt mode ("Cannot combine --prompt with --auto" / "...--yolo"),
# so do not add one back thinking it grants write access; verified by having a
# throwaway `-p` run create a file with no flags at all.
#
# `-p` is single-shot, so a run that stops to ask a question ends with no
# deliverable. If that happens, give the scenario an `opening.kimi-code` that
# pre-empts the interview — the way `opening.codex-cli` does.
#
# Same caveats: binds to the `kimi` binary, makes REAL API calls, costs about a
# full task per arm. Manual/record tool, never CI.
#
# TWO ARMS:
#   --arm green   installs the managed plugin from the working tree (your edit).
#   --arm red     installs from a throwaway `git worktree` at --base, so the
#                 before-arm stays reproducible AFTER the change is committed.
#
# Usage:
#   run-behavioral.sh --scenario spec-it --arm green [--keep]
#   run-behavioral.sh --scenario spec-it --arm red --base origin/dev [--timeout 2400]

set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"
cd "$scriptdir/../../.." || exit 2
repo="$PWD"
source_kimi_home="${KIMI_CODE_HOME:-${HOME:-}/.kimi-code}"

scenario=""; arm=""; base="origin/dev"; timeout_s=2400; keep=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --scenario) scenario="$2"; shift 2;;
    --arm)      arm="$2"; shift 2;;
    --base)     base="$2"; shift 2;;
    --timeout)  timeout_s="$2"; shift 2;;
    --keep)     keep="1"; shift;;
    *) echo "unknown argument: $1" >&2; exit 2;;
  esac
done

[ -n "$scenario" ] || { echo "needs --scenario NAME" >&2; exit 2; }
case "$arm" in red|green) ;; *) echo "needs --arm red|green" >&2; exit 2;; esac
command -v kimi >/dev/null 2>&1 || { echo "no \`kimi\` CLI on PATH" >&2; exit 3; }
command -v jq   >/dev/null 2>&1 || { echo "needs \`jq\`" >&2; exit 3; }

sdir="$scriptdir/../../behavioral-scenarios/$scenario"
[ -d "$sdir/fixture" ] || { echo "no fixture at $sdir/fixture" >&2; exit 2; }
opening_file="$sdir/opening.kimi-code"
[ -f "$opening_file" ] || opening_file="$sdir/opening.default"
[ -f "$opening_file" ] || { echo "no opening in $sdir" >&2; exit 2; }

workdir="$(mktemp -d)"; stream="$(mktemp)"; errlog="$(mktemp)"
kimi_home="$(mktemp -d)"; redtree=""
cleanup() {
  [ -n "$redtree" ] && git -C "$repo" worktree remove --force "$redtree" >/dev/null 2>&1
  rm -rf "$kimi_home"
  if [ -n "$keep" ]; then echo "kept: workdir=$workdir stream=$stream errlog=$errlog"
  else rm -rf "$workdir"; rm -f "$stream" "$errlog"; fi
}
trap cleanup EXIT

if [ "$arm" = "red" ]; then
  git -C "$repo" rev-parse --verify "$base" >/dev/null 2>&1 || {
    echo "--base '$base' is not a valid ref (fetch first?)" >&2; exit 2; }
  redtree="$(mktemp -d)"; rm -rf "$redtree"
  git -C "$repo" worktree add --detach "$redtree" "$base" >/dev/null 2>&1 || {
    echo "could not create worktree at $base" >&2; redtree=""; exit 2; }
  plugin_src="$redtree"
else
  plugin_src="$repo"
fi

# --- isolated home: auth ------------------------------------------------------
for f in config.toml device_id; do
  [ -f "$source_kimi_home/$f" ] && cp "$source_kimi_home/$f" "$kimi_home/$f"
done
for d in credentials oauth; do
  [ -d "$source_kimi_home/$d" ] && cp -r "$source_kimi_home/$d" "$kimi_home/$d"
done

# --- isolated home: managed plugin install from this arm's source -------------
managed="$kimi_home/plugins/managed/augments"
mkdir -p "$managed"
( cd "$plugin_src" && tar --exclude=.git --exclude=.augments -cf - . ) | tar -xf - -C "$managed"
[ -f "$managed/.kimi-plugin/plugin.json" ] || {
  echo "no .kimi-plugin/plugin.json in $plugin_src — does that ref carry the Kimi adapter?" >&2
  exit 2; }
skill_count="$(find "$managed/skills" -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')"
jq -n --arg root "$managed" \
      --arg manifest_path "$managed/.kimi-plugin/plugin.json" \
      --arg original "$plugin_src" \
      --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      --argjson skills "$skill_count" \
      --slurpfile manifest "$managed/.kimi-plugin/plugin.json" \
  '{version: 1, plugins: [{
     id: "augments", root: $root, source: "local-path", enabled: true,
     state: "ok", installedAt: $now, updatedAt: $now, originalSource: $original,
     skillCount: $skills, manifest: $manifest[0],
     manifestKind: "kimi-plugin-dir", manifestPath: $manifest_path,
     diagnostics: [], skillInstructions: $manifest[0].skillInstructions
   }]}' > "$kimi_home/plugins/installed.json" || exit 2

# --- disposable fixture, on a task branch ------------------------------------
cp -r "$sdir/fixture/." "$workdir/" || exit 2
(
  cd "$workdir" || exit 2
  git init -q . 2>/dev/null || exit 2
  git add -A
  git -c user.name='Augments Harness' -c user.email='harness@example.invalid' \
      commit -q -m 'scenario baseline'
  git switch -qc task/behavioral-probe
) || { echo "failed to seed fixture repo" >&2; exit 2; }

# No prompt suffix: the sessionStart nudge is part of what this exercises, so the
# opening goes in bare, as a real user opening.
( cd "$workdir" && exec timeout "$timeout_s" env KIMI_CODE_HOME="$kimi_home" \
    kimi -p "$(cat "$opening_file")" --output-format stream-json ) \
    < /dev/null > "$stream" 2>>"$errlog"
status=$?

chain="$(jq -rc '
  select(.role == "assistant")
  | .tool_calls[]?
  | select(.function.name == "Skill")
  | (.function.arguments | try fromjson catch {} | .skill // empty)
  | "augments:" + .' "$stream" 2>/dev/null | awk '!seen[$0]++' | paste -sd' ' -)"

echo "scenario   : $scenario"
echo "adapter    : kimi-code"
echo "arm        : $arm  (skills from: $([ "$arm" = red ] && echo "$base" || echo 'working tree'))"
echo "opening    : $(basename "$opening_file")"
echo "exit       : $status"
echo "skill chain: ${chain:-（none）}"
echo "artifacts  :"
# Committed AND uncommitted: an agent that wraps its branch commits the work,
# and a status-only view then shows an empty tree and reads as "produced nothing".
( cd "$workdir" && {
    root="$(git rev-list --max-parents=0 HEAD 2>/dev/null | tail -1)"
    [ -n "$root" ] && git diff --name-status --diff-filter=A "$root" HEAD 2>/dev/null | sed "s/^/  committed /"
    git status --porcelain -uall | sed "s/^/  /"
  } )

if [ "$status" -eq 124 ]; then
  echo "verdict    : TIMEOUT after ${timeout_s}s — run was cut off, treat as inconclusive"
  exit 1
elif [ "$status" -ne 0 ]; then
  echo "verdict    : ERROR — kimi exited $status (see $errlog)"
  exit 1
fi
if grep -qi 'usage limit\|api_error: 4' "$stream" "$errlog" 2>/dev/null; then
  echo "verdict    : BLOCKED — provider refused (quota/auth); not a behavioural result"
  exit 1
fi

if [ -x "$sdir/probe.sh" ]; then
  echo "probe      :"
  "$sdir/probe.sh" "$workdir" 2>&1 | sed 's/^/  /'
  pstat="${PIPESTATUS[0]}"
  [ "$pstat" -eq 0 ] && echo "verdict    : PASS" || echo "verdict    : FAIL (probe exit $pstat)"
  exit "$pstat"
fi

echo "verdict    : UNSCORED — no executable probe.sh in $sdir"
exit 0
