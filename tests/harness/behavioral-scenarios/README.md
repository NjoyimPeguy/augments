# behavioral-scenarios/

Shared scenarios for the per-adapter `run-behavioral.sh` runners.

Activation asks *did the skill fire?* — one generic verdict, so its engine can be
scenario-agnostic. Behaviour asks *did the skill change what got **built**?*,
which has no generic verdict: success differs per skill. So the runner owns the
plumbing (isolation, which skills the arm loads, write access, capture) and the
scenario owns the judgement.

```
<name>/
  fixture/            a seeded project, copied per run, committed on a task branch
  opening.default     the prompt, used by any adapter without an override
  opening.<adapter>   optional per-adapter override (see below)
  probe.sh            gets the finished workdir as $1; prints evidence and exits
                      non-zero when the arm did not produce the target behaviour
```

**Why the fixture and probe are shared, but the opening is not.** A probe reads a
finished working directory, so it is harness-agnostic by construction and the
verdicts stay directly comparable across adapters. Openings are not: `codex exec`
is single-turn, so a scenario that invites a clarifying question ends that run
with **no deliverable at all** — the first Codex arm of `spec-it` terminated on an
`interview-me` question after routing correctly. `opening.codex-cli` therefore
pre-empts the interview. An override changes what is comparable, so use one only
for a harness constraint, never to make an arm look better — and say so in the
record when you do.

**The arms must share one opening within an adapter.** RED and GREEN differ only
in which skills are loaded. An arm that also changes the prompt is not a
comparison.

## Adding a scenario

Drop in a directory with the four parts above, `chmod +x probe.sh`, and it is
runnable by every adapter that has a `run-behavioral.sh`. No runner edit.

Write the probe so its **exit code** is the verdict. A record is prose written by
the same agent that wants it to be green; an exit code is not. Check the things
that are easy to fake and hard to see in a transcript — that an artifact exists,
that it *loads* (one that errors on import is not a criterion), and that it fails
for the right reason rather than passing vacuously.

Run a probe offline against workdirs you already captured
(`bash <name>/probe.sh <dir>`) to check the probe itself with no API call — the
same idea as `run-activation.sh selftest`.
