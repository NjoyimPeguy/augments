# Coding-standards section template

Copy this into the project's coding-standards section (per `../SKILL.md`, step 5) and fill every `{{placeholder}}`. Delete the guidance italics as you fill; what remains is the standard itself. Keep it short — a section nobody reads governs nothing.

## The template

````markdown
## Coding standards

### Vocabulary

One canonical term per concept. Use the canonical term in names, comments,
docs, and conversation — never the banned synonym.

| Concept            | Canonical term   | Banned synonyms            |
| ------------------ | ---------------- | -------------------------- |
| {{concept}}        | {{term}}         | {{synonym-1}}, {{synonym-2}} |
| {{concept}}        | {{term}}         | {{synonym}}                |

Generic labels banned where a domain term exists: {{service, manager, handler, util — adjust}}.

### Patterns

The one way this project does each of these. Anything else is a defect in review.

- **Errors:** {{how errors are represented and propagated — e.g. typed result objects returned, never thrown across module boundaries}}
- **Validation:** {{where input is validated and what it returns — e.g. at the trust boundary only, returning the parsed value or a typed error}}
- **Async:** {{the project's async idiom — e.g. promises with async/await, no raw callbacks}}
- **Dependencies:** {{how modules get their collaborators — e.g. constructor injection, no ambient singletons}}
- **Testing seams:** {{how tests substitute collaborators — e.g. inject fakes through the constructor, no module monkey-patching}}

Example — the pattern as it should look:

```{{language}}
{{short, real example of one pattern above, in this project's style}}
```

### Never

- {{hard rule — e.g. no business logic in the UI layer}}
- {{hard rule — e.g. no raw queries outside the data layer}}
- {{hard rule — e.g. no swallowing errors silently}}
- {{at most ~7 rules total; each must be something a reviewer will actually reject}}

### Exemplar

`{{path/to/exemplar-file}}` does all of the above right. When in doubt, write
the new code so it could sit next to this file without looking out of place.
````

## Worked example (filled, minimal)

```markdown
### Vocabulary

| Concept                          | Canonical term | Banned synonyms                |
| -------------------------------- | -------------- | ------------------------------ |
| A request to move money          | transfer       | payment, transaction, remittance |
| The party the transfer pays      | payee          | recipient, beneficiary, vendor   |
| A transfer that failed to settle | reversal       | rollback, refund, undo           |

### Patterns

- **Errors:** functions return a result object with `ok` or `err`; exceptions only for programmer bugs.
- **Validation:** request bodies are parsed once at the route boundary into domain types; inner layers never re-check.
- **Dependencies:** passed as constructor parameters; no imports of concrete infrastructure from domain modules.

### Never

- No business logic in route handlers — they parse, call a use case, render.
- No string-typed identifiers across layer boundaries; wrap in a domain type.
- No catching an error and returning a generic 500 without logging the cause.

### Exemplar

`src/transfers/create-transfer.ts`
```

## Edge cases and failure patterns

- **A real project has legacy synonyms everywhere.** Standardize on the term going forward and rename opportunistically on touch; don't schedule a mass rename as a condition of adopting the standard.
- **Two candidate canonical terms, both in use.** Pick one by fiat — which one matters less than that there is one. Record the loser as banned so search finds both during the transition.
- **A pattern with two legitimate uses** (e.g. two error idioms, one for the CLI edge, one for the core) is fine — say where each applies. "One way" means one way *per situation*, not one way per universe.
- **The exemplar drifts.** Re-point it the moment a better file exists; an exemplar that no longer passes review teaches the wrong standard.
- **Failure: the standards file becomes a style guide.** Indentation, brace placement, and import order belong to the formatter and linter — automatable, so automate them. The standards section is only for what a machine can't enforce: vocabulary, layering, pattern choice.
- **Failure: nevers with no teeth.** Every "never" must be something a reviewer will actually send back. A never nobody enforces trains readers to ignore the whole list.
