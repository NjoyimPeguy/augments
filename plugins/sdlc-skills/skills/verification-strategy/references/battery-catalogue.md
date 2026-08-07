# Assurance gate catalogue

Use this catalogue while filling the risk-to-gate matrix. It is a set of
capabilities, not a universal checklist: select gates because a material risk
needs them, and give every omitted category a reason. Prefer capabilities
already present in the project before adding machinery.

## Differential equivalence and characterization

**Proves:** source and target produce equivalent observable results over a
representative corpus, modulo explicitly approved deviations.

Define independent source and target runners, input inventory, normalization,
comparison dimensions, tolerated deltas, and artifact retention. Include durable
data, errors, ordering, side effects, and resource behavior when they are part of
the contract. Before trusting the oracle, introduce a deliberate divergence it
must detect. A target-derived expected value is not independent proof. For a
moving source, independently derive every post-baseline change, reconcile it
exactly once to affected target shards, and block when ownership, evidence, or
the approved lag bound is missing. For mutable data or work, test concurrent
writes around the snapshot/high-water boundary and reject gaps, duplicates,
ordering loss, non-idempotent retries, and catch-up beyond its approved lag.

## Unit and observable behavior

**Unit gates** prove small pieces follow their local contracts quickly. They do
not prove wiring or that the contract is right. Their construction belongs to
`test-driven-development`.

**Behavior and acceptance gates** exercise real entry points and observable
outcomes independently of implementation structure. They cover happy, boundary,
failure, recovery, and permission paths selected from requirements. A scenario
that names internal collaborators will not survive the rewrite it is meant to
protect.

## Static and dynamic safety

**Static gates** find type, contract, unreachable-path, dependency, format, and
policy violations without executing every path. Record their exact scope and
warning floor; a tool run over only one subtree does not cover the project.

**Dynamic safety gates** exercise runtime properties such as invalid memory
access, leaks, races, deadlocks, undefined behavior, resource cleanup, and
instrumented assertions. State which runtime and build mode enables the check;
an instrumented debug run cannot silently stand in for a release build.

## Property, fuzz, stress, and concurrency

- **Property checks** generate cases around durable invariants rather than
  enumerating only examples. Record generators, shrink/reproduction output, and
  seeds.
- **Fuzz checks** explore malformed and adversarial inputs. Retain the corpus and
  every minimizing crash input; bound routine runs and schedule longer campaigns
  at a cadence proportional to risk.
- **Stress and concurrency checks** exercise saturation, ordering, retry,
  idempotency, contention, cancellation, and recovery. Record topology, load
  shape, duration, repetitions, and the nondeterministic failure policy.

## Performance and resource floors

Protect latency, throughput, startup, memory, storage, descriptor, network, and
energy budgets that matter to the product. Compare on a controlled environment
or against a pinned baseline, define statistical treatment and tolerated noise,
and fail on regression beyond the accepted floor. A faster median cannot hide a
tail-latency or peak-memory regression.

## Security

Map trust-boundary risks to static checks, dependency and secret scans,
attacker-controlled input tests, authorization/isolation checks, and required
`security-audits` review. Preserve findings and re-run the relevant gate after
fixes. Passing generic scans does not prove authorization or tenant isolation.

## Platform and build-mode parity

Inventory every supported platform, architecture, runtime, feature set, build
mode, packaging form, and compatibility direction. Define which gates run on
each cell and what evidence permits an explicitly unsupported cell. A single
developer build cannot stand in for the release artifact.

## Visual and interface correctness

When the accepted contract includes how an integrated GUI or TUI looks or
responds, unit and snapshot gates cannot decide it: they assert a serialized
fragment, not the rendered result. Define the deciding matrix of journeys,
states, viewports, themes, input methods, and content pressure; the observer and
rubric; and where raw frames are retained. Calibrate the inspection with a
deliberately broken frame it must mark red. `visual-ui-verification` owns the run
and returns the verdict; a project may label the row `VQA`. Bind each verdict to
the exact candidate or release artifact — a source-tree pass is acceptance
evidence, never release evidence.

## Production-like and operational gates

Use representative data, topology, fault injection, QA procedures, canary, soak,
and recovery drills when lower layers cannot expose operational failures. State
privacy and safety boundaries, duration, observability, abort thresholds, and
the promotion each run protects. `release-readiness` consumes these results; it
does not retroactively invent them.

## Falsifiability, mutation, and metric floors

For every gate, name a realistic defect it should reject. In an isolated
authorized state, bind exact data/effects/resources, mutation, recovery/cleanup
authority, and pre-state; run the divergence, observe red, restore the complete
candidate/data/effect state, and observe green. If live injection is unsafe, replay a
retained known-bad case or purpose-built calibration fixture. A gate with no
safe falsification evidence is explicitly uncalibrated and cannot be the sole
proof for its risk. Never inject a defect into production to test the gate.

One establishment-time mutation does not continuously protect assertions.
Schedule retained mutation/fault cells or a mutation floor at the cadence that
protects test/control changes. Deleting or hollowing a required oracle must make
that cadence red; assertion-shaped text or a historical calibration log is not
continuing proof.

For high-risk generated work, the target implementer cannot be the sole author,
reviewer, and change authority for its oracle and promotion controls. Record an
independent assurance challenger and use held-out/adversarial cases or mutation
corpora outside the target writer's control where correlated blind spots or
gaming are material risks. Any role-separation exception names its owner,
consequence, compensating gate, and expiry.

Coverage and other metrics are floors that fail a promotion, not targets to
game. They show what was exercised, never whether assertions were meaningful.
Pair them with behavioral falsification.

## Test-inventory integrity

Derive stable identities for required suites, cases, fixtures, corpora, shards,
attempts/leases, platform cells, and quarantines. Reconcile required, discovered, and eligible
runtime receipts as exact multisets. Require exactly one non-skipped, non-todo,
non-cancelled receipt per cell; duplicate or wrapper receipts are red. Exercise
framework-supported modifiers, options, annotations, parameterization, and
wrappers—not one textual spelling. New exclusions, empty shards, reduced
repetitions, or weakened assertions require a gated explicit disposition.
For queue work, accept one current result per shard and account for every
expired/reclaimed attempt, quarantined partial, and late result.

Keep inventory definitions, baselines, thresholds, validators, and promotion
wiring in a protected control plane outside target-writer ownership, or derive
them from an immutable approved source. A generated target diff cannot weaken
its own gauntlet. Control changes are separately inventoried, gated, reviewed,
and approved; they never ride silently with the work they judge. The author
cannot approve that control plane or self-grant its independent-challenge
exception merely because the initiating request authorized building it.

A mutable project command cannot attest that it still invokes its controller:
replacing it with another valid green command bypasses self-checks. Bind the
invocation through protected CI/branch/promotion configuration outside the
candidate, or mark that protection `planned`/`blocked`. A broken missing-file
rewire is not evidence against a valid bypass.

For a tiny fixed inventory, prefer one path/count assertion in the existing
project command and prove deleting its sole protected test/layer turns that
command red. Do not add a controller, parser, launcher, manifest, receipt
protocol, or dependency unless a named execution-loss risk survives that simple
floor and `yagni`'s pre-edit challenge accepts the extra surface.

For a larger or dynamic inventory with that unmet risk, make its control plane
fail closed and resource-bounded. The top-level project command must not
recursively invoke itself. Its external inventory controller passes the
validated discovered set to an explicitly excluded leaf runner, or reconciles
runtime receipts for every required cell before green. Merely validating names
and then launching an independently narrowable runner does not prove full
execution. Discovery traverses every declared nested test/corpus root unless the
accepted contract forbids nesting. Risk-select the smallest attacks that decide
these mechanisms: empty inventory, validator/manifest removal, valid invocation
rewiring, skip/focus/todo, nested sentinels, case/cell deletion/duplication/
addition/hollowing, and narrowed or partial execution. When the real controller
can hang or spawn descendants, add a representative escaped child/process-group
failure at the bounded ceiling and prove cleanup. Do not invent controllers or
process trees solely to test them. A controller that disappears with its tests,
passes vacuously, or exhausts resources is itself a failed gate.

Challenge each inner controller from an independently owned parent. The
outermost mutable project control cannot prove that it was not validly rewired
or replaced wholesale with forged output; that is the external control-change
owner's gate. Without that owner, local execution may be calibrated, but the
claimed branch, phase, or release promotion remains `planned` or `blocked`.

## Failure evidence

Every gate result identifies the exact revision/artifact, command or controlled
procedure, environment and configuration, raw result location, timestamp,
threshold comparison, and owner. Define whether failure blocks a change, phase,
trial expansion, cutover, decommission, release, or all work, plus the triage,
repair, re-run, and resume authority.
