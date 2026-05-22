# Artifact Templates Reference

Use these templates as the default shape for persisted Delivery Episode Package files. Add subphase blocks when the phase is large, risky, blocked, or needs an auditable handoff.

## requirements.md template

```md
# Requirements

Status: draft | active | blocked | complete | deferred
Phase: requirements
Updated: <timestamp or phase marker>
Runtime: codex | claude-code | generic
Evidence: <user request, repo files, issue links, or reason unavailable>

## Phase State

### Goal

### Checklist

- [ ] Goal is explicit.
- [ ] Success criteria are verifiable.
- [ ] Scope and non-goals are explicit.
- [ ] High-impact unknowns are resolved or recorded.
- [ ] Blocking unknowns are resolved or explicitly accepted.
- [ ] Requirements Maturity is `ready-for-design` or explicitly excepted.
- [ ] `superpowers:brainstorming` is used or marked not applicable with evidence.

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|
| G1 | requirements | Goal, success criteria, scope, non-goals, risks, open questions, user decisions, uncertainty disposition, Requirements Maturity, and brainstorming decision are explicit. | blocked | <evidence pointer> | <required if exception> |

### Hook Ledger

| Hook | Trigger | Required Action | Status | Evidence | Failure Handling |
|---|---|---|---|---|---|
| before_requirements | before G1 completion | [soft] <runtime> hook: Read user goal, repo instructions, relevant specs/docs, uncertainty disposition, Requirements Maturity, and brainstorming decision; record runtime-specific evidence. | blocked | <evidence pointer> | <required if exception> |

### Review Ledger

| Review | Role | Perspective | Challenge | Status | Resolution | Evidence |
|---|---|---|---|---|---|---|
| requirements_product | Product | User intent and acceptance | Are success criteria specific and user-visible? | blocked | <resolution> | <evidence pointer> |
| requirements_engineering | Engineering | Feasibility and repo constraints | Can the repo support this without hidden assumptions? | blocked | <resolution> | <evidence pointer> |
| requirements_risk | Risk | Ambiguity and failure modes | Are blocking unknowns resolved or explicitly accepted? | blocked | <resolution> | <evidence pointer> |

### Todo List

| Item | Status | Owner | Evidence |
|---|---|---|---|

### Failure List

| Failure | Impact | Root Cause | Resolution | Status |
|---|---|---|---|---|

### Change List

| Change | Reason | Files/Links | Approval |
|---|---|---|---|

## Goal

## Background

## Success Criteria

## Scope

## Non-Goals

## Risks

## Open Questions

## User Decisions

## Uncertainty Register

| Unknown | Impact | Disposition | Evidence |
|---|---|---|---|

## Requirements Maturity

- Maturity: `ready-for-design` | `accepted-risk`
- Blocking Unknowns:
- Maturity Evidence:

## Superpowers Decisions

- Brainstorming:
```

## plan.md template

```md
# Plan

Status: draft | active | blocked | complete | deferred
Phase: plan
Updated: <timestamp or phase marker>
Runtime: codex | claude-code | generic
Evidence: <repo inspection commands, files, issue links, or reason unavailable>

## Phase State

### Goal

### Checklist

- [ ] Affected areas are identified.
- [ ] Specialist skills are selected or rejected with reason.
- [ ] Implementation steps are ordered.
- [ ] Design options and rejected alternatives are recorded.
- [ ] Design Readiness is `ready-for-implementation` or explicitly excepted.
- [ ] Validation strategy covers success criteria.
- [ ] Rollback or mitigation notes are recorded.
- [ ] Dependency Decision is recorded.
- [ ] `superpowers:writing-plans` is used or marked not applicable with evidence.

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|
| G2 | plan | Repo findings, design options, selected approach, rejected alternatives, affected areas, specialist skills, Superpowers planning decision, Dependency Decision, implementation steps, validation commands, acceptance criteria, Design Readiness, rollback notes, and checkpoints are recorded. | blocked | <evidence pointer> | <required if exception> |

### Hook Ledger

| Hook | Trigger | Required Action | Status | Evidence | Failure Handling |
|---|---|---|---|---|---|
| before_plan | before G2 completion | [soft] <runtime> hook: Record skill activation, tool reality, design options, selected approach, rejected alternatives, Dependency Decision, validation strategy, Design Readiness, and writing-plans decision; record runtime-specific evidence. | blocked | <evidence pointer> | <required if exception> |

### Review Ledger

| Review | Role | Perspective | Challenge | Status | Resolution | Evidence |
|---|---|---|---|---|---|---|
| plan_architecture | Architecture | Boundaries and alternatives | Is the selected approach justified against alternatives? | blocked | <resolution> | <evidence pointer> |
| plan_validation | Validation | Acceptance and tests | Does validation prove every acceptance criterion? | blocked | <resolution> | <evidence pointer> |
| plan_risk | Risk | Rollback and dependency impact | Are rollback, dependency, and migration risks explicit? | blocked | <resolution> | <evidence pointer> |

### Todo List

| Item | Status | Owner | Evidence |
|---|---|---|---|

### Failure List

| Failure | Impact | Root Cause | Resolution | Status |
|---|---|---|---|---|

### Change List

| Change | Reason | Files/Links | Approval |
|---|---|---|---|

## Repo Findings

## Specialist Skills

## Superpowers Decisions

- Brainstorming:
- Writing Plans:

## Design Options

| Option | Tradeoff | Decision | Evidence |
|---|---|---|---|

## Design Readiness

- Readiness: `ready-for-implementation` | `accepted-risk`
- Selected Approach:
- Rejected Alternatives:
- Acceptance Mapping:
- Start Gate:

## Dependency Decision

- Decision: `no-new-dependency` | `existing-toolchain` | `new-dependency-required`
- Reason:
- Evidence:
- Fallback:

## Implementation Steps

## Validation Strategy

## Acceptance Criteria

## Rollback Notes

## Checkpoints
```

## verification.md template

```md
# Verification

Status: draft | active | blocked | complete | deferred
Phase: verification
Updated: <timestamp or phase marker>
Runtime: codex | claude-code | generic
Evidence: <commands, diff, scanner output summary, PR/MR links, CI/CD links, or reason unavailable>

## Phase State

### Goal

### Checklist

- [ ] Worktree or branch and base ref are recorded.
- [ ] Changed files are intentional and mapped to acceptance criteria.
- [ ] Local validation commands are run or marked unavailable with reason.
- [ ] Diff review is complete.
- [ ] Sensitive information scan is complete.
- [ ] PR/MR state is recorded or marked not applicable.
- [ ] CI/CD terminal state is recorded or marked not applicable.

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|
| G3 | local-development | Worktree or branch, base ref, and dirty-state handling are recorded. | blocked | <evidence pointer> | <required if exception> |
| G4 | implementation | Changed files are intentional and mapped to acceptance criteria. | blocked | <evidence pointer> | <required if exception> |
| G5 | verification | Local commands, command results, diff review, sensitive information scan, and unresolved risks are recorded. | blocked | <evidence pointer> | <required if exception> |
| G6 | pr-mr | PR/MR URL or not-applicable reason is recorded. | blocked | <evidence pointer> | <required if exception> |
| G7 | ci-cd | Terminal CI/CD state, async observation state, or not-applicable reason is recorded. | blocked | <evidence pointer> | <required if exception> |

### Hook Ledger

| Hook | Trigger | Required Action | Status | Evidence | Failure Handling |
|---|---|---|---|---|---|
| before_edit | before editing files | [soft] <runtime> hook: Confirm Requirements Maturity and Design Readiness, repo/worktree state, dirty-state handling, affected paths, and preservation of unrelated changes; record runtime-specific evidence. | blocked | <evidence pointer> | <required if exception> |
| after_edit | after editing files | [soft] <runtime> hook: Map changed files to acceptance criteria and check for unintended churn; record runtime-specific evidence. | blocked | <evidence pointer> | <required if exception> |
| before_commit | before commit or PR/MR preparation | [soft] <runtime> hook: Run or record local validation, diff review, and sensitive information scan; record runtime-specific evidence. | blocked | <evidence pointer> | <required if exception> |
| before_pr | before PR/MR creation or not-applicable decision | [soft] <runtime> hook: Record commit/head state, PR/MR body readiness, review status, and reason when no PR/MR is created; record runtime-specific evidence. | blocked | <evidence pointer> | <required if exception> |
| after_pr | after PR/MR creation or not-applicable decision | [soft] <runtime> hook: Record PR/MR URL or not-applicable reason, CI/CD observation plan, terminal check state, and failure follow-up; record runtime-specific evidence. | blocked | <evidence pointer> | <required if exception or warn> |

### Review Ledger

| Review | Role | Perspective | Challenge | Status | Resolution | Evidence |
|---|---|---|---|---|---|---|
| verification_implementation | Implementation | Diff and requirements fit | Do changed files map cleanly to accepted requirements? | blocked | <resolution> | <evidence pointer> |
| verification_security | Security | Secrets and unsafe behavior | Were sensitive data and unsafe operations checked? | blocked | <resolution> | <evidence pointer> |
| verification_ci | CI/CD | Remote checks and async policy | Is CI/CD state recorded without unsupported pass claims? | blocked | <resolution> | <evidence pointer> |

### Todo List

| Item | Status | Owner | Evidence |
|---|---|---|---|

### Failure List

| Failure | Impact | Root Cause | Resolution | Status |
|---|---|---|---|---|

### Change List

| Change | Reason | Files/Links | Approval |
|---|---|---|---|

## Local Commands

| Command | Result | Evidence |
|---|---|---|

## Command Results

## Diff Review

### Requirements Compliance

### Implementation Quality

### Test Adequacy

### Security and Sensitive Information

## Sensitive Information Scan

## PR/MR

## CI/CD

## Unresolved Risks
```

## delivery-report.md template

```md
# Delivery Report

Status: draft | active | blocked | complete | deferred
Phase: report
Updated: <timestamp or phase marker>
Runtime: codex | claude-code | generic
Evidence: <artifact links, commands, PR/MR links, CI/CD links, or reason unavailable>

## Phase State

### Goal

### Checklist

- [ ] Requirements result is summarized.
- [ ] Implementation and changed files are summarized.
- [ ] Validation, review, and sensitive scan are summarized.
- [ ] PR/MR and CI/CD state are summarized.
- [ ] Risks and follow-ups are explicit.
- [ ] Version or release report notes are recorded when applicable.

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|
| G8 | report | Final delivery report includes requirements, implementation, changed files, validation, review, sensitive scan, PR/MR, CI/CD, risks, follow-ups, and version or release report notes. | blocked | <evidence pointer> | <required if exception> |

### Hook Ledger

| Hook | Trigger | Required Action | Status | Evidence | Failure Handling |
|---|---|---|---|---|---|
| before_final | before final delivery report | [soft] <runtime> hook: Re-check evidence before claims, merge state, cleanup state, local runtime sync when applicable, risks, follow-ups, and release/version report; record runtime-specific evidence. | blocked | <evidence pointer> | <required if exception> |

### Review Ledger

| Review | Role | Perspective | Challenge | Status | Resolution | Evidence |
|---|---|---|---|---|---|---|
| report_delivery | Delivery | User-facing result | Does the report answer what changed and what remains? | blocked | <resolution> | <evidence pointer> |
| report_operations | Operations | CI/CD, cleanup, and release | Are async CI, cleanup, and release/version notes explicit? | blocked | <resolution> | <evidence pointer> |
| report_user | User Advocate | Clarity and unsupported claims | Are claims backed by evidence and easy to act on? | blocked | <resolution> | <evidence pointer> |

### Todo List

| Item | Status | Owner | Evidence |
|---|---|---|---|

### Failure List

| Failure | Impact | Root Cause | Resolution | Status |
|---|---|---|---|---|

### Change List

| Change | Reason | Files/Links | Approval |
|---|---|---|---|

## Summary

## Requirements Result

## Implementation Summary

## Changed Files

## Validation Summary

## PR/MR and CI/CD

## Risks and Follow-ups

## Release Notes

## Version or Release Report
```
