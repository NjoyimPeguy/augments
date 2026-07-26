#!/usr/bin/env bash
# Assertion helpers for behavioural scenarios. Sourced, never executed.
#
# A scenario's assertions decide the verdict, and the verdict is this script's
# EXIT CODE — not prose in a summary written by the agent that wants it green.
# Call `assert_*` freely; call `assert_result` last to return the verdict.

_af=0

pass() { printf '  ok    %s\n' "$1"; }
fail() { printf '  FAIL  %s\n' "$1"; _af=1; }
note() { printf '  ---   %s\n' "$1"; }

assert_file() { # $1 path (glob ok)  $2 description
  local f; f="$(compgen -G "$1" 2>/dev/null | head -1)"
  [ -n "$f" ] && { pass "$2 ($f)"; ASSERT_MATCH="$f"; return 0; }
  fail "$2 — nothing matched $1"; ASSERT_MATCH=""; return 1
}

assert_contains() { # $1 haystack  $2 regex  $3 description
  printf '%s' "$1" | grep -qiE -- "$2" && { pass "$3"; return 0; }
  fail "$3 — expected to match: $2"; return 1
}

assert_not_contains() { # $1 haystack  $2 regex  $3 description
  printf '%s' "$1" | grep -qiE -- "$2" && { fail "$3 — matched: $2"; return 1; }
  pass "$3"; return 0
}

# Everything added since the runner's baseline commit, COMMITTED or not.
# Untracked-only detection is a false-negative trap: an agent that wraps its
# branch commits its work, `git status` then reports a clean tree, and a real
# pass gets scored as "produced nothing". That happened once, on Kimi.
added_since_baseline() { # $1 workdir
  ( cd "$1" || return
    local root; root="$(git rev-list --max-parents=0 HEAD 2>/dev/null | tail -1)"
    { [ -n "$root" ] && git diff --name-only --diff-filter=A "$root" HEAD 2>/dev/null
      git status --porcelain -uall 2>/dev/null | awk '$1=="??"{print $2}'; } | sort -u )
}

assert_result() { [ "$_af" -eq 0 ] && { echo "  RESULT: pass"; return 0; }; echo "  RESULT: fail"; return 1; }
