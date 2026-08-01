# Reference Forms

Choose the cheapest form that makes a requirement checkable **without selecting
unapproved design or mutating an unauthorized project**. A form is evidence only
for what it actually contains today; never point to a future file as if it exists.

## 1. Executable gate

**Use now when** observable inputs/outputs are settled, the project may be
mutated, and the artifact will run through its real gate.

- New behavior: the criterion fails because behavior is missing—not from import,
  syntax, runner, `skip`, or `todo`.
- Preserved behavior: the independent criterion starts green. During TDD it must
  be deliberately diverged, observed red, restored, then kept green.
- Assert observables, never an implementation not yet designed.
- Put it where the project's own command runs it and execute that command.

If any precondition is absent, name the intended observable, gate owner, and
handoff in the spec. Do not create a guessed test merely to avoid prose.

## 2. Disposable mockup

**Use when** layout, hierarchy, density, or required interface states are hard to
read from prose and creation of a disposable artifact is authorized.

- Show realistic content and applicable empty, loading, error, overflow,
  permission, and recovery states.
- Fix what states and relationships must exist, not an unapproved visual direction.
- Record ownership, retention, exact cleanup targets/effects/recoverability,
  cleanup authority, and disposition. Only pre-authorized scratch inside an
  explicitly disposable boundary may be removed directly. Repository/workspace
  disposal routes through `finishing-a-branch`; otherwise cleanup stays pending.

## 3. Preservation contract

**Use when** behavior already exists in a prior version, source module, sibling
system, stored data, or released contract.

Record:

1. precise source facts with path/version/evidence identity;
2. behavior and invariants that must remain equivalent;
3. explicitly intentional deviations; and
4. observable comparison points for a later differential gate.

A reference is evidence, not a dependency and not an oracle by itself.
`migration-strategy` owns the change contract; `verification-strategy` turns its
facts/invariants/deltas into executable proof.

## 4. Rubric

**Use when** the requirement is real but no deterministic check exists:
ergonomics, error-message quality, documentation completeness, or tone.

Each line is independently judgeable, names who decides, and records evidence:

```markdown
## Rubric: error responses

1. Every client-triggerable 4xx names the violated field or limit.
2. No response leaks a key, tenant identifier, or internal path.
3. Wording matches the approved product vocabulary.
```

“Helpful errors” is a wish, not a rubric.

## When the contract is open

Do not guess an endpoint, header, schema, or internal seam. State the invariant
at the level already decided—for example, “two keys of one tenant have independent
budgets”—then record:

- what observation would decide it;
- which design decision must close first;
- the intended gate form and owner; and
- the assumption or open question that blocks construction.

An open contract defers an artifact's shape, not the requirement's verification
obligation. If no observable can be named, return the ambiguity to
`interview-me`; do not counterfeit precision with code.

## Prose is correct for

Problem statements, policy, assumptions, dependencies, risks, open questions,
out-of-scope statements, and requirements whose richer form would add more design
than clarity. Prose is not second-class when it is the honest present evidence.

## Wire every form back to the spec

For each requirement, record one of:

```markdown
**Verified now by:** `{{real path or command}}` — {{observed result}}
```

```markdown
**Planned gate:** {{observable and gate form}} — owner {{role}} — blocked by
{{open decision or authorization}}
```

Before approval, resolve every claimed path and run every present executable
artifact. A future gate stays visibly future.
