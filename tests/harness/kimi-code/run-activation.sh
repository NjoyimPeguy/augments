#!/usr/bin/env bash
# Real activation probe for the Kimi Code CLI adapter.
#
# Each live run uses an isolated temporary KIMI_CODE_HOME: the user's auth
# (config.toml, credentials/, device_id, oauth/) is copied in, and this
# checkout is installed as a managed plugin (plugins/managed/augments plus a
# plugins/installed.json record), the same layout `kimi /plugins install`
# produces. The probe then drives `kimi -p --output-format stream-json` and
# observes activation as a `Skill` tool call naming a canonical Augments skill.

set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"
orig_pwd="$PWD"
repo="$(cd "$scriptdir/../../.." && pwd)"
source_kimi_home="${KIMI_CODE_HOME:-${HOME:-}/.kimi-code}"

SKILL_FILTER='
  select(.role == "assistant")
  | .tool_calls[]?
  | select(.function.name == "Skill")
  | (.function.arguments | try fromjson catch {} | .skill // empty)
  | "augments:" + .'

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
  check builtin-skill.jsonl "augments:check-kimi-code-docs"
  [ "$fail" -eq 0 ] && echo "Kimi activation detector self-test: PASS" || echo "Kimi activation detector self-test: FAIL"
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
command -v kimi >/dev/null 2>&1 || { echo "no \`kimi\` CLI on PATH" >&2; exit 3; }
command -v jq >/dev/null 2>&1 || { echo "needs \`jq\`" >&2; exit 3; }

workdir="$(mktemp -d)"
kimi_home="$(mktemp -d)"
stream="$(mktemp)"
errlog="$(mktemp)"
trap '[ -z "$keep" ] && rm -f "$stream" "$errlog"; rm -rf "$workdir" "$kimi_home"' EXIT

# --- isolated home: auth -----------------------------------------------------
for f in config.toml device_id; do
  [ -f "$source_kimi_home/$f" ] && cp "$source_kimi_home/$f" "$kimi_home/$f"
done
for d in credentials oauth; do
  [ -d "$source_kimi_home/$d" ] && cp -r "$source_kimi_home/$d" "$kimi_home/$d"
done

# --- isolated home: managed plugin install from this checkout ----------------
managed="$kimi_home/plugins/managed/augments"
mkdir -p "$managed"
( cd "$repo" && tar --exclude=.git --exclude=.augments -cf - . ) | tar -xf - -C "$managed"
jq -n --arg root "$managed" \
      --arg manifest_path "$managed/.kimi-plugin/plugin.json" \
      --arg original "$repo" \
      --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      --slurpfile manifest "$managed/.kimi-plugin/plugin.json" \
  '{version: 1, plugins: [{
     id: "augments",
     root: $root,
     source: "local-path",
     enabled: true,
     state: "ok",
     installedAt: $now,
     updatedAt: $now,
     originalSource: $original,
     skillCount: 30,
     manifest: $manifest[0],
     manifestKind: "kimi-plugin-dir",
     manifestPath: $manifest_path,
     diagnostics: [],
     skillInstructions: $manifest[0].skillInstructions
   }]}' > "$kimi_home/plugins/installed.json"

# --- drive the CLI -----------------------------------------------------------
# No prompt suffix: the sessionStart.skill nudge (using-augments) is part of
# what this probe proves, so the scenario goes in bare, as a real user opening.
( cd "$workdir" && exec timeout "$timeout_s" env KIMI_CODE_HOME="$kimi_home" kimi -p "$scenario" --output-format stream-json ) < /dev/null >"$stream" 2>>"$errlog"
status=$?

chain="$(jq -rc "$SKILL_FILTER" "$stream" 2>/dev/null | awk '!seen[$0]++')"
chain_str="$(printf '%s' "$chain" | paste -sd' ' -)"
want=""
[ -n "$expect" ] && want="augments:$expect"

if [ -n "$want" ] && printf '%s\n' "$chain" | grep -qx "$want"; then
  verdict="ACTIVATED — chain: ${chain_str} (invoked ${want})"
  result=0
elif [ -z "$want" ] && [ -n "$chain" ]; then
  verdict="ACTIVATED — chain: ${chain_str}"
  result=0
elif [ "$status" -ne 0 ] && [ "$status" -ne 124 ]; then
  verdict="ERROR — kimi exited $status"
  result=1
elif [ -n "$chain" ]; then
  verdict="ROUTED ELSEWHERE — chain: ${chain_str} (expected ${want})"
  result=1
else
  verdict="NONE (no Augments Skill invocation)"
  result=1
fi

echo "scenario : ${scenario}"
[ -n "$expect" ] && echo "expected : augments:${expect}"
echo "verdict  : ${verdict}"
echo "captured : $(grep -c . "$stream" 2>/dev/null || echo 0) JSON events"
if [ "$status" -eq 124 ]; then
  echo "note     : run hit the ${timeout_s}s timeout after activation evidence was captured"
fi
if [ -s "$errlog" ]; then
  echo "stderr   : $(grep -c . "$errlog" 2>/dev/null || echo 0) lines"
fi
if [ -n "$keep" ]; then
  cp "$stream" "$scriptdir/last-stream.jsonl"
  cp "$errlog" "$scriptdir/last-stderr.log"
  echo "stream   : tests/harness/kimi-code/last-stream.jsonl"
  echo "stderr   : tests/harness/kimi-code/last-stderr.log"
fi
exit "$result"
