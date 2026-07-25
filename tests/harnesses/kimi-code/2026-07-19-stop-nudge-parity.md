# Stop-hook parity record (2026-07-19)

## Problem

The Kimi adapter shipped with the session-start nudge but no done-boundary
re-nudge: `hooks/stop-nudge.sh` speaks the Claude-style Stop payload
(`last_assistant_message` inline, `{"decision":"block"}` envelope), which
Kimi's blockable `Stop` event does not provide.

## Change

- Extracted the shared detection policy (in-progress filter, completion-claim
  matcher, reason text) into `hooks/stop-nudge-detect.sh`; `hooks/stop-nudge.sh`
  keeps its exact payload/JSON interface and now delegates to it.
- Added `hooks/stop-nudge-kimi.sh`, adapting the two harness differences:
  the last assistant message is recovered from the session wire log
  (`$KIMI_CODE_HOME/sessions/*/<session_id>/agents/main/wire.jsonl`, last
  `content.part` text event), and blocking is exit 2 with the reason on
  stderr. Loop guard via the payload's `stop_hook_active`; fail-open
  everywhere else.
- Declared the hook in `.kimi-plugin/plugin.json`'s `hooks` array.
- Added the offline test `tests/harnesses/kimi-code/test-stop-nudge.sh`
  (payload + wire fixtures). All three harnesses' offline tests pass against
  the shared detector.

## Offline evidence

```bash
bash tests/harnesses/kimi-code/test-stop-nudge.sh
```

```text
ok    done-claim             re-nudges (exit 2)
ok    fixed-claim            re-nudges (exit 2)
ok    in-progress            lets turn end
ok    no-claim               lets turn end
ok    loop-guard             lets turn end
ok    missing-wire           lets turn end
PASS - Kimi stop-nudge blocks done-claims and fails open
```

## Live evidence (Kimi Code CLI 0.27.0, isolated managed install)

Prompt: "Create a file called done-probe.txt containing the word hello, verify
it exists, then stop." Observed stream:

1. The agent wrote the file, read it back, and claimed: *"Done —
   `done-probe.txt` exists with content `hello`, verified by reading it
   back."* — a completion claim; the Stop hook fired and blocked.
2. Forced to continue, the agent immediately invoked the
   `verifying-completion` skill (`Skill` tool call).
3. It ran a **fresh** check (`ls -l` + exact content match) and re-stated done
   with the exact command and its output quoted.
4. The second Stop fired with `stop_hook_active: true` and the turn ended —
   the loop guard worked; the nudge fired exactly once.

## Honest limits

- The wire-log path is an internal layout, not a documented API. If a future
  CLI moves it, the hook fails open (no nudge), never blocks spuriously —
  verified by the `missing-wire` offline case.
- Proven for the main agent's wire log; subagent Stop events were not
  exercised.
