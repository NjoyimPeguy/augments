---
name: coding-standards
description: Use once per project, or when conventions drift, to set the coding standards agents and humans follow — the domain vocabulary, the patterns to use, and the things to never do. Produces the coding-standards section of the design document or a standing conventions file. Skip if the project already has clear, followed standards.
---

# Coding Standards

Set the conventions once so every contributor — human or agent — writes code that reads like one author. The highest-leverage standard is **shared vocabulary**: name things from the domain, consistently, so the same concept is never two words.

## When to use

- Starting a project, or when conventions have drifted and the code reads like several authors.
- **Skip** if the project already has clear standards that are actually followed.

## Procedure

1. **Fix the domain vocabulary.** One canonical term per concept ("order", not order/purchase/transaction). Ban generic labels ("service", "manager", "handler", "util") where a domain term exists — the model treats synonyms as distinct things, so this is a design decision, not pedantry. Keep it as a standing glossary the project updates, not a one-time list — agents read it for naming, which cuts drift and token waste.
2. **Name the patterns to use** — error handling, validation, async, dependency injection, testing seams — the *one* way this project does each, with a short example.
3. **State the hard "never"s** — the small list of things that must not happen here (no business logic in the UI layer, no raw queries outside the data layer). Keep it short; a long list is ignored.
4. **Point to the exemplar** — one existing file that already does it right, so the standard is shown, not just told.
5. **Write the coding-standards section** of the shared design document `.augments/designs/{{YYYY-MM-DD}}-{{topic}}.md` (the standard designs location; a standing conventions file or other path only if the user has set one).

## Common mistakes

- A long list of rules no one reads — keep it to what actually matters here.
- Standards told but never shown — point to a real exemplar file.
- Generic vocabulary that lets one concept drift into many names.
