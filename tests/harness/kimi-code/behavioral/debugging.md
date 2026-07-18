# Behavioral test: debugging (Kimi Code)

A discipline skill is proven only by watching an agent fail *without* it, then
hold the line *with* it (see `skills/common/writing-skills/testing.md`). This
is the Kimi Code record for the 2026-07-19 additions to `debugging`:

- step 3: *grep the literal error string — verbatim — across code and logs
  before theorizing*;
- step 5: *for an intermittent bug, the regression test must replay the
  observed failure (captured payload/timing), not an inferred trigger*.

## Scenarios

Fixture: a five-file Python service, copied fresh per run.

- **A — grep-first.** Startup crash `ValueError: quota window 'rollling_24h'
  is not a known window` from `check_quota()`; the literal string lives in
  `settings.py` as a config typo. Pressure: incident lead orders "smallest
  change that stops the crash, we're losing money", while three seniors debate
  cache layer vs DB pool in the channel.
- **B — inferred trigger.** Webhook handler fails ~1 in 50; `capture/` holds
  the real traceback (`IndexError` on `tags[0]`) and the failing payload
  (`"tags": []`). Pressure: team lead is "fairly sure" it's slow-client
  timeouts, orders a retry plus a test simulating a slow client, "ship today".

RED: fresh subagent, scenario only. GREEN: fresh subagent, scenario + "read
`debugging/SKILL.md` completely and follow it". Probes run 2026-07-19 as Kimi
Code CLI 0.27.0 coder subagents.

## Pass criteria

- **RED-A** fails if the agent theorizes about cache/DB or patches the crash
  site without locating the literal string; **GREEN-A** passes if it finds the
  config typo via the verbatim string and verifies with a reproduction.
- **RED-B** fails if the agent writes the retry and a slow-client test against
  the inferred trigger; **GREEN-B** passes if the test replays the captured
  payload and the retry is refused as evidence-free.

## Result (2026-07-19 · 1 RED + 1 GREEN per scenario)

**Both RED runs did the right thing — the failure modes did not reproduce.
Inconclusive for necessity, positive for the wording.**

- **RED-A:** reproduced the crash, read the five files, fixed the config typo
  (`rollling_24h` → `daily`), dismissed the seniors' debate as "noise" on its
  own. No grep-first was needed: the fixture is small enough that reading
  everything is equivalent to grepping. The scenario under-pressured the rule.
- **GREEN-A:** ran the verbatim grep explicitly (`rollling_24h|rolling_24h` →
  one hit), then *falsified the typo-fix* — probed that `rolling_24h` is also
  rejected, so the obvious "fix the spelling" patch would have kept prod down.
  Cited the new step-3 sentence as the section that "mattered most".
- **RED-B:** rejected the team lead's hypothesis on the capture evidence,
  wrote `test_replays_captured_failing_payload` against the production
  payload, and refused the retry ("would just fail N times"). The inferred-
  trigger trap did not catch this model.
- **GREEN-B:** same correct behavior, and quoted the new step-5 sentence
  verbatim as "exactly this situation".

## Conclusion (honest)

On this model and these scenarios, the baseline already greps verbatim error
strings and already replays captured payloads — the RED half of the proof is
absent, so necessity is **unproven**, not established. The additions were kept
anyway: each is a single sentence sharpening a step the skill already had
(hypothesize; regression-test the real bug), both are grounded in field
reports of exactly these failures, and both were recognized and cited by name
in the GREEN runs. If a future RED probe reproduces either failure, this
record should be updated to a full RED/GREEN proof.
