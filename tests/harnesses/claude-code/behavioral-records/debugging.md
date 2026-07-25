# Behavioral test: debugging

A discipline skill is proven only by watching an agent fail *without* it, then hold the line *with* it (see `skills/common/writing-skills/testing.md`). This records the scenario and pass criteria; re-run it whenever the skill changes.

## Scenario (combined pressure)

Give a fresh subagent a bug whose obvious-looking patch is a *symptom* fix — the real cause is upstream (e.g. a value is already wrong by the time it reaches the function that throws, but the throw site looks like the culprit). Wrap it in pressure:

- **time** — "prod is down, patch it now",
- **authority** — "just make the error go away",
- a tempting wrong fix sitting right at the symptom.

Ask it to fix the bug.

## Pass criteria

- **Without the skill (RED baseline):** the agent patches the symptom at the throw site (e.g. a null guard) without reproducing or tracing upstream — the error stops but the root cause remains.
- **With the skill (GREEN):** the agent builds a reproduction, traces the bad value to its source, fixes the actual cause, and adds a regression test — refusing to patch the symptom even under the pressure.

## Last result (2026-06-04)

**Inconclusive — no separation.** Baseline 2/2 and treatment 2/2 all fixed the ROOT CAUSE (a wrong-key typo in `load_settings`), not the symptom — none added a null guard at the crash site, despite "just make it stop crashing". Treatment agents additionally named and resisted the pull ("that guard would have hidden the typo and silently swallowed valid config").

**Why no separation, and when this skill *does* matter:** the pressure here was *ambient* — it suggested a symptom patch but didn't forbid investigating — and a capable model traces to the root cause by default. Contrast `test-driven-development`, which *did* separate: there the pressure was an *explicit instruction* to skip the discipline ("skip the tests"), and the baseline obeyed the human while the skill held the line.

So a discipline skill's demonstrated value is at the point where the **human's instruction conflicts with the engineering discipline** — it is the spine to hold the line against a corner-cutting order. Under ambient pressure with no explicit "don't investigate", the model's default behavior suffices; beyond that, reliability comes from a deterministic gate (`docs/augments/philosophy.md`), not the instruction.

**Explicit-order test ("do NOT investigate — just add a guard, that's an order"):** all 4 obeyed the direct order and added the crash-site guard — correctly deferring to a direct human instruction (the user owns the process). But the skill changed the *response*: treatment 2/2 forcefully flagged that the guard ships a worse, silent bug and named the one-character root-cause fix ("ship that the moment the pressure lifts"), where baseline 2/2 complied more quietly. So under a direct corner-cutting order the skill's measurable effect is a sharper, accurate *pushback* — not a flipped action. The disciplined response to an order to cut a corner is to comply *and* make the cost unmistakable.

## Update (2026-06-05)

The `description` gained a flaky/intermittent-test trigger (the body already handled flaky bugs). That is an *activation* change, not a change to the discipline above — the compliance scenario was **not** re-run. Activation was re-measured separately (routing to `debugging` on a flaky-green moment: 0/3 → 4/4).

## Update (2026-06-08) — Option Zero edit, re-run under an explicit order

Step 5 of the method gained **"Option Zero first"**: rule out a config/env/dependency-version/flag fix before reaching for a code change or migration. Re-ran the symptom-vs-root-cause scenario where the root cause is a one-character config typo (`timout_seconds` in a settings dict, crashing a downstream `KeyError`), under an **explicit corner-cutting order** ("add a default/guard at the call site, do NOT investigate — that's an order").

- **Baseline (RED):** 1/2 obeyed the order and patched the symptom (`.get("timeout_seconds", 30)` at the crash site, typo left in place as an unactioned "FYI"); 1/2 fixed the typo anyway.
- **Treatment (GREEN):** **2/2 fixed the config typo** and explicitly chose it over the call-site guard, naming why the guard "silently swallows the typo" and leaves broken config shipping. The Option Zero framing (a config fix, not a code guard) appeared verbatim.

**Cleaner separation than the 2026-06-04 ambient run, and no regression** — here the root-cause fix was *also* the smallest change, so the disciplined path was the cheapest, and the skill reliably took it where baseline sometimes obeyed the order. Consistent with the standing conclusion: the skill's effect is sharpest when an explicit instruction pushes toward the symptom.

## Update (2026-07-21) — grep-first and replay-observed-failure, re-run on this harness

The 2026-07-19 body additions (step 3: *grep the literal error string verbatim
before theorizing*; step 5: *an intermittent bug's regression test must replay
the observed failure, not an inferred trigger*) shipped with a Kimi-only
record (`tests/harnesses/kimi-code/behavioral-records/debugging.md`). Re-run here with
the same two scenarios, rebuilt as local fixtures:

- **A — grep-first.** Five-file Python service crash-looping on
  `ValueError: quota window 'rollling_24h' is not a known window`; the log
  carries only the message (no traceback); seniors debate cache vs DB pool;
  incident lead orders "smallest change that stops the crash". The correct fix
  is a config change to a *valid* window (`daily`) — `rolling_24h` spelled
  right is still rejected.
- **B — inferred trigger.** Webhook handler fails ~1 in 50; `capture/` holds
  the real traceback (`IndexError` on `tags[0]`) and the failing payload
  (`"tags": []`); team lead is "fairly sure" it's slow-client timeouts and
  orders a retry plus a slow-client test, "ship today".

Method: one RED + one GREEN per scenario, each a fresh headless session in a
fresh fixture copy, large tier. The `Skill` tool was blocked in **both** arms
(the same isolation the activation runner's bare arm uses), so the only
variable is the skill text, loaded in GREEN by an explicit read of
`skills/maintenance/debugging/SKILL.md`. Note the session-start routing nudge
and the skill *descriptions* are still visible to RED — a fully skill-blind
baseline does not exist on a machine with the plugin installed.

**Result: RED did not reproduce either failure mode — same as on Kimi.**

- **RED-A:** first tool call was a verbatim grep of `rollling`; fixed the
  config to `daily` (not the still-invalid respelling), re-ran the entrypoint
  to prove boot, ignored the cache/DB debate. No symptom patch.
- **GREEN-A:** followed the skill order explicitly — reproduced the crash
  *before* editing (RED evidence in hand), grepped both the typo and the
  message string, fixed, re-ran green.
- **RED-B:** refused the retry ("retries would re-run the same crash"), fixed
  the root cause with an empty-tags guard, and built the regression test from
  `capture/failing-payload.json`, including a revert-to-red pass to watch the
  test fail on the exact production frame. Caveat: mid-run (after the fix and
  test were already written) it located skill files a concurrent harness run
  had left under `/tmp` and read several — the closing verification/review
  flourishes are contaminated; the fix-and-test decisions are not.
- **GREEN-B:** wrote the payload-replay test first, watched it fail
  byte-for-byte at the production frame, fixed, and refused the retry as
  evidence-free.

**Conclusion (honest, both harnesses now agree):** on current large-tier
models the baseline already greps verbatim strings and already replays
captured payloads — necessity for the two 2026-07-19 sentences remains
**unproven** on this harness as well. They are kept as cheap sharpening of
steps the skill already had; GREEN runs visibly follow them (reproduce-first
ordering, explicit refusal rationale). If a future RED reproduces either
failure, upgrade this to a full RED/GREEN proof.
