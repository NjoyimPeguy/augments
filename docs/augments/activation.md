# Activation: how augments stays active across a long session

Augments' skills are only useful if the agent actually reaches for them at the right moment. Two hooks keep that routing reflex alive on Claude Code.

## The two layers

1. **SessionStart bootstrap** (`hooks/claude-code/context.md`) — injected once at the start of every session (and on resume / clear / compact). It states the routing procedure: before any non-trivial request, check whether an installed skill fits, and invoke it first.

2. **Per-turn floor** (`hooks/claude-code/per-turn.md`, via a `UserPromptSubmit` hook) — one short line prepended to *every* user turn, reminding the agent to route before acting.

## Why the per-turn floor exists

A SessionStart injection is a one-shot event. Over a long session — many turns, and especially once the context is compacted — that nudge is summarized away, and the agent silently loses the instruction that points it at the library. This is the most common cause of "skills worked at first, then stopped firing."

The per-turn floor fixes that structurally: the routing reminder can't decay if it re-lands every turn. It carries the *firing pressure* so the skill descriptions don't have to — they can describe **when** a skill fits without shouting "ALWAYS", keeping the library's alongside-your-judgment tone.

## The cost, stated honestly

The per-turn line is ~20–30 tokens. Over a 1,000-turn session that is ~20–30k tokens cumulative — about one SessionStart injection's worth, spread across the whole session (and compaction trims even that). It is a small, steady tax.

This is a deliberate divergence from the heavier approach of re-injecting a full router every turn, which *does* explode token cost — that is why some skill libraries refuse per-turn injection entirely and accept the decay. Augments takes the opposite bet: a single short line per turn is cheap, and it targets the decay directly.

## Turning it off

If you would rather accept some decay than pay the per-turn tax, remove the `UserPromptSubmit` entry from `hooks/claude-code/hooks.json`. The SessionStart bootstrap still fires; only the per-turn floor is gone.
