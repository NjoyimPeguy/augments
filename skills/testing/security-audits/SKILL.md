---
name: security-audits
description: Use when a change touches a trust boundary — authentication, authorization, attacker-controlled input, secrets, or data exposure — and you need to review it for security problems before it ships. Traces untrusted data from source to sink rather than eyeballing. Skip for a change with no security surface.
---

# Security Audits

A security review is not a tidier code review — it reasons about an *adversary*. The question is never "is this clean?" but "what can an attacker make this do?" Findings are traced, not guessed: untrusted input is followed from where it enters (**source**) to where it acts (**sink**).

## When to use

- A change touches auth, handles attacker-controlled input, moves secrets, or exposes data — anything with a trust boundary.
- **Skip** for a change with no security surface: an internal refactor, docs, or a pure-compute helper over already-trusted input.

## Procedure

Scope to the diff, then walk each category. For every suspect, state the concrete **source → propagation → sink** path — not "this could be unsafe".

1. **Authn / authz** — does the change touch who-can-do-what? Does it *weaken* an existing guard — a check removed, narrowed, or moved to after the action it protects?
2. **Input validation** — is attacker-controlled input validated before use? Follow it to every sink it reaches.
3. **Injection** — is untrusted input built into a query, shell command, path, URL, or template? (SQL, command, path traversal, SSRF.)
4. **Secrets** — is any credential, token, or key introduced in code or committed config instead of the environment or a secret store?
5. **Data exposure** — is sensitive data logged, serialized into an untrusted response, or returned in a field that shouldn't carry it?
6. **Security regression** — did the diff loosen something previously tighter: a validation, a rate limit, a permission check?

Report findings evidence-backed and severity-tiered (Critical / Important / Minor), each with its trace and a fix. End with an explicit **ship / don't-ship** verdict.

## Common mistakes

- Auditing the whole app instead of the change — review the diff's surface, deeply.
- "Looks unsafe" with no source-to-sink path — that's a guess, not a finding.
- Checking only added lines — a removed or weakened guard is the more dangerous diff.
