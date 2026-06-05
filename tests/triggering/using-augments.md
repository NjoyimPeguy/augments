# Triggering test: using-augments

Activation depends solely on the `description` — it is the only text the runtime reads when deciding whether to load a skill (see `skills/common/writing-skills/reference.md`). This records the scenario and pass criteria; re-run whenever the description changes.

**Method.** Give fresh subagents only the skill *catalogue* (every skill's `name :: description`, no bodies) plus one opening user message, and ask which skill(s) the triggers match at the start of the conversation. This is an LLM-judge proxy for the runtime's load decision, not a deterministic gate — a portable "did the Skill tool fire" check isn't possible here without binding to one harness's CLI and output format, which the project's harness-agnosticism forbids. Run several fresh trials per arm (same model across arms) so the only variable is the description.

## Scenario

Two framings, because they isolate different things:

- **Best-fit ("pick the skill that fits; don't pad"):** opening messages = a feature kickoff ("add rate limiting to our API gateway — where do I start?"), a bug ("SSO login is broken — investigate"), and a trivial change ("bump lodash to the latest patch"). Measures whether `using-augments` is *invoked first* and whether it over-fires on the trivial task.
- **Neutral ("list every trigger that matches this moment"):** same kickoff/bug openings. Measures whether the description is *recognised* as matching the start of a conversation.

## Pass criteria

- **New description (GREEN):** recognised as a conversation-start trigger under the neutral framing; **not** fired on the trivial change (no ceremony on tiny tasks).
- **Old description (RED baseline):** the self-referential "starting work in a repo that uses augments" is misread as "the augments repo itself" and fails to fire in an ordinary user repo.

## Last result (2026-06-05)

Description reworded from *"Use to get oriented in the augments skill library … starting work in a repo that uses augments, or when unsure which skill fits"* to a conversation-start trigger keyed on the task moment.

- **Neutral framing:** old **0/6** recognised `using-augments` (every judge read "a repo that uses augments" as the augments repo itself — *"this is not the augments repo, so the trigger does not match"*); new **5/6** recognised it as firing "at the start of any task or conversation." Clear improvement, and it fixes a latent misfire that would have suppressed the skill in every real user repo.
- **Best-fit framing:** both old and new fired `using-augments` **first 0/9** — when a specific skill (interview-me, debugging) matches, a discerning agent skips the router as redundant. **No over-trigger** on the trivial change (0/3 both arms).

**Caveat (important):** a description can only *signal* "entry point"; it cannot *force* the router to be invoked when a sharper skill competes (best-fit, 0/9 in both arms). Guaranteeing it fires every conversation would require always-loading it via a harness mechanism — which the project rejects as non-portable and as ceremony the toolbox philosophy avoids. The reworded description is the right portable ceiling: better recognition, fixed misread, no over-fire.
