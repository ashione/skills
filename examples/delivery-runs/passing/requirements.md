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
| G1 | requirements | Goal, success criteria, scope, non-goals, risks, open questions, user decisions, uncertainty disposition, Requirements Maturity, and brainstorming decision are explicit. | pass | decision:requirements fixture records all required fields | |

### Hook Ledger

| Hook | Trigger | Required Action | Status | Evidence | Failure Handling |
|---|---|---|---|---|---|
| before_requirements | before G1 completion | [hard] Read user goal, repo instructions, relevant specs/docs, uncertainty disposition, Requirements Maturity, and brainstorming decision. | pass | decision:fixed fixture requirements reviewed | |

### Review Ledger

| Review | Role | Perspective | Challenge | Status | Resolution | Evidence |
|---|---|---|---|---|---|---|
| requirements_product | Product | User intent and acceptance | Are success criteria specific and user-visible? | pass | Fixture success criteria are explicit. | file:examples/delivery-runs/passing/requirements.md |
| requirements_engineering | Engineering | Feasibility and repo constraints | Can the repo support this without hidden assumptions? | pass | Fixture scope is limited to delivery artifact validation. | file:examples/delivery-runs/passing/requirements.md |
| requirements_risk | Risk | Ambiguity and failure modes | Are blocking unknowns resolved or explicitly accepted? | pass | No blocking fixture unknowns remain. | decision:fixture |

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
