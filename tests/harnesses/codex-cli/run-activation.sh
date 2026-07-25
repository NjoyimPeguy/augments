#!/usr/bin/env bash
# Real activation probe for the Codex CLI adapter.

set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"
orig_pwd="$PWD"
repo="$(cd "$scriptdir/../../.." && pwd)"
source_codex_home="${CODEX_HOME:-${HOME:-}/.codex}"

SKILL_FILTER='
  if (.type == "item.started" or .type == "item.completed")
     and .item.type == "command_execution" then
    (.item.command // "") as $cmd
    | ($cmd | scan("/skills/(?<skill>[A-Za-z0-9_-]+)/SKILL[.]md")? | .[0])
    | if . == "" then empty else "augments:" + . end
  else
    empty
  end'

is_skill() { find "$repo/skills" -maxdepth 2 -type d -name "$1" 2>/dev/null | grep -q .; }

if [ "${1:-}" = "selftest" ]; then
  command -v jq >/dev/null 2>&1 || { echo "selftest needs jq" >&2; exit 3; }
  # Inline fixtures, written to a temp dir per run — no .jsonl files in the tree.
  fxdir="$(mktemp -d)"; trap 'rm -rf "$fxdir"' EXIT
  cat > "$fxdir/fired-debugging.jsonl" <<'FX'
{"type":"item.started","item":{"id":"item_1","type":"command_execution","command":"/bin/bash -lc \"sed -n '1,260p' /home/user/.codex/plugins/cache/augments-dev/augments/2.2.0/skills/debugging/SKILL.md\"","aggregated_output":"","exit_code":null,"status":"in_progress"}}
{"type":"item.completed","item":{"id":"item_1","type":"command_execution","command":"/bin/bash -lc \"sed -n '1,260p' /home/user/.codex/plugins/cache/augments-dev/augments/2.2.0/skills/debugging/SKILL.md\"","aggregated_output":"---\nname: debugging\n---\n","exit_code":0,"status":"completed"}}
FX
  cat > "$fxdir/none.jsonl" <<'FX'
{"type":"response_item","payload":{"type":"message","role":"assistant","content":[{"type":"output_text","text":"I can inspect the code first."}]}}
FX
  cat > "$fxdir/routed-multi-skill-command.jsonl" <<'FX'
{"type":"item.completed","item":{"type":"command_execution","command":"/bin/bash -lc \"sed -n '1,240p' /tmp/codex/plugins/cache/augments/skills/using-augments/SKILL.md && sed -n '1,240p' /tmp/codex/plugins/cache/augments/skills/using-task-branches/SKILL.md\""}}
FX
  fail=0
  check() {
    fixture="$1"
    want="$2"
    got="$(jq -rc "$SKILL_FILTER" "$fxdir/$fixture" 2>/dev/null | head -n1)"
    if [ "$got" = "$want" ]; then
      printf 'ok    %-24s -> %s\n' "$fixture" "${got:-<none>}"
    else
      printf 'FAIL  %-24s -> got "%s" want "%s"\n' "$fixture" "$got" "$want"
      fail=1
    fi
  }
  check_has() {
    fixture="$1"
    want="$2"
    if jq -rc "$SKILL_FILTER" "$fxdir/$fixture" 2>/dev/null | grep -qx "$want"; then
      printf 'ok    %-24s contains %s\n' "$fixture" "$want"
    else
      printf 'FAIL  %-24s lacks "%s"\n' "$fixture" "$want"
      fail=1
    fi
  }
  check fired-debugging.jsonl "augments:debugging"
  check none.jsonl ""
  check_has routed-multi-skill-command.jsonl "augments:using-task-branches"
  [ "$fail" -eq 0 ] && echo "Codex activation detector self-test: PASS" || echo "Codex activation detector self-test: FAIL"
  exit "$fail"
fi

scenario=""
sfile=""
expect=""
timeout_s=180
keep=""
fixture_git=""
wt=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --scenario) scenario="$2"; shift 2;;
    --scenario-file) sfile="$2"; shift 2;;
    --expect) expect="$2"; shift 2;;
    --timeout) timeout_s="$2"; shift 2;;
    --keep) keep="1"; shift;;
    --fixture-git-repo) fixture_git="1"; shift;;
    --working-tree) wt="1"; shift;;
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
codex_home=""
trap '[ -z "$keep" ] && rm -f "$stream" "$errlog"; rm -rf "$workdir" "$codex_home"' EXIT

if [ -n "$fixture_git" ]; then
  (
    cd "$workdir" || exit 2
    git init -q -b main 2>/dev/null || { git init -q && git checkout -qb main; }
    printf '# Activation fixture\n\nA disposable repository for skill-routing probes.\n' > README.md
    git add README.md
    git -c user.name='Augments Harness' -c user.email='harness@example.invalid' commit -q -m 'fixture baseline'
  ) || { echo "failed to create disposable git repo fixture" >&2; exit 2; }
fi

if [ -n "$wt" ]; then
  codex_home="$(mktemp -d)"
  for f in auth.json config.toml models_cache.json; do
    [ -f "$source_codex_home/$f" ] && cp "$source_codex_home/$f" "$codex_home/$f"
  done
  env CODEX_HOME="$codex_home" codex plugin marketplace add "$repo" --json >/dev/null 2>>"$errlog" || exit $?
  env CODEX_HOME="$codex_home" codex plugin add augments@augments-dev --json >/dev/null 2>>"$errlog" || exit $?
fi

prompt="$scenario

Use the relevant Augments skill according to the skill instructions: read its SKILL.md completely before answering."

if [ -n "$wt" ]; then
  ( cd "$workdir" && exec timeout "$timeout_s" env CODEX_HOME="$codex_home" codex exec --json --ephemeral --skip-git-repo-check -s read-only -C "$workdir" "$prompt" ) < /dev/null >"$stream" 2>>"$errlog"
else
  ( cd "$workdir" && exec timeout "$timeout_s" codex exec --json --ephemeral --skip-git-repo-check -s read-only -C "$workdir" "$prompt" ) < /dev/null >"$stream" 2>>"$errlog"
fi
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
elif [ -n "$chain" ]; then
  verdict="ROUTED ELSEWHERE — chain: ${chain_str} (expected ${want})"
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
  echo "stream   : tests/harnesses/codex-cli/last-stream.jsonl"
  echo "stderr   : tests/harnesses/codex-cli/last-stderr.log"
fi
exit "$result"
