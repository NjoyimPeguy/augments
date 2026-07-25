#!/usr/bin/env bash
# Real end-to-end BEHAVIOURAL test for the Claude Code adapter.
#
# run-activation.sh answers "did the skill fire?" — a question with one generic
# verdict (a structured Skill tool_use), which is why it can be a scenario-
# agnostic engine. This script answers "did the skill change what actually got
# BUILT?", which has no generic verdict: what counts as success differs per
# skill. So responsibility is split —
#
#   this runner   owns the plumbing: fixture isolation, which skills the arm
#                 loads, write permissions, running to completion, capture.
#   the scenario  owns the verdict, as a probe.sh that turns a finished
#                 workdir into pass/fail.
#
# Same non-portability caveats as run-activation.sh: it binds to the `claude`
# binary and makes a REAL API call, so it is a manual/record tool, never CI.
# It costs about one full task per arm — far more than an activation probe,
# which kills on the first Skill call. Run it when a skill's BODY changed.
#
# TWO ARMS. A behavioural claim is a comparison, so the runner materialises both
# sides itself:
#   --arm green   loads the working tree (your edit) via --plugin-dir.
#   --arm red     loads the skills as of --base (default origin/dev) from a
#                 throwaway `git worktree`, so the before-arm stays reproducible
#                 AFTER the change is committed. Running RED by hand before
#                 editing works exactly once and cannot be re-run.
#
# WRITE ACCESS is the other difference from activation: the agent must be able to
# produce artifacts, so Write/Edit/Bash are allowed and edits are auto-accepted.
# That is safe because the run happens in a disposable copy of the scenario
# fixture under /tmp — never in this repo.
#
# Usage:
#   run-behavioral.sh --scenario spec-it --arm red
#   run-behavioral.sh --scenario spec-it --arm green --keep
#   run-behavioral.sh --scenario spec-it --arm red --base <ref> --timeout 1200
#
# Scenario layout (behavioral-scenarios/<name>/):
#   fixture/   a seeded project, copied per run and committed on a task branch
#   opening    the prompt, byte-identical across arms — an arm that changes the
#              prompt is not a comparison
#   probe.sh   receives the finished workdir as $1; prints evidence lines and
#              exits non-zero when the arm did not produce the target behaviour.
#              Exit code is the verdict; prose in a record is not.

set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"
cd "$scriptdir/../../.." || exit 2   # repo root
repo="$PWD"

scenario=""; arm=""; base="origin/dev"; timeout_s=1200; keep=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --scenario) scenario="$2"; shift 2;;
    --arm)      arm="$2"; shift 2;;
    --base)     base="$2"; shift 2;;      # RED arm: the ref holding pre-change skills
    --timeout)  timeout_s="$2"; shift 2;;
    --keep)     keep="1"; shift;;         # preserve workdir + stream for inspection
    *) echo "unknown argument: $1" >&2; exit 2;;
  esac
done

[ -n "$scenario" ] || { echo "needs --scenario NAME" >&2; exit 2; }
case "$arm" in red|green) ;; *) echo "needs --arm red|green" >&2; exit 2;; esac
command -v claude >/dev/null 2>&1 || { echo "no \`claude\` CLI on PATH" >&2; exit 3; }
command -v jq     >/dev/null 2>&1 || { echo "needs \`jq\`" >&2; exit 3; }

sdir="$scriptdir/behavioral-scenarios/$scenario"
[ -d "$sdir/fixture" ] || { echo "no fixture at $sdir/fixture" >&2; exit 2; }
[ -f "$sdir/opening" ] || { echo "no opening at $sdir/opening" >&2; exit 2; }

workdir="$(mktemp -d)"; stream="$(mktemp)"; errlog="$(mktemp)"; redtree=""
cleanup() {
  [ -n "$redtree" ] && git -C "$repo" worktree remove --force "$redtree" >/dev/null 2>&1
  if [ -n "$keep" ]; then
    echo "kept: workdir=$workdir stream=$stream errlog=$errlog"
  else
    rm -rf "$workdir"; rm -f "$stream" "$errlog"
  fi
}
trap cleanup EXIT

# --- which skills does this arm load? -------------------------------------
if [ "$arm" = "red" ]; then
  git -C "$repo" rev-parse --verify "$base" >/dev/null 2>&1 || {
    echo "--base '$base' is not a valid ref (fetch first?)" >&2; exit 2; }
  redtree="$(mktemp -d)"; rm -rf "$redtree"
  git -C "$repo" worktree add --detach "$redtree" "$base" >/dev/null 2>&1 || {
    echo "could not create worktree at $base" >&2; redtree=""; exit 2; }
  plugin_dir="$redtree"
else
  plugin_dir="$repo"
fi

# --- disposable fixture, on a task branch so branch-discipline skills settle ---
cp -r "$sdir/fixture/." "$workdir/" || exit 2
(
  cd "$workdir" || exit 2
  git init -q . 2>/dev/null || exit 2
  git add -A
  git -c user.name='Augments Harness' -c user.email='harness@example.invalid' \
      commit -q -m 'scenario baseline'
  git switch -qc task/behavioral-probe
) || { echo "failed to seed fixture repo" >&2; exit 2; }

opening="$(cat "$sdir/opening")"

( cd "$workdir" && exec timeout "$timeout_s" claude -p "$opening" \
    --output-format stream-json --verbose \
    --plugin-dir "$plugin_dir" \
    --allowedTools Skill Read Glob Grep Write Edit Bash TodoWrite \
    --permission-mode acceptEdits ) < /dev/null > "$stream" 2>>"$errlog"
status=$?

# --- capture ---------------------------------------------------------------
chain="$(jq -r 'select(.type=="assistant") | .message.content[]?
                | select(.type=="tool_use" and .name=="Skill") | .input.skill' \
         "$stream" 2>/dev/null | awk '!seen[$0]++' | paste -sd' ' -)"
calls="$(jq -r 'select(.type=="assistant") | .message.content[]?
                | select(.type=="tool_use") | .name' "$stream" 2>/dev/null | wc -l | tr -d ' ')"

echo "scenario   : $scenario"
echo "arm        : $arm  (skills from: $([ "$arm" = red ] && echo "$base" || echo 'working tree'))"
echo "exit       : $status"
echo "skill chain: ${chain:-（none）}"
echo "tool calls : $calls"
echo "artifacts  :"
( cd "$workdir" && git status --porcelain -uall | sed 's/^/  /' )

if [ "$status" -ne 0 ]; then
  echo "verdict    : ERROR — claude exited $status (see $errlog)"
  exit 1
fi

# --- verdict belongs to the scenario ---------------------------------------
if [ -x "$sdir/probe.sh" ]; then
  echo "probe      :"
  "$sdir/probe.sh" "$workdir" 2>&1 | sed 's/^/  /'
  pstat="${PIPESTATUS[0]}"
  [ "$pstat" -eq 0 ] && echo "verdict    : PASS" || echo "verdict    : FAIL (probe exit $pstat)"
  exit "$pstat"
fi

echo "verdict    : UNSCORED — no executable probe.sh in $sdir"
exit 0
