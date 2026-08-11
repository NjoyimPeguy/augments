---
name: coding-standards
description: "Use once per project, or when conventions have drifted, to settle the conventions agents and humans both follow — domain vocabulary, naming, patterns to reach for, things to never do. Fires on a request for a style guide or house rules, on the codebase is inconsistent, and on how should we name this, even if nobody says standards or conventions. Skip when the project already has clear, followed standards, and when the question is proving the code correct — tests, quality gates, CI."
---

# Coding Standards

Set the conventions once so every contributor — human or agent — writes code that reads like one author. The highest-leverage standard is **shared vocabulary**: name things from the domain, consistently, so the same concept is never two words.

## When to use

- Starting a project, or when conventions have drifted and the code reads like several authors.
- **Skip** if the project already has clear standards that are actually followed.

## Procedure

1. **Adopt the domain vocabulary.** Where an approved `data-model` or domain
   contract exists, take the canonical concepts and terms from it. This skill
   owns how those terms appear in code — representation, casing, abbreviations,
   and enforcement against drift — but never their meaning, and never a rename.
   A genuine dispute about what a concept *is* routes to `data-model`.

   Without such a contract, derive the terms from the domain evidence you can
   see. Either way, ban a generic label wherever a domain term exists, and keep
   the glossary current.
2. **Name the patterns to use** — error handling, validation, async, dependency injection, testing seams — the *one* way this project does each, with a short example.
3. **State the hard "never"s** — the small list of things that must not happen
   here. Keep it short; a long list is ignored.
4. **Assign enforcement, rule by rule.** Anything about syntax, style, or
   otherwise statically detectable goes to a formatter, a linter, a type or
   static check, or a repository check — one that actually fails. Anything about
   vocabulary, architecture, or judgement gets a named review rubric and a named
   owner instead.

   The standard owns the rule and its conformance reference. An assurance matrix
   may consume that check, but it owns the wider risk threshold, the cadence, and
   the promotion wiring. Documentation on its own is not conformance.
5. **Point to and validate the exemplar.** Run its checks and rubric now. If a
   greenfield project has none, name the first artifact and owner and keep
   adoption pending; never fabricate a path or claim the standard is followed.
6. **Set precedence and exceptions.** Name which project instruction wins when
   two conflict, and who may approve an exception. Every exception records its
   scope, its reason, when it expires, and the compensating check that covers the
   gap meanwhile. A silent exception is standards drift.
7. **Set drift review.** Name a cadence or trigger—new language/framework,
   repeated review finding, conflicting exemplar—and who updates the standard.
8. **Write the proposed coding-standards section** into
   `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}.md`, or the project's standing
   conventions path. Open `assets/standards-template.md` and fill it — it carries
   the enforcement and exception blocks, the identity and ledger fields, the
   stable rule IDs, and the decision-owner rule, plus a worked example and the
   failure patterns. Preserve the other approved sections; the section is
   immutable once its identity is issued.
9. **Present the standards for decision.** Print exactly this, then stop:

   ```text
   Coding standards ready for your decision — {{standards-path}}

   Vocabulary: {{domain-terms}}
   Patterns:   {{patterns-to-use}}
   Nevers:     {{hard-nevers}}
   Enforced:   {{automated}} automatically · {{by-review}} by review
   Exemplar:   {{exemplar-path}} ({{gate-result}})

   1. Approve — these are the conventions
   2. Request changes — tell me what to revise
   3. Reject — wrong conventions
   4. Cancel — stop this work

   Which?
   ```

   Only one of the four hands off. Record lifecycle externally. An issued
   identity never mutates: a normative change creates a successor with a per-ID
   `added / changed / removed / preserved` delta (removal needs owning approval)
   that invalidates stale downstream bindings until owners revalidate.
10. **Claim adoption only after enforcement and the exemplar gate run.** Approval
    is not conformance. Record `in force / suspended / superseded` externally
    with fresh evidence; never mutate normative standards to mirror adoption.

## Common mistakes

- A long list of rules no one reads — keep it to what actually matters here.
- Standards told but never shown — point to a real exemplar file.
- Generic vocabulary that lets one concept drift into many names.
- “Reviewers will catch it” with no rubric, owner, or checked exemplar.
