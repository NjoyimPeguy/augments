#!/usr/bin/env bash
# Scoped implementation-entry guard for structured edit-class code changes.
#
# This hook catches accidental routing skips on the tool surface it can observe.
# It is not a universal mutation boundary: shell commands can write files without
# using Write, Edit, or apply_patch, and unsupported harnesses may expose
# different tools. The adapter documentation and tests name that scope.
#
# Claude-style hook payloads carry transcript_path, so loaded skills are read
# from the real session transcript. Kimi and Codex payloads use an owner-only
# per-session ledger: Kimi records native Skill calls; Codex records successful
# reads of the two skill files because that adapter has no native Skill action.
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
  printf 'Blocked on the structured edit-class implementation boundary: %s has not loaded in this session. Invoke `test-driven-development` and `yagni` through the configured skill-loading action, then retry. This guard covers code paths written through Write/Edit/apply_patch-class actions; it does not claim to cover shell-driven writes.' "$1"
}

target_path() {
  local path
  path="$(get '.tool_input.file_path')"
  [ -n "$path" ] || path="$(get '.tool_input.path')"
  printf '%s' "$path"
}

tool_input_text() {
  printf '%s' "$input" | jq -r '
    .tool_input // empty | if type == "string" then . else tojson end
  ' 2>/dev/null
}

patch_paths() {
  tool_input_text | grep -oE '\*\*\* (Add|Update|Delete) File: [^\\"[:cntrl:]]+' |
    sed -E 's/^\*\*\* (Add|Update|Delete) File: //'
}

codex_loaded_disciplines() {
  local raw skill
  raw="$(tool_input_text)"
  printf '%s' "$raw" | grep -qiE '\b(cat|sed|awk|head|tail|less|bat|read|open)\b' || return 0
  for skill in test-driven-development yagni; do
    printf '%s' "$raw" | grep -qE "(^|/)$skill/SKILL\.md([[:space:]\\\"']|$)" &&
      printf '%s\n' "$skill"
  done
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
    if [ "$tool" = "Skill" ]; then
      skill="$(get '.tool_input.skill')"
      [ -n "$skill" ] && ( umask 077; printf '%s\n' "$skill" >> "$ledger" )
    elif [[ "$tool" =~ ^(exec|exec_command|functions.exec)$ ]]; then
      loaded="$(codex_loaded_disciplines)"
      [ -n "$loaded" ] && ( umask 077; printf '%s\n' "$loaded" >> "$ledger" )
    fi
    ;;
  PreToolUse)
    case "$tool" in
      Write|Edit|MultiEdit)
        paths="$(target_path)" ;;
      apply_patch|ApplyPatch)
        paths="$(patch_paths)" ;;
      exec|functions.exec)
        tool_input_text | grep -qE 'tools\.apply_patch|\*\*\* Begin Patch' || exit 0
        paths="$(patch_paths)" ;;
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
    case "$tool" in
      apply_patch|ApplyPatch|exec|functions.exec) deny_json "$reason"; exit 0 ;;
      *) printf '%s' "$reason" >&2; exit 2 ;;
    esac
    ;;
esac
