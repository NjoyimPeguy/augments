#!/usr/bin/env bash
# Install smoke test — ONE runner for every harness. NO model call.
#
# Answers the question that comes before every other test: if a user installs
# augments the way this harness installs plugins, do the skills actually land
# where the CLI will look for them? A harness can pass every activation scenario
# against a working tree and still be broken for a real user whose install path
# differs — files present but never discovered is not a working integration.
#
# It drives `adapter_install`, the same function the live runners use, so it
# smokes the real path rather than a description of it.
#
# Usage: tests/run-plugin-smoke.sh --harness claude-code|codex|kimi-code

set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"
cd "$scriptdir/.." || exit 2
repo="$PWD"

harness=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --harness) harness="$2"; shift 2;;
    *) echo "unknown argument: $1" >&2; exit 2;;
  esac
done
[ -n "$harness" ] || { echo "needs --harness claude-code|codex|kimi-code" >&2; exit 2; }
[ -f "$scriptdir/harnesses/$harness.sh" ] || { echo "no harness adapter: $harness" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "needs \`jq\`" >&2; exit 3; }
. "$scriptdir/harnesses/$harness.sh"
adapter_check || exit 3

errlog="$(mktemp)"; harness_home=""; plugin_dir=""
trap '[ -n "$harness_home" ] && rm -rf "$harness_home"; rm -f "$errlog"' EXIT

canonical="$(find "$repo/skills" -name SKILL.md | wc -l | tr -d ' ')"
fails=0
echo "harness : $harness"
echo "skills  : $canonical on disk"

if ! adapter_install "$repo"; then
  echo "  FAIL  install failed (see below)"; cat "$errlog" >&2; exit 1
fi
echo "  ok    install completed"

# Whatever the mechanism, the skills must be discoverable afterwards. Claude Code
# loads the tree in place, so plugin_dir is the answer; the others copy or
# register into an isolated home.
root="${harness_home:-$plugin_dir}"
[ -n "$root" ] || { echo "  FAIL  adapter_install set neither harness_home nor plugin_dir"; exit 1; }

found="$(find "$root" -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')"
if [ "$found" -ge "$canonical" ]; then
  echo "  ok    $found SKILL.md discoverable after install"
else
  echo "  FAIL  only $found of $canonical skills discoverable under $root"; fails=1
fi

# The manifest this harness reads must exist wherever the install put it.
case "$harness" in
  claude-code) manifest='.claude-plugin/plugin.json';;
  kimi-code)   manifest='.kimi-plugin/plugin.json';;
  codex)       manifest='';;   # registered via the marketplace, not a copied file
esac
if [ -n "$manifest" ]; then
  if find "$root" -path "*/$manifest" 2>/dev/null | grep -q .; then
    echo "  ok    $manifest present after install"
  else
    echo "  FAIL  $manifest missing after install"; fails=1
  fi
fi

[ "$fails" -eq 0 ] && echo "plugin smoke: PASS" || echo "plugin smoke: FAIL"
exit "$fails"
