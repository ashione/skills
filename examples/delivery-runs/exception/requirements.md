# Requirements

Status: complete
Phase: requirements
Updated: fixture
Evidence: decision:exception fixture requirements

## Phase State

### Goal

Show a complete requirements gate for an exception fixture.

### Checklist

- [x] Goal is explicit.
- [x] Success criteria are verifiable.
- [x] Scope and non-goals are explicit.
- [x] High-impact unknowns are resolved or recorded.
- [x] `superpowers:brainstorming` is used or marked not applicable with evidence.

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|
| G1 | requirements | Goal, success criteria, scope, non-goals, risks, open questions, user decisions, uncertainty disposition, Requirements Maturity, and brainstorming decision are explicit. | pass | decision:requirements fixture records all required fields | |

### Hook Ledger

| Hook | Trigger | Required Action | Status | Evidence | Failure Handling |
|---|---|---|---|---|---|
| before_requirements | before G1 completion | Read user goal, repo instructions, relevant specs/docs, uncertainty disposition, Requirements Maturity, and brainstorming decision. | pass | decision:fixed fixture requirements reviewed | |

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
| Fixture requirements accepted | Exception validator example | file:examples/delivery-runs/exception/requirements.md | decision:fixture |

## Goal

Validate accepted exception records.

## Background

This fixture is committed for CI validation.

## Success Criteria

- Validator exits successfully.

## Scope

Delivery Episode Package structure only.

## Non-Goals

No product behavior.

## Risks

Accepted exception appears in verification.

## Open Questions

None.

## User Decisions

Fixture uses `superpowers:brainstorming` as not applicable.

## Uncertainty Register

| Unknown | Impact | Disposition | Evidence |
|---|---|---|---|
| Fixture ambiguity | None for committed validator fixture | not-applicable | decision:fixed fixture |

## Requirements Maturity

- Maturity: `ready-for-design`
- Blocking Unknowns: none
- Maturity Evidence: decision:fixture requirements are fully specified

## Superpowers Decisions

- Brainstorming: not-applicable, because this is a fixed validation fixture.
