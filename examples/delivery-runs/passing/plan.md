# Plan

Status: complete
Phase: plan
Updated: fixture
Evidence: file:examples/delivery-runs/passing/plan.md

## Phase State

### Goal

Show a fully satisfied plan gate.

### Checklist

- [x] Affected areas are identified.
- [x] Specialist skills are selected or rejected with reason.
- [x] Minimum Skill Dependencies are checked and carried forward from requirements.
- [x] Implementation steps are ordered.
- [x] Validation strategy covers success criteria.
- [x] Rollback or mitigation notes are recorded.
- [x] Dependency Decision is recorded.
- [x] `superpowers:writing-plans` is used or marked not applicable with evidence.

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|
| G2 | plan | Repo findings, design options, selected approach, rejected alternatives, affected areas, specialist skills, Minimum Skill Dependencies, Superpowers planning decision, Dependency Decision, implementation steps, validation commands, acceptance criteria, Design Readiness, rollback notes, and checkpoints are recorded. | pass | file:examples/delivery-runs/passing/plan.md | |

### Hook Ledger

| Hook | Trigger | Required Action | Status | Evidence | Failure Handling |
|---|---|---|---|---|---|
| before_plan | before G2 completion | [hard] Record skill activation, Minimum Skill Dependencies, tool reality, design options, selected approach, rejected alternatives, Dependency Decision, validation strategy, Design Readiness, and writing-plans decision. | pass | file:examples/delivery-runs/passing/plan.md | |

### Review Ledger

| Review | Role | Perspective | Challenge | Status | Resolution | Evidence |
|---|---|---|---|---|---|---|
| plan_architecture | Architecture | Boundaries and alternatives | Is the selected approach justified against alternatives? | pass | Declarative fixture is selected over irrelevant product implementation. | file:examples/delivery-runs/passing/plan.md |
| plan_validation | Validation | Acceptance and tests | Does validation prove every acceptance criterion? | pass | Validator command maps to fixture acceptance criteria. | cmd:bash scripts/validate-delivery-run.sh examples/delivery-runs/passing |
| plan_risk | Risk | Rollback and dependency impact | Are rollback, dependency, and migration risks explicit? | pass | No new dependency and rollback are recorded. | file:examples/delivery-runs/passing/plan.md |

### Todo List

| Item | Status | Owner | Evidence |
|---|---|---|---|
| Plan gate | done | fixture | decision:G2 pass |

### Failure List

| Failure | Impact | Root Cause | Resolution | Status |
|---|---|---|---|---|

### Change List

| Change | Reason | Files/Links | Approval |
|---|---|---|---|
| Fixture plan accepted | Positive validator example | file:examples/delivery-runs/passing/plan.md | decision:fixture |

## Repo Findings

Fixture uses committed example files.

## Specialist Skills

- `mobius-harness`: primary delivery loop.

## Minimum Skill Dependencies

| Skill | Minimum Requirement | Dependency Class | Evidence | Fallback |
|---|---|---|---|---|
| mobius-harness | Primary delivery loop and artifact contract. | no-new-dependency | file:skills/mobius-harness/SKILL.md | blocked until available |
| local-repo-development | Repo topology, instruction discovery, validation, commit, and PR workflow. | no-new-dependency | file:skills/local-repo-development/SKILL.md | record equivalent local workflow or exception |
| superpowers:brainstorming | Requirements-phase design support when applicable. | no-new-dependency | reason:platform-provided skill dependency checked at runtime | not-applicable only with fixed requirements; otherwise blocked or exception |
| superpowers:writing-plans | Plan-phase support for Standard or Strict delivery and multi-step work. | no-new-dependency | reason:platform-provided skill dependency checked at runtime | not-applicable only for trivial plans; otherwise blocked or exception |

## Superpowers Decisions

- Brainstorming: not-applicable, fixed fixture.
- Writing Plans: not-applicable, fixed fixture.

## Design Options

| Option | Tradeoff | Decision | Evidence |
|---|---|---|---|
| Declarative delivery fixture | Exercises harness artifact validation without product code | selected | file:examples/delivery-runs/passing/plan.md |
| Product implementation | Would add irrelevant behavior to a validator fixture | rejected | reason:no product behavior is in scope |

## Design Readiness

- Readiness: `ready-for-implementation`
- Selected Approach: declarative fixture plus shell validator coverage
- Rejected Alternatives: reason:product implementation is outside fixture scope
- Acceptance Mapping: decision:G1-G8 and required hooks map to validator assertions
- Start Gate: decision:requirements maturity and design readiness are satisfied for fixture

## Dependency Decision

- Decision: `no-new-dependency`
- Reason: fixture uses Markdown and shell validation only.
- Evidence: file:examples/delivery-runs/passing/plan.md
- Fallback: reason:if validator is unavailable, record a gate exception.

## Implementation Steps

1. Commit fixture artifacts.
2. Run validator.

## Validation Strategy

Run `bash scripts/validate-delivery-run.sh examples/delivery-runs/passing`.

## Acceptance Criteria

Validator exits successfully.

## Rollback Notes

Remove the fixture files.

## Checkpoints

- Validator pass.
