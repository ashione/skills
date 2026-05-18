# Requirements

Status: complete
Phase: requirements
Updated: fixture
Evidence: decision:blocked fixture requirements

## Phase State

### Goal

Show a blocked requirements gate that the validator must reject.

### Checklist

- [x] Goal is explicit.
- [x] Success criteria are verifiable.
- [x] Scope and non-goals are explicit.
- [x] High-impact unknowns are resolved or recorded.
- [x] `superpowers:brainstorming` is used or marked not applicable with evidence.

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|
| G1 | requirements | Goal, success criteria, scope, non-goals, risks, open questions, user decisions, and brainstorming decision are explicit. | blocked | decision:fixture intentionally blocks G1 | |

### Todo List

| Item | Status | Owner | Evidence |
|---|---|---|---|
| Requirements gate | blocked | fixture | decision:G1 blocked |

### Failure List

| Failure | Impact | Root Cause | Resolution | Status |
|---|---|---|---|---|
| G1 blocked fixture | Negative validator example | Intentional blocked gate | Validator should fail | open |

### Change List

| Change | Reason | Files/Links | Approval |
|---|---|---|---|
| Fixture requirements blocked | Negative validator example | file:examples/delivery-runs/blocked/requirements.md | decision:fixture |

## Goal

Validate that blocked gates fail.

## Background

This fixture is committed for CI negative validation.

## Success Criteria

- Validator exits with failure.

## Scope

Delivery Episode Package structure only.

## Non-Goals

No product behavior.

## Risks

None.

## Open Questions

None.

## User Decisions

Fixture uses `superpowers:brainstorming` as not applicable.

## Superpowers Decisions

- Brainstorming: not-applicable, because this is a fixed validation fixture.
