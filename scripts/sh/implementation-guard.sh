#!/usr/bin/env bash
# PreToolUse implementation guard: no code is written before the implementation
# pair has fired.
#
# Why this exists: prompt wording — even NON-NEGOTIABLE in caps — is input to
# the same generator that decides whether to follow it, and measured runs show
# implementation skills getting skipped on exactly the tasks they govern. This
# hook is outside the model: the Write/Edit passes through here first, and the
# hook can deny it. The prompt shifts odds; the gate decides.
#
# One script serves both block-mode harness shapes, detected from the payload:
#   - Claude-style: payload carries transcript_path; fired skills are read back
#     from the transcript (JSONL; a Skill invocation is an assistant tool_use
#     block named Skill with .input.skill). Deny = JSON permissionDecision.
#   - Kimi-style: payload carries hook_event_name but no transcript. The
#     PostToolUse half RECORDS each Skill invocation into a per-session ledger;
#     the PreToolUse half checks the ledger. Deny = stderr + exit 2.
#
# Policy: only Write/Edit-class tools on code extensions are guarded (docs,
# config, data, plans pass unchallenged). Anything unreadable or malformed ->
# ALLOW: a guard that fails closed on its own errors blocks legitimate work;
# fail-open is the standing policy. A user waiver of the pair outranks the
# gate — the deny text says so.
#
# Honest limits: this guards the Write/Edit-class TOOLS, not the act of
# writing code. A shell write (a Bash heredoc) bypasses it by construction,
# and the kimi ledger is agent-writable — it trusts the agent not to append
# to it directly. So this catches UNINTENTIONAL skips, which is the common
# case; it is not a boundary against a model actively working around it.
set -uo pipefail
command -v jq >/dev/null 2>&1 || exit 0
input="$(cat)"
get() { printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null; }

is_code_path() {
  printf '%s' "$1" | grep -qiE '\.(js|jsx|ts|tsx|mjs|cjs|py|go|rs|java|kt|rb|php|c|cc|cpp|h|hpp|cs|swift|sh|bash|sql|lua|pl|ex|exs|erl|hs|scala|clj|dart|vue|svelte|ps1|bat|cmd|r|jl|groovy|m|mm|zig)$'
}

# pair_missing — reads skill names (one per line, optionally "plugin:name") on
# stdin; prints which of the pair is missing, nothing if both fired.
pair_missing() {
  local skills missing=""
  skills="$(cat)"
  printf '%s\n' "$skills" | grep -Eq '(^|:)test-driven-development$' || missing="test-driven-development"
  printf '%s\n' "$skills" | grep -Eq '(^|:)yagni$' || missing="${missing:+$missing and }yagni"
  printf '%s' "$missing"
}

guard_reason() {
  printf 'Blocked: this is the first code edit of the session and %s has not fired. Implementation work in this environment runs behind the pair: invoke `test-driven-development` and `yagni` NOW (Skill tool), then retry this edit. If the user explicitly waived them for this task, say so and ask them to confirm — otherwise there is no code before the pair.' "$1"
}

target_path() {
  local p; p="$(get '.tool_input.file_path')"; [ -n "$p" ] || p="$(get '.tool_input.path')"
  printf '%s' "$p"
}

# --- Harness detection --------------------------------------------------------
# Route on transcript_path, NOT hook_event_name: claude payloads carry BOTH
# hook_event_name and transcript_path, kimi payloads carry hook_event_name but
# never a transcript. Routing on hook_event_name would send claude into the
# ledger branch, where no ledger ever appears — a permanent deny. (Measured.)

# --- Claude-style payloads: transcript-based ----------------------------------
if [ -n "$(get '.transcript_path')" ]; then
  tool="$(get '.tool_name')"
  case "$tool" in Write|Edit|MultiEdit) ;; *) exit 0;; esac
  path="$(target_path)"
  [ -n "$path" ] && is_code_path "$path" || exit 0
  transcript="$(get '.transcript_path')"
  [ -f "$transcript" ] || exit 0

  skills="$(jq -r 'select(.type=="assistant") | .message.content[]?
                 | select(.type=="tool_use" and .name=="Skill") | .input.skill' \
            "$transcript" 2>/dev/null)" || exit 0

  missing="$(printf '%s\n' "$skills" | pair_missing)"
  [ -z "$missing" ] && exit 0

  reason="$(guard_reason "$missing")"
  esc="$reason"; esc="${esc//\\/\\\\}"; esc="${esc//\"/\\\"}"; esc="${esc//$'\n'/\\n}"
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$esc"
  exit 0
fi

# --- Kimi-style payloads: hook_event_name, no transcript ----------------------
[ -n "$(get '.hook_event_name')" ] || exit 0
event="$(get '.hook_event_name')"
# Sanitize the session id before it becomes a path component; an absent or
# empty id fails open rather than sharing a cross-session "unknown" ledger.
session="$(get '.session_id' | tr -cd 'A-Za-z0-9._-')"
[ -n "$session" ] || exit 0
ledger="${TMPDIR:-/tmp}/augments-skill-ledger-$session"
case "$event" in
  PostToolUse)
    [ "$(get '.tool_name')" = "Skill" ] || exit 0
    skill="$(get '.tool_input.skill')"
    # Owner-only ledger: another local user must not be able to pre-create
    # or poison it (world-shared /tmp).
    [ -n "$skill" ] && ( umask 077; printf '%s\n' "$skill" >> "$ledger" )
    exit 0
    ;;
  PreToolUse)
    tool="$(get '.tool_name')"
    case "$tool" in Write|Edit|MultiEdit) ;; *) exit 0;; esac
    path="$(target_path)"
    [ -n "$path" ] && is_code_path "$path" || exit 0
    # An existing ledger we cannot read or do not own is not evidence either
    # way -> fail open. A MISSING ledger is the normal fresh-session state:
    # the pair has not fired, so deny.
    if [ -e "$ledger" ]; then
      [ -r "$ledger" ] && [ -O "$ledger" ] || exit 0
      missing="$(pair_missing < "$ledger")"
      [ -z "$missing" ] && exit 0
    else
      missing="test-driven-development and yagni"
    fi
    guard_reason "$missing" >&2
    exit 2
    ;;
  *) exit 0;;
esac
