---
name: zoom-out
description: Use when you're about to work in a region of the codebase you don't know well — map the relevant modules and their callers in the project's own vocabulary before changing anything. Skip when you already understand the area.
---

# Zoom Out

Before you touch unfamiliar code, understand its shape. The failure this prevents is editing a region by pattern-matching on syntax while missing how it actually fits together — who calls it, what it owns, where the boundaries are.

## When to use

- You're about to change, debug, or extend a part of the codebase you don't know well.
- **Skip** when you already understand the region, or the change is a self-contained one-liner.

## Procedure

1. **Go up a layer.** Don't start at the line you'll edit — start at the module that contains it and the ones around it. What is each responsible for?
2. **Map the callers.** Trace who calls into this region and what it calls out to. The map is the entry points, the collaborators, and the data that flows between them.
3. **Use the domain's vocabulary**, not generic "service / handler / util" — name things the way the project names them, so the map matches the code.
4. **State the boundaries** you found: what this region owns, what it delegates, where the seams are. That's the orientation — now you can change it deliberately.

## Common mistakes

- Editing first and understanding later — the pattern-match that looks right and isn't.
- A map of files instead of responsibilities — paths don't tell you what owns what.
- Generic vocabulary that doesn't match how the team talks about the code.
