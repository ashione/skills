---
name: sql-query-optimizer
description: Analyze SQL query performance and provide index and query rewrite recommendations.
---

# SQL Query Optimizer

## Intent

Analyze SQL query performance and provide index and query rewrite recommendations.

## Inputs

- `query`: SQL statement.
- `schema`: Relevant tables, indexes, and cardinality hints.
- `explain_plan`: Query plan output.

## Instructions

1. Inspect scan types, join order, and filter selectivity.
2. Recommend indexes with expected impact.
3. Suggest query rewrites that preserve semantics.
4. Mention trade-offs such as write amplification.

## Examples

Input: Query on orders table is slow with full table scan.

Output: Add composite index (customer_id, created_at), replace function-wrapped date filter with range predicate, and validate with before/after EXPLAIN ANALYZE.
