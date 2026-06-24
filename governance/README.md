# governance/ — deterministic gates

augments routes skills by **firm persuasion** (the SessionStart bootstrap + firm descriptions — see [`../docs/augments/activation.md`](../docs/augments/activation.md)). Persuasion is firm but **leaky**: an LLM can skip an instruction. For the **production-critical** procedures — the ones whose skip causes an incident — that isn't enough. These gates make those procedures **non-skippable** by enforcing them where the agent can't route around: the commit / PR / CI boundary.

**The airtight layer is CI / branch-protection** — it judges the *artifact*, not the agent, so it binds humans and any agent on any harness. In-session blocks (`PreToolUse`, the next build step) shift the same checks left but are bypassable; the guarantee is here.

## What each gate enforces

| Gate | Governs (skill) | Strength | How |
| --- | --- | --- | --- |
| `branch-protection.sh` | `verifying-completion`, `finishing-a-branch`, `requesting`/`receiving-code-review` | **bulletproof** | require CI green + review + conversation-resolution before merge |
| `ci/tests-accompany-code.yml` | `test-driven-development`, `debugging` (outcome) | **heuristic** | a PR changing impl code must change a test — gameable with a trivial test |
| `ci/release-readiness.yml` | `release-readiness` | partial | a release PR must update the changelog — extend with your migration/rollback checks |
| `ci/trust-boundary-flag.yml` | `security-audits` (outcome) | **heuristic** | a diff touching auth/input/secret patterns needs a `security-reviewed` label |
| (`tests/validate-skills.sh`, augments' own) | `writing-skills` | bulletproof | skill files must pass the structural gate |

**Bulletproof** = config the agent cannot bypass. **Heuristic** = a real signal that reduces but doesn't eliminate gaming — never sold as a wall. The classification behind this lives in the governance design.

## Adopt it (in a consuming repo)

1. Copy `ci/*.yml` → `.github/workflows/`. Edit the path/label patterns at the top of each for your stack.
2. Copy `pre-commit/` into place and `pre-commit install` for the shift-left convenience (a `--no-verify` bypass is caught by the CI re-run — the wall is CI, not the hook).
3. Apply branch protection: `bash governance/branch-protection.sh <owner>/<repo> <branch> [check ...]` (needs a `gh` admin token). Read `branch-protection.md` first.

## In-session shift-left — use the existing pattern, don't rebuild

The CI gates above are the guarantee. For *immediate* feedback inside a session — blocking, say, an `Edit` to implementation code before a failing test exists — use a **`PreToolUse` hook**. augments deliberately does **not** ship one: it is harness-specific, `Bash`-bypassable (so never a guarantee — Anthropic `claude-code#29709` declined to close that gap), and the pattern is already done well by [`tdd-guard`](https://github.com/nizos/tdd-guard) (a `PreToolUse` hook that blocks implementation-without-a-failing-test). Adopt that for the shift-left; let these CI gates be the wall behind it. A worse in-house copy would be the over-build this project refuses.

## Dogfooding (augments itself)

augments is a skills/docs repo, not an app, so only the gates that fit apply: `validate-skills.sh` (already gated in CI) governs `writing-skills`, and `.github/workflows/release-readiness.yml` requires a CHANGELOG entry when a release bumps the manifest version. The code-test and trust-boundary gates are templates for consuming **app** repos — augments has no app code or trust boundary to gate, and faking one would be the over-claim this project refuses. Branch-protection is the maintainer's to apply (it requires review; a solo maintainer leaves admins exempt and accepts the looser guarantee).
