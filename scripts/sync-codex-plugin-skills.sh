#!/usr/bin/env bash
# Rebuild the flat Codex plugin skill mirror from the canonical phase tree.

set -euo pipefail
cd "$(dirname "$0")/.." || exit 2

out="plugins/augments/skills"
mkdir -p "$out"

find "$out" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +

while IFS= read -r skill_md; do
  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  dest="$out/$name"
  mkdir -p "$dest"
  cp -a "$src/." "$dest/"
done < <(find skills -mindepth 3 -maxdepth 3 -name SKILL.md | sort)
