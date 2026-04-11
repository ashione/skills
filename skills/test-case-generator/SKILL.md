# Test Case Generator

## Intent

Generate practical test cases with edge conditions and expected outcomes.

## Inputs

- `feature_spec`: Functional behavior to test.
- `risk_notes`: Known risk or failure patterns.

## Instructions

1. Create positive, negative, and boundary test scenarios.
2. State clear preconditions and expected results.
3. Prioritize by risk and user impact.
4. Include at least one regression test suggestion.

## Examples

Input: Password reset token expires in 15 minutes.

Output: Add tests for valid token at 14m59s, expired token at 15m01s, reused token rejection, and timezone-neutral expiration checks.
