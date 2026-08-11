---
name: security-audits
description: "Use when a change touches a trust boundary, attacker-controlled input, authentication or authorization, secrets, sensitive data, isolation, a dependency, build or deploy exposure, availability, session handling, cryptography, or security-relevant reachability. Fires on anything touching login, tokens, permissions, uploads, or user-supplied input reaching a query or a shell, even if nobody says security. A generic security review, scanner, or ordinary code review is not a substitute. Skip only when evidence shows no security surface changed."
---

# Security Audits

Reason about what an adversary can make the exact candidate do. The scope is the
changed attack surface, not merely the changed lines: a one-line route or policy
change can expose an old vulnerable path. A prior finding, a scanner summary, or
a comment asserting a verdict is evidence to check — never the verdict to copy.

## When to use

- The candidate changes a trust boundary, or changes how untrusted actors reach
  data, operations, dependencies, runtime resources, or deployment.
- **Skip** only after inspecting reachability and confirming that no security
  surface changed. “Small diff” and “internal refactor” are not evidence.

## Procedure

1. **Freeze the candidate and bind it to an identity.** Stop anything still
   writing to it. Reuse a current `requesting-code-review` descriptor, or invoke
   that skill and fill the review-candidate descriptor it owns. Invoke
   `verifying-completion` for whichever exact-state gates apply, and join its
   state identity byte-for-byte before auditing. An audit on its own is not a
   breadth review and does not substitute for one.
2. **Model the threat this change introduces.** Inventory the protected assets,
   the trusted and untrusted actors, the entry points, the trust boundaries, the
   privileges, the security assumptions, and the abuse cases. Give each a stable
   ID and the source digest it was taken against.

   An assumption is the part that quietly rots, so record for each one what
   evidence or state supports it, how that gets validated, who owns it, when it
   expires, and what happens when it turns out to be false.
3. **Expand the scope by reachability.** Start from what the candidate changed,
   then trace outward: old code that is newly reachable, callers and consumers,
   shared serializers and guards, generated sources, data stores, dependencies,
   the build and CI, configuration, deployment, and operational paths. Record why
   each expansion is relevant. Pre-existing issues unrelated to this change stay
   separate — note them, do not fold them into this verdict.
4. **Trace each finding from source to effect.** Work through the nine category
   checklists in `references/audit-checklists.md`, from authentication and
   authorization through to dependencies, build, and deployment. Each one names
   what it commonly misses.

   Every category is either covered or carries an accountable, approved omission
   obtained through *When a category cannot be covered* below. And every finding
   names three things: the attacker-controlled source, how it propagates, and the
   security-sensitive sink or effect it actually reaches.
5. **Run the security gates that exist.** Execute the assurance-matrix checks
   that apply to every security-relevant platform, build mode, and environment
   cell. Probes run under `verifying-completion`'s effect authority; never
   exploit shared or production state without exact, direct authority for it. A
   gate that is missing or stale is recorded as a blocker, not worked around, and
   goes to the user through the section below.
6. **Write findings bound to the revision.** The checklist file's *Writing the
   finding* section is the record shape — one finding, one record, with the
   severity scale it defines and the fields each finding owes.

   Two of those fields decide whether the finding is usable: the fix is the
   smallest change that closes the path, not a re-architecture, and sensitive
   evidence is recorded as a redacted location or digest, never as the value
   itself.
7. **Keep implementation, fix, and verdict in separate hands.** A `security
   clear` verdict requires an auditor independent of whoever implemented the
   candidate; where that independence is unavailable, the verdict is
   `inconclusive`. Findings flow back through `receiving-code-review`, and
   whoever writes a fix cannot certify their own correction: create a new
   candidate, rerun the affected gates, and obtain an independent focused
   security re-audit.
8. **Dispatch that auditor through a real callable action.** “Running” means the
   action returned a nonempty auditor or job receipt. A name in prose, an empty
   target, and an empty status are not dispatch. If the action is unavailable,
   refuses, or returns nothing, do not simulate the result and do not
   self-certify — issue `inconclusive` with the gate left pending.

   Poll the exact receipt until the deadline. A failure or a passed deadline puts
   the attempt into cancellation-requested until the worker, its descendants, and
   its effects have gone quiet; quarantine any partial output. A retry links its
   predecessor, rejects that predecessor's late results and mutations, and stays
   inconclusive until it comes back clear.
9. **Issue the security verdict, and nothing broader.** One of `security clear`,
   `security blocked`, or `inconclusive`, bound to the exact candidate and
   review-input identities. Any security-relevant edit invalidates it. The
   broader releasability decision belongs to release readiness, not here. End the
   returned report with exactly one valid JSON line, copying both full descriptor
   identities byte-for-byte:

   ```text
   SDLC_SKILLS_SECURITY_RESULT={"candidate":"{{exact result identity}}","context":"{{exact review-input identity}}","verdict":"{{security clear | security blocked | inconclusive}}","report":"{{nonempty location or returned directly}}"}
   ```

## When a category cannot be covered

Two things block coverage mid-audit: no gate exists for that category, or the
probe that would settle it needs shared or production state you hold no authority
to touch. Neither is yours to wave through — an omission the auditor approved for
itself is the one nobody else knows to look at. Print exactly this, then stop:

```text
Security audit blocked — {{candidate-id}}

Blocked:  {{category}} — {{no gate | no probe authority}}
Exposure: {{what stays unexamined, and what can reach it}}

1. Authorize the probe — {{exact target, effects, and blast radius}}
2. Accept the omission — name its owner, its expiry, and what compensates
3. Block — the verdict stays `security blocked` until this is covered

Which?
```

Silence is not acceptance and neither is urgency: an unanswered gap leaves the
verdict `inconclusive`, never covered. An accepted omission binds to this exact
candidate, and any security-relevant edit invalidates it along with the verdict.
Missing auditor independence is not on this menu — step 7 already settles it.
