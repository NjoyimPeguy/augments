#!/usr/bin/env bash
# Claude Code adapter. Sourced by the dispatchers in tests/; never executed.
#
# Everything harness-agnostic lives in tests/lib/. This file holds only what is
# true of the `claude` CLI: how skills are loaded, how it is invoked, how an
# activation is detected, and where its Stop hook lives.

adapter_name='claude-code'

adapter_check() {
  command -v claude >/dev/null 2>&1 || { echo "no \`claude\` CLI on PATH" >&2; return 3; }
}

# Claude Code loads a plugin tree directly — no install step, no isolated home.
adapter_install() { plugin_dir="$1"; }

# DETECTION: only a structured `Skill` tool_use in an ASSISTANT event counts.
# The SessionStart nudge text and the init manifest both contain `augments:`
# tokens; a raw grep matches those and reports a phantom activation. The first
# cut of this harness did exactly that.
adapter_chain() {
  jq -r 'select(.type=="assistant") | .message.content[]?
         | select(.type=="tool_use" and .name=="Skill") | .input.skill' "$1" 2>/dev/null
}

# Read-only: the tool under test (Skill) plus read-only tools. Any Write/Edit/
# Bash a skill attempts is denied, so activation is observed without side effects.
adapter_run_activation() { # $1 workdir  $2 prompt  $3 stream  $4 extra flags...
  local wd="$1" prompt="$2" stream="$3"; shift 3
  # --max-turns bounds a run that never reaches the expected skill; without it a
  # miss burns a full session instead of stopping.
  ( cd "$wd" && exec timeout "$timeout_s" claude -p "$prompt" \
      --output-format stream-json --verbose "$@" \
      --max-turns "${maxturns:-6}" \
      --allowedTools Skill Read Glob Grep ) < /dev/null > "$stream" 2>>"$errlog"
}

adapter_activation_flags() {   # --working-tree loads live edits, not the install cache
  printf '%s\n' --plugin-dir "$repo"
}

# WRITE access — a behavioural arm must be able to produce artifacts. Safe: the
# run happens in a disposable fixture copy under /tmp, never in this repo.
adapter_run_behavioral() { # $1 workdir  $2 opening file  $3 stream
  ( cd "$1" && exec timeout "$timeout_s" claude -p "$(cat "$2")" \
      --output-format stream-json --verbose \
      --plugin-dir "$plugin_dir" \
      --allowedTools Skill Read Glob Grep Write Edit Bash TodoWrite \
      --permission-mode acceptEdits ) < /dev/null > "$3" 2>>"$errlog"
}

adapter_stop_hook() { printf '%s\n' "$repo/scripts/sh/stop-nudge.sh"; }

# The Stop payload this harness delivers: stop_hook_active + the last message.
adapter_stop_payload() { # $1 stop_hook_active  $2 last message
  jq -cn --argjson a "$1" --arg m "$2" '{stop_hook_active:$a, last_assistant_message:$m}'
}
