#!/usr/bin/env bash
# Offline test for the governed localhost preview (skills/**/scripts/serve.py).
#
# What this guards: the preview's safety contract is script logic, so it gets
# a unit check — the session key must gate every request, traversal and
# dotfile paths must never resolve, and the documented `kill` stop must shut
# the server down. A preview that leaks the trail to any local process, or
# that orphans a listener, is the failure this script exists to prevent.
#
# Deterministic and free: loopback only, no model, no network beyond
# 127.0.0.1. Both skill copies are exercised (the gate pins them identical;
# this checks the one agents actually run from each skill).
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

case "${1-}" in
  -h|--help)
    cat <<'EOF'
tests/run-serve-preview.sh — offline unit check for the serve.py preview.

Starts each skill's scripts/serve.py against a fixture root on 127.0.0.1 and
asserts the auth gate, path confinement, response headers, and clean stop.

  --help    this text

Exit codes: 0 every check passed · 1 at least one failed · 2 bad environment
EOF
    exit 0;;
esac

command -v python3 >/dev/null 2>&1 || { echo "needs python3" >&2; exit 2; }
command -v curl >/dev/null 2>&1 || { echo "needs curl" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "needs jq" >&2; exit 2; }

fails=0
ok()   { echo "  ok    $1"; }
bad()  { echo "  FAIL  $1"; fails=1; }
check(){ if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (expected '$3', got '$2')"; fi; }

fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/root/sub"
echo '<h1>preview</h1>' > "$fixture/root/index.html"
echo 'nested' > "$fixture/root/sub/page.txt"
echo 'secret' > "$fixture/outside.txt"

test_copy() { # $1 = path to the serve.py copy under test
  local script="$1" label="$2"
  echo "--- $label"

  python3 "$script" --help >/dev/null 2>&1
  check "--help exits 0" "$?" "0"

  local log="$fixture/server.log"
  : > "$log"
  python3 "$script" --root "$fixture/root" --idle-timeout-minutes 5 >"$log" 2>&1 &
  local shell_pid=$!

  local line="" i
  for i in $(seq 1 50); do
    line="$(grep -m1 'server-started' "$log" 2>/dev/null)" && break
    kill -0 "$shell_pid" 2>/dev/null || break
    sleep 0.1
  done
  if [ -z "$line" ]; then
    bad "server started and printed its record"; cat "$log" >&2; return
  fi
  ok "server started and printed its record"

  local url pid base key origin
  url="$(printf '%s' "$line" | jq -r .url)"
  pid="$(printf '%s' "$line" | jq -r .pid)"
  base="$(printf '%s' "$url" | sed 's|\?key=.*||')"
  key="$(printf '%s' "$url" | sed 's|.*\?key=||')"
  origin="$(printf '%s' "$url" | cut -d'/' -f1-3)"
  case "$url" in
    http://127.0.0.1:*/index.html\?key=*) ok "URL is loopback with entry and key" ;;
    *) bad "URL is loopback with entry and key (got $url)" ;;
  esac

  local code body headers
  code="$(curl -s -o /dev/null -w '%{http_code}' "$base")"
  check "no key is refused" "$code" "403"
  code="$(curl -s -o /dev/null -w '%{http_code}' "$base?key=deadbeef")"
  check "wrong key is refused" "$code" "403"

  headers="$(curl -s -D - -o "$fixture/body" "$url")"
  check "full key URL serves the page" "$(cat "$fixture/body")" "<h1>preview</h1>"
  body="$(printf '%s' "$headers" | tr -d '\r')"
  for h in 'Cache-Control: no-store' 'X-Content-Type-Options: nosniff' 'X-Frame-Options: SAMEORIGIN' 'Set-Cookie: serve-key-'; do
    case "$body" in *"$h"*) ok "header: $h" ;; *) bad "header: $h" ;; esac
  done
  case "$body" in *HttpOnly*SameSite=Strict*) ok "cookie is HttpOnly + SameSite=Strict" ;; *) bad "cookie is HttpOnly + SameSite=Strict" ;; esac

  local cookie
  cookie="$(printf '%s' "$body" | grep -m1 'Set-Cookie' | sed 's/Set-Cookie: //; s/;.*//')"
  code="$(curl -s -o /dev/null -w '%{http_code}' -H "Cookie: $cookie" "$base")"
  check "planted cookie authorizes plain URLs" "$code" "200"

  code="$(curl -s -o /dev/null -w '%{http_code}' --path-as-is "$origin/../outside.txt?key=$key")"
  check "traversal never resolves" "$code" "404"
  code="$(curl -s -o /dev/null -w '%{http_code}' "$origin/.git/config?key=$key")"
  check "dotfile segments never resolve" "$code" "404"
  body="$(curl -s "$origin/sub/page.txt?key=$key")"
  check "nested file under root is served" "$body" "nested"

  kill "$pid" 2>/dev/null
  for i in $(seq 1 50); do kill -0 "$pid" 2>/dev/null || break; sleep 0.1; done
  if kill -0 "$pid" 2>/dev/null; then bad "documented kill stops the server"; else ok "documented kill stops the server"; fi
  grep -q 'server-stopped' "$log" && ok "stop is recorded" || bad "stop is recorded"
}

test_copy skills/common/viewing-artifacts/scripts/serve.py "viewing-artifacts copy"
test_copy skills/design/ui-ux-design/scripts/serve.py "ui-ux-design copy"

echo "--- start/stop wrappers"
S=skills/common/viewing-artifacts/scripts
log="$fixture/wrapper.log"

line="$(bash "$S/start-server.sh" --root "$fixture/root" --idle-timeout-minutes 5 2>"$log")"
if printf '%s' "$line" | jq -e '.url' >/dev/null 2>&1; then ok "start-server prints the startup record"; else bad "start-server prints the startup record (got: $line)"; fi
url="$(printf '%s' "$line" | jq -r .url)"
pid="$(printf '%s' "$line" | jq -r .pid)"
code="$(curl -s -o /dev/null -w '%{http_code}' "${url%%\?*}")"
check "wrapper-started server still gates on the key" "$code" "403"
code="$(curl -s -o /dev/null -w '%{http_code}' "$url")"
check "wrapper-started server serves with the key" "$code" "200"

bash "$S/stop-server.sh" $$ >/dev/null 2>&1
check "stop-server refuses a PID that is not the preview" "$?" "1"

bash "$S/stop-server.sh" "$pid" >/dev/null 2>&1
check "stop-server stops the preview" "$?" "0"
kill -0 "$pid" 2>/dev/null && bad "preview process is gone after stop" || ok "preview process is gone after stop"

echo
if [ "$fails" -eq 0 ]; then echo "✓ serve preview passes"; else echo "✗ serve preview violations found"; fi
exit "$fails"
