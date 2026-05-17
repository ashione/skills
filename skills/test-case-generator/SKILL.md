---
name: test-case-generator
description: Use when converting a feature spec, bug risk, acceptance criteria, or behavior change into executable test scenarios with preconditions, expected results, priorities, and regression coverage.
---

# Test Case Generator

## Intent

Convert expected behavior and risk into a focused test matrix that can be implemented manually or automated.

## When to Use

- Feature specs, acceptance criteria, bug fixes, regression risks, QA planning, or release validation.
- Translating vague behavior into concrete positive, negative, boundary, state, permission, and integration cases.
- Do not use to invent requirements that are not implied by the product behavior.

## Inputs

- `feature_spec`: Functional behavior to test.
- `risk_notes`: Known risk or failure patterns.

## Test Scope

Classify the test target before generating cases.

| Scope | Use For | Required Cases | Usually Skip |
|-------|---------|----------------|--------------|
| Pure function | Deterministic inputs/outputs | Happy, boundary, invalid input, type/shape, regression | UI/browser setup |
| Component/UI | Interaction and rendering behavior | Keyboard/mouse/touch, loading/empty/error, responsive, accessibility labels | Backend internals |
| API/contract | Request/response behavior | Auth, validation, idempotency, error schema, compatibility, rate/limit | Pixel-level UI |
| Workflow/E2E | Multi-step user journey | Critical path, recovery path, persistence, permissions, integration failure | Exhaustive permutations |
| Data migration/job | Batch or state transformation | Idempotency, partial failure, rollback, large data, resume/retry | Cosmetic cases |
| Security/permission | Access control or sensitive data | Allowed/denied roles, tenant boundary, audit/logging, data leakage | Non-security edge cases unless adjacent |

## Case Families

Use only the families relevant to the scope.

| Family | Question It Answers |
|--------|---------------------|
| Happy path | Does the primary intended behavior work? |
| Negative | Are invalid inputs rejected safely and clearly? |
| Boundary | What happens at exact limits, off-by-one points, empty/max values, and time edges? |
| State transition | Are allowed and forbidden state changes enforced? |
| Permission | Can only the right actor perform the action or see the data? |
| Idempotency/retry | Is repeating the action safe after timeout or partial failure? |
| Concurrency | What happens when two actors or jobs act at the same time? |
| Persistence | Is state saved, loaded, expired, and cleaned up correctly? |
| Compatibility | Do old clients/data/configs keep working? |
| Accessibility/UI | Can users operate and understand the behavior through supported interfaces? |

## Instructions

1. Classify test scope using `Test Scope`; choose relevant case families from `Case Families`.
2. Extract testable rules from the spec: actors, inputs, outputs, state transitions, permissions, limits, timing, error handling, integrations, and persistence.
3. Identify ambiguity before inventing behavior. Mark unclear cases as `Open Question`.
4. Generate cases across only the relevant families; include a reason when an obvious family is intentionally skipped.
5. For each case, state preconditions, steps or stimulus, expected result, priority, automation level, and why the case matters.
6. Prioritize by user impact and failure likelihood: `P0` release blocker, `P1` core behavior, `P2` important edge, `P3` low-risk coverage.
7. Include data setup and teardown needs when state matters.
8. Keep the set lean. Prefer fewer high-signal tests over exhaustive permutations unless the user asks for a full matrix.

## Output Standard

- Start with `Scope Classification` and selected `Case Families`.
- Use a table with columns: `ID`, `Priority`, `Scenario`, `Preconditions`, `Steps/Input`, `Expected Result`, `Type`, `Automate?`.
- Include at least one regression test for a known or plausible failure mode.
- Include boundary values with exact numbers, times, lengths, or limits when available.
- Do not write vague expected results like "works correctly".
- Do not test implementation details unless the feature spec exposes them as behavior.

## Examples

Input: Password reset token expires in 15 minutes.

Output:

| ID | Priority | Scenario | Preconditions | Steps/Input | Expected Result | Type | Automate? |
|----|----------|----------|---------------|-------------|-----------------|------|-----------|
| PR-1 | P1 | Token works before expiry | Token issued at T0 | Redeem at T0+14m59s | Password reset succeeds once | Boundary | Yes |
| PR-2 | P1 | Token expires after limit | Token issued at T0 | Redeem at T0+15m01s | Reset is rejected with expired-token error | Boundary | Yes |
| PR-3 | P1 | Token cannot be reused | Token already redeemed | Redeem same token again | Reset is rejected and password is unchanged | Regression | Yes |
| PR-4 | P2 | Expiry is timezone-neutral | Server/user time zones differ | Redeem around DST/timezone boundary | Expiry uses server canonical time, not local display time | Timing | Yes |
