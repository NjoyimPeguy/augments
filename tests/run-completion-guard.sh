#!/usr/bin/env bash
# Offline contract for the turn-end done-boundary guard.
#
# What this pins is the FALSE-FIRE behaviour, not the block. A turn-end event
# fires on every turn, including the ones where blocking is wrong: a question to
# the user, a read-only answer, a turn whose work was already verified. A gate
# that fires on those is worse than no gate, because it trains its own dismissal.
# So most of what follows asserts silence, and one case asserts the block.
#
# Deterministic on purpose: this is script logic over a transcript. Whether the
# block actually changes an agent's behaviour is a live question, answered by
# tests/run-behavioral.sh, and is not claimed here.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

case "${1-}" in
  -h|--help)
    cat <<'EOF'
tests/run-completion-guard.sh — offline contract for the turn-end done boundary.

Takes no arguments. Feeds synthetic Stop payloads and transcripts to
scripts/sh/completion-guard.sh without calling a model.

  --help    this text

Exit codes: 0 every check passed · 1 at least one failed · 2 bad repository state
EOF
    exit 0;;
esac

guard=scripts/sh/completion-guard.sh
[ -f "$guard" ] || { echo "FAIL: missing $guard"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "needs jq" >&2; exit 2; }

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
fails=0
ok()  { echo "  ok    $1"; }
bad() { echo "  FAIL  $1"; fails=1; }

# --- transcript builders -----------------------------------------------------
edit()   { printf '{"type":"assistant","message":{"content":[{"type":"tool_use","name":"%s","input":{"file_path":"%s"}}]}}\n' "${2:-Write}" "$1"; }
skill()  { printf '{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Skill","input":{"skill":"%s"}}]}}\n' "$1"; }
say()    { jq -cn --arg t "$1" '{type:"assistant",message:{content:[{type:"text",text:$t}]}}'; }
sh()     { jq -cn --arg c "$1" '{type:"assistant",message:{content:[{type:"tool_use",name:"Bash",input:{command:$c}}]}}'; }
user()   { printf '{"type":"user","message":{"content":"go"}}\n'; }

# Every case gets its own session id, because the guard is deliberately stateful
# across turns: one block per change-episode. Sharing a session between cases
# would make each case depend on the ones before it. The id is derived from the
# transcript name rather than a counter — $(run ...) is a subshell, so a counter
# would silently reset and every case would collide on one session.
new_session() { basename "${1:-anon}" | tr -cd 'A-Za-z0-9._-'; }

# Blocking is exit 2 with the reason on stderr — the one convention every
# supported harness documents. A JSON envelope on stdout is NOT portable between
# them, so emitting one is a failure here, not an alternative.
call() { # $1 payload json
  local out err status=0
  err="$tmpdir/err"
  out="$(printf '%s' "$1" | TMPDIR="$tmpdir" bash "$guard" 2>"$err")" || status=$?
  if [ -n "$out" ]; then
    echo "unportable-envelope:$out"
  elif [ "$status" -eq 2 ] && [ -s "$err" ]; then
    echo block
  elif [ "$status" -ne 0 ]; then
    echo "error:$status"
  else
    echo silent
  fi
}

run() { # $1 transcript file, $2 stop_hook_active, $3 session (optional)
  call "$(jq -cn --arg p "$1" --argjson a "${2:-false}" --arg s "${3:-$(new_session "$1")}" \
           '{session_id:$s,transcript_path:$p,hook_event_name:"Stop",stop_hook_active:$a}')"
}

# Ledger-backed harness: no transcript_path, evidence written by PostToolUse.
run_ledger() { # $1 session id
  call "$(jq -cn --arg s "$1" '{session_id:$s,hook_event_name:"Stop"}')"
}
ledger_write() { # $1 session id, rest: literal ledger lines
  local s="$1"; shift
  printf '%s\n' "$@" > "$tmpdir/sdlc-skills-implementation-$s"
}

expect() { # $1 label, $2 got, $3 want
  if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (expected $3, got $2)"; fi
}

# --- registration ------------------------------------------------------------
if jq -e 'any(.hooks.Stop[]?.hooks[]?; .command | contains("completion-guard.sh"))' \
     hooks/hooks.json >/dev/null; then
  ok "Claude: Stop installs the completion guard"
else
  bad "Claude: Stop does not install the completion guard"
fi
if jq -e '.hooks | has("SubagentStop")' hooks/hooks.json >/dev/null 2>&1; then
  bad "SubagentStop is registered — a subagent finishing is not the done boundary"
else
  ok "SubagentStop is not registered"
fi
if jq -e 'any(.hooks[]?; .event == "Stop" and (.command | contains("completion-guard.sh")))' \
     .kimi-plugin/plugin.json >/dev/null; then
  ok "Kimi: Stop installs the completion guard"
else
  bad "Kimi: Stop does not install the completion guard"
fi
# Codex exposes no skill-invocation tool, so nothing there can record that
# `verifying-completion` ran. A turn-end hook that can never clear is a cadence,
# which is what the turn-end retirement removed — so Codex gets none.
if jq -e '.hooks | has("Stop")' plugins/sdlc-skills/hooks/hooks.json >/dev/null 2>&1; then
  bad "Codex: a turn-end hook is registered on an adapter with no skill receipt"
else
  ok "Codex: no turn-end hook, because it has no skill receipt to clear one"
fi
if [ -e plugins/sdlc-skills/scripts/sh/completion-guard.sh ]; then
  bad "Codex: guard mirror is shipped for a lifecycle event Codex does not register"
else
  ok "Codex: no unused guard mirror is shipped"
fi

# --- filter 1: the loop ceiling ---------------------------------------------
t="$tmpdir/claim.jsonl"; { user; edit src/a.js; say "Done. Tests pass."; } > "$t"
expect "blocks an unverified completion claim"        "$(run "$t" false)" block
expect "honours the harness loop flag (stop_hook_active)" "$(run "$t" true)" silent

# The retirement's core objection was repetition. One block per change-episode,
# enforced without depending on any harness flag.
sess="episode"
expect "blocks the first time"                        "$(run "$t" false "$sess")" block
expect "stays quiet on the next turn — no new code"   "$(run "$t" false "$sess")" silent
expect "and on the turn after that"                   "$(run "$t" false "$sess")" silent
t2="$tmpdir/claim2.jsonl"; { user; edit src/a.js; edit src/b.js; say "Done."; } > "$t2"
expect "reopens once new code appears"                "$(run "$t2" false "$sess")" block
expect "then quiet again"                             "$(run "$t2" false "$sess")" silent

# --- filter 2: nothing was built --------------------------------------------
t="$tmpdir/readonly.jsonl"; { user; say "That module parses the config. Done reading."; } > "$t"
expect "silent on a read-only turn"                   "$(run "$t")" silent

t="$tmpdir/docs.jsonl"; { user; edit README.md; say "Done — docs updated."; } > "$t"
expect "silent when only non-code paths changed"      "$(run "$t")" silent

# --- filter 3: already verified ---------------------------------------------
t="$tmpdir/verified.jsonl"
{ user; edit src/a.js; skill sdlc-skills:verifying-completion; say "Done. Tests pass."; } > "$t"
expect "silent once verifying-completion ran after the edit" "$(run "$t")" silent

t="$tmpdir/stale.jsonl"
{ user; skill sdlc-skills:verifying-completion; edit src/a.js; say "Done. Tests pass."; } > "$t"
expect "blocks when verification predates the last edit"     "$(run "$t")" block

t="$tmpdir/bare-name.jsonl"
{ user; edit src/a.js; skill verifying-completion; say "Done."; } > "$t"
expect "accepts an unprefixed skill name"             "$(run "$t")" silent

t="$tmpdir/other-skill.jsonl"
{ user; edit src/a.js; skill sdlc-skills:yagni; say "Done."; } > "$t"
expect "another skill does not satisfy the boundary"  "$(run "$t")" block

# --- filter 2: shell writes count as changes --------------------------------
t="$tmpdir/heredoc.jsonl"
{ user; sh "cat > src/a.js <<'"'"'EOF'"'"'\nexport const a = 1\nEOF"; say "Done."; } > "$t"
expect "a heredoc redirect into a code path is a change"     "$(run "$t")" block

t="$tmpdir/sedi.jsonl"
{ user; sh "sed -i 's/a/b/' src/a.js"; say "Done."; } > "$t"
expect "sed -i on a code path is a change"                   "$(run "$t")" block

t="$tmpdir/tee.jsonl"
{ user; sh "printf 'x' | tee -a src/a.js"; say "Done."; } > "$t"
expect "tee into a code path is a change"                    "$(run "$t")" block

t="$tmpdir/read-redirect.jsonl"
{ user; sh "grep -n export src/a.js > /tmp/out.txt"; say "Done."; } > "$t"
expect "a redirect whose TARGET is not code is not a change" "$(run "$t")" silent

t="$tmpdir/read-only-shell.jsonl"
{ user; sh "cat src/a.js && npm test"; say "Done — the suite is green."; } > "$t"
expect "reading and running are not changes"                 "$(run "$t")" silent

t="$tmpdir/shell-then-verify.jsonl"
{ user; sh "cat > src/a.js <<EOF\nx\nEOF"; skill sdlc-skills:verifying-completion; say "Done."; } > "$t"
expect "a shell write is cleared by verifying-completion"    "$(run "$t")" silent

t="$tmpdir/multiline-cmd.jsonl"
{ user; sh "set -e\n\tcat > src/a.js <<EOF\nbody\nEOF\necho ok"; say "Done."; } > "$t"
expect "a command with newlines and tabs does not corrupt the stream" "$(run "$t")" block

# --- filter 4: hand-back vs claim -------------------------------------------
t="$tmpdir/question.jsonl"
{ user; edit src/a.js; say "Should the default tier be free or paid?"; } > "$t"
expect "silent on a mid-task question"                "$(run "$t")" silent

t="$tmpdir/claim-question.jsonl"
{ user; edit src/a.js; say "Done, tests pass. Want me to open a PR?"; } > "$t"
expect "a claim outranks a trailing question mark"    "$(run "$t")" block

t="$tmpdir/multiline-q.jsonl"
{ user; edit src/a.js; say "I sketched the module.

Two ways to slice this. Which do you want?"; } > "$t"
expect "silent on a question after intervening lines" "$(run "$t")" silent

# --- the ledger path (harnesses with no transcript) --------------------------
ledger_write ledger-a "$(printf 'EDIT\tsrc/a.js')"
expect "ledger: an unverified code change blocks"     "$(run_ledger ledger-a)" block
expect "ledger: and does not block again"             "$(run_ledger ledger-a)" silent

ledger_write ledger-b "$(printf 'EDIT\tsrc/a.js')" "sdlc-skills:verifying-completion"
expect "ledger: verification after the change clears" "$(run_ledger ledger-b)" silent

ledger_write ledger-c "sdlc-skills:verifying-completion" "$(printf 'EDIT\tsrc/a.js')"
expect "ledger: verification before the change is stale" "$(run_ledger ledger-c)" block

ledger_write ledger-d "sdlc-skills:test-driven-development" "sdlc-skills:yagni"
expect "ledger: skills without a code change do not block" "$(run_ledger ledger-d)" silent

expect "ledger: an absent ledger is silent"           "$(run_ledger ledger-none)" silent

# --- fail open ---------------------------------------------------------------
expect "silent when the transcript is missing"        "$(run "$tmpdir/nope.jsonl")" silent

out="$(printf '%s' '{"hook_event_name":"Stop","session_id":"kimi"}' | bash "$guard" 2>/dev/null)"
[ -z "$out" ] && ok "silent on a payload carrying no transcript_path" \
              || bad "acted on a payload carrying no transcript_path ($out)"

t="$tmpdir/garbage.jsonl"; printf 'not json\n' > "$t"
expect "silent on an unparseable transcript"          "$(run "$t")" silent

[ "$fails" -eq 0 ] && echo "completion guard: all checks passed"
exit "$fails"
