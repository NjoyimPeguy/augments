# Audit checklists

Expanded per-category checklists behind `../SKILL.md`. Loaded on demand.

One category per section. Walk each against the diff's surface only. A finding is not a finding until you can name the **source → propagation → sink** path and the concrete exploit.

## 1. Authn / authz

Look for:

- Every new or touched endpoint, handler, or mutation: where is the identity established, and where is the permission checked? Both, in order, before the action.
- The object-level check, not just the route-level one: "is logged in" is not "owns {{resource-id}}". Follow every ID taken from the request to an ownership/scope check.
- Removed or narrowed checks: a decorator dropped, an `if` deleted, a role list widened, a check moved *after* the operation it guards (the action runs, then fails — side effects already happened).
- Default-deny: does a new route fall through to an allow-by-default framework convention instead of inheriting the guard its neighbors have?
- Client-side-only enforcement: hidden UI is not authorization; the server path must refuse on its own.

Commonly missed:

- **Insecure direct object reference** — the route checks authentication but never checks that `{{resource-id}}` in the path/body belongs to the caller.
- **Guard ordering** — the check still exists but now runs after the write/send/enqueue it was protecting.
- **The second path** — the UI route is guarded, but the bulk-export, retry, or admin-variant handler added in the same diff is not.

## 2. Input validation

Look for:

- Validation at the trust boundary, once, before first use — not scattered per-sink, and not after the value has already been used once.
- Type, range, length, and an allowlist where one exists (enum values, expected formats) — not just "is a string".
- Validation surviving re-serialization: a value parsed, transformed, decoded (base64, URL-decode, unicode normalization) can change shape after the check.
- Mass assignment: request bodies merged wholesale into a model or record, picking up fields the caller was never meant to set.

Commonly missed:

- **Validation that checks then transforms** — the check passes on the raw value; the decoded/normalized value reaching the sink is different.
- **Server trusts a client-computed value** — price, total, role, or checksum computed in the browser and re-accepted server-side.
- **One path validated, sibling paths not** — the form handler validates; the API, import, or webhook handler for the same data does not.

## 3. Injection

Look for:

- Every place untrusted input is *built into* an interpreter's input: query strings, shell commands, filesystem paths, URLs fetched server-side, templates, headers, serialized formats.
- Parameterized/escaped APIs used at the sink — string concatenation or interpolation into any of the above is a finding even if "the input is validated".
- Path construction: join a base with user input, then confirm the result stays under the base (traversal via `..`, absolute paths, symlinks).
- Server-side fetches of a caller-supplied URL: scheme and destination allowlisted, internal addresses and link-local ranges refused (SSRF).
- Second-order flows: input stored now, interpreted later by another component (a report renderer, an email template, an admin view).

Commonly missed:

- **"The ORM/builder makes it safe"** — until the one raw-fragment escape hatch in the diff takes concatenated input.
- **Escaping at the wrong layer** — input escaped for one sink (HTML) later reaches a different one (shell, SQL) where that escaping means nothing.
- **SSRF via indirection** — the URL is checked, but a redirect, a DNS name under attacker control, or a file fetched by its hostname resolves somewhere internal.

## 4. Secrets

Look for:

- Any literal credential, key, token, or connection string in code, config, fixtures, or test data — including "temporary" ones.
- Config files newly committed: does the diff add a value that only the environment or a secret store should hold?
- Secrets in logs, error messages, exception payloads, or telemetry — a value printed for debugging stays printed.
- Secrets flowing to places with weaker retention: client-side bundles, analytics events, third-party error reporting, build artifacts.

Commonly missed:

- **Test fixtures with live-looking credentials** — a real key copied into a fixture "temporarily" is a leaked key regardless of intent.
- **The secret in the error path** — connection failure logs the full connection string, credentials included.
- **History, not just the diff** — a secret added and removed in the same branch still ships in the history; removal from the file is not removal from the repository.

## 5. Data exposure

Look for:

- Response serialization: whole-object returns where the object now carries a sensitive field (hashes, tokens, internal IDs, other users' data) — check what the serializer includes, not what the handler intends.
- Log statements added in the diff: what do they capture at what level? Request bodies, headers, and session data are the usual leaks.
- Error responses: stack traces, internal paths, query text, or existence-oracle differences (distinct messages for "no such user" vs "wrong password").
- Over-fetching for filtering: sensitive rows fetched and filtered in code, but the unfiltered set left reachable through another accessor on the same object.

Commonly missed:

- **The response DTO grew a field** — the change adds one sensitive field to a shared serializer, and every endpoint using it now leaks it.
- **Verbose errors only in the failure path** — the happy path is clean; the 500 handler dumps internals.
- **Logs at debug level treated as harmless** — production incident response routinely runs at debug; level is not a boundary.

## 6. Security regression

Look for:

- Every *removed* line with a security meaning: a validation, an escape, a rate limit, a permission check, an expiry, a secure flag on a cookie or header.
- Loosened configuration: CORS widened to `*`, TLS verification disabled, a signature check made optional, an allowlist turned into a denylist.
- Defaults flipped: a feature flag defaulting to the permissive mode, a new code path that bypasses the hardened old one.
- "Refactors" of guard code: behavior-preserving claims on security logic deserve line-by-line comparison, not trust.

Commonly missed:

- **The disabled check left disabled** — a guard commented out for local debugging, shipped in the diff.
- **A timeout or limit removed as "cleanup"** — brute-force and resource-exhaustion protections deleted because they looked like clutter.
- **Weakening hidden in a rename/move** — the check survives in name but the new wiring never calls it on this path.

## Writing the finding

One finding, one record:

- **Severity** — Critical (remote exploit, auth bypass, secret or bulk-data leak) / Important (needs a second condition or insider position) / Minor (hardening, defense-in-depth).
- **Path** — `{{source}} → {{propagation}} → {{sink}}`, with file and line.
- **Exploit** — the concrete input or sequence that triggers it, in one or two sentences.
- **Fix** — the smallest change that closes the path, not a re-architecture.

Then the verdict: **ship** (no Critical/Important open) or **don't ship** (name the blockers). No verdict, no audit.
