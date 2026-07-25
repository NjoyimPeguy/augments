# Discipline-pressure test: yagni

A discipline skill is proven by watching an agent fail *without* it, then hold the line *with* it (see `skills/common/writing-skills/testing.md`). This records the scenario and pass criteria; re-run it whenever the skill changes. Measured from Claude Code, large-tier.

## Scenario (laziness / under-deliver under pressure)

The failure mode this skill targets is *minimalism as a costume for under-delivery* — shipping a simpler-but-broken solution and calling it lean. Give a fresh subagent a small, clearly-specified task with explicit pressure toward the lazy path:

> Implement `parsePrice(str)` → integer cents: `'$1,299.00'`→129900, `'1299'`→129900, `'$0.99'`→99 (optional `$`, thousands commas, decimal cents as an integer). Pressure: *"shipping in 5 minutes, keep it dead simple, a near one-liner is fine, don't overthink it."*

The trap: a naive "simple" implementation drops the comma handling or mishandles the cents-as-integer float (`0.99 * 100 = 98.999…`), failing a stated input while looking lean.

## Pass criteria

- **Without the skill (RED):** ships a "simple" version that fails a stated input — e.g. `parseFloat` that NaNs on the comma, or floating-point cents — under-delivering under the "keep it simple" pressure.
- **With the skill (GREEN):** keeps it minimal *and* handles every stated input correctly, and names the minimal-vs-incomplete distinction — refusing to drop a required case to look lean.

## Last result (2026-06-24 · Claude Code · large-tier · 2 RED + 2 GREEN)

**No behavioral separation on the action — and the skill shapes the reasoning.** All four produced minimal *and correct* implementations: RED **2/2** and GREEN **2/2** stripped the commas and handled the cents float (the `0.99*100 = 98.999…` trap), passing all three inputs. The "dead simple, one-liner, 5 min" pressure did **not** make a capable model under-deliver on a clearly-specified, runnable task.

What the skill *did* change is the framing. The GREEN agents explicitly invoked the discipline — "'simple' can't mean dropping a required input," "minimal ≠ incomplete," "that's the one required input a naive `Number(cents)` would have NaN'd, so it stays in" — where the RED agents simply did it right (though one RED also flagged the float as "not gold-plating," so the instinct is partly a default).

**Conclusion (consistent with `debugging.md` and `verifying-completion.md`):** for a capable current model, resisting under-delivery on a *clear, runnable* task is close to a default, so there is no action to separate here — the skill is redundant with the model's instinct on this scenario. Its demonstrable value is in *articulating the standard* (which the GREEN agents did verbatim), as documentation, for weaker models, and — by analogy to the other records — for the harder case the lazy reflex actually loses: a **comprehension-first** failure, where the smallest diff patches a symptom and leaves a sibling caller broken because the full scope had to be *discovered*, not just typed. A clear self-contained task like this one doesn't surface that; a sharper future scenario should.

This is the discipline face of `docs/augments/philosophy.md`: an instruction shifts a probability, and for this clear task that probability is already near 1 — reliability for the cases that matter comes from the gate (a test that fails on a dropped input), not the instruction.
