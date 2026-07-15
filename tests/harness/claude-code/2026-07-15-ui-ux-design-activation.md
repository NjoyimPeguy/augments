# Activation record - ui-ux-design (2026-07-15)

## Problem

The former `ui-ux` skill had a narrow trigger and only a short flow/layout
procedure. It did not make existing project setup the first design constraint or
give an agent a portable way to present controlled visual alternatives. Renaming
the invocation address also requires proving that supported adapters can discover
the new name rather than a stale mirror.

## Change

- Renamed the public skill address to `ui-ux-design` and updated both adapters.
- Expanded the trigger to cover interface flows, states, hierarchy, visual
  direction, and evidence-backed alternatives before implementation.
- Added project-first behavior: inspect routes, components, tokens, content,
  previews, accessibility conventions, responsive conventions, and tests before
  inventing any new setup.
- Added progressive guides for design quality and visual decisions, including
  2–4 controlled variants and non-server visualization fallbacks.
- Updated the activation scenario to describe an established application whose
  component library and preview environment must be preserved.

## Detector evidence

```bash
bash tests/harness/claude-code/run-activation.sh selftest
bash tests/harness/codex-cli/run-activation.sh selftest
```

Both detector self-tests passed. The Claude detector recognized its fired,
empty, proceeded-without-invocation, router-first, and routed-chain fixtures. The
Codex detector recognized its fired, empty, and combined-command fixtures.

## Claude Code live probe - unavailable

The working-tree command was attempted with Claude Code 2.1.210:

```bash
bash tests/harness/claude-code/run-activation.sh \
  --scenario-file tests/harness/claude-code/scenarios/design/ui-ux-design \
  --expect ui-ux-design --working-tree --keep
```

Observed result:

```text
verdict  : NONE (no Skill tool_use, no mention in any assistant turn)
first move: Not logged in · Please run /login …
```

The user confirmed they have no Claude account access. This run never reached
routing and is **unverified**, not a trigger miss. The retained stream also shows
a read-only filesystem failure while the SessionStart hook tried to create its
session environment, plus a duplicate-hooks plugin-load error. Authentication is
therefore not the only observed issue to resolve before a later live probe. The
offline detector remains green, but this change has no live Claude activation
claim. The maintainer will re-run this scenario in a subsequent release when
Claude access is available and re-check both hook errors at that time.

## Codex live probe - activation and RED/GREEN behavior

The first sandboxed run could not connect to the model service and failed before
an assistant action. The identical read-only probe was rerun with network access
using Codex CLI 0.144.4:

```bash
bash tests/harness/codex-cli/run-activation.sh \
  --scenario-file tests/harness/codex-cli/scenarios/design/ui-ux-design \
  --expect ui-ux-design --working-tree --keep
```

Activation reached the renamed skill. During repetition, one with-skill run
exposed a stochastic loophole: after finding the workspace empty, it proposed
using generic component roles. That would preserve no existing setup because the
setup was never inspected. The skill's first step was sharpened to stop before
directions when claimed existing-product evidence is unavailable.

The behavior comparison then used the same core scenario in fresh sessions:

```text
An established checkout application already has a component library, theme
tokens, component previews, and accessibility tests, but none of those project
files are available in this workspace. Before implementation, design the user
flows and unhappy states and give me visually comparable layout directions
without replacing the existing setup.
```

**RED — no skill.** Codex ran with an isolated temporary home, copied
authentication only, `--ignore-user-config`, and no plugin installed. The stream
contains no Augments skill read. It nevertheless wrote a library-agnostic design
brief, assumed a standard cart/delivery/payment/review flow, produced Directions
A/B/C, and recommended a desktop/mobile hybrid despite having none of the
claimed project evidence.

```bash
baseline_home="$(mktemp -d)"
baseline_work="$(mktemp -d)"
cp "${CODEX_HOME:-$HOME/.codex}/auth.json" "$baseline_home/auth.json"
HOME="$baseline_home" CODEX_HOME="$baseline_home" codex exec --json \
  --ephemeral --ignore-user-config --skip-git-repo-check -s read-only \
  -C "$baseline_work" "$scenario"
```

Its explicit rationale was: “Below is a library-agnostic design brief … It
assumes a standard checkout with cart, delivery, payment, review, and
confirmation.” That assumption is the wrong behavior the project-evidence gate
exists to prevent.

**GREEN — working-tree skill.** The same core scenario ran through the working-
tree adapter. Final observed activation:

```bash
bash tests/harness/codex-cli/run-activation.sh \
  --scenario "$scenario" --expect ui-ux-design --working-tree --keep
```

```text
verdict  : ACTIVATED — chain: augments:ui-ux-design augments:using-augments (read augments:ui-ux-design)
```

The GREEN output stopped before directions, explicitly citing the evidence gate.
It requested the repository, component preview plus screenshots, or responsive
screenshots with component and token documentation. It described the flows,
state matrix, 2–4 controlled directions, accessibility requirements, and human
checks it would produce only after that evidence became available.

## Portable verification

```bash
bash tests/validate-skills.sh
bash tests/token-budget.sh
git diff --check
```

Structural validation passed, including the canonical skill rules, Claude
manifest sync, generated Codex mirror, manifest-version agreement, and internal
reference resolution. The renamed always-loaded body measures approximately 974
tokens; the detailed design and visual-decision guides remain lazy-loaded sibling
files. The diff whitespace check passed.

## Honest limit

This proves current Codex discovery, routing, and the project-evidence hard stop
on the recorded scenario. It does not prove live Claude activation, because no
Claude account is available. It also does not visually certify the quality of a
real comparison surface: the activation workspace is intentionally empty, and
subjective design acceptance remains a human gate on an actual UI project.
