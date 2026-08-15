---
name: viewing-artifacts
description: "Use when the state of an SDLC artifact trail needs to be seen at a glance instead of read file by file — progress across briefs, specs, designs, plans, and execution, what needs attention, and what drifted after a downstream artifact consumed it. Fires on show me the state of my specs and plans, where does my project stand, what needs attention, is my plan still in sync with the spec, and visualize the trail, even if nobody says artifact or viewer. Emits one self-contained local HTML page from `.sdlc-skills/`, deriving state only from real markers and rendering unknown where approval is underivable. Skip when a specific artifact must be read, written, or edited — viewing is read-only."
---

# Viewing Artifacts

One self-contained page answers "what is the state of my SDLC work, and what
needs attention?" from the `.sdlc-skills/` artifact trail. Every value on it
is derived from a real marker; where no marker exists the page says unknown.
A confident guess is fabrication — the failure this skill exists to prevent.
The page carries state, not documents.

## When to use

- The user asks for the state, progress, or drift of their SDLC work — what needs attention, how far each initiative is, what changed after a downstream artifact consumed it — or asks to see the trail as a page.
- **Skip** when a specific artifact must be read, created, or edited: that is the owning skill's work, and this skill never mutates the trail.
- **Skip** when there is no trail and nobody asked for its state — an unprompted empty page helps nobody.

## Procedure

1. **Discover the trail.** Read `.sdlc-skills/` at the project root:
   `briefs/`, `specs/`, `designs/`, `plans/`, `verification/`, `audits/`,
   `post-mortems/`. An absent folder means an unreached phase, not an error.
   No `.sdlc-skills/` at all — or the user overrode artifact paths so the
   convention is not there — render the template's empty state naming what
   produces artifacts; never search the filesystem for look-alikes.

2. **Thread topics by slug.** `YYYY-MM-DD-<topic>` is the identity. The same
   slug across folders is one topic: `designs/<slug>.md`, its
   `<slug>-migration.md` sibling, and its `<slug>/visuals/` directory all
   belong to it — never split them into phantom topics. Plans are directories
   (`plans/<slug>/00-index.md`). Audits and post-mortems thread by the same
   slug but carry no spine phase — never invent a sixth node for them.

3. **Derive phase status from real markers only.** The spine is brief, spec,
   design, plan, execute. For each phase of each topic:

   - **No artifact** → a pending node naming what produces it; no fabricated dates or counts.
   - **Presence plus a `**Status:** draft|proposed` field** → the artifact exists; decision state is external, and its `**Normative version:**` identity is what approval binds to.
   - **Approval comes only from the decision ledger.** Follow the artifact's `**External decision ledger:**` pointer and parse best-effort — only the markdown-table form, matching the row whose `Identity` equals the artifact's normative version and whose location points at that artifact (the same identity string on another file's row is a different decision). A missing pointer, missing file, non-table content, an ambiguous parse, or no matching row → render approval `external/unknown` (pill `pending`, content `… unknown`). A `**Status:** proposed` field is not approval.
   - **Section-level state, file-level freshness.** A brief or design file may hold several sections (goals, scope, ADRs), each with its own normative identity and ledger row; derive state per section, freshness per file.
   - **Execute** derives from the plan index's checkbox rows: only the exact marker `[x] done` counts complete. `[x] done with concerns`, `blocked`, `in progress`, `needs context`, `cancelled`, `superseded`, and `todo` each count separately — the same label under a different checkbox is a different signal.

4. **Compute drift from real change times.** Per artifact file, the
   last-change time is `git log -1 --format=%ct --` followed by the path;
   outside a git repository, fall back to the file's mtime. Flag drift when
   an artifact is newer than a downstream artifact that consumed it — a spec
   edited after the plan written against it. Checkbox ticks and status
   labels in the plan index are the mutable execution projection, not a
   normative change: normalize them away before comparing, so a
   checkbox-only plan update never flags. Equal times flag nothing — a
   fresh clone outside git is blind by construction, and that is the safe
   default.

5. **Group topics by attention.** Needs attention first — drift flags,
   blocked tasks, decisions derivably pending from a parsed ledger row — and
   its first topic is the preselected one. Then Waiting: active, nothing
   flagged. Then Complete: everything reached is done, nothing flagged. With
   no attention topics, preselect the first waiting, else the first
   complete.

6. **Fill the template.** Open `assets/page-template.html` — its top-of-file
   comment is the fill contract: region order, allowed values, what to
   repeat, what to omit. You bring the derived state:

   - header `{{page-title}}`, `{{as-of}}`, `{{as-of-iso}}` — the current UTC instant;
   - tiles `{{tile-number}}`/`{{tile-total}}`/`{{tile-label}}` — numbers and short labels, the attention tile last;
   - sidebar groups `{{group-label}}`/`{{group-count}}` attention-first; per topic `{{topic-slug}}`, `{{topic-pill-class}}`/`{{topic-pill-content}}`, `{{dot-1}}`…`{{dot-5}}` in brief→execute order, `{{topic-freshness}}`; the preselected item carries `sel`;
   - one pane per topic in sidebar order, the preselected pane last in DOM with class `default`;
   - spine nodes from the `{{brief-…}}`, `{{spec-…}}`, `{{design-…}}`, `{{plan-…}}`, `{{execute-…}}` stub families (node class, pill, meta, source path);
   - the drift connector `{{drift-explanation}}` directly after the stale node, naming which artifact is newer, by how much, and the re-alignment action — omit when there is none;
   - the ADR chain from the designs file's ADR sections, newest first — chains exist only via `Predecessor` links plus ledger state, rendered in the ADR vocabulary (accepted / in force / retired; a superseded record stays `superseded`) — omit when the topic has none;
   - each `<slug>/visuals/*.html` embedded inline via iframe with an `open file ↗` fallback, paths relative to the page; prose artifacts are linked from node meta, never re-rendered — omit when none;
   - the execute rollup `{{tasks-done}}`/`{{tasks-total}}`/`{{tasks-pct}}`, task rows `{{task-id}}`/`{{task-title}}`/pill, and the `… {{tasks-remaining}} more` line;
   - the assurance matrix from the topic's `verification/` artifact, one row per gate, keeping the matrix's own state words (executable / planned / blocked, go / go-if / no-go) mapped onto pill classes — omit when the topic has none.

7. **Encode everything artifact-derived.** Entity-encode before inserting:
   `&` → `&amp;` first, then `<` → `&lt;`, `>` → `&gt;`, `"` → `&quot;`.
   Artifact titles are untrusted input — a hostile task title must render as
   inert text. Derived values go in as text, never into `href` or `src`;
   only the template's own relative paths carry attributes.

8. **Write exactly one file: `.sdlc-skills/views/index.html`.** Create
   `views/` if missing. No external URLs, no JavaScript, no server or
   watcher, no scratch or backup files under `.sdlc-skills/` — the trail is
   read-only to you. Regeneration is this same procedure again: recompute
   from the trail and rewrite the same path in place, never reading or
   merging a previous render. The as-of is the current UTC instant; it is
   the page's staleness signal.

9. **Report the path and the as-of.** One short reply: the written path,
   the as-of UTC, and every place the page says unknown or a block was
   omitted for missing state — the user should learn the gaps from you, not
   discover them.

## Common mistakes

- Treating `**Status:** proposed`, or an impressive document, as approval → approval lives only in a matching ledger row; otherwise the page says unknown.
- Counting `[x] done with concerns` as done → only the exact `[x] done` counts; every other label counts separately.
- Pasting artifact prose into nodes or tiles → the page carries state; prose stays behind open-file links.
- Splitting `<slug>-migration.md` or `<slug>/visuals/` into their own topics → thread by slug.
- Flagging drift from a checkbox-only plan update → normalize the execution projection before comparing times.
- Hunting the filesystem when the convention is absent or overridden → render the empty state naming what produces artifacts.
- Linkifying a URL found in artifact text, or adding a script for interactivity → self-containment: no external requests, no JavaScript; navigation is pure CSS.
- Assuming git exists → use the mtime fallback; equal times flag nothing.
