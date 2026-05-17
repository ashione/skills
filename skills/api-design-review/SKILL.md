---
name: api-design-review
description: Use when reviewing REST, GraphQL, RPC, or webhook API contracts for naming, versioning, error semantics, compatibility, auth, idempotency, pagination, or long-term client safety.
---

# API Design Review

## Intent

Review an API contract as a client-facing product surface. The result must identify concrete contract risks, explain their client impact, and propose compatible fixes.

## When to Use

- REST, GraphQL, RPC, event, or webhook contract review.
- New endpoint/schema proposals before implementation.
- API changes that may affect clients, SDKs, integrations, auth, pagination, idempotency, or error handling.
- Do not use for implementation code review unless the API contract itself is in scope.

## Inputs

- `api_spec`: API contract in any format — OpenAPI 3.x, GraphQL schema, or raw endpoint definitions with method/path/body/response.
- `constraints`: Compatibility requirements, latency SLA, auth model, governance rules. Example: "Must support v1 clients for 6 months, p99 < 200ms, OAuth 2.0 bearer."

## API Surface Types

Classify the API surface before reviewing. Different surfaces fail in different ways.

| Surface | Review Focus | Breaking Change Examples | Required Evidence |
|---------|--------------|--------------------------|-------------------|
| REST resource | Resource model, HTTP method semantics, status codes, pagination, idempotency | Path removal, response field rename, changed status code, unsafe GET | OpenAPI/routes, examples, client compatibility notes |
| GraphQL | Schema evolution, nullability, resolver cost, pagination, deprecation | Removing field, making nullable field non-null, enum contraction | Schema diff, persisted queries, resolver cost limits |
| RPC/action | Command names, request/response shape, retry semantics, deadlines | Renamed method, changed required field, different side effect | Proto/IDL/schema, timeout/retry rules |
| Webhook/event | Delivery guarantees, schema versioning, idempotency, ordering, retries | Removing field, changing event meaning, duplicate semantics | Event catalog, retry policy, consumer list |
| SDK/CLI/config | Naming, defaults, backwards compatibility, error surfaces | Changed default, removed option, new required config | Changelog, migration notes, telemetry/client list |

## Change Risk Classes

| Class | Meaning | Default Decision |
|-------|---------|------------------|
| Additive | New optional field, endpoint, enum value clients can ignore, new event type | Usually acceptable with docs/tests |
| Behavior-changing | Same shape but different meaning, timing, sorting, default, authorization, or side effect | Needs explicit migration and client impact review |
| Breaking | Removes/renames fields, tightens validation, changes requiredness/nullability, changes error/status contract | Block unless versioned or compatibility plan exists |
| Operational | Same contract but different rate limits, retryability, timeout, consistency, or ordering | Requires SLO/observability and rollout plan |

## Instructions

1. Classify API surface type and change risk class before listing findings.
2. Build the contract inventory: resources, operations, request/response shapes, auth context, pagination, filtering, sorting, async behavior, webhooks/events, SDK/CLI surfaces, and documented error cases.
3. Review the surface-specific concerns from `API Surface Types`; do not apply REST-only rules blindly to GraphQL/RPC/webhooks.
4. Review resource/action modeling and naming against the API style already present. Flag verbs in resource paths, inconsistent pluralization, hidden side effects, unclear ownership boundaries, and non-composable query parameters.
5. Check method/action semantics and safety: safe reads must not mutate, mutating retries must document idempotency keys or replay behavior, and bulk operations must define partial failure handling.
6. Validate response and error consistency: status codes or equivalent error codes, envelope shape, machine-readable error codes, retryability, validation details, correlation/request IDs, rate-limit headers, and empty/list responses.
7. Evaluate compatibility using `Change Risk Classes`; state migration path, versioning/deprecation mechanism, Sunset or equivalent headers when relevant, and minimum client notice period from `constraints`.
8. Review operational contracts: authz/authn boundary, tenant isolation, pagination stability, ordering guarantees, limits, timeouts, eventual consistency, webhook retries, and observability fields.
9. Produce findings ordered by severity. Each finding must include affected contract element, surface type, risk class, client impact, fix, compatibility impact, and a before/after example when the shape changes.

## Output Standard

- Lead with findings, not general commentary.
- Include `Surface Classification` and `Change Risk Summary`.
- Use severity labels: `Blocker`, `High`, `Medium`, `Low`.
- For each finding use: `Severity`, `Surface`, `Risk Class`, `Affected Contract`, `Client Impact`, `Recommendation`, `Migration/Compatibility`.
- Include `Open Questions` only for decisions that materially affect compatibility or safety.
- Include `Acceptable As-Is` notes for important areas reviewed with no issue, so the review scope is auditable.
- Do not say "ensure consistency" without naming the exact inconsistent fields, endpoints, or schemas.
- Do not recommend a breaking change without a migration or versioning plan.

## Examples

Input: REST spec for user lifecycle: PUT /users/{id} replaces entire user object; errors return {message: string} on some endpoints and {error: {code, detail}} on others.

Output:

High: `PUT /users/{id}` currently behaves like partial update and silently drops omitted fields, so retries and SDK clients can lose data. Fix: use `PATCH /users/{id}` for partial updates; keep `PUT` only for full replacement with required-field validation. Compatibility: additive if `PUT` behavior is preserved during a deprecation window.

Medium: Error schema alternates between `{message}` and `{error}`. Fix: normalize to `{error: {code: string, message: string, details?: object}}`; document stable machine codes.

Open Question: confirm whether existing clients already depend on unversioned paths before adding `/v1`.
