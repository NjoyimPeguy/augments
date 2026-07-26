---
name: yagni
description: "Use whenever implementation code is being written — invoke it the moment implementation starts, as test-driven-development's pair — and at any point you catch either scope failure: building MORE than the task asked (a new abstraction, interface, config knob, or dependency it doesn't need; anything kept \"for later\") or delivering LESS than the task asked (a stub, a TODO, a patch that quiets one symptom while sibling callers stay broken). Build exactly what the task needs — no more, no less — and prove it runs. Skip throwaway spikes or pure config with no logic."
---

# YAGNI — build only what's needed, and make it work

You Ain't Gonna Need It: the cheapest code is the code you never write. But "less code" measures **design**, never **correctness or effort** — a smaller solution that doesn't solve the task isn't lean, it's *unfinished*. This is a discipline skill: under pressure you'll reach for the smallest diff, and the point is to keep that reflex aimed at *scope*, not at *finishing*.

## The one definition everything hangs on

**"Needed" = solves the task the user actually asked for, and runs.** Cutting scope is YAGNI. Cutting *behaviour the task requires* is under-delivery wearing YAGNI as a costume.

## Make the correct path the lazy path

"Be thorough" doesn't hold under pressure. Instead, see the shortcut's *real* cost: a stub is not less work — it's deferred work, plus the bug it ships, plus re-reading all this context when you come back to it. **Doing it right once is the lazier path.** Aim the laziness instinct at the complete solution instead of fighting it.

## The ladder — stop at the first rung that holds

1. **Does it need to exist at all?** Speculative need → skip it, say so in one line.
2. **Already in this codebase?** Reuse it — re-implementing what's a few files over is the most common waste.
3. **Standard library?** Use it.
4. **Native platform feature?** A built-in over a dependency; a constraint over hand-rolled code.
5. **An already-installed dependency?** Use it. Never add one for what a few lines do.
6. **One line?** One line.
7. **Only then:** the minimum code that *fully works*.

No unrequested abstraction: no interface with one implementation, no factory for one product, no config for a value that never changes.

## The ladder runs AFTER comprehension, never instead of it

Read the task and the code it touches; trace the real flow end to end; *then* minimise. The smallest change in the wrong place isn't lazy — it's a second bug. A bug fix targets the **root cause**: fix the shared function every caller routes through once — that is a *smaller* diff than one patch per caller, and patching only the named path leaves siblings broken. (Pair with `debugging`.)

## Minimal ≠ unreadable — craft is not scope

The ladder minimises *how much* you build, never *how well* it's written. Readability is part of "it works": code the next reader can't understand stops working the moment it needs a change — and the next reader is often you, after compaction, with no memory of writing it. Match the file's conventions, name for the domain rather than brevity, comment the *why* above non-obvious logic, prefer simple over clever. The full craft checklist and examples: `references/yagni-in-depth.md`.

## When you're tempted to call it done

| The thought | The reality |
| --- | --- |
| "Simplest version: just stub this / return a placeholder" | A stub is an *unsolved* task, not a simpler solution. |
| "I'll keep it minimal and leave a TODO" | YAGNI defers *unneeded* features, never *needed* behaviour. |
| "Shortest diff wins, so I'll touch the smallest spot" | Smallest diff in the wrong place is a second bug. |
| "Skipped the error/edge handling to stay lean" | Correctness is never the thing you minimise. |
| "Simple enough to be obviously right — didn't run it" | Unverified is not done. Run it. |
| "Deleted that code, it looked unused" | Removing needed behaviour to shrink the diff is under-delivery. |
| "Ship the quick version, clean it up later" | Later never comes; every future change pays the re-reading cost. Readable now is the cheaper path. |
| "Clear names and comments are gold-plating" | Gold-plating is unneeded *features*. Clarity is maintenance cost — the thing this skill exists to protect. |
| "My usual style beats this file's conventions" | A codebase in one voice is cheaper to change than your personal best practice. Match it. |

## Hard stops

- **Minimal ≠ incomplete.** If it doesn't solve the task and run, it isn't done — "smaller" is only a tiebreaker between two solutions that *both fully work*.
- Before claiming done: it runs / passes its check; it handles the inputs the task implies; no TODO or placeholder sits on a path the task needs *now*. A stub on a required path is an automatic fail (confirm with `verifying-completion`).
- **Never minimise away:** input validation at a trust boundary, error handling that prevents data loss, security, accessibility, or anything the user explicitly asked for.
- **Never compress away:** names that say what things are, the *why* above non-obvious logic, the conventions of the file around the change. Before claiming done, the diff should read like one author wrote the whole file.

## Minimal vs unfinished

Before shipping, put every cut on the right list. **Minimal:** fewer abstractions, files, dependencies, lines — for the *same working behaviour*. **Unfinished:** missing behaviour, stubs, unhandled cases, untested logic, deleted-but-needed code, code so compressed the next reader must reverse-engineer it. Cutting from the first list is the skill; cutting from the second is the failure this skill exists to stop.

## The one exception

A throwaway spike answering a single question, or pure config/content with no logic — there's no task-correctness to protect, so minimise freely. Everything with real behaviour gets the full discipline.

For the ladder in depth, worked minimal-vs-bloated examples, and the full carve-out list, see `references/yagni-in-depth.md`.
