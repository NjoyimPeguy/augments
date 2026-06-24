# Branch protection — the bulletproof gates

These enforce `verifying-completion` (CI green), `requesting`/`receiving-code-review` (review + resolved threads), and `finishing-a-branch` (green before merge) at the merge boundary. They are **config, not instructions** — neither a human nor an agent can route around them.

## Settings (on the protected branch, e.g. `main`)

- **Require status checks to pass before merging** — *strict* (branch up to date), listing your CI check name(s) (e.g. `validate`, `test`). → `verifying-completion`, `finishing-a-branch`.
- **Require a pull request before merging**, ≥1 approving review, dismiss stale approvals on new commits. → `requesting`/`receiving-code-review`.
- **Require conversation resolution before merging.** → `receiving-code-review` (findings addressed, not ignored).
- **Include administrators** (no bypass) makes the gate *truly* non-skippable. A solo maintainer who must self-merge leaves admins exempt (`enforce_admins=false`) and accepts the looser guarantee — honestly a weaker wall, not a fake one.

## Apply

```bash
governance/branch-protection.sh <owner>/<repo> <branch> [required-check ...]
```

Needs `gh` authenticated with **admin** on the repo. Review the JSON the script sends before running — branch protection changes how everyone (and every agent) merges.
