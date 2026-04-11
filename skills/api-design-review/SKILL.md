---
name: api-design-review
description: Review an API interface for consistency, safety, and long-term maintainability.
---

# API Design Review

## Intent

Review an API interface for consistency, safety, and long-term maintainability.

## Inputs

- `api_spec`: API contract in any format — OpenAPI 3.x, GraphQL schema, or raw endpoint definitions with method/path/body/response.
- `constraints`: Compatibility requirements, latency SLA, auth model, governance rules. Example: "Must support v1 clients for 6 months, p99 < 200ms, OAuth 2.0 bearer."

## Instructions

1. Identify endpoint naming, versioning, and resource model issues.
2. Validate status code and error model consistency.
3. Evaluate backward compatibility and migration risk with concrete timeline.
4. Check idempotency guarantees for mutating operations.
5. Propose specific changes with before/after examples.

## Examples

Input: REST spec for user lifecycle: PUT /users/{id} replaces entire user object; errors return {message: string} on some endpoints and {error: {code, detail}} on others.

Output:

Issue 1: PUT /users/{id} is non-idempotent because it silently drops unset fields. Fix: use PATCH for partial update, keep PUT for full replacement with required field validation.

Issue 2: Inconsistent error schema. Fix: normalize to {error: {code: string, message: string, details?: object}} across all endpoints.

Issue 3: No versioning strategy. Fix: add /v1/ prefix now; define deprecation header (Sunset) for future migration.
