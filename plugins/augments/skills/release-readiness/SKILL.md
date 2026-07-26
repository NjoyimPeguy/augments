---
name: release-readiness
description: "Use after a change is merged and before it ships to production — the pre-deploy gate an agent can check from the repo: CI green on the merged result, reversible migrations, a named rollback target, risky behaviour behind a flag, config and secrets present, downstream breakage flagged. Skip for a change that doesn't reach a running system."
---

# Release Readiness

The deploy command is environment-specific — run by your platform's tooling or your hands. This skill is the portable layer *before* that: the checks an agent can actually reason about, so you don't ship a change that can't be rolled back or that silently breaks something downstream.

## When to use

- A change is merged (or a hotfix is cut) and about to go to production.
- **Skip** for a change that doesn't reach a running system (internal docs, a library change behind no release).

## The readiness gate

Walk each item. For each, the answer is *yes, with evidence*, *not applicable*, or *surface it to the human* — never a silent assumption.

1. **CI is green** on the merged result — the integration checks, not just local tests.
2. **Acceptance criteria verified** — every criterion from the spec or issue actually met, not assumed (lean on `verifying-completion`).
3. **Migrations are reversible** — any schema or data migration has a tested down-path, or the rollback is documented.
4. **Rollback target is named** — the exact commit or tag to revert to, and how.
5. **Risk is gated** — non-trivial new behaviour sits behind a feature flag or a phased rollout, not flipped on for everyone at once.
6. **Config and secrets** changes are documented and present in the target environment — no "works on my machine" variable.
7. **Changelog / release notes** written, even one line — a release nobody can describe is one nobody can debug.
8. **Breaking changes flagged** to dependents — an API surface, event schema, or data change something downstream relies on.
9. **Downtime** is either none, or a window is scheduled and communicated.

An unchecked item is a blocker or an explicit, owned risk — never something you skip quietly.

## Common mistakes

- Treating "tests passed locally" as "CI is green" — different gates.
- Shipping a forward-only migration with no way back.
- A big-bang rollout of risky behaviour with no flag and no canary.
- A silent breaking change — the dependent finds out in production.

For per-item checks, fill-in templates, and the common silent failure of each gate item, see `references/gate-details.md`.
