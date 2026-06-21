# Invocation test: dispatching-parallel-agents

*Invocation, not triggering — see `README.md`.*

**Method.** Fresh subagents, shipped nudge on/off, catalogue as available tools,
one realistic terse opening, `FIRST: invoke | proceed` (`invocation-harness.sh`).
Model-judged proxy, not a gate.

## Scenario

> "Several tests are failing in different parts of the app — auth, billing,
> search. Can you get them green?"

Deliberately **not pre-shaped** as "independent work units, fan out fast" — that
framing is exactly what rigs the triggering record. Here the independence is
present but unstated, and "get them green" actively tempts guess-and-patch.

## Last result (2026-06-21 · Claude Code · large-tier judge)

- **nudge ON — 3/3 invoked, 0 proceeded:** 3 `dispatching-parallel-agents`.
- **nudge OFF — 3/3 invoked, 0 proceeded:** 1 `dispatching-parallel-agents`,
  2 `debugging`.
- **No agent guess-and-patched.** Every reply refused "chase green" and named
  root-cause-first; none proceeded straight to editing.

**Finding.** Firing rate was 100% in both arms — the nudge did not change
*whether* a skill fired. It changed *which*: with the nudge, all three reached
for the cross-cutting `dispatching-parallel-agents`; without it, two reached for
`debugging` first (root-cause each failure before parallelizing — arguably the
*more* fundamental first move, since you debug before you fan out). So on this
opening the nudge's measurable effect was a mild pull toward the showier
cross-cutting skill over the discipline skill, not a lift in activation. Small N;
directional only. As with the planning record, the catalogue's presence plus
strong descriptions — not the nudge prose — is what drives invocation here, and
the `FIRST:` scaffold makes this a ceiling, not a field rate (`README.md`).
