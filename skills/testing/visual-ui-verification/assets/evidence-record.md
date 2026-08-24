# Visual evidence record

Keep this record outside the candidate identity. Fill one run header and one row
per required observation; use stable `{{double-curly}}` values.

## Run

- **Run ID / time:** `{{stable attempt identity and UTC interval}}`
- **Candidate:** `{{immutable source/artifact identity, or working-tree digest
  covering staged, unstaged, untracked, and relevant ignored inputs}}`
- **Launch path:** `{{command or controlled action}}`
- **Acceptance source:** `{{requirements, UI state IDs, rubric identity}}`
- **Selected visual references:** `{{keyed collection applicable to this
  candidate, copied field for field from the approved design and, when
  plan-bound, the approved plan; or not applicable}}`

| Reference ID | Decision ID | Medium | Approved design artifact version | Artifact locator | Artifact version | Content digest | Selection ID | Rendering-input identity | Freshness evaluator | Normative conditions | Distinguishing invariants |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `{{VR-001}}` | `{{D-001}}` | `{{medium}}` | `{{design version}}` | `{{stable path, route, or artifact ID}}` | `{{immutable version, revision, or capture ID}}` | `{{selected content digest}}` | `{{stable selection ID}}` | `{{immutable rendering-input identity}}` | `{{exact freshness check}}` | `{{normative states/viewports/themes/fixtures/captures}}` | `{{observable distinguishing traits}}` |

- **Freshness evidence:** `{{one current pass / mismatch / unavailable-error
  evaluator receipt per applicable Reference ID, or pending recovery route}}`
- **Plan binding:** `{{not plan-bound, or approved plan/task identity plus each
  Reference ID → conformance evaluator ID mapping}}`
- **Environment:** `{{platform, build mode, runtime, display or terminal}}`
- **Capture tool:** `{{tool, version, configuration, digest}}`
- **Observer / authority:** `{{who inspects; mechanical or human-owned criteria;
  accountable human set and conflict rule when human-owned}}`
- **Data / effects:** `{{authorized environment, data, actions, recovery}}`
- **Evidence controls:** `{{external location, access, integrity, retention,
  exact cleanup targets and authority}}`
- **Invalidation:** `{{candidate, input, environment, rubric, or tool changes}}`

## Scenario matrix

| Row | Journey/state | Size | Theme/input/platform | Raw capture + digest | Rendered frame + digest | Observation | Defects | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `{{VQA-01}}` | `{{...}}` | `{{...}}` | `{{...}}` | `{{path + digest}}` | `{{path + digest}}` | `{{what was inspected}}` | `{{IDs or none}}` | `pass / fail / pending` |

- **Capture attempts:** `{{one accepted receipt per required row; every retry,
  duplicate, late result, or superseded frame with digest and disposition}}`

## Calibration

- **Frozen rubric / observer:** `{{identity}}`
- **Known-bad method:** `{{reversible fault or fixture outside candidate}}`
- **Expected and observed red:** `{{frame identity and detected defect}}`
- **Restoration:** `{{action, receipt, and unaffected candidate identity}}`

## Defects

| ID | Severity | Requirement | Row/frame | Reproduction and impact | Disposition | Re-shot |
| --- | --- | --- | --- | --- | --- | --- |
| `{{VQA-D01}}` | `{{blocking / major / minor}}` | `{{...}}` | `{{...}}` | `{{...}}` | `{{open / fixed / accepted by owner}}` | `{{new row/frame identity or pending}}` |

## Verdict

- **Required rows reconciled:** `{{yes / no, counts}}`
- **Probe caught and restored:** `{{receipt}}`
- **Blocking defects:** `{{none or IDs}}`
- **Human-owned receipts:** `{{trusted user-origin receipts, or not applicable;
  each binds candidate, environment, row, observation, and time}}`
- **Verdict:** `{{pass / fail / pending}}`
- **Release handoff:** `{{source/working-tree acceptance evidence only, or exact
  immutable release artifact/set identity and fresh visual verdict}}`
- **Gate wiring:** `{{verification matrix row, cadence, protected promotion}}`
