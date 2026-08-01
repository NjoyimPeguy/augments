---
name: zoom-out
description: Use when you're about to work in a region of the codebase you don't know well — map the relevant modules and their callers in the project's own vocabulary before changing anything. Skip when you already understand the area.
---

# Zoom Out

Before you touch unfamiliar code, understand its shape. The failure this prevents is editing a region by pattern-matching on syntax while missing how it actually fits together — who calls it, what it owns, where the boundaries are.

## When to use

- You're about to change, debug, or extend a part of the codebase you don't know well.
- **Skip** only when you already understand the region and affected surfaces;
  one changed line can still alter a public, data, security, or release path.

## Procedure

1. **Set breadth from risk.** Name the intended change, plausible blast radius,
   why the chosen boundary is enough, the inspected repository/working-state
   and material external-input identity, and the freshness or invalidation
   rule. A local edit may need one module; a wide or compatibility-sensitive
   change cannot stop at direct callers.
2. **Go up a layer.** Start at the containing module and its neighbors. Identify
   responsibilities, runtime entry points, callers, collaborators, and the data
   flowing between them.
3. **Inspect affected surfaces.** As the risk warrants, trace generated code and
   build inputs; persistent state and migrations; public contracts and
   consumers; configuration, deployment, and operational paths; tests, CI, and
   other proof surfaces; and relevant ownership or change history. Record an
   evidence-based reason for each material surface excluded.
4. **Use the domain's vocabulary**, not generic "service / handler / util," so
   the map matches the code and its contracts.
5. **Cite the evidence.** Attach each conclusion to current files, symbols,
   searches, commands, or revisions. Separate observed facts from inference and
   mark anything stale or unavailable. The map's input identity covers every
   material source and external fact on which its conclusions rely.
6. **State the boundaries** found: what the region owns, what it delegates,
   where its seams are, and which downstream obligations a change must preserve.
   Before relying on the map after its freshness limit or a material input
   change, revalidate affected claims against current evidence. Reorient if
   implementation reveals a caller or surface outside the map.

## Common mistakes

- Editing first and understanding later — the pattern-match that looks right and isn't.
- A map of files instead of responsibilities — paths don't tell you what owns what.
- Tracing direct imports while missing generated inputs, stored state, external
  consumers, or deployment paths that carry the real blast radius.
- Presenting remembered architecture as current repository evidence.
- Reusing a previously correct map after its source or external inputs changed.
- Generic vocabulary that doesn't match how the team talks about the code.
