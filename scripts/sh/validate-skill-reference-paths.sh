#!/usr/bin/env bash
# Resolve navigation paths exactly as they appear in one installable skill tree.
# Usage: bash scripts/sh/validate-skill-reference-paths.sh <tree>

set -uo pipefail
cd "$(dirname "$0")/../.." || exit 2

tree="${1:-}"
[ -n "$tree" ] && [ -d "$tree" ] || {
  echo "usage: $0 <skill-tree>" >&2
  exit 2
}

fail=0
err() { printf '  FAIL: %s\n' "$1"; fail=1; }

check_ref() {
  local src="$1" line="$2" ref="$3" target
  ref="${ref%%#*}"
  case "$ref" in
    ""|\#*|/*|*://*|mailto:*|.sdlc-skills/*|*\{\{*) return ;;
  esac
  target="$(dirname "$src")/$ref"
  [ -e "$target" ] ||
    err "$src:$line: reference '$ref' does not resolve in install tree '$tree'"
}

while IFS=: read -r src line ref; do
  check_ref "$src" "$line" "$ref"
done < <(
  {
    find "$tree" -name '*.md' -exec grep -HnoE '\]\([^)]*\)' {} + |
      sed -E 's#:\]\(([^)]*)\)$#:\1#'
    find "$tree" -name SKILL.md -exec \
      grep -HnoE '(\.\./)*([A-Za-z0-9._-]+/)*references/[A-Za-z0-9._/-]+\.md' {} +
    find "$tree" -path '*/references/*.md' -exec \
      grep -HnoE '`(\.\./SKILL\.md|SKILL\.md|[A-Za-z0-9._-]+\.md)`' {} + |
      sed -E 's/:`([^`]*)`$/:\1/'
  } | sort -u
)

# Install adapters are allowed to package only a skill directory/tree. A
# shipped skill cannot depend on repository-only rationale under docs/.
while IFS=: read -r src line _; do
  err "$src:$line: repository-only docs/sdlc-skills path is not install-portable"
done < <(grep -rnE 'docs/sdlc-skills/[A-Za-z0-9._/-]+\.md' "$tree" || true)

exit "$fail"
