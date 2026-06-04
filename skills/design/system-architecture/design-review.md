# Design Review (optional)

A fresh-context subagent catches what the design's authors can't — you're anchored to your own decisions. Use for a high-stakes design (a new subsystem, a wide blast radius, an irreversible choice). **Single pass, not a loop.**

This reviews the **design document** — before anyone builds against it.

Dispatch a subagent with the design document and the codebase, and this brief:

> Review the design document at `{{design file}}`. Flag **only** issues that would lead to building the wrong thing or an unbuildable design — skip wording and detail-level variation. Check:
>
> 1. **Completeness** — no TBDs, placeholders, or "decide later" in load-bearing sections.
> 2. **External services** — every third party has a named testability strategy and an "unavailable" behaviour.
> 3. **Decisions** — every significant choice shows its options and why the alternatives were rejected.
> 4. **Seams** — every proposed port has at least two real adapters justifying it; flag single-adapter ports.
> 5. **Cross-section consistency** — UI flows reference real entities from the data model; components match the interface seams.
> 6. **Vocabulary** — domain terms, not generic "service/handler", consistent across sections.
> 7. **YAGNI** — no unrequested features, no "for future extensibility" without a named use.
>
> Return a short list, one line each: `section — issue — fix`. If nothing blocks a correct, buildable design, say so in one line.

Apply the fixes to the design document yourself. Don't re-dispatch unless it changed substantially.
