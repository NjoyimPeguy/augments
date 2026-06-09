# tests/

Two kinds of test live here, because only one kind *can* be deterministic.

## 1. Structural — deterministic, automatable

`validate-skills.sh` checks the shape of every skill: frontmatter present, `name` matches the directory, description ≤ 1024 chars, body line limits, and no external references, vendor model names, or bare `<angle>` placeholders. It exits non-zero on any violation, so it can run in CI.

This is automatable precisely *because* it inspects files, not behaviour — it asks nothing of any model or harness.

## 2. Behavioural & triggering — dated markdown records, not gates

Everything under `behavioral/` and `triggering/` is a **dated markdown record**, never an automated pass/fail gate:

- **`triggering/<skill>.md`** — *activation*: does the `description` fire on the right opening, and stay quiet on trivial ones? (A description is the only text a runtime reads when deciding to load a skill.)
- **`behavioral/<skill>.md`** — *compliance*: does a discipline hold under pressure?

Each record is the same shape: **Scenario → Pass criteria → "Last result (date)"**. It is re-run by a human or agent whenever the skill changes, and it records the *real* outcome — including inconclusive or no-separation results. A record never green-washes; an honest null is the finding.

**What each skill owes.** Every skill owes a *triggering* record (does its description route the right opening?). A *behavioral* record is owed only by the **discipline** skills (the ones holding a line under pressure — see `writing-skills`): a capability skill has no temptation to counter, so pressure-testing it proves nothing — its procedure is proven by watching it work, not by resisting stress.

### The triggering harness

`triggering-harness.sh` automates the *mechanical* half of that proxy, so a record stays cheap to re-run and never drifts from the live skill set. It does **not** call a model and does **not** assert pass/fail — it only prepares the inputs and counts the outputs:

- `catalogue [--exclude NAME]…` — build the current `name :: description` catalogue from frontmatter (use `--exclude` to reproduce a RED baseline *without* a skill).
- `prompt --scenario "…" [--exclude NAME]…` — emit a ready-to-run routing prompt (catalogue + scenario + the `CHOICE:/WHY:` format).
- `tally [FILE…]` — count the `CHOICE:` verdicts from pasted subagent replies.

You still dispatch the prompt to fresh subagents in your own harness and write the dated tally into the record — the deterministic part stays deterministic, the judgment part stays honest.

### Why these can only be records

A deterministic "did the skill fire / did the discipline hold" test would have to drive a specific harness — invoke *its* CLI, pass *its* plugin and permission flags, and parse *its* output format to see which skill activated. That binds the test to one harness.

This library is **harness-agnostic** (see `../CLAUDE.md`): it must not assume any one harness's tooling or paths. So the deterministic route is closed by the same rule that bans vendor model names. What remains is a model-judged proxy — fresh subagents that see only the catalogue of `name :: description` (no bodies) and route an opening message — whose result is *directional*, model- and run-dependent, and therefore recorded with a date rather than asserted as a gate.

This is the testing face of `docs/augments/philosophy.md`: an instruction (a skill) only shifts a probability, so its effect is measured, not guaranteed. The guarantee comes from a **deterministic gate** — and the only gate that stays portable is the structural one above. Authoring guidance for writing these records is in `../skills/common/writing-skills/testing.md`.
