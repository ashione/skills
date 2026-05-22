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
- [x] Minimum Skill Dependencies are checked, including required Superpowers decisions.
- [x] `superpowers:brainstorming` is used or marked not applicable with evidence.

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|
| G1 | requirements | Goal, success criteria, scope, non-goals, risks, open questions, user decisions, Minimum Skill Dependencies, uncertainty disposition, Requirements Maturity, and brainstorming decision are explicit. | pass | decision:requirements fixture records all required fields | |

### Hook Ledger

| Hook | Trigger | Required Action | Status | Evidence | Failure Handling |
|---|---|---|---|---|---|
| before_requirements | before G1 completion | [hard] Read user goal, repo instructions, relevant specs/docs, Minimum Skill Dependencies, uncertainty disposition, Requirements Maturity, and brainstorming decision. | pass | decision:fixed fixture requirements reviewed | |

### Review Ledger

| Review | Role | Perspective | Challenge | Status | Resolution | Evidence |
|---|---|---|---|---|---|---|
| requirements_product | Product | User intent and acceptance | Are success criteria specific and user-visible? | pass | Fixture success criteria are explicit. | file:examples/delivery-runs/exception/requirements.md |
| requirements_engineering | Engineering | Feasibility and repo constraints | Can the repo support this without hidden assumptions? | pass | Fixture scope is limited to delivery artifact validation. | file:examples/delivery-runs/exception/requirements.md |
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
