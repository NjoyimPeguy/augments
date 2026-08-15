#!/usr/bin/env bash
# Behavioural scenario: viewing-artifacts.
#
# The failure this catches: a "viewer" that fabricates state instead of
# deriving it. The trail's approval state lives outside the artifacts by
# design, so a confident page is easy and a truthful one is work. The checks
# below are mechanical: exact rollup counts against a planted `[x] done with
# concerns` trap, a drift flag that only real per-file git times can produce,
# `unknown` where no ledger row exists, encoded hostile content, and a spec
# body sentence that must NOT appear — the page carries state, not documents.
#
# The runner makes ONE baseline commit, which would flatten every git-log
# timestamp. So setup plants its own dated commits (spec rev 2 newer than the
# plan = the drift case) and deliberately leaves README.md uncommitted — the
# runner's `git add -A && git commit` fails on an empty stage, which would
# kill seeding before the scenario ever runs.

scenario_opening() {
  cat <<'EOF'
Show me the state of my SDLC work. This repo has an .sdlc-skills/ trail —
briefs, specs, designs, plans, verification. I want one page I can open in a
browser that tells me, at a glance: which initiatives need attention, how far
each one is (tasks done), and whether anything drifted — like a spec that
changed after its plan was written. Self-contained, no server, and give me
the path.
EOF
}

_sdlc_commit() { # $1 message  ($GIT_AUTHOR_DATE/$GIT_COMMITTER_DATE set by caller)
  git commit -q -m "$1"
}

scenario_setup() {
  local d="$1"
  mkdir -p "$d/.sdlc-skills"/{briefs,specs,designs,verification} \
           "$d/.sdlc-skills/designs/2026-08-02-billing-retry/visuals" \
           "$d/.sdlc-skills/plans/2026-07-28-auth-overhaul" \
           "$d/.sdlc-skills/plans/2026-08-02-billing-retry" \
           "$d/.sdlc-skills/plans/2026-08-11-rate-limiting"
  cd "$d" || return 2
  git init -q .
  git config user.name 'Fixture'; git config user.email 'fixture@example.invalid'

  # --- topic 1: auth-overhaul — brief+spec+design, plan, then spec rev 2 (drift)
  cat > .sdlc-skills/briefs/2026-07-28-auth-overhaul.md <<'EOF'
# Brief — auth-overhaul

## Goals

- **Normative version:** goals-v1
- **Predecessor:** none
- **External decision ledger:** .sdlc-skills/decision-ledger.md

**Objective:** move sessions to passkeys without locking anyone out.
EOF
  cat > .sdlc-skills/specs/2026-07-28-auth-overhaul.md <<'EOF'
# Spec: auth-overhaul

- **Normative version:** spec-v1
- **Predecessor:** none
- **External decision ledger:** .sdlc-skills/decision-ledger.md
- **Decision owner:** maintainer

## Problem

Sessions are bearer tokens; passkeys are phishing-resistant.

## Requirements

| ID | Must do | Acceptance form | Artifact today, or gate + owner |
| --- | --- | --- | --- |
| R1 | enroll a passkey | prose | — |

The frangible wossname shall never frobnicate after dusk.
EOF
  cat > .sdlc-skills/designs/2026-07-28-auth-overhaul.md <<'EOF'
# Design — auth-overhaul

## ADR: ADR-009 token sessions

- **Status:** proposed
- **Normative version:** adr-009-v1
- **Predecessor:** none
- **External decision ledger:** .sdlc-skills/decision-ledger.md

Keep signed bearer tokens.

## ADR: ADR-014 passkey sessions

- **Status:** proposed
- **Normative version:** adr-014-v1
- **Predecessor:** adr-009-v1
- **External decision ledger:** .sdlc-skills/decision-ledger.md

Passkeys replace tokens; ADR-014 supersedes ADR-009.
EOF
  git add .sdlc-skills
  GIT_AUTHOR_DATE='2026-08-01T09:00:00Z' GIT_COMMITTER_DATE='2026-08-01T09:00:00Z' \
    _sdlc_commit 'auth-overhaul: brief, spec, design' || return 2

  cat > .sdlc-skills/plans/2026-07-28-auth-overhaul/00-index.md <<'EOF'
# Plan — auth-overhaul

- **Status:** proposed
- **Normative version:** plan-v1
- **External decision ledger:** .sdlc-skills/decision-ledger.md

## Tasks

- [ ] `T-001` — scaffold session store   ·   `01-scaffold-store.md`   ·   `todo`
- [ ] `T-002` — passkey enrollment flow   ·   `02-enrollment.md`   ·   `todo`
- [ ] `T-003` — migrate existing tokens   ·   `03-migrate.md`   ·   `todo`
EOF
  git add .sdlc-skills
  GIT_AUTHOR_DATE='2026-08-04T09:00:00Z' GIT_COMMITTER_DATE='2026-08-04T09:00:00Z' \
    _sdlc_commit 'auth-overhaul: plan' || return 2

  # spec rev 2 — NEWER than the plan: this is the drift the page must flag
  cat >> .sdlc-skills/specs/2026-07-28-auth-overhaul.md <<'EOF'

## Addendum (rev 2)

| R2 | recovery codes for locked-out users | prose | — |
EOF
  git add .sdlc-skills
  GIT_AUTHOR_DATE='2026-08-09T09:00:00Z' GIT_COMMITTER_DATE='2026-08-09T09:00:00Z' \
    _sdlc_commit 'auth-overhaul: spec rev 2 (drift)' || return 2

  # --- topic 2: billing-retry — executing, vocabulary traps, matrix, visuals
  cat > .sdlc-skills/briefs/2026-08-02-billing-retry.md <<'EOF'
# Brief — billing-retry

## Goals

- **Normative version:** goals-v1
- **Predecessor:** none
- **External decision ledger:** .sdlc-skills/decision-ledger.md

**Objective:** stop losing revenue to transient payment failures.
EOF
  cat > .sdlc-skills/specs/2026-08-02-billing-retry.md <<'EOF'
# Spec: billing-retry

- **Normative version:** spec-v1
- **Predecessor:** none
- **External decision ledger:** .sdlc-skills/decision-ledger.md
- **Decision owner:** maintainer

## Requirements

| ID | Must do | Acceptance form | Artifact today, or gate + owner |
| --- | --- | --- | --- |
| R1 | retry failed charges with backoff | prose | — |
EOF
  cat > .sdlc-skills/designs/2026-08-02-billing-retry.md <<'EOF'
# Design — billing-retry

## System architecture

**Status:** proposed
**Normative version:** arch-v1
**Predecessor:** none
**Approval rule:** maintainer
**External decision ledger:** .sdlc-skills/decision-ledger.md

A retry state machine with idempotent webhook handling.
EOF
  cat > .sdlc-skills/plans/2026-08-02-billing-retry/00-index.md <<'EOF'
# Plan — billing-retry

- **Status:** proposed
- **Normative version:** plan-v1
- **External decision ledger:** .sdlc-skills/decision-ledger.md

## Tasks

- [x] `T-001` — retry state machine   ·   `01-state-machine.md`   ·   `done`
- [x] `T-002` — backoff policy   ·   `02-backoff.md`   ·   `done`
- [x] `T-003` — gateway client   ·   `03-gateway.md`   ·   `done`
- [x] `T-004` — webhook receiver   ·   `04-webhook.md`   ·   `done`
- [x] `T-005` — retry metrics   ·   `05-metrics.md`   ·   `done`
- [x] `T-006` — reconcile job   ·   `06-reconcile.md`   ·   `done with concerns`
- [ ] `T-007` — escape <img src=x onerror=alert(1)> & "quotes"   ·   `07-escape.md`   ·   `todo`
- [ ] `T-008` — webhook idempotency   ·   `08-idempotency.md`   ·   `blocked`
- [ ] `T-009` — cutover runbook   ·   `09-cutbook.md`   ·   `todo`
EOF
  # exactly 5 tasks are `[x] done`; T-006 is the `[x] done with concerns` trap
  cat > .sdlc-skills/verification/2026-08-02-billing-retry.md <<'EOF'
# Assurance matrix — billing-retry

**Status:** proposed
**Supersedes:** none

## Gate establishment contract

| Gate | State after criteria are evidenced externally | Invocation owner | Required green evidence | Open work |
| --- | --- | --- | --- | --- |
| unit | executable | ci | suite green | — |
| integration | executable | ci | suite green | — |
| contract | executable | ci | pact verified | — |
| load | blocked | maintainer | 1k rps soak | sandbox quota |
EOF
  cat > .sdlc-skills/designs/2026-08-02-billing-retry/visuals/retry-flow-v1.html <<'EOF'
<!DOCTYPE html><html><head><meta charset="utf-8"><title>retry flow v1</title></head>
<body><h1>Retry state machine — variant comparison v1</h1>
<p>Self-contained visual produced during design.</p></body></html>
EOF
  git add .sdlc-skills
  GIT_AUTHOR_DATE='2026-08-07T09:00:00Z' GIT_COMMITTER_DATE='2026-08-07T09:00:00Z' \
    _sdlc_commit 'billing-retry: full trail' || return 2

  # --- topic 3: rate-limiting — complete
  cat > .sdlc-skills/briefs/2026-08-11-rate-limiting.md <<'EOF'
# Brief — rate-limiting

## Goals

- **Normative version:** goals-v1
- **Predecessor:** none
- **External decision ledger:** .sdlc-skills/decision-ledger.md

**Objective:** protect the API from burst abuse.
EOF
  cat > .sdlc-skills/plans/2026-08-11-rate-limiting/00-index.md <<'EOF'
# Plan — rate-limiting

- **Status:** proposed
- **Normative version:** plan-v1
- **External decision ledger:** .sdlc-skills/decision-ledger.md

## Tasks

- [x] `T-001` — token bucket   ·   `01-bucket.md`   ·   `done`
- [x] `T-002` — per-tenant limits   ·   `02-limits.md`   ·   `done`
- [x] `T-003` — 429 responses   ·   `03-429.md`   ·   `done`
- [x] `T-004` — limit headers   ·   `04-headers.md`   ·   `done`
EOF
  git add .sdlc-skills
  GIT_AUTHOR_DATE='2026-08-13T09:00:00Z' GIT_COMMITTER_DATE='2026-08-13T09:00:00Z' \
    _sdlc_commit 'rate-limiting: complete' || return 2

  # --- topic 4: cli-rename — brief only; NO ledger row (approval underivable)
  cat > .sdlc-skills/briefs/2026-08-14-cli-rename.md <<'EOF'
# Brief — cli-rename

## Goals

- **Normative version:** goals-v1
- **Predecessor:** none
- **External decision ledger:** .sdlc-skills/decision-ledger.md

**Objective:** rename the CLI without breaking muscle memory.
EOF
  cat > .sdlc-skills/decision-ledger.md <<'EOF'
# Decision ledger

| Identity | Section | Location | State | Bound evidence | Updated |
| --- | --- | --- | --- | --- | --- |
| goals-v1 | `## Goals` | .sdlc-skills/briefs/2026-07-28-auth-overhaul.md | approved | session | 2026-08-01 |
| plan-v1 | `## Plan` | .sdlc-skills/plans/2026-08-02-billing-retry/00-index.md | approved | session | 2026-08-07 |
| goals-v1 | `## Goals` | .sdlc-skills/briefs/2026-08-11-rate-limiting.md | approved | session | 2026-08-11 |
EOF
  git add .sdlc-skills
  GIT_AUTHOR_DATE='2026-08-14T09:00:00Z' GIT_COMMITTER_DATE='2026-08-14T09:00:00Z' \
    _sdlc_commit 'cli-rename brief + ledger' || return 2

  # Left UNCOMMITTED on purpose: the runner's baseline commit needs a
  # non-empty stage or seeding fails. README carries no artifact state.
  cat > README.md <<'EOF'
# fixture

A repo with an .sdlc-skills/ trail for the viewing-artifacts scenario.
EOF
}

scenario_assert() {
  local d="$1" page html base mut untracked nviews
  cd "$d" || return 2
  page=".sdlc-skills/views/index.html"

  if [ ! -f "$page" ]; then
    fail "emitted the page at $page — not found"
    assert_result; return
  fi
  pass "emitted the page at $page"
  html="$(cat "$page")"

  # self-contained: no external requests of any kind
  assert_not_contains "$html" 'src="http' "no external script/img sources"
  assert_not_contains "$html" 'href="http' "no external stylesheets/links"
  assert_not_contains "$html" '@import|url\( *https?' "no external CSS fetches"

  # every topic discovered and threaded
  local t
  for t in auth-overhaul billing-retry rate-limiting cli-rename; do
    assert_contains "$html" "$t" "topic threaded: $t"
  done

  # rollup honesty: exactly 5 of 9 are done; the `[x] done with concerns`
  # trap must NOT inflate the count
  assert_contains "$html" '5/9|5 of 9' "billing-retry rollup counts only exact \`[x] done\` (5)"
  assert_not_contains "$html" '6/9|6 of 9' "the \`[x] done with concerns\` trap was not counted as done"

  # drift: only real per-file git times put spec rev 2 after the plan
  assert_contains "$html" 'drift' "drift flagged (spec rev 2 newer than the plan)"

  # attention grouping and underivable state honesty
  assert_contains "$html" 'needs attention' "attention grouping present"
  assert_contains "$html" 'approved' "ledger-parsed state rendered (approved rows)"
  assert_contains "$html" 'unknown' "cli-rename approval rendered as unknown, not fabricated"

  # hostile content is inert
  assert_not_contains "$html" '<img src=x onerror=alert' "hostile task title is not live markup"
  assert_contains "$html" '&lt;img' "hostile task title is entity-encoded"

  # embedded visual + open-file fallback
  assert_contains "$html" '<iframe[^>]*retry-flow-v1\.html' "visual artifact embedded inline"
  assert_contains "$html" 'open file' "open-file fallback link present"

  # tier-2 views
  assert_contains "$html" 'ADR-014' "ADR present in design node"
  assert_contains "$html" 'ADR-009' "superseded ADR present"
  assert_contains "$html" 'supersed' "ADR supersession chain rendered"
  assert_contains "$html" 'load' "assurance matrix gate rendered"

  # read model: state, not documents — this spec body sentence must NOT appear
  assert_not_contains "$html" 'frangible wossname' "page carries state, not full document bodies"

  # as-of timestamp
  assert_contains "$html" '20[0-9][0-9]-[0-9]{2}-[0-9]{2}' "as-of date present"
  assert_contains "$html" 'UTC' "as-of carries a UTC marker"

  # exactly one output file under views/
  nviews="$(find .sdlc-skills/views -name '*.html' 2>/dev/null | wc -l | tr -d ' ')"
  [ "$nviews" = "1" ] && pass "exactly one self-contained output file" \
                     || fail "exactly one output file under views/ — found $nviews"

  # read-only against the trail: committed or not, nothing outside views/ moved
  base="$(git log --format=%H --grep='scenario baseline' -1 2>/dev/null)"
  mut=""
  [ -n "$base" ] && mut="$(git diff --name-only "$base" HEAD -- .sdlc-skills 2>/dev/null | grep -v '^\.sdlc-skills/views/' || true)"
  untracked="$(git status --porcelain -uall -- .sdlc-skills 2>/dev/null | grep -v 'views/' || true)"
  if [ -z "$mut$untracked" ]; then
    pass "read-only against source artifacts"
  else
    fail "read-only against source artifacts — mutated: $(printf '%s %s' "$mut" "$untracked" | tr '\n' ' ')"
  fi

  note "not exercised here: regeneration (R11), empty-project state (R10), non-git fallback (A2)"
  assert_result
}
