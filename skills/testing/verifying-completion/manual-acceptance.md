# Manual Acceptance — when no automated check exists

Some claims cannot be proven by a command that returns pass/fail: visual output, real-browser behavior, multi-step user flows, realtime UI, notifications, subjective usability. The honest position (`docs/philosophy.md`) is that here you have *process, not proof* — so the discipline is to make the human-run check as close to a gate as it can be: structured, traceable, and tied to a requirement. Informal "I clicked around, looks fine" is not acceptance.

## The rule

1. **Automate everything that can be.** Manual acceptance covers only behavior that is genuinely hard, expensive, or inappropriate to assert in code — never a test you could have written and skipped. If a check *can* be a command, it belongs in `verifying-completion`'s gate, not here.

2. **One row per un-automatable user-facing requirement.** Trace each back to a requirement or acceptance scenario (from `ui-ux` or the spec) — a step with no requirement behind it is noise, a requirement with no step is a gap.

3. **A human performs the step.** You cannot self-certify a gate whose whole point is human judgment. The agent prepares the matrix and drives whatever it can; the *verdict* on look/feel/flow comes from the person.

4. **Evidence, not assertion.** Each passed row records what was observed — a screenshot, a recording, or an explicit "did X, saw Y". An unrun row is **not** a pass; mark it pending. The same hollow-verification rule as automated checks applies.

## The matrix

| ID | Requirement | Manual step | Expected result | Observed / evidence | Status |
| -- | ----------- | ----------- | --------------- | ------------------- | ------ |
| {{A1}} | {{what must be true}} | {{exact action the human takes}} | {{what they should see}} | {{what they saw + artifact}} | pass / fail / pending |

Done means every row is `pass` with evidence, or a `fail`/`pending` row is surfaced as not-done — never quietly dropped. Pair this with the automated gate: tests prove the logic, the matrix proves the experience.
