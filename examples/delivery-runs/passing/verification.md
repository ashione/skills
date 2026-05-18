# Verification

Status: complete
Phase: verification
Updated: fixture
Evidence: cmd:bash scripts/validate-delivery-run.sh examples/delivery-runs/passing

## Phase State

### Goal

Show satisfied local-development, implementation, verification, PR/MR, and CI/CD gates.

### Checklist

- [x] Worktree or branch and base ref are recorded.
- [x] Changed files are intentional and mapped to acceptance criteria.
- [x] Local validation commands are run or marked unavailable with reason.
- [x] Diff review is complete.
- [x] Sensitive information scan is complete.
- [x] PR/MR state is recorded or marked not applicable.
- [x] CI/CD terminal state is recorded or marked not applicable.

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|
| G3 | local-development | Worktree or branch, base ref, and dirty-state handling are recorded. | pass | reason:fixture has no live worktree state | |
| G4 | implementation | Changed files are intentional and mapped to acceptance criteria. | pass | file:examples/delivery-runs/passing/verification.md | |
| G5 | verification | Local commands, command results, diff review, sensitive information scan, and unresolved risks are recorded. | pass | cmd:bash scripts/validate-delivery-run.sh examples/delivery-runs/passing | |
| G6 | pr-mr | PR/MR URL or not-applicable reason is recorded. | not-applicable | reason:fixture is not a real PR delivery | |
| G7 | ci-cd | Terminal CI/CD state or not-applicable reason is recorded. | not-applicable | reason:fixture is validated by repository CI when committed | |

### Hook Ledger

| Hook | Trigger | Required Action | Status | Evidence | Failure Handling |
|---|---|---|---|---|---|
| before_edit | before editing files | Confirm Requirements Maturity and Design Readiness, repo/worktree state, dirty-state handling, affected paths, and preservation of unrelated changes. | pass | reason:fixture has no live worktree state | |
| after_edit | after editing files | Map changed files to acceptance criteria and check for unintended churn. | pass | file:examples/delivery-runs/passing/verification.md | |
| before_commit | before commit or PR/MR preparation | Run or record local validation, diff review, and sensitive information scan. | pass | cmd:bash scripts/validate-delivery-run.sh examples/delivery-runs/passing | |
| before_pr | before PR/MR creation or not-applicable decision | Record commit/head state, PR/MR body readiness, review status, and reason when no PR/MR is created. | not-applicable | reason:fixture is not a real PR delivery | |
| after_pr | after PR/MR creation or not-applicable decision | Record PR/MR URL or not-applicable reason, CI/CD observation plan, terminal check state, and failure follow-up. | not-applicable | reason:fixture is validated by repository CI when committed | |

### Todo List

| Item | Status | Owner | Evidence |
|---|---|---|---|
| Verification gate | done | fixture | cmd:validator |

### Failure List

| Failure | Impact | Root Cause | Resolution | Status |
|---|---|---|---|---|

### Change List

| Change | Reason | Files/Links | Approval |
|---|---|---|---|
| Fixture verification accepted | Positive validator example | file:examples/delivery-runs/passing/verification.md | decision:fixture |

## Local Commands

| Command | Result | Evidence |
|---|---|---|
| `bash scripts/validate-delivery-run.sh examples/delivery-runs/passing` | pass | cmd:validator |

## Command Results

Validator succeeds.

## Diff Review

### Requirements Compliance

Fixture maps to G1-G8.

### Implementation Quality

Markdown is minimal and explicit.

### Test Adequacy

Positive fixture covers passing gates.

### Security and Sensitive Information

No sensitive values.

## Sensitive Information Scan

Not applicable for fixture content.

## PR/MR

Not applicable.

## CI/CD

Validated by repository CI.

## Unresolved Risks

None.
