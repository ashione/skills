---
name: sql-query-optimizer
description: Use when a SQL query, database endpoint, report, or job has slow runtime, high cost, poor plan shape, missing indexes, or needs safer query/index recommendations.
---

# SQL Query Optimizer

## Intent

Explain why a SQL workload is slow or costly, then recommend query and index changes that preserve semantics and are safe to validate.

## When to Use

- Slow SQL queries, reports, jobs, API endpoints, dashboards, or migrations.
- EXPLAIN/EXPLAIN ANALYZE review, index design, join/filter rewrite, pagination, aggregation, or cardinality issues.
- Do not use for logical data modeling unless query performance is the focus.

## Inputs

- `query`: SQL statement.
- `schema`: Relevant tables, indexes, and cardinality hints.
- `explain_plan`: Query plan output.

## Workload Classes

Classify the workload before recommending indexes. The same index can be right for one class and harmful for another.

| Class | Symptoms | Primary Levers | Avoid |
|-------|----------|----------------|-------|
| Point lookup/API path | High p95/p99 on selective lookup | Equality-first covering index, stable parameter plan, limit enforcement | Broad indexes that hurt writes |
| Paginated list | Slow page fetch, unstable ordering, offset cost | Keyset pagination, `(filter, sort, id)` index, deterministic order | Large OFFSET pagination |
| Reporting/aggregation | Long scans, sort/hash spill, high cost | Pre-aggregation, partition pruning, column order for group/filter | OLTP index spam for one report |
| Join-heavy query | Bad join order, nested loop explosion, key lookups | Join key indexes, stats, join rewrite, cardinality correction | Rewriting joins without row semantics check |
| Write-heavy table | Inserts/updates slowed by index count | Partial indexes, narrower indexes, query rewrite | Adding every plausible composite index |
| Multi-tenant workload | Tenant hot spots, cross-tenant scans | Tenant-leading indexes, partitioning, per-tenant limits | Indexes that omit tenant boundary |

## Bottleneck Types

| Bottleneck | Evidence | Typical Fix |
|------------|----------|-------------|
| Missing/unused index | Sequential scan on selective predicate, key lookup storm | Exact composite/covering/partial index |
| Non-sargable predicate | Function/cast/wildcard prevents index use | Range predicate, generated column, normalized search key |
| Cardinality mismatch | Estimated rows far from actual rows | Refresh stats, extended stats, rewrite predicate |
| Join explosion | Loops multiply rows unexpectedly | Pre-filter, change join order, add join key index |
| Sort/hash spill | Disk/temp files, memory spill | Matching sort index, reduce rows earlier, memory/config note |
| Pagination cost | Large OFFSET or unstable order | Keyset pagination with deterministic tie-breaker |

## Instructions

1. Identify database engine/version when available. Do not assume PostgreSQL, MySQL, SQLite, SQL Server, BigQuery, or Snowflake behavior without evidence.
2. Classify workload using `Workload Classes` and bottleneck using `Bottleneck Types`; state the evidence for both.
3. Summarize query purpose, tables, joins, filters, grouping, ordering, limits, expected row counts, and parameter selectivity.
4. Inspect the plan for scan type, join order, row estimates vs actuals, sort/hash spill, temp files, key lookups, sequential scans, remote reads, partition pruning, and late filters.
5. Identify the dominant bottleneck and evidence: estimated/actual rows, loops, timing, I/O, memory, cardinality mismatch, missing statistics, or partition miss.
6. Compare index options when more than one is plausible: column order, uniqueness/partial/covering choices, write cost, and whether it supports equality, range, sort, and join predicates.
7. Recommend rewrites only when they preserve semantics. Call out NULL behavior, duplicate rows, time zone/date boundaries, collation, and aggregation changes.
8. Include trade-offs: write amplification, lock/build strategy, storage, planner risk, stale stats, and migration/rollback plan.
9. Define validation: before/after EXPLAIN ANALYZE, representative parameters, warm/cold cache caveats, runtime budget, and regression checks for other queries.

## Output Standard

- Include `Workload Class`, `Bottleneck Type`, and `Evidence`.
- Lead with `Likely Bottleneck` and the evidence.
- Include `Recommended Indexes`, `Query Rewrites`, `Validation Plan`, and `Trade-offs`.
- If recommending an index, show why each column is first/second/third and what query clause it serves.
- If plan or schema is missing, state what cannot be concluded and request the minimum missing artifact.
- Do not recommend indexes without exact column order.
- Do not claim performance gains without a validation method.

## Examples

Input: Query on orders table is slow with full table scan.

Output: Likely Bottleneck: full scan on `orders` because the filter cannot use an index. Recommended Index: `(customer_id, created_at)` if equality on `customer_id` and range/order on `created_at` are the dominant predicates. Query Rewrite: replace function-wrapped date filter with a half-open range predicate to preserve index use. Trade-offs: extra write cost and storage on `orders`. Validation Plan: run before/after `EXPLAIN ANALYZE` with representative customer IDs and check that related write-heavy paths stay within budget.
