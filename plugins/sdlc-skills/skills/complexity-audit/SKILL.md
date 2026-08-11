---
name: complexity-audit
description: "Use when existing code should be examined for accidental complexity — abstraction nothing needs, ownership it should not hold, flexibility nobody uses, or custom machinery a library already provides. Fires on is this over-engineered, why is this so complicated, and do we still need all of this, even if nobody says complexity or audit. Diagnoses only; it changes no code. Skip implementation choices, exact-candidate review, and structural work already approved."
---

# Complexity Audit

Find accidental complexity without calling essential guarantees bloat. This is
diagnosis, not permission to change code.

## When to use

- Audit an existing module or repository independently of a current candidate.
- **Skip** choosing an implementation (`yagni`), reviewing an exact candidate
  (`requesting-code-review`), or applying known structural work
  (`refactor-architecture`).
- A whole-repository claim requires explicit whole-repository scope; otherwise
  name the bounded surface and make no wider claim.

## Procedure

1. **Freeze the target and your authority.** Open `assets/audit-report.md` and
   fill its *What was frozen* block first — it names the identity, goal, path
   boundary, guarantees in force, and admissible evidence this audit is bound to.

   The report is written to `.sdlc-skills/audits/{{YYYY-MM-DD}}-{{topic}}.md`,
   owned by the coordinator, and predeclared outside the audited target's own
   identity. If the target drifts from what you froze, stop or restart.

2. **Derive the inventory.** The template's inventory table is the checklist:
   code, dependencies, configuration, build and test machinery, generated
   sources, dynamic and reflection and registration paths, external consumers,
   and operational ownership wherever that applies.
3. **Partition only when necessary.** Prefer one bounded audit. For a large
   surface, give partitions stable IDs, complete exclusive inventories, and
   cross-boundary edges. Use `dispatching-parallel-agents` only when their read
   sets, resources, data boundaries, and outputs are independently reconcilable.
4. **Challenge read-only.** Read `references/yagni-auditor.md` and dispatch it
   against each exact partition. A name or prompt is not dispatch; record real
   receipts and terminal outcomes. Auditors return partition reports; the
   coordinator alone writes the canonical audit. If no independent action is
   available, an inline pass must say so; an explicitly requested independent
   audit stays pending.
5. **Reconcile coverage before writing any finding.** The template's
   reconciliation block is what you owe: every partition, every exclusion, every
   cross-boundary candidate, every duplicate, every failed attempt, and every
   area left inconclusive.

   Copy each dispatched auditor's valid terminal `SDLC_SKILLS_YAGNI_AUDIT`
   receipt into the canonical audit verbatim. A receipt that is missing,
   malformed, or bound to a different identity makes that partition
   inconclusive. Never state a repository-wide conclusion from sampled or partial
   coverage.

6. **Publish decisions, not a deletion score.** Each finding is `keep`,
   `simplify`, `remove`, `decision`, or `investigate`, and carries the evidence,
   the guarantee at stake, the replacement, how that replacement is verified, and
   what a migration or recovery would owe. The template's findings table holds
   those columns. Line count is not authority.
7. **Keep mutation separate.** The audit cannot apply or approve findings.
   Accepted structural changes route to `refactor-architecture`; behavior work
   follows its owning feature/bug route and produces a new verified candidate.
   The private audit report is evidence, not an integration candidate: verify
   its coverage, then stop. Review/branch finishing applies only if the user
   separately asks to ship that report.

## Common mistakes

- “No direct caller” → dynamic, configured, generated, or external use remains
  `investigate` until disproved or deprecated.
- “One implementation” → a seam containing real impedance, policy, or test
  isolation may be justified; apply the deletion test, not a slogan.
- “Tests and rollback are overhead” → a current assurance or recovery guarantee
  owns them; duplicate machinery with no distinct guarantee is the candidate.
- Editing during the audit → freezes neither evidence nor conclusions; report
  first, then obtain separate implementation authority.
