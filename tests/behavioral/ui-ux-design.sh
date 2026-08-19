#!/usr/bin/env bash
# Behavioural scenario: ui-ux-design — the visual default and the served preview.
#
# Two failures this catches:
#   1. Asked to design a screen whose direction is open, the agent writes only
#      the markdown section and describes variants in prose. The re-centered
#      step 6 makes the rendered comparison surface the default; the assertion
#      is the filled surface under designs/<slug>/visuals/ with >= 2 variants.
#   2. Never asked for a link, the agent dumps a file path and waits to be
#      asked, or serves ad hoc (python3 -m http.server). The governed preview
#      leaves a startup record in /tmp/serve-preview.*.log whose root binds to
#      this workdir — key-gated, loopback, self-terminating. That record is
#      the observable.
#
# The 200/403 mechanics of the server itself are covered offline and for free
# by tests/run-serve-preview.sh; what only a live run can show is the agent
# CHOOSING the governed path. A server started during the run is reaped by the
# owner watchdog once the harness exits, so assertions bind to the log record,
# never to a live probe.

scenario_opening() {
  cat <<'EOF'
This repo is the start of a marketing site for "Nordwind", a SaaS that helps
independent bakeries take pre-orders online. Before we build anything, I need
the hero and pricing section designed — layout, look and feel, the lot. I have
not settled on a visual direction, so show me directions I can react to. Stop
before writing any production markup.
EOF
}

scenario_setup() {
  local d="$1"
  mkdir -p "$d/site"
  cat > "$d/site/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><title>Nordwind — pre-orders for bakeries</title></head>
<body>
  <h1>Nordwind</h1>
  <p>Placeholder.</p>
</body>
</html>
EOF
  cat > "$d/README.md" <<'EOF'
# nordwind-site

Static marketing site for Nordwind (bakery pre-orders). `site/` holds the
pages; no build step, no design system yet.
EOF
}

scenario_assert() {
  local d="$1" section visuals nvariants html
  cd "$d" || return 2

  section="$(ls .sdlc-skills/designs/*.md 2>/dev/null | head -1)"
  if [ -n "$section" ]; then
    pass "design section written ($section)"
  else
    fail "no design section under .sdlc-skills/designs/"
  fi

  visuals="$(find .sdlc-skills/designs -path '*/visuals/*.html' 2>/dev/null | head -1)"
  if [ -z "$visuals" ]; then
    fail "rendered comparison surface under designs/<slug>/visuals/ — none found"
  else
    pass "comparison surface written ($visuals)"
    html="$(cat "$visuals")"
    assert_not_contains "$html" '\{\{' "surface is filled, not a stub copy"
    assert_not_contains "$html" 'src="http|href="http' "surface is self-contained"
    nvariants="$(grep -o 'class="variant variant-[0-9]"' "$visuals" | sort -u | wc -l | tr -d ' ')"
    if [ "$nvariants" -ge 2 ]; then
      pass "surface compares $nvariants rendered variants (>= 2)"
    else
      fail "surface carries $nvariants template variants (< 2)"
    fi
  fi

  # The governed preview, bound to THIS workdir via the record's root. Stale
  # logs from other runs name other roots and never match.
  local log rec root url
  rec=""
  for log in /tmp/serve-preview.*.log; do
    [ -f "$log" ] || continue
    rec="$(grep -m1 'server-started' "$log" 2>/dev/null)" || continue
    root="$(printf '%s' "$rec" | jq -r '.root // empty' 2>/dev/null)"
    case "$root" in "$d"/*) break ;; *) rec="" ;; esac
  done
  if [ -z "$rec" ]; then
    fail "governed preview served from this workdir — no matching server-started record"
  else
    pass "governed preview served from this workdir"
    url="$(printf '%s' "$rec" | jq -r '.url // empty' 2>/dev/null)"
    case "$url" in
      http://127.0.0.1:*\?key=*) pass "preview URL is loopback and carries the session key" ;;
      *) fail "preview URL is loopback and carries the session key — got: $url" ;;
    esac
  fi

  note "not observable from the workdir: ad-hoc-server avoidance (no record distinguishes it); live 200/403 (covered offline by tests/run-serve-preview.sh)"
  assert_result
}
