# Triggering test: post-mortem

Activation depends solely on the `description` (see `skills/common/writing-skills/reference.md`). `post-mortem` is a capability/process skill, not a discipline skill, so it has no compliance/pressure scenario — the risk is purely *routing*: it must fire when a failure has *escaped* and stay quiet on a plain bug (which belongs to `debugging`). Re-run whenever the description changes.

**Method.** Fresh subagents (small tier) see only the skill catalogue (descriptions, no bodies) and one opening message, and name the single skill they'd reach for first. LLM-judge proxy, not a deterministic gate. Several fresh trials.

## Scenario

Two activation prompts (a failure that already escaped and was fixed — the cause is known, so it is *not* `debugging`'s job) and one non-over-fire prompt (a plain bug that must route to `debugging`, not `post-mortem`):

- **Activation A:** "Production outage last night — null in the payments webhook took checkout down ~40 min. Root cause already found, patched, deployed, verified. Team wants to understand why it slipped past review and CI and make sure this class can't ship again."
- **Activation B:** "A reporting bug we shipped three weeks ago was just found by a customer … the fix is trivial. What bothers me is it got through everything unnoticed for three weeks. How should we handle *that* part?"
- **Non-over-fire:** "Bug in our date parser: wrong month for ISO strings with a timezone offset. Figure out what's going on and fix it."

## Pass criteria

- **Without the skill (RED baseline):** an escaped-failure retrospective has no home and falls back to `debugging` (treating "why did it escape" as just another bug to fix).
- **With the skill (GREEN):** the escaped-failure prompts route to `post-mortem` ("why the process let it through"), and the plain bug still routes to `debugging` — the `Skip for a bug you can simply fix — that is debugging` clause prevents over-firing.

## Last result (2026-06-08)

New skill added; clean separation on first measurement.

- **Routing to `post-mortem`: 0/2 (before) → 3/3 (after).** Before (catalogue without `post-mortem`), both escaped-failure prompts routed to `debugging` — nothing else fit. After, all three activation trials (outage ×2, late-found defect ×1) routed to `post-mortem`, quoting "Use after a failure escaped to production … to find why the process let it through and turn that into a structural fix."
- **Non-over-fire: 2/2 to `debugging`.** Both plain-bug trials chose `debugging`, not `post-mortem` — the description cedes plain bugs cleanly.
