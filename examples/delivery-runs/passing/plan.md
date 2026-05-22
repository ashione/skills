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
- [x] Prior attempts are compared against the selected approach or marked not applicable with evidence.
- [x] Validation strategy covers success criteria.
- [x] Validation prerequisites are recorded before validation commands.
- [x] Rollback or mitigation notes are recorded.
- [x] Dependency Decision is recorded.
- [x] `superpowers:writing-plans` is used or marked not applicable with evidence.

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|
| G2 | plan | Repo findings, prior attempt comparison, design options, selected approach, rejected alternatives, affected areas, specialist skills, Minimum Skill Dependencies, Superpowers planning decision, Dependency Decision, implementation steps, validation commands, Validation Prerequisites, acceptance criteria, Design Readiness, rollback notes, and checkpoints are recorded. | pass | file:examples/delivery-runs/passing/plan.md | |

### Hook Ledger

| Hook | Trigger | Required Action | Status | Evidence | Failure Handling |
|---|---|---|---|---|---|
| before_plan | before G2 completion | [hard] Record skill activation, Minimum Skill Dependencies, tool reality, prior attempt comparison, design options, selected approach, rejected alternatives, Dependency Decision, validation strategy, Validation Prerequisites, Design Readiness, and writing-plans decision. | pass | file:examples/delivery-runs/passing/plan.md | |

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

## Prior Attempt Comparison

- Prior Attempt Disposition: not-applicable, because requirements found no issue-driven prior attempt.
- Freshness Evidence: reason:fixture has no time-sensitive external API, package, or platform behavior.

| Attempt | Useful Elements | Differences from Selected Approach | Action |
|---|---|---|---|
| Fixture scope | None | No prior attempt applies to a committed validator fixture | Continue with fixture validation |

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

## Validation Prerequisites

| Prerequisite | Applies To | Evidence | Fallback |
|---|---|---|---|
| Repository setup or generated artifacts | Validator fixture commands | reason:none required for committed fixture | record failed command, run the prerequisite, and rerun the validation command |

## Acceptance Criteria

Validator exits successfully.

## Rollback Notes

Remove the fixture files.

## Checkpoints

- Validator pass.
