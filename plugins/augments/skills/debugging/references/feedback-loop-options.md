# Debugging — Feedback Loop Options

The loop is the engine of debugging: a fast, deterministic, runnable signal for whether the bug is present. Reach for the highest one that fits — a 2-second deterministic loop is worth far more than a 30-second flaky one.

Ranked, tightest first:

1. **A failing unit test** — the bug expressed as an assertion.
2. **A request script** — hit the endpoint, assert the status and body.
3. **A CLI run against a fixture** — feed a saved input, diff the output against a snapshot.
4. **A headless UI script** — drive the interface, assert on the result.
5. **A replayed trace** — capture a real failing request or session and replay it.
6. **A throwaway harness** — a tiny script that calls just the suspect unit with the triggering input.
7. **A property or fuzz loop** — generate inputs until the bug appears; now you have a case.
8. **A bisection harness** — script the good-vs-bad check, then bisect commits (or inputs) to the boundary.
9. **A differential loop** — run the old and new versions side by side on the same input; the diff is the bug.
10. **A human-run script (last resort)** — you provide the exact commands; a human runs them and pastes the output.

If none is achievable, that itself is the finding: say so, list what you tried, and ask for what you'd need — environment access, a captured artifact, or permission to add temporary instrumentation. Don't proceed without a loop you believe in.
