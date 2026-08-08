#!/usr/bin/env bash
# Rebuild the Codex plugin package from canonical sources.
#
# The plugin is installed standalone — copied out of this repository into Codex's
# plugin cache — so anything its manifest or hooks reference must live inside the
# plugin root. That is the skills (flattened, because the manifest points at one
# directory) AND the session-start injector its hooks run.

set -euo pipefail
cd "$(dirname "$0")/../.." || exit 2

root="plugins/sdlc-skills"
out="$root/skills"
mkdir -p "$out"

find "$out" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +

while IFS= read -r skill_md; do
  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  dest="$out/$name"
  mkdir -p "$dest"
  cp -a "$src/." "$dest/"
done < <(find skills -mindepth 3 -maxdepth 3 -name SKILL.md | sort)

# The hook is inert without the injector beside it. session-start.sh resolves the
# router relative to its own location, and it knows the flat mirror layout, so
# the copy needs no rewriting — only to be present and executable.
mkdir -p "$root/scripts/sh"
cp -a scripts/sh/session-start.sh "$root/scripts/sh/session-start.sh"
chmod +x "$root/scripts/sh/session-start.sh"
