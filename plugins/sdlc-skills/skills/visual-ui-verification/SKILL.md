---
name: visual-ui-verification
description: "Use before declaring any page, screen, view, or other UI-bearing candidate visually correct, done, or ready to ship. Also use when acceptance or release depends on how an integrated running GUI or TUI looks or responds across states, viewports, themes, or input paths. Fires on does this look right, is the UI done, and check the screen, even if nobody asks for a visual check. Skip isolated widget or snapshot assertions, nonvisual behavior, and open design decisions."
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

1. **Bind the target and the judge.** Open `assets/evidence-record.md` and fill
   its run header before anything is captured — it names every field this
   binding owes, from the candidate's identity down to the invalidation rule.

   The candidate is an immutable source or artifact identity, or a working-tree
   digest that covers staged, unstaged, untracked, and relevant ignored inputs.
   The record itself lives outside that identity, so writing evidence never
   changes what the evidence is about.

   When an approved UI design contains **Selected visual references**, bind every
   reference applicable to this candidate field for field, and run each Freshness
   evaluator before capture. A missing field or failed evaluator leaves the
   verdict pending until the bound artifact is restored and re-evaluated, or an
   approved design successor and then an approved plan successor replace it.
2. **Build the smallest deciding matrix.** Cross applicable journeys and states
   with viewport/window size, theme, input method, platform, and content
   pressure. Include empty, loading, error, overflow, and no-permission states
   when the accepted UI contract contains them; disposition omissions.
3. **Drive the real interface.** Exercise the integrated artifact through its
   real input boundary. Use screenshots or recordings for GUIs. For TUIs, use a
   PTY at the declared dimensions and a VT-capable renderer; retain the raw
   terminal stream as well as the rendered frame. A row ends at a stable,
   named observation, not merely successful launch.
4. **Capture attributable evidence** into the same
   [evidence-record.md](assets/evidence-record.md), one row per required
   observation. Hash the raw capture bytes and the rendered media, keep the
   capture tool's identity and the row's inputs, and never overwrite an earlier
   frame.

   Each required row reconciles to exactly one accepted result. Retries,
   duplicates, late output, and superseded frames are retained and dispositioned
   rather than discarded. A rendered derivative never stands in for raw bytes.
5. **Calibrate inspection before a pass.** Freeze the rubric and observer, then
   use a reversible fault or known-bad fixture outside the candidate to produce
   one deliberately broken frame. The same inspection must mark it red. Restore
   the probe and retain red/restoration receipts; an unsafe or missed probe
   leaves the gate pending.
6. **Inspect every frame** with a media-capable observer, against the accepted UI
   criteria. Where each is relevant, look at visual hierarchy, legibility,
   clipping and overflow, focus, contrast, behaviour at content extremes, state
   feedback, and whether recovery controls are actually visible.

   Judge conformance to all selected visual references applicable to the
   candidate explicitly. A candidate that satisfies generic quality criteria
   but substitutes a rejected layout, hierarchy, or interaction fails unless
   approved design and plan successors replace the binding.

   File each defect with its severity, the requirement it violates, the matrix
   row and frame it was seen in, its impact, and how to reproduce it. An agent's
   observation is evidence, never authority. Where a criterion or an exception is
   human-owned, follow `verifying-completion`'s manual-acceptance contract — only
   its trusted user-origin receipt can pass that row.
7. **Close the loop.** Do not edit without authority. Route fixes through their
   implementation discipline, then recapture the same row and affected
   neighbors. Preserve before/after evidence. Any candidate or material
   environment change invalidates affected passes.
8. **Return the verdict, and wire it in.** Pass only when all four hold: the
   calibrated probe was caught and restored, every required row was captured and
   inspected, no blocking defect remains, and every human-owned row carries its
   trusted receipt. Anything short of that returns fail or pending.

   When the project battery is being established, this becomes a row in
   `verification-strategy`'s matrix, with its own cells, action, evidence, owner,
   cadence, promotion, and failure response. A project may label that row `VQA`.

   A verdict taken against source or a working tree is acceptance evidence only.
   `release-readiness` consumes only a fresh verdict bound to the exact immutable
   artifact being promoted, and this skill never authorizes that promotion.

## Common mistakes

- Treating widget snapshots as integrated-app evidence.
- Capturing frames without driving interactions or retaining raw identity.
- Overwriting failed frames with re-shots or storing evidence in the candidate.
- Calling subjective preference a defect when the design direction is unsettled.
- Returning “looks good” without a calibrated rubric and row-by-row verdict.
