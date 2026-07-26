#!/usr/bin/env bash
# No-model smoke test for the Codex plugin adapter.

set -uo pipefail
scriptdir="$(cd "$(dirname "$0")" && pwd)"
repo="$(cd "$scriptdir/../.." && pwd)"

command -v codex >/dev/null 2>&1 || { echo "no \`codex\` CLI on PATH" >&2; exit 3; }

home="$(mktemp -d)"
trap 'rm -rf "$home"' EXIT

echo "marketplace add: $repo"
env CODEX_HOME="$home" codex plugin marketplace add "$repo" --json >/tmp/augments-codex-marketplace-add.json || exit $?

echo "plugin list: augments-dev"
if ! env CODEX_HOME="$home" codex plugin list --marketplace augments-dev --available --json | grep -q '"name"[[:space:]]*:[[:space:]]*"augments"'; then
  echo "augments was not listed from augments-dev" >&2
  exit 1
fi

echo "plugin add: augments@augments-dev"
env CODEX_HOME="$home" codex plugin add augments@augments-dev --json >/tmp/augments-codex-plugin-add.json || exit $?

echo "Codex plugin smoke: PASS"
