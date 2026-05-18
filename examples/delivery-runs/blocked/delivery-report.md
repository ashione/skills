# Delivery Report

Status: complete
Phase: report
Updated: fixture
Evidence: file:examples/delivery-runs/blocked/delivery-report.md

## Phase State

### Goal

Show a report gate while G1 remains blocked.

### Checklist

- [x] Requirements result is summarized.
- [x] Implementation and changed files are summarized.
- [x] Validation, review, and sensitive scan are summarized.
- [x] PR/MR and CI/CD state are summarized.
- [x] Risks and follow-ups are explicit.
- [x] Version or release report notes are recorded when applicable.

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|
| G8 | report | Final delivery report includes requirements, implementation, changed files, validation, review, sensitive scan, PR/MR, CI/CD, risks, follow-ups, and release notes. | pass | file:examples/delivery-runs/blocked/delivery-report.md | |

### Todo List

| Item | Status | Owner | Evidence |
|---|---|---|---|
| Report gate | done | fixture | decision:G8 pass |

### Failure List

| Failure | Impact | Root Cause | Resolution | Status |
|---|---|---|---|---|

### Change List

| Change | Reason | Files/Links | Approval |
|---|---|---|---|
| Fixture report accepted | Negative validator example | file:examples/delivery-runs/blocked/delivery-report.md | decision:fixture |

## Summary

Blocked fixture validates blocked gate rejection.

## Requirements Result

G1 is intentionally blocked.

## Implementation Summary

Fixture files were added.

## Changed Files

- file:examples/delivery-runs/blocked

## Validation Summary

Validator should fail.

## PR/MR and CI/CD

Not applicable for fixture; repository CI validates expected failure.

## Risks and Follow-ups

None.

## Release Notes

No release.
