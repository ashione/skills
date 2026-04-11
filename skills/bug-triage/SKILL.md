# Bug Triage

## Intent

Classify bugs by severity, impact, and reproducibility, then propose next actions.

## Inputs

- `bug_report`: Bug report with observed symptoms.
- `system_context`: Runtime, version, and dependency context.

## Instructions

1. Extract observed behavior, expected behavior, and scope.
2. Assign severity and confidence level.
3. List likely root-cause areas in priority order.
4. Provide a minimal reproducible test plan.

## Examples

Input: App crashes when opening empty workspace.

Output: Severity: High; suspected null workspace metadata path; add guard for empty project index and regression test.
