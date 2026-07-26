# Reference Forms

A requirement written as prose has to be re-interpreted by every reader — the
designer, the executor, the reviewer — and each re-interpretation is a chance to
drift. A requirement written as something *executable* is re-checked by a machine
instead. Same intent, no re-interpretation.

So the question for each requirement is not "how do I word this?" but **"what is
the cheapest form that makes this requirement checkable?"** Prose is the fallback
for requirements no other form fits — not the starting point.

The failure this prevents is specific and common: a spec that *promises*
verification it never delivers — "all acceptance criteria are automated tests
under `test/`" written above thirty requirements and zero test files. The
verification story reads as done and does not exist.

## The four forms

### 1. Executable specification — a failing test suite

**Use when** the requirement is behaviour with observable inputs and outputs: an
API response, a state transition, a calculation, an error path.

Write the tests now, against the interface the requirement implies, and leave
them **genuinely failing**. They *are* the acceptance criteria — the spec's prose
says what and why, the test says exactly.

Do not neuter them to keep the suite green. A `skip`, `todo`, or `pending` marker
turns a criterion into a comment: the suite exits 0, the gate can never go red,
and the spec is back to promising verification it does not perform. A criterion
that cannot fail is not a criterion. If the project's convention really requires
a marker, the suite must still report red overall — check by running it.

- Put them where they **run**: the project's own test tree. A test file parked in
  a spec folder is never executed by anything, which defeats the point.
- Match the project's existing test idiom and runner — read a neighbouring test
  first. A spec that introduces a second test framework is a design decision
  smuggled into requirements.
- Assert the observable behaviour, not an implementation you have not designed
  yet. `expects 429 after the 11th request in a 60s window` is a requirement;
  `expects tokenBucket.consume() to return false` is a design.
- Name each test so it reads as the requirement it encodes.

### 2. Rendered mockup — a page you can open

**Use when** the requirement is about layout, hierarchy, density, or the set of
states a surface must handle. Prose loses exactly what matters here: how it looks
when the name is 60 characters long and the list is empty.

- One self-contained page, inline styles, no external requests, no dependency and
  no server added merely to display it.
- Populate it with realistic content and show the unhappy states — empty,
  loading, error, overflow. A mockup with tidy placeholder content hides the
  requirements you most need to pin down.
- Keep it a requirements artifact: it fixes *what states must exist*, not the
  visual direction. Choosing between directions belongs to `ui-ux-design`.

### 3. Reference implementation — code that already behaves correctly

**Use when** the behaviour exists somewhere already: a prior version, a sibling
service, a module in another codebase, a library whose semantics you want.

Point at it precisely — path, function, and the version or commit you read — and
state the **deltas**: what must behave identically, and what must differ. "Port
this, but per-tenant instead of global" carries more fidelity in nine words than
a page of prose reconstructing the algorithm.

Record it as a reference, not a dependency: a link to code you are not going to
ship does not make that code a project dependency.

### 4. Rubric — named criteria for what a machine cannot check

**Use when** the requirement is real but has no deterministic check: interface
ergonomics, error-message quality, documentation completeness, tone.

A rubric is an ordered pass-list a reviewer — human or a fresh verifier agent —
applies to the built result. It only works if every line is independently
checkable:

```markdown
## Rubric: error responses
1. Every 4xx body names the field or limit that was violated.
2. No error message leaks a key, tenant id, or internal path.
3. Every error a client can trigger is reachable from the documented flows.
4. Wording matches the imperative voice used by existing errors.
```

Not `error messages should be helpful` — that is the wish the rubric replaces.
Rubrics carry judgement that would otherwise live only in the author's head, so a
reviewer applies the same standard the author intended.

## When the contract is still open

The most common reason an executable form gets skipped is that the interface it
would assert has not been chosen — the endpoint path, the header names, the
response shape. The reasoning feels careful: *"writing a test now would pick the
wire contract, and this is requirements-only."* It is the loophole, not the rule.

A requirement fixes something **regardless** of the contract that carries it.
"Two keys of one tenant hold independent budgets" stays true whatever the
endpoint is called. So:

- **Assert at the level the requirement fixes**, and no lower. Test through the
  smallest observable the requirement genuinely pins.
- **Or assume the contract and say so.** Write the test against a stated
  assumption, record it beside the requirement, and note that changing the
  contract changes the test. That is a design *input*, not smuggled design — the
  assumption is now visible and arguable instead of implicit.
- **Never let it become "no test yet."** An open contract defers the test's
  *shape*. It does not make the requirement unverifiable, and the spec that says
  it does has quietly returned to prose.

If the contract is so undetermined that no observable can be asserted, the
problem is upstream: the requirement is not yet a requirement. Send it back to
`interview-me` rather than shipping a criterion that cannot fail.

## Prose is still right for

The problem statement, assumptions, dependencies, risks, open questions, out of
scope — and any requirement that is a policy or constraint rather than a
behaviour ("data stays in the tenant's region"). These have no executable form;
forcing one adds ceremony without removing ambiguity.

## Choosing, without gold-plating

A richer form must remove more ambiguity than it costs to build. Two checks:

- **Would anyone actually misread the prose?** If not, prose is correct. Do not
  build a mockup for a requirement nobody would get wrong.
- **Does the form survive to the build?** An artifact only pays off if the plan
  and the executor reach for it — a failing test that becomes a task's Evaluator
  earns its keep; a mockup nobody opens does not.

Mixed specs are normal and expected: a failing test suite for the behavioural
requirements, a rubric for the error-message quality bar, and prose for the
assumptions and risks — in one spec.

## Wiring artifacts back to the spec

The spec file stays the map. For each requirement, name the form and the path, so
a reader can get from requirement to check in one hop:

```markdown
### FR-4 — Limits are enforced per API key, not per tenant

Two keys belonging to one tenant consume independent budgets.

**Verified by:** `test/ratelimit.spec.js` — "counts per key, not per tenant"
(failing: not yet implemented)
```

An artifact the spec does not point at will be missed; a pointer to an artifact
that does not exist is worse than prose. Before the spec is done, confirm every
referenced path resolves and every executable artifact actually runs — failing
for the right reason, not erroring because it never loaded.
