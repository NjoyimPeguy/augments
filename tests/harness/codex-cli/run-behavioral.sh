#!/usr/bin/env bash
# Real end-to-end BEHAVIOURAL test for the Codex CLI adapter.
#
# The Codex sibling of ../claude-code/run-behavioral.sh: same two-arm shape, same
# shared scenarios (../behavioral-scenarios/), same rule that the verdict is the
# scenario probe's EXIT CODE rather than prose in a record. Only the plumbing is
# harness-specific — an isolated CODEX_HOME with this checkout installed from a
# local marketplace, as run-activation.sh does, with `-s read-only` swapped for
# `-s workspace-write` so the agent can actually produce artifacts.
#
# Same caveats: binds to the `codex` binary, makes REAL API calls, costs about a
# full task per arm. Manual/record tool, never CI.
#
# TWO ARMS:
#   --arm green   installs the plugin from the working tree (your edit).
#   --arm red     installs from a throwaway `git worktree` at --base, so the
#                 before-arm stays reproducible AFTER the change is committed.
#
# OPENING: this adapter uses ../behavioral-scenarios/<name>/opening.codex-cli
# when present. `codex exec` is single-turn, so a scenario that invites a
# clarifying question ends the run with NO deliverable — the first spec-it arm
# terminated on an interview question after routing correctly. Both arms share
# whichever opening is selected; that is what keeps RED vs GREEN a comparison.
#
# Usage:
#   run-behavioral.sh --scenario spec-it --arm green [--keep]
#   run-behavioral.sh --scenario spec-it --arm red --base origin/dev [--timeout 2400]

set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"
cd "$scriptdir/../../.." || exit 2
repo="$PWD"
source_codex_home="${CODEX_HOME:-${HOME:-}/.codex}"

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
command -v codex >/dev/null 2>&1 || { echo "no \`codex\` CLI on PATH" >&2; exit 3; }
command -v jq    >/dev/null 2>&1 || { echo "needs \`jq\`" >&2; exit 3; }

sdir="$scriptdir/../behavioral-scenarios/$scenario"
[ -d "$sdir/fixture" ] || { echo "no fixture at $sdir/fixture" >&2; exit 2; }
opening_file="$sdir/opening.codex-cli"
[ -f "$opening_file" ] || opening_file="$sdir/opening.default"
[ -f "$opening_file" ] || { echo "no opening in $sdir" >&2; exit 2; }

workdir="$(mktemp -d)"; stream="$(mktemp)"; errlog="$(mktemp)"
codex_home="$(mktemp -d)"; redtree=""
cleanup() {
  [ -n "$redtree" ] && git -C "$repo" worktree remove --force "$redtree" >/dev/null 2>&1
  rm -rf "$codex_home"
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

# --- isolated home: auth, then install from this arm's source ----------------
for f in auth.json config.toml models_cache.json; do
  [ -f "$source_codex_home/$f" ] && cp "$source_codex_home/$f" "$codex_home/$f"
done
# A copied config.toml can already register `augments-dev` against the real repo,
# which collides when this arm's source differs. Drop it in the ISOLATED home
# only — the user's own CODEX_HOME is never touched.
env CODEX_HOME="$codex_home" codex plugin remove augments >/dev/null 2>&1
env CODEX_HOME="$codex_home" codex plugin marketplace remove augments-dev >/dev/null 2>&1
env CODEX_HOME="$codex_home" codex plugin marketplace add "$plugin_src" --json >/dev/null 2>>"$errlog" || {
  echo "marketplace add failed (see $errlog)" >&2; exit 3; }
env CODEX_HOME="$codex_home" codex plugin add augments@augments-dev --json >/dev/null 2>>"$errlog" || {
  echo "plugin add failed (see $errlog)" >&2; exit 3; }

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

# Same skill-instructions suffix run-activation.sh appends for this harness.
prompt="$(cat "$opening_file")

Use the relevant Augments skill according to the skill instructions: read its SKILL.md completely before answering."

( cd "$workdir" && exec timeout "$timeout_s" env CODEX_HOME="$codex_home" \
    codex exec --json --skip-git-repo-check -s workspace-write -C "$workdir" "$prompt" ) \
    < /dev/null > "$stream" 2>>"$errlog"
status=$?

# Codex reads skills as shell commands, so activation is a command_execution that
# touches an installed SKILL.md — the same filter run-activation.sh uses.
chain="$(jq -rc '
  if (.type == "item.started" or .type == "item.completed")
     and .item.type == "command_execution" then
    (.item.command // "") as $cmd
    | ($cmd | scan("/skills/(?<skill>[A-Za-z0-9_-]+)/SKILL[.]md")? | .[0])
    | if . == "" then empty else "augments:" + . end
  else empty end' "$stream" 2>/dev/null | awk '!seen[$0]++' | paste -sd' ' -)"

echo "scenario   : $scenario"
echo "adapter    : codex-cli"
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
  echo "verdict    : ERROR — codex exited $status (see $errlog)"
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
