---
name: coding-standards
description: Use once per project, or when conventions drift, to set the conventions agents and humans follow — domain vocabulary, naming, patterns to use, things to never do. Skip if the project already has clear, followed standards, or when the question is proving the code correct — tests, quality gates, CI — which is verification-strategy's territory.
---

# Coding Standards

Set the conventions once so every contributor — human or agent — writes code that reads like one author. The highest-leverage standard is **shared vocabulary**: name things from the domain, consistently, so the same concept is never two words.

## When to use

- Starting a project, or when conventions have drifted and the code reads like several authors.
- **Skip** if the project already has clear standards that are actually followed.

## Procedure

1. **Adopt the domain vocabulary.** Consume canonical concepts and terms from
   the approved `data-model` or domain contract when one exists; this skill owns
   their code representation, casing, abbreviations, and drift enforcement—not
   their meaning or renaming. Without that contract, derive terms from current
   domain evidence; a material concept dispute routes to `data-model`. Ban
   generic labels where a domain term exists and keep the glossary current.
2. **Name the patterns to use** — error handling, validation, async, dependency injection, testing seams — the *one* way this project does each, with a short example.
3. **State the hard "never"s** — the small list of things that must not happen
   here. Keep it short; a long list is ignored.
4. **Assign enforcement.** Route syntax/style and statically detectable rules to
   formatter, linter, type/static, or repository checks that fail. Give
   vocabulary, architecture, and judgment rules a named review rubric and owner.
   The standard owns the rule and its conformance reference; an assurance matrix
   may consume that check but owns any wider risk threshold, cadence, and
   promotion wiring. Documentation alone is not conformance.
5. **Point to and validate the exemplar.** Run its checks and rubric now. If a
   greenfield project has none, name the first artifact and owner and keep
   adoption pending; never fabricate a path or claim the standard is followed.
6. **Set precedence and exceptions.** Name which project instruction wins on
   conflict, who may approve an exception, its scope/reason/expiry, and the
   compensating check. Silent exceptions are standards drift.
7. **Set drift review.** Name a cadence or trigger—new language/framework,
   repeated review finding, conflicting exemplar—and who updates the standard.
8. **Write an immutable proposed coding-standards section**, preserving approved
   sections, at
   `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}.md` (or the project-set standing
   conventions path), including enforcement, exceptions, normative identity,
   predecessor, external decision/adoption-ledger locations, stable IDs for
   rules/patterns/exceptions/exemplar/enforcement, and one accountable decision
   owner or required approvers, conflict resolver, and decision rule.
9. **Obtain the exact decision.** Record lifecycle externally; only approved
   hands off. Once identity is issued, never mutate it: every normative change
   creates a successor with per-ID `added / changed / removed / preserved`
   delta; removal needs owning approval. An approved successor records the
   downstream artifact inventory bound to its predecessor, invalidates stale
   bindings externally, and blocks use until owners revalidate or reconcile.
10. **Claim adoption only after enforcement and the exemplar gate run.** Approval
    is not conformance. Record `in force / suspended / superseded` externally
    with fresh evidence; never mutate normative standards to mirror adoption.

## Common mistakes

- A long list of rules no one reads — keep it to what actually matters here.
- Standards told but never shown — point to a real exemplar file.
- Generic vocabulary that lets one concept drift into many names.
- “Reviewers will catch it” with no rubric, owner, or checked exemplar.

For a fill-in template for the standards section, a worked example, and the failure patterns, see `references/standards-template.md`.
