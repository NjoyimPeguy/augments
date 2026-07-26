#!/usr/bin/env bash
# Structural validator for the repo-local Codex plugin adapter.

set -uo pipefail
cd "$(dirname "$0")/../.." || exit 2

fail=0
err() { printf '  FAIL: %s\n' "$1"; fail=1; }

plugin_root="plugins/augments"
manifest="$plugin_root/.codex-plugin/plugin.json"
marketplace=".agents/plugins/marketplace.json"
codex_hook=".codex/hooks.json"
codex_hook_template="hooks/hooks-codex.json"

echo "• $manifest"
[ -f "$manifest" ] || err "missing Codex plugin manifest"
[ -f "$marketplace" ] || err "missing Codex marketplace"

if [ -f "$manifest" ]; then
  grep -q '"name"[[:space:]]*:[[:space:]]*"augments"' "$manifest" || err "plugin name is not augments"
  grep -q '"skills"[[:space:]]*:[[:space:]]*"\./skills/"' "$manifest" || err "plugin skills path must be ./skills/"
  for field in displayName shortDescription longDescription developerName category defaultPrompt; do
    grep -q "\"$field\"" "$manifest" || err "missing interface.$field"
  done
fi

if [ -f "$marketplace" ]; then
  grep -q '"name"[[:space:]]*:[[:space:]]*"augments-dev"' "$marketplace" || err "marketplace name is not augments-dev"
  grep -q '"path"[[:space:]]*:[[:space:]]*"\./plugins/augments"' "$marketplace" || err "marketplace source path must be ./plugins/augments"
  grep -q '"installation"[[:space:]]*:[[:space:]]*"AVAILABLE"' "$marketplace" || err "marketplace policy.installation missing"
  grep -q '"authentication"[[:space:]]*:[[:space:]]*"ON_INSTALL"' "$marketplace" || err "marketplace policy.authentication missing"
  grep -q '"category"[[:space:]]*:[[:space:]]*"Developer Tools"' "$marketplace" || err "marketplace category missing"
fi

echo "• Codex hook config"
[ -f "$codex_hook" ] || err "missing repo Codex hook config"
[ -f "$codex_hook_template" ] || err "missing reusable Codex hook config"
if [ -f "$codex_hook" ] && [ -f "$codex_hook_template" ]; then
  diff -q "$codex_hook_template" "$codex_hook" >/dev/null || err "repo Codex hook config differs from hooks/hooks-codex.json"
  grep -q 'hooks/stop-nudge.sh' "$codex_hook" || err "Codex hook config does not invoke hooks/stop-nudge.sh"
fi
[ -x hooks/stop-nudge.sh ] || err "hooks/stop-nudge.sh is not executable"

echo "• Codex skill mirror"
while IFS= read -r skill; do
  name="$(basename "$(dirname "$skill")")"
  mirror="$plugin_root/skills/$name"
  [ -d "$mirror" ] || { err "missing mirrored skill for $name at $mirror"; continue; }
  [ -f "$mirror/SKILL.md" ] || err "mirrored skill for $name is missing SKILL.md"
  diff -qr "$(dirname "$skill")" "$mirror" >/dev/null || err "mirrored skill differs from canonical skill: $name"
done < <(find skills -mindepth 3 -maxdepth 3 -name SKILL.md | sort)

echo "• manifest versions agree"
codex_v=""
claude_v=""
if [ -f "$manifest" ]; then
  codex_v="$(grep -m1 -oE '"version"[[:space:]]*:[[:space:]]*"[^"]+"' "$manifest" | sed -E 's/.*"([^"]+)"$/\1/')"
fi
if [ -f ".claude-plugin/plugin.json" ]; then
  claude_v="$(grep -m1 -oE '"version"[[:space:]]*:[[:space:]]*"[^"]+"' .claude-plugin/plugin.json | sed -E 's/.*"([^"]+)"$/\1/')"
fi
[ -n "$codex_v" ] || err "Codex manifest has no version"
[ -n "$claude_v" ] || err "Claude manifest has no version"
[ -n "$codex_v" ] && [ -n "$claude_v" ] && [ "$codex_v" != "$claude_v" ] && err "Codex version $codex_v != Claude version $claude_v"

echo ""
if [ "$fail" -eq 0 ]; then
  echo "✓ Codex plugin adapter passes structural validation"
else
  echo "✗ Codex plugin adapter violations found"
fi
exit "$fail"
