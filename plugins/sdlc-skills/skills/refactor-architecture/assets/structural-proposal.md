Fill this in before presenting a structural change. Its identity covers the
content below and nothing else: the approval outcome, slice progress, and any
execution receipts stay outside it, so recording progress never rewrites the
proposal.

```markdown
# Structural proposal {{proposal-id}}

- **Input identity:** {{the exact source revision, contracts, and external inputs
  the friction was measured against}}
- **Predecessor:** {{prior proposal id, or none — drift needs an approved
  successor, and invalidates the slices it touches}}
- **Approver rule:** {{one accountable approver, OR the required approvers and
  how a disagreement resolves}}
- **External decision ledger:** {{where the approve / request changes / reject /
  cancel outcome is recorded}}

## Now

{{current structure, and the friction actually measured — which change bounced
across which files, how often}}

## Proposed

{{target structure, in terms of depth and locality}}

## Alternatives considered

| Structure | Depth | Locality | Behavior | Performance | Compatibility | Churn | Recovery |
| --- | --- | --- | --- | --- | --- | --- | --- |
| {{proposed}} | {{how much behavior sits behind how small an interface}} | {{does a change land in one place}} | {{preserved / changed}} | {{effect}} | {{effect}} | {{files touched}} | {{how it is undone}} |
| {{alternative}} | | | | | | | |
| Leave it as it is | | | | | | | |

Why the alternatives lose: {{the reason, not the preference}}

## Removals

| Surface removed | Why it is provably redundant | Invariant it carried | Where that invariant now lives |
| --- | --- | --- | --- |
| {{module, interface, or file}} | {{evidence of absence across every consumer path}} | {{what it guaranteed}} | {{the surviving gate, and how that gate was falsified}} |

## Slices

Each slice is independently reviewable, independently revertible, and leaves the
tree green.

| ID | Change | Depends on | Effects beyond the code | Gate it must pass | Rollback |
| --- | --- | --- | --- | --- | --- |
| {{S1}} | {{one structural move}} | {{slice ids}} | {{data, config, deploy, or consumer effects}} | {{the bound gate plus the project gate}} | {{how this slice alone is undone}} |

## Rollback for the whole change

{{what returns the system to the known-green state, and until when that stays
recoverable}}
```
