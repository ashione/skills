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
- [x] Issue context and prior attempts are recorded or marked not applicable with evidence.
- [x] Minimum Skill Dependencies are checked, including required Superpowers decisions.
- [x] `superpowers:brainstorming` is used or marked not applicable with evidence.

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|
| G1 | requirements | Goal, success criteria, scope, non-goals, risks, open questions, user decisions, Issue and Prior Attempts, Minimum Skill Dependencies, uncertainty disposition, Requirements Maturity, and brainstorming decision are explicit. | blocked | decision:fixture intentionally blocks G1 | |

### Hook Ledger

| Hook | Trigger | Required Action | Status | Evidence | Failure Handling |
|---|---|---|---|---|---|
| before_requirements | before G1 completion | [hard] Read user goal, repo instructions, relevant specs/docs, issue context, prior PR or attempt search, Minimum Skill Dependencies, uncertainty disposition, Requirements Maturity, and brainstorming decision. | pass | decision:fixed fixture requirements reviewed | |

### Review Ledger

| Review | Role | Perspective | Challenge | Status | Resolution | Evidence |
|---|---|---|---|---|---|---|
| requirements_product | Product | User intent and acceptance | Are success criteria specific and user-visible? | pass | Fixture success criteria are explicit. | file:examples/delivery-runs/blocked/requirements.md |
| requirements_engineering | Engineering | Feasibility and repo constraints | Can the repo support this without hidden assumptions? | pass | Fixture scope is limited to delivery artifact validation. | file:examples/delivery-runs/blocked/requirements.md |
| requirements_risk | Risk | Ambiguity and failure modes | Are blocking unknowns resolved or explicitly accepted? | pass | No blocking fixture unknowns remain. | decision:fixture |

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

## Issue and Prior Attempts

- Prior Attempt Search: not-applicable, because this fixture is not issue-driven.
- Prior Attempt Evidence: reason:fixture has no linked issue, PR, fork, commit, or previous fix.

| Source | Finding | Difference or Reuse Decision | Evidence |
|---|---|---|---|
| Fixture scope | No prior attempt applies | Continue with declarative validator fixture | reason:fixture is not issue-driven |

## Minimum Skill Dependencies

| Skill | Minimum Requirement | Dependency Class | Evidence | Fallback |
|---|---|---|---|---|
| mobius-harness | Primary delivery loop and artifact contract. | no-new-dependency | file:skills/mobius-harness/SKILL.md | blocked until available |
| local-repo-development | Repo topology, instruction discovery, validation, commit, and PR workflow. | no-new-dependency | file:skills/local-repo-development/SKILL.md | record equivalent local workflow or exception |
| superpowers:brainstorming | Requirements-phase design support when applicable. | no-new-dependency | reason:platform-provided skill dependency checked at runtime | not-applicable only with fixed requirements; otherwise blocked or exception |
| superpowers:writing-plans | Plan-phase support for Standard or Strict delivery and multi-step work. | no-new-dependency | reason:platform-provided skill dependency checked at runtime | not-applicable only for trivial plans; otherwise blocked or exception |

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
