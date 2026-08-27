#!/usr/bin/env bash
# Scoped implementation-entry guard for structured edit-class code changes.
#
# This hook catches accidental routing skips on the tool surface it can observe.
# It is not a universal mutation boundary: shell commands can write files without
# using Write or Edit, and unsupported harnesses may expose
# different tools. The adapter documentation and tests name that scope.
#
# Claude-style hook payloads carry transcript_path, so loaded skills are read
# from the real session transcript. Kimi payloads use an owner-only per-session
# ledger of native Skill calls.
set -uo pipefail
command -v jq >/dev/null 2>&1 || exit 0

input="$(cat)"
get() { printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null; }

is_code_path() {
  printf '%s' "$1" | grep -qiE '\.(js|jsx|ts|tsx|mjs|cjs|py|go|rs|java|kt|rb|php|c|cc|cpp|h|hpp|cs|swift|sh|bash|sql|lua|pl|ex|exs|erl|hs|scala|clj|dart|vue|svelte|ps1|bat|cmd|r|jl|groovy|m|mm|zig)$'
}

pair_missing() {
  local skills missing=""
  skills="$(cat)"
  printf '%s\n' "$skills" | grep -Eq '(^|:)test-driven-development$' || missing="test-driven-development"
  printf '%s\n' "$skills" | grep -Eq '(^|:)yagni$' || missing="${missing:+$missing and }yagni"
  printf '%s' "$missing"
}

guard_reason() {
  printf 'Blocked on the structured edit-class implementation boundary: %s has not loaded in this session. Invoke `test-driven-development` and `yagni` through the configured skill-loading action, then retry. This guard covers code paths written through Write/Edit-class actions; it does not claim to cover shell-driven writes.' "$1"
}

target_path() {
  local path
  path="$(get '.tool_input.file_path')"
  [ -n "$path" ] || path="$(get '.tool_input.path')"
  printf '%s' "$path"
}

deny_json() {
  local reason="$1"
  jq -n --arg reason "$reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
}

# Claude-style payloads carry transcript_path as well as hook_event_name.
tool="$(get '.tool_name')"
if [ -n "$(get '.transcript_path')" ] && [[ "$tool" =~ ^(Write|Edit|MultiEdit)$ ]]; then
  path="$(target_path)"
  [ -n "$path" ] && is_code_path "$path" || exit 0
  transcript="$(get '.transcript_path')"
  [ -f "$transcript" ] || exit 0

  skills="$(jq -r 'select(.type=="assistant") | .message.content[]?
                 | select(.type=="tool_use" and .name=="Skill")
                 | .input.skill // empty' "$transcript" 2>/dev/null)" || exit 0
  missing="$(printf '%s\n' "$skills" | pair_missing)"
  [ -z "$missing" ] && exit 0

  reason="$(guard_reason "$missing")"
  deny_json "$reason"
  exit 0
fi

# Ledger-backed payloads carry hook_event_name and session_id.
[ -n "$(get '.hook_event_name')" ] || exit 0
event="$(get '.hook_event_name')"
session="$(get '.session_id' | tr -cd 'A-Za-z0-9._-')"
[ -n "$session" ] || exit 0
ledger="${TMPDIR:-/tmp}/sdlc-skills-implementation-$session"

case "$event" in
  PostToolUse)
    # Skill loads and code edits are recorded in the order they happened. The
    # ordering is what lets the turn-end completion guard answer "was this change
    # verified AFTER it was made?" on a harness that exposes no transcript.
    if [ "$tool" = "Skill" ]; then
      skill="$(get '.tool_input.skill')"
      [ -n "$skill" ] && ( umask 077; printf '%s\n' "$skill" >> "$ledger" )
    elif [[ "$tool" =~ ^(Write|Edit|MultiEdit)$ ]]; then
      edited="$(target_path)"
      [ -n "$edited" ] && is_code_path "$edited" &&
        ( umask 077; printf 'EDIT\t%s\n' "$edited" >> "$ledger" )
    fi
    ;;
  PreToolUse)
    case "$tool" in
      Write|Edit|MultiEdit)
        paths="$(target_path)" ;;
      *) exit 0;;
    esac
    [ -n "$paths" ] && is_code_path "$paths" || exit 0

    if [ -e "$ledger" ]; then
      [ -r "$ledger" ] && [ -O "$ledger" ] || exit 0
      missing="$(pair_missing < "$ledger")"
      [ -z "$missing" ] && exit 0
    else
      missing="test-driven-development and yagni"
    fi
    reason="$(guard_reason "$missing")"
    printf '%s' "$reason" >&2
    exit 2
    ;;
esac
