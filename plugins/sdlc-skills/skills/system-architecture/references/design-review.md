# Independent design review

A fresh-context reviewer catches what the design's authors cannot because they
are anchored to their own decisions. This review is mandatory for a high-risk
design: a new critical subsystem, wide blast radius, difficult recovery,
sensitive trust boundary, or hard-to-reverse choice. The reviewer must not be
the design's sole author.

Before review, bind the exact design version, reviewer identity, allowed artifact
access, current authority for its worker/provider/storage/egress, and report
location/lifecycle. A dispatched reviewer exists only after
the callable action returns a nonempty reviewer/job identity; unavailable,
refused, or empty dispatch leaves review pending and cannot be replaced by
self-review. Declare a terminal deadline and timeout/cancel owner/action; poll
only the exact attempt identity until then. Failure/deadline enters
`cancellation requested` until worker, descendants, and effects reach confirmed
quiescence; quarantine partial output. Reassignment creates a linked successor
attempt and rejects every predecessor late result/mutation. Failed, timed-out,
or cancelled stays pending. Completion requires one nonempty version-bound
report; never wait indefinitely.

This reviews the **design document** — before anyone builds against it.

Give the reviewer the approved requirements, data model, design document, and
relevant codebase evidence with this brief:

> Review the design document at `{{design file}}`. Flag **only** issues that would lead to building the wrong thing or an unbuildable design — skip wording and detail-level variation. Check:
>
> 1. **Traceability** — every requirement and preserved obligation reaches a
>    component, interface, and evaluator; no component is unjustified.
> 2. **Trust and data** — ownership, authorization boundaries, sensitive paths,
>    and sources of truth are explicit.
> 3. **Failure and recovery** — dependencies and asynchronous paths define
>    unavailable, retry, idempotency, degraded, and recovery behavior.
> 4. **Operations** — the risk-selected runtime, deployment, scale/resource,
>    observability, rollout, and compatibility views are sufficient.
> 5. **Decisions and seams** — hard-to-reverse choices have accepted ADRs; each
>    proposed seam has a stable owner and measured change friction or one real
>    volatile/external boundary with measured impedance, failure policy, or
>    test-isolation value; implementation count alone proves nothing.
> 6. **Cross-section consistency** — flows use real data-model concepts and
>    component boundaries match the named interfaces.
> 7. **Vocabulary and scope** — domain terms are consistent and no unrequested
>    feature or future-only abstraction appears.
>
> Return each finding as `severity — requirement/risk — evidence — required
> correction`. If nothing blocks a correct, buildable design, say so in one
> line and name the reviewed design version.

The design owner resolves every blocking finding and records its disposition.
Every normative correction creates a proposed successor and requires a focused
re-review of affected and dependent sections. Direct approval applies only to
the reviewed version.
