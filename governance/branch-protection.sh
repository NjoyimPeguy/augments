#!/usr/bin/env bash
# Apply augments' bulletproof branch-protection gates to a branch.
# Governs verifying-completion (CI green), requesting/receiving-code-review (review +
# resolved threads), finishing-a-branch (green before merge) — as config, not instructions.
#
# Usage: governance/branch-protection.sh <owner>/<repo> <branch> [required-check ...]
#   required-check   CI status-check name(s) that must pass (default: validate)
# Needs: gh authenticated with ADMIN on the repo. Review the settings before running.
set -euo pipefail
repo="${1:?usage: branch-protection.sh <owner>/<repo> <branch> [check ...]}"
branch="${2:?branch required}"; shift 2
checks=("$@"); [ "${#checks[@]}" -eq 0 ] && checks=(validate)

command -v gh >/dev/null || { echo "needs the gh CLI" >&2; exit 2; }
command -v jq >/dev/null || { echo "needs jq" >&2; exit 2; }

# Build the JSON array of required-check contexts from the names.
contexts=$(printf '%s\n' "${checks[@]}" | jq -R . | jq -cs .)

gh api -X PUT "repos/${repo}/branches/${branch}/protection" --input - <<JSON
{
  "required_status_checks": { "strict": true, "contexts": ${contexts} },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "required_approving_review_count": 1
  },
  "required_conversation_resolution": true,
  "restrictions": null
}
JSON

echo "Applied branch protection to ${repo}@${branch} (required checks: ${checks[*]})."
echo "  CI green (strict) + 1 review + conversation resolution before merge."
echo "  enforce_admins=false — a solo maintainer can self-merge; set it true for a true wall."
