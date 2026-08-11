# Independent design review

A fresh-context reviewer catches what the design's authors cannot because they
are anchored to their own decisions. This review is mandatory for a high-risk
design: a new critical subsystem, wide blast radius, difficult recovery,
sensitive trust boundary, or hard-to-reverse choice. The reviewer must not be
the design's sole author.

Before review, bind the exact design version, the reviewer role ID, allowed
artifact access, current authority for its worker/provider/storage/egress, and
the report location. No receipt, no reviewer: an unavailable, refused, or empty
dispatch leaves the review pending, and self-review cannot stand in for it. Set
a terminal deadline and a timeout/cancel owner before dispatching, then poll only
that attempt ID. Quarantine output from any run that did not reach quiescence,
and reject a late result from a reassigned predecessor. Completion is one
nonempty report bound to that design version; failed, timed out, and cancelled
all stay pending.

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
