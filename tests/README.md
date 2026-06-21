# tests/

Two kinds of test live here, because only one kind *can* be deterministic.

## 1. Structural — deterministic, automatable

`validate-skills.sh` checks the shape of every skill: frontmatter present, `name` matches the directory, description ≤ 1024 chars, body line limits, and no external references, vendor model names, or bare `<angle>` placeholders. It also checks the harness-collision surface: no scanner trigger-words in shipped text (skill bodies and the nudge — a literal a harness keyword-scans for can hijack the session every time the text loads) and no skill name that shadows a common built-in slash command (a shadowed name gets mis-invoked). It exits non-zero on any violation, so it can run in CI.

This is automatable precisely *because* it inspects files, not behaviour — it asks nothing of any model or harness.

## 2. Behavioural & triggering — dated markdown records, not gates

Everything under `behavioral/` and `triggering/` is a **dated markdown record**, never an automated pass/fail gate:

- **`triggering/<skill>.md`** — *activation*: does the `description` fire on the right opening, and stay quiet on trivial ones? (A description is the only text a runtime reads when deciding to load a skill.)
- **`behavioral/<skill>.md`** — *compliance*: does a discipline hold under pressure?

Each record is the same shape: **Scenario → Pass criteria → "Last result (date)"**. It is re-run by a human or agent whenever the skill changes, and it records the *real* outcome — including inconclusive or no-separation results. A record never green-washes; an honest null is the finding.

**What each skill owes.** Every skill owes a *triggering* record (does its description route the right opening?). A *behavioral* record is owed only by the **discipline** skills (the ones holding a line under pressure — see `writing-skills`): a capability skill has no temptation to counter, so pressure-testing it proves nothing — its procedure is proven by watching it work, not by resisting stress.

**Where a result was measured.** A record's verdicts come from some real harness and model, and that environment is part of the result — the same measurement from a different harness or tier is a new data point, not a repeat. Every dated entry names the harness it was dispatched from and the model tier that judged it; a re-run from another harness appends a new dated entry to the *same* record rather than forking a per-harness copy. **Entries dated 2026-06-09 or earlier predate this convention and were all measured from Claude Code with a large-tier model; entries after that date name their environment inline.** The library has not yet been measured from any other harness.

**When a record goes stale.** A skill change is not the only thing that invalidates a verdict — the measuring model is half the measurement, and it changes on its own schedule. Routing and discipline-compliance shift across model generations, so when the harness's model moves a generation, treat existing verdicts as that *previous* generation's data and append a fresh dated entry the next time the skill is touched — starting with the descriptions that needed tuning to pass at all, since a trigger tuned against one generation's reading is the first thing to drift. Old entries are never rewritten; the time series is the drift evidence.

### The triggering harness

`triggering-harness.sh` automates the *mechanical* half of that proxy, so a record stays cheap to re-run and never drifts from the live skill set. It does **not** call a model and does **not** assert pass/fail — it only prepares the inputs and counts the outputs:

- `catalogue [--exclude NAME]…` — build the current `name :: description` catalogue from frontmatter (use `--exclude` to reproduce a RED baseline *without* a skill).
- `prompt --scenario "…" [--exclude NAME]…` — emit a ready-to-run routing prompt (catalogue + scenario + the `CHOICE:/WHY:` format).
- `tally [FILE…]` — count the `CHOICE:` verdicts from pasted subagent replies.

You still dispatch the prompt to fresh subagents in your own harness and write the dated tally into the record — the deterministic part stays deterministic, the judgment part stays honest.

### The invocation harness (a third record kind)

`triggering/` measures the wrong half on its own. Its harness *commands* a
subagent to "pick the SINGLE skill that best fits" — a forced classification
that presumes the agent already decided to reach for a skill, and measures only
whether it discriminates. The step that fails in the field — deciding to invoke
*at all* on a terse "build me X" rather than just starting — it assumes away.

`invocation-harness.sh` measures that step: the shipped nudge on/off, the skills
as *available* tools (not a menu), a realistic terse opening, and "proceed
without a skill" as a co-equal outcome. Records land in `invocation/<skill>.md`.
It is the same model-judged proxy (not a gate) and, by construction,
*over*-measures the firing rate — see `invocation/README.md` for why a high
number is a ceiling, not a field rate. Selective: most relevant for skills whose
absence leaves no failing artifact (the planning wing), where the nudge is the
only thing that makes them fire.

### Why these can only be records

A deterministic "did the skill fire / did the discipline hold" test would have to drive a specific harness — invoke *its* CLI, pass *its* plugin and permission flags, and parse *its* output format to see which skill activated. That binds the test to one harness.

This library is **harness-agnostic** (see `../CLAUDE.md`): it must not assume any one harness's tooling or paths. So the deterministic route is closed by the same rule that bans vendor model names. What remains is a model-judged proxy — fresh subagents that see only the catalogue of `name :: description` (no bodies) and route an opening message — whose result is *directional*, model- and run-dependent, and therefore recorded with a date rather than asserted as a gate.

This is the testing face of `docs/augments/philosophy.md`: an instruction (a skill) only shifts a probability, so its effect is measured, not guaranteed. The guarantee comes from a **deterministic gate** — and the only gate that stays portable is the structural one above. Authoring guidance for writing these records is in `../skills/common/writing-skills/testing.md`.

### Coverage and budget (deterministic helpers)

Two file-inspection scripts — no model, no harness — that report on the surface the records above describe; both can become gates once the gaps they surface are closed:

- `coverage.sh` — every skill owes a triggering record; this lists any that are missing and heuristically warns when a record shows no skip/negative scenario (a record should prove the trigger stays *quiet* on a trivial opening, not only that it fires). The **existence** half is now enforced by `validate-skills.sh` — every skill must have a record, the check that would have caught a skill shipping without one. `coverage.sh` stays the detailed companion: it surfaces the skip-scenario warnings the gate deliberately does *not* enforce (they are heuristic, not deterministic).
- `token-budget.sh` — the companion to the line budget in §1: it reports the approximate context cost (chars/4, no tokenizer — portable, not exact) of the always-loaded surface, every `SKILL.md` body plus the SessionStart nudge, so "earn every line" becomes a number you can watch for drift. `--max N` flags any body over N approx-tokens (discipline skills legitimately run large); report-only by default.

## 3. Harness activation — per-adapter records

`harness/{{harness-name}}.md` records the one thing every record above assumes: that on a given harness, the installed library actually **loads and activates** in a clean session — files present on disk is not a working integration. One dated record per adapter; an adapter with no record here is unproven, and `docs/augments/harness-support.md` must say so. This folder is the designated home for the activation transcript a new-harness PR owes.
