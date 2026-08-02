---
name: visual-ui-verification
description: "ALWAYS use before declaring a UI-bearing candidate visually correct or complete, and when acceptance or release depends on how an integrated running GUI or TUI looks or responds across states, viewports, themes, or input paths. Owns live visual verification after design direction is settled. Skip isolated widget or snapshot assertions, nonvisual behavior, and open design decisions."
---

# Visual UI Verification

Drive the integrated interface and inspect retained frames. A visual claim cites
candidate-bound evidence; snapshots and “looks good” do not establish it.

## When to use

- A running GUI or TUI must be judged before acceptance or release.
- A claim depends on integrated layout, rendering, or visible interaction state.
- **Skip** isolated component/snapshot checks and purely nonvisual behavior.
- Route unsettled flow or visual direction to `ui-ux-design` before verifying it.

## Procedure

1. **Bind the target and judge.** Use an immutable source/artifact identity or a
   working-tree digest covering staged, unstaged, untracked, and relevant
   ignored inputs. Record launch path, acceptance/design state IDs, environment,
   observer, authority, and evidence location outside that identity. Before
   driving rows, bind data/effect authority, recovery, access, retention,
   cleanup, and invalidation.
2. **Build the smallest deciding matrix.** Cross applicable journeys and states
   with viewport/window size, theme, input method, platform, and content
   pressure. Include empty, loading, error, overflow, and no-permission states
   when the accepted UI contract contains them; disposition omissions.
3. **Drive the real interface.** Exercise the integrated artifact through its
   real input boundary. Use screenshots or recordings for GUIs. For TUIs, use a
   PTY at the declared dimensions and a VT-capable renderer; retain the raw
   terminal stream as well as the rendered frame. A row ends at a stable,
   named observation, not merely successful launch.
4. **Capture attributable evidence.** Use
   [evidence-record.md](references/evidence-record.md). Hash raw capture bytes
   and rendered media, preserve capture-tool identity and row inputs, and never
   overwrite an earlier frame. Reconcile one accepted result per required row;
   retain and disposition retries, duplicates, late output, and superseded
   frames. A rendered derivative never replaces raw bytes.
5. **Calibrate inspection before a pass.** Freeze the rubric and observer, then
   use a reversible fault or known-bad fixture outside the candidate to produce
   one deliberately broken frame. The same inspection must mark it red. Restore
   the probe and retain red/restoration receipts; an unsafe or missed probe
   leaves the gate pending.
6. **Inspect every frame.** Use a media-capable observer and the accepted UI
   criteria. Check hierarchy, legibility, clipping/overflow, focus, contrast,
   content extremes, state feedback, and visible recovery controls as relevant.
   File each defect with severity, requirement, matrix row, frame identity,
   impact, and reproduction. Agent observations are evidence, not authority. If
   any criterion or exception is human-owned, follow `verifying-completion`'s
   manual-acceptance contract: only its trusted user-origin receipt can pass it.
7. **Close the loop.** Do not edit without authority. Route fixes through their
   implementation discipline, then recapture the same row and affected
   neighbors. Preserve before/after evidence. Any candidate or material
   environment change invalidates affected passes.
8. **Return and wire the verdict.** Pass only when the calibrated probe was
   caught and restored, every required row was captured and inspected, no
   blocking defect remains, and every human-owned row has its trusted receipt.
   Otherwise return fail or pending. When establishing the project battery,
   make this a `verification-strategy` row with cells, action, evidence, owner,
   cadence, promotion, and failure response. A project may label it `VQA`.
   Source or working-tree verdicts are acceptance evidence only.
   `release-readiness` consumes only a fresh verdict bound to the exact immutable
   release artifact or artifact set being promoted; this skill does not
   authorize promotion.

## Common mistakes

- Treating widget snapshots as integrated-app evidence.
- Capturing frames without driving interactions or retaining raw identity.
- Overwriting failed frames with re-shots or storing evidence in the candidate.
- Calling subjective preference a defect when the design direction is unsettled.
- Returning “looks good” without a calibrated rubric and row-by-row verdict.
