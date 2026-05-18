# Artifact Templates Reference

Use these templates as the default shape for persisted Delivery Episode Package files. Add subphase blocks when the phase is large, risky, blocked, or needs an auditable handoff.

## requirements.md template

```md
# Requirements

Status: draft | active | blocked | complete | deferred
Phase: requirements
Updated: <timestamp or phase marker>
Evidence: <user request, repo files, issue links, or reason unavailable>

## Phase State

### Goal

### Checklist

- [ ] Goal is explicit.
- [ ] Success criteria are verifiable.
- [ ] Scope and non-goals are explicit.
- [ ] High-impact unknowns are resolved or recorded.
- [ ] `superpowers:brainstorming` is used or marked not applicable with evidence.

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|
| G1 | requirements | Goal, success criteria, scope, non-goals, risks, open questions, user decisions, and brainstorming decision are explicit. | blocked | <evidence pointer> | <required if exception> |

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

## Superpowers Decisions

- Brainstorming:
```

## plan.md template

```md
# Plan

Status: draft | active | blocked | complete | deferred
Phase: plan
Updated: <timestamp or phase marker>
Evidence: <repo inspection commands, files, issue links, or reason unavailable>

## Phase State

### Goal

### Checklist

- [ ] Affected areas are identified.
- [ ] Specialist skills are selected or rejected with reason.
- [ ] Implementation steps are ordered.
- [ ] Validation strategy covers success criteria.
- [ ] Rollback or mitigation notes are recorded.
- [ ] Dependency Decision is recorded.
- [ ] `superpowers:writing-plans` is used or marked not applicable with evidence.

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|
| G2 | plan | Repo findings, affected areas, specialist skills, Superpowers planning decision, Dependency Decision, implementation steps, validation commands, acceptance criteria, rollback notes, and checkpoints are recorded. | blocked | <evidence pointer> | <required if exception> |

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
| G7 | ci-cd | Terminal CI/CD state or not-applicable reason is recorded. | blocked | <evidence pointer> | <required if exception> |

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
| G8 | report | Final delivery report includes requirements, implementation, changed files, validation, review, sensitive scan, PR/MR, CI/CD, risks, and follow-ups. | blocked | <evidence pointer> | <required if exception> |

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
