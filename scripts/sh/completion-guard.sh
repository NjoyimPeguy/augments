#!/usr/bin/env bash
# Turn-end guard for the done boundary.
#
# The library enforces at two moments — session start and the first structured
# edit — and those are the two moments where routing reliably happens. Every
# skill whose trigger only comes into existence at the END of a turn has no
# enforcement point at all: the completion claim, the commit, the PR. Measured
# against a bare agent, an in-body handoff to `verifying-completion` fired zero
# times out of five; a hard stop in the same body fired once out of two. Prose
# asking for a discretionary tool call at the moment the agent wants to stop is
# the same skippable step the session-start injector already had to remove.
#
# A turn-end hook was retired here once, and correctly: it triggered on the
# TURN'S WORDING, so any sentence containing a completion word re-blocked, over
# and over, for as long as the session ran. That is a cadence. This guard is the
# other kind — the kind the same retirement kept, which "fires on an observable
# action, not on wording":
#
#   1. spent          this change-episode has already been blocked once.
#   2. nothing built  no code change is recorded -> nothing to verify.
#   3. already done   `verifying-completion` ran after the last code change.
#   4. hand-back      the turn asks the user something and claims nothing.
#
# Filters 1-3 read observable events. Filter 4 reads prose and is deliberately
# the last and the softest: it only ever SUPPRESSES, never triggers, and it is
# ordered so a completion claim outranks a trailing question mark. Filter 1 is
# what bounds its mistakes — a wrong block costs one short turn, once, and the
# gate then stays quiet until code changes again. There is no path to a loop and
# no path to repetition.
#
# Two evidence sources, because harnesses differ. A payload carrying
# transcript_path is read from the real session transcript. A payload carrying
# only session_id is read from the per-session ledger the implementation guard
# writes on PostToolUse. A harness that offers neither an ordered transcript nor
# a skill receipt cannot answer filter 3, so it gets no turn-end hook at all
# rather than one that can never clear.
#
# The turn-end contracts genuinely differ between harnesses, so nothing here
# guesses at one. Read from each harness's own hook documentation:
#
#   * The JSON envelope is NOT portable. Three shapes are in play across the
#     supported set — a `decision`/`reason` object, and a `permissionDecision`/
#     `permissionDecisionReason` object nested under `hookSpecificOutput` or at
#     top level. Emitting the wrong one is silently ignored, which reads as a
#     gate that does not fire.
#   * Exit status 2 with the reason on stderr IS portable: every supported
#     harness documents it as blocking turn-end and feeding stderr back to the
#     model. That is what this guard uses, everywhere, for exactly that reason.
#   * The turn-end event takes no matcher on the harnesses that have one, so the
#     registrations declare none.
#   * A harness-supplied loop flag (`stop_hook_active`) is not universal — one
#     harness documents it, another does not list it at all. It is honoured where
#     present, but the portable ceiling is the change-episode state below, which
#     needs nothing from the payload but a session id.
#   * The final assistant text is read from `last_assistant_message` where the
#     payload carries it, which the harness docs prefer over re-reading the
#     transcript, and reconstructed from the transcript only as a fallback.
#
# Scope, stated rather than implied: "code changed" is read from Write/Edit-class
# actions AND from shell commands that redirect, tee, or sed -i into a path with
# a code extension. A write whose target is computed at runtime, or performed by
# a program the command merely invokes, stays invisible; the guard under-fires
# there rather than guessing.
set -uo pipefail
command -v jq >/dev/null 2>&1 || exit 0

input="$(cat)"
get() { printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null; }

# The harness's own loop flag, where it has one. Belt to the braces below.
[ "$(get '.stop_hook_active')" = "true" ] && exit 0

# One extension list, used for a structured edit's target path and for a shell
# command's redirect target alike. Classification happens inside jq so a command
# containing newlines or tabs can never corrupt the marker stream.
code_re='\.(js|jsx|ts|tsx|mjs|cjs|py|go|rs|java|kt|rb|php|c|cc|cpp|h|hpp|cs|swift|sh|bash|sql|lua|pl|ex|exs|erl|hs|scala|clj|dart|vue|svelte|ps1|bat|cmd|r|jl|groovy|m|mm|zig)([^A-Za-z0-9]|$)'
target='["'"'"']?[^[:space:]"'"'"'|;&<>()]*'
# A write operator whose TARGET carries a code extension. Requiring the target
# rather than mere co-occurrence keeps `grep foo src/a.js > /tmp/out` silent.
write_re=">>?[[:space:]]*${target}${code_re}"
write_re="${write_re}|\\btee\\b[[:space:]]+(-a[[:space:]]+)?${target}${code_re}"
write_re="${write_re}|\\bsed\\b[^|;&]*[[:space:]]-i[^|;&]*${code_re}"

# --- evidence ---------------------------------------------------------------
markers=""
transcript="$(get '.transcript_path')"
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  markers="$(jq -r --arg code "$code_re" --arg write "$write_re" '
    select(.type=="assistant") | .message.content[]?
    | select(.type=="tool_use")
    | if .name == "Skill" then
        (if ((.input.skill // "") | test("(^|:)verifying-completion$")) then "VERIFIED" else empty end)
      elif (.name | test("^(Write|Edit|MultiEdit)$")) then
        (if ((.input.file_path // .input.path // "") | test($code; "i")) then "EDIT" else empty end)
      elif .name == "Bash" then
        (if ((.input.command // "") | test($write; "i")) then "EDIT" else empty end)
      else empty end
  ' "$transcript" 2>/dev/null)" || exit 0
fi

# Ledger-backed harnesses: the implementation guard records skill loads and code
# edits on PostToolUse, in order, for exactly this reason.
session="$(get '.session_id' | tr -cd 'A-Za-z0-9._-')"
ledger=""
if [ -n "$session" ]; then
  ledger="${TMPDIR:-/tmp}/sdlc-skills-implementation-$session"
  if [ -z "$markers" ] && [ -r "$ledger" ] && [ -O "$ledger" ]; then
    markers="$(while IFS= read -r line; do
      case "$line" in
        EDIT*) echo EDIT ;;
        *) printf '%s' "$line" | grep -Eq '(^|:)verifying-completion$' && echo VERIFIED ;;
      esac
    done < "$ledger")"
  fi
fi
[ -n "$markers" ] || exit 0

edits=0
verified=0
while read -r kind; do
  case "$kind" in
    # A later change invalidates an earlier verification: the evidence is stale.
    EDIT)     edits=$((edits + 1)); verified=0 ;;
    VERIFIED) verified=1 ;;
  esac
done <<< "$markers"

# 2. Nothing was built, so there is no completion claim to gate.
[ "$edits" -gt 0 ] || exit 0
# 3. The boundary was honoured.
[ "$verified" -eq 0 ] || exit 0

# 1. One block per change-episode, on every harness, whether or not it supplies a
# loop flag. The count of code changes at the last block is the episode's
# identity: the gate reopens when new code appears, and never before. This is
# what keeps a boundary from decaying into a cadence.
state=""
if [ -n "$session" ]; then
  state="${TMPDIR:-/tmp}/sdlc-skills-completion-$session"
  if [ -r "$state" ] && [ -O "$state" ]; then
    spent="$(tr -cd '0-9' < "$state")"
    [ -n "$spent" ] && [ "$edits" -le "$spent" ] && exit 0
  fi
fi

# 4. Distinguish a completion claim from a mid-task hand-back. The claim wins:
# "done, tests pass — want a PR?" is a claim that happens to end in a question.
last_text="$(get '.last_assistant_message')"
if [ -z "$last_text" ] && [ -n "$transcript" ] && [ -f "$transcript" ]; then
  last_text="$(jq -rs '
    map(select(.type=="assistant"))
    | map(select(any(.message.content[]?; .type=="text" and (.text | test("\\S")))))
    | last // empty
    | .message.content[]? | select(.type=="text") | .text
  ' "$transcript" 2>/dev/null)"
fi

claims_done() {
  printf '%s' "$1" | grep -qiE '\b(done|complete|completed|finished|fixed|resolved|implemented|shipped|works now|working now|all set|ready to (commit|merge|ship|review)|tests? (pass|are green)|suite is green|should do it|good to go)\b'
}
ends_in_question() {
  printf '%s' "$1" | grep -v '^[[:space:]]*$' | tail -n 1 | grep -qE '\?[[:space:]]*$'
}

if [ -n "$last_text" ] && ! claims_done "$last_text" && ends_in_question "$last_text"; then
  exit 0
fi

[ -n "$state" ] && ( umask 077; printf '%s\n' "$edits" > "$state" )

reason='Turn-end done boundary: this session changed code and `verifying-completion` has not been invoked since the last change. Invoke it through the configured skill-loading action and act on what it returns, then report. If you are pausing to ask the user something rather than reporting this work finished, say so in one line and stop — this gate will not fire again until code changes again.'

printf '%s' "$reason" >&2
exit 2
