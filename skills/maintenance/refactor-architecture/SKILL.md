---
name: refactor-architecture
description: Use when an existing codebase has architectural friction — changes touch many files, modules are shallow, seams leak — and you want to improve its structure. Reviews for module depth and locality, then proposes targeted refactors. Skip for new design (use system-architecture) or a quick local fix.
---

# Refactor Architecture

Improve the structure of code that already exists. The goal is **deep modules** — a lot of behaviour behind a small interface — and **locality**, so a change lives in one place. This is maintenance; for designing new structure, use `system-architecture`. The vocabulary these steps lean on — module, interface, depth, seam, adapter, leverage, and the deletion test — is defined in `vocabulary.md`.

## When to use

- An existing codebase has friction: a change bounces you across many files, modules are thin wrappers, tests couple to internals, seams leak.
- **Skip** for greenfield design (`system-architecture`) or a one-off local fix.

## Procedure

1. **Walk the friction.** Find where a single change forces edits across many files, and where a module's complexity has spread to its callers.
2. **Apply the deletion test** to each suspect module: if removing it would concentrate complexity across its callers, it's earning its depth — keep it. If complexity merely *relocates*, it's shallow — collapse it.
3. **Find the real seams.** A seam is justified by **two** actual implementations, not one hypothetical. Classify each dependency: in-process (deepen freely), substitutable (in-memory fake), owned-remote (port + adapter), true-external (mock at the boundary).
4. **Design it twice.** For a load-bearing refactor, sketch two distinct structures (e.g. minimize entry points vs. optimize the common caller) and compare on depth, locality, and seam placement before committing.
5. **Propose targeted refactors**, smallest-leverage-first, each with a before/after and the principle it serves. Record load-bearing choices as an ADR (`architecture-decisions`).
6. **When you deepen a module, move its tests to the new interface** and delete the now-redundant tests on the old shallow internals — the interface is the test surface.

## Common mistakes

- Refactoring for tidiness, not leverage — change structure only where it cuts real friction.
- Adding a port with one adapter — a hypothetical seam, not a real one.
- Keeping unit tests on internals after deepening — they're waste once the interface is tested.
