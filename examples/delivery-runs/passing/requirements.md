# Requirements

Status: complete
Phase: requirements
Updated: fixture
Evidence: decision:example fixture for a passing delivery run

## Phase State

### Goal

Show a fully satisfied requirements gate.

### Checklist

- [x] Goal is explicit.
- [x] Success criteria are verifiable.
- [x] Scope and non-goals are explicit.
- [x] High-impact unknowns are resolved or recorded.
- [x] `superpowers:brainstorming` is used or marked not applicable with evidence.

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|
| G1 | requirements | Goal, success criteria, scope, non-goals, risks, open questions, user decisions, and brainstorming decision are explicit. | pass | decision:requirements fixture records all required fields | |

### Todo List

| Item | Status | Owner | Evidence |
|---|---|---|---|
| Requirements gate | done | fixture | decision:G1 pass |

### Failure List

| Failure | Impact | Root Cause | Resolution | Status |
|---|---|---|---|---|

### Change List

| Change | Reason | Files/Links | Approval |
|---|---|---|---|
| Fixture requirements accepted | Positive validator example | file:examples/delivery-runs/passing/requirements.md | decision:fixture |

## Goal

Validate the delivery-run gate contract.

## Background

This fixture is committed for CI validation.

## Success Criteria

- Validator exits successfully.

## Scope

Delivery Episode Package structure only.

## Non-Goals

No product behavior.

## Risks

No runtime risk.

## Open Questions

None.

## User Decisions

Fixture uses `superpowers:brainstorming` as not applicable.

## Superpowers Decisions

- Brainstorming: not-applicable, because this is a fixed validation fixture.
