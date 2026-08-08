#!/usr/bin/env bash
# Kimi Code CLI adapter. Sourced by the dispatchers in tests/; never executed.

adapter_name='kimi-code'
source_kimi_home="${KIMI_CODE_HOME:-${HOME:-}/.kimi-code}"

adapter_check() {
  command -v kimi >/dev/null 2>&1 || { echo "no \`kimi\` CLI on PATH" >&2; return 3; }
}

# Isolated home with this checkout as a managed plugin — the layout
# `kimi /plugins install` produces (plugins/managed/sdlc-skills + installed.json).
adapter_install() { # $1 plugin source
  harness_home="$(mktemp -d)"
  local f d
  for f in config.toml device_id; do
    [ -f "$source_kimi_home/$f" ] && cp "$source_kimi_home/$f" "$harness_home/$f"
  done
  for d in credentials oauth; do
    [ -d "$source_kimi_home/$d" ] && cp -r "$source_kimi_home/$d" "$harness_home/$d"
  done
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

adapter_chain() {
  jq -rc 'select(.role == "assistant")
          | .tool_calls[]?
          | select(.function.name == "Skill")
          | (.function.arguments | try fromjson catch {} | .skill // empty)
          | "sdlc-skills:" + .' "$1" 2>/dev/null
}

# No prompt suffix: the sessionStart nudge is part of what this exercises, so the
# opening goes in bare, as a real user opening.
adapter_prompt_suffix() { :; }

# NO permission flag, deliberately. `kimi -p` already auto-approves tool calls;
# both approval flags are REJECTED in prompt mode ("Cannot combine --prompt with
# --auto" / "...--yolo"). Verified by having a throwaway `-p` run create a file
# with no flags at all — do not add one back thinking it grants write access.
adapter_run_activation() { # $1 workdir  $2 prompt  $3 stream
  ( cd "$1" && exec timeout "$timeout_s" env KIMI_CODE_HOME="$harness_home" \
      kimi -p "$2" --output-format stream-json ) < /dev/null > "$3" 2>>"$errlog"
}

adapter_activation_flags() { :; }

adapter_run_behavioral() { # $1 workdir  $2 opening file  $3 stream
  ( cd "$1" && exec timeout "$timeout_s" env KIMI_CODE_HOME="$harness_home" \
      kimi -p "$(cat "$2")" --output-format stream-json ) < /dev/null > "$3" 2>>"$errlog"
}
