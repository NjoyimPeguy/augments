# Triggering test: session-nudge (proactive-use hook)

The session-start nudge (`hooks/claude-code/context.md`) is harness-side text, not a skill description — but its wording decides whether an agent reaches for the library at all, so a wording change owes the same dated proof as a description change. Re-run whenever the nudge text changes.

**Method.** Fresh subagents receive the nudge text verbatim, the live skill catalogue, and one kickoff opening, and state their honest first action. LLM-judge proxy, not a deterministic gate.

## Scenario

> "Add rate limiting to our API gateway — where do I start?"

## Pass criteria

- **GREEN:** the agent's first move consults or invokes a fitting skill (orientation, interview, zoom-out, planning) rather than diving into freehand implementation.
- **RED:** the agent starts implementing or designing inline without reaching for any skill.

## Last result (2026-06-09)

Reworded the core imperative from "invoke it **instead of working freehand**" to "invoke it **to anchor the work — the skills work alongside your judgment, adding the gates and checks it cannot supply alone**", aligning the nudge with the philosophy's *Alongside intelligence* section. The escape clause ("if no skill genuinely applies, proceed normally") is unchanged.

- **3/3** named a skill as the first or immediate-next action: `zoom-out` first in all three, followed by `interview-me` (2) / `spec-it` (1) / `writing-plans` (1). One led with a quick code search before naming the skill — orienting, not bypassing.
- Context: a same-day end-to-end sandbox run under the *old* wording also activated skills reliably, so this measures that the friendlier wording **preserves** activation, not that it improves it. Directional, single-model, three trials.

## Delivery change (2026-06-14)

Changed *how* the nudge is delivered, not *what* it says — so no triggering re-run is owed (activation depends on the text, which is byte-identical):

- **Matcher** `startup|clear|compact` → `startup|resume|clear|compact`. The old matcher skipped resumed sessions (`--continue`/`--resume`/`/resume`), so the nudge never fired on resume; `resume` closes that gap.
- **Output** raw `cat` of `context.md` → `hooks/claude-code/session-start.sh`, which wraps the *same* `context.md` in the harness's JSON context envelope (`hookSpecificOutput.additionalContext`). Raw stdout is consumed as context only on some harnesses; the explicit envelope is robust and the script round-trips byte-for-byte to `context.md` (verified). The script carries forward-looking branches for sibling adapters, but only its own harness's branch runs under this manifest.

Both are delivery/robustness changes; the proactive-use text is untouched, so the 2026-06-09 activation result above still stands.

## Wording change (2026-06-14) — invocation as the visible first act

**Field RED.** A real session in a mature project *delivered* the nudge into context (confirmed in the session transcript — the nudge text present in the injected `additionalContext`) yet the agent opened a debugging request by dispatching an explorer and **never invoked a skill** — no `Skill` call anywhere in the session. Delivery worked; invocation didn't. The old wording asked the agent to "check whether a skill fits … and invoke it," then handed it a silent exit ("if no skill applies, proceed normally") — which it took without ever making the check visible.

**Change.** The nudge now frames the first act as the invocation itself, with the choice made visible: "before you touch the code, invoke the skill that fits — and say which as you do it: `Using augments:<name> to <purpose>`." The escape hatch is kept but must now be *spoken* ("if no skill genuinely fits, say so in one line and proceed"), closing the silent skip. No coercion ("must / no choice / 1% chance") and no whole-skill injection — the nudge stays ~800 tokens.

**Method.** Two proxies, old vs new, plus a third condition prepending the **verbatim** competing output-style injections from the field session (two output styles were active there, injected ahead of the nudge). Fresh subagents; Claude Code; large-tier model.

1. *Structured* (name one skill or NONE): **11/11 chose `debugging`** across old, new, and competition. No separation — the question foregrounds the catalogue and floors at 100%. Measures only that the new wording **does not regress** activation and **survives the competition**, not that it improves on the old.
2. *Open-ended* (no skill-foregrounding — "write your actual first response"): both wordings still reach for debugging, so this proxy too cannot reproduce the silent skip — a reflective agent with the catalogue in view routes correctly either way. The measured separation is in **visibility**: the new wording produced the explicit `Using augments:<name> to <purpose>` announcement in **7/7** (new 4/4 + competition 3/3); the old wording produced only soft, embedded mentions ("I'd like to invoke…", "let me reach for…") in **0/4**. Under the verbatim output-style competition that drowned the nudge in the field, the announcement still fired **3/3** — alongside, not instead of, the output styles' own formatting.

**What this proves, and what it doesn't.** Proven: no activation regression; the announcement convention — the visible trace that a skill is being loaded — is adopted reliably and survives the real competition. Not proven here: that it fixes the silent skip, because neither proxy reproduces that failure (both put the catalogue before a reflective agent; the field failure needs a live session with competing priorities and no reflective space). **The definitive proof is a live re-test, owed after this ships:** start a fresh debugging session in the same kind of mature project and read the transcript for an actual `Skill` call on an `augments:*` skill — the same transcript-level check that caught the RED. Recorded as pending, not green.
