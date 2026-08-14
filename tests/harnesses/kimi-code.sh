#!/usr/bin/env bash
# Kimi Code CLI adapter. Sourced by the runners under tests/ — behavioural,
# plugin-smoke, and trigger-eval — never executed directly.

adapter_name='kimi-code'
source_kimi_home="${KIMI_CODE_HOME:-${HOME:-}/.kimi-code}"

adapter_check() {
  command -v kimi >/dev/null 2>&1 || { echo "no \`kimi\` CLI on PATH" >&2; return 3; }
}

# Isolated home with this checkout as a managed plugin — the layout
# `kimi /plugins install` produces (plugins/managed/sdlc-skills + installed.json).
adapter_install() { # $1 plugin source ("" = NONE arm, install nothing)
  harness_home="$(mktemp -d)"
  local f d
  for f in config.toml device_id; do
    [ -f "$source_kimi_home/$f" ] && cp "$source_kimi_home/$f" "$harness_home/$f"
  done
  for d in credentials oauth; do
    [ -d "$source_kimi_home/$d" ] && cp -r "$source_kimi_home/$d" "$harness_home/$d"
  done
  # NONE arm: an isolated home with credentials and no plugins/ tree at all.
  [ -n "$1" ] || return 0
  local managed="$harness_home/plugins/managed/sdlc-skills"
  mkdir -p "$managed"
  ( cd "$1" && tar --exclude=.git --exclude=.sdlc-skills -cf - . ) | tar -xf - -C "$managed"
  [ -f "$managed/.kimi-plugin/plugin.json" ] || {
    echo "no .kimi-plugin/plugin.json in $1 — does that ref carry the Kimi adapter?" >&2
    return 2; }
  local skills; skills="$(find "$managed/skills" -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')"
  jq -n --arg root "$managed" \
        --arg manifest_path "$managed/.kimi-plugin/plugin.json" \
        --arg original "$1" \
        --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --argjson skills "$skills" \
        --slurpfile manifest "$managed/.kimi-plugin/plugin.json" \
    '{version: 1, plugins: [{
       id: "sdlc-skills", root: $root, source: "local-path", enabled: true,
       state: "ok", installedAt: $now, updatedAt: $now, originalSource: $original,
       skillCount: $skills, manifest: $manifest[0],
       manifestKind: "kimi-plugin-dir", manifestPath: $manifest_path,
       diagnostics: [], skillInstructions: $manifest[0].skillInstructions
     }]}' > "$harness_home/plugins/installed.json" || return 2
}

# DID IT RUN? kimi emits no terminal record, so the signal is whether the model
# spoke at all: a real run carries `assistant` records, and a run that died
# before reaching the model carries only the opening `meta` line. Observed on
# 0.34.0 — a full 20-query eval returned one line per call,
# {"role":"meta","type":"system.version",...}, with stderr `failed to run
# prompt: internal: The provided authorization grant is invalid`, and scored as
# 20 clean misses because nothing here noticed the provider never answered.
adapter_ran() {
  jq -e -s 'any(.[]; .role == "assistant")' >/dev/null 2>&1 <"$1"
}

adapter_chain() {
  jq -rc 'select(.role == "assistant")
          | .tool_calls[]?
          | select(.function.name == "Skill")
          | (.function.arguments | try fromjson catch {} | .skill // empty)
          | "sdlc-skills:" + .' "$1" 2>/dev/null
}

adapter_behavioral_events() {
  jq -r 'select(.role == "assistant") | .tool_calls[]?
         | .function as $fn
         | ($fn.arguments | try fromjson catch {}) as $input
         | if $fn.name == "Skill" then
             "SKILL sdlc-skills:" + ($input.skill // "")
           elif ($fn.name == "Write" or $fn.name == "Edit" or $fn.name == "MultiEdit") then
             "EDIT " + ($input.path // $input.file_path // "")
           else empty end' "$1" 2>/dev/null
}

# No prompt suffix: the sessionStart nudge is part of what this exercises, so the
# opening goes in bare, as a real user opening.
adapter_prompt_suffix() { :; }

# NO permission flag, deliberately. `kimi -p` already auto-approves tool calls;
# both approval flags are REJECTED in prompt mode ("Cannot combine --prompt with
# --auto" / "...--yolo"). Verified by having a throwaway `-p` run create a file
# with no flags at all — do not add one back thinking it grants write access.
#
# The consequence, stated rather than left implicit: this is the one adapter
# whose activation runs are NOT restricted to reading. The other two are —
# claude-code pins the available tools, codex sandboxes with `-s read-only` —
# and kimi publishes no flag that does either; every switch it offers grants
# permission rather than withholding it. Containment is therefore positional
# only: the caller runs each activation in a disposable `mktemp -d` and removes
# it afterwards, so an ordinary relative write is thrown away, while a write to
# an absolute path outside that directory is not prevented by anything here.
# Do not point this adapter at a directory whose contents matter.
adapter_run_activation() { # $1 workdir  $2 prompt  $3 stream
  ( cd "$1" && exec timeout "$timeout_s" env KIMI_CODE_HOME="$harness_home" \
      kimi -p "$2" --output-format stream-json ) < /dev/null > "$3" 2>>"$errlog"
}

adapter_activation_flags() { :; }

adapter_run_behavioral() { # $1 workdir  $2 opening file  $3 stream
  ( cd "$1" && exec timeout "$timeout_s" env KIMI_CODE_HOME="$harness_home" \
      kimi -p "$(cat "$2")" --output-format stream-json ) < /dev/null > "$3" 2>>"$errlog"
}

# Continue a multi-turn behavioural session through Kimi's structured resume
# hint. An absent id is an adapter failure; starting fresh would invalidate any
# approval/version handoff the scenario is meant to observe.
adapter_continue_behavioral() { # $1 workdir  $2 prompt  $3 new stream  $4 prior stream
  local wd="$1" prompt="$2" out="$3" prior="$4" session_id
  session_id="$(jq -r 'select(.role == "meta" and .type == "session.resume_hint")
                       | .session_id // empty' "$prior" 2>/dev/null | tail -1)"
  [ -n "$session_id" ] || { echo "Kimi stream contains no resumable session id" >&2; return 2; }
  ( cd "$wd" && exec timeout "$timeout_s" env KIMI_CODE_HOME="$harness_home" \
      kimi --session "$session_id" -p "$prompt" --output-format stream-json \
    ) < /dev/null > "$out" 2>>"$errlog"
}

# NO adapter_usage here, and that is a finding rather than an omission. On kimi
# 0.34.0 the only prompt-mode formats are `text` and `stream-json`, and a real
# stream-json run emits just `meta` (version, resume hint) and `assistant`
# events — no usage object, no token counts, no cost, and no flag that adds
# them. So run-behavioral.sh reports this harness's wall clock and states that
# tokens are unreported, which is true, instead of inventing a number. Add the
# function if a later version starts reporting one — read it off a real stream.
