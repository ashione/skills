---
name: refactor-planner
description: Use when planning a risky refactor, migration, decomposition, dependency untangling, architecture cleanup, codemod campaign, framework move, data migration, or public contract change that needs scope classification, pattern comparison, validation gates, and rollback criteria.
---

# Refactor Planner

## Intent

Design a refactor or migration plan that preserves behavior while reducing architecture risk in measurable phases.

## When to Use

- Refactors touching shared modules, public interfaces, persistence, build systems, dependency boundaries, runtime behavior, deployment topology, or release flow.
- Decomposition, migration, framework replacement, package extraction, dependency inversion, behavior-preserving cleanup, codemod campaigns, or compatibility-preserving rewrites.
- Do not use for tiny local cleanup that can be reviewed in one diff without migration risk.

## Inputs

- `current_code_summary`: Architecture pattern, LOC estimate, module dependencies, tech debt, and pain points. Example: "Monolithic 50K LOC Node.js service, tight auth/storage coupling, 35% test coverage."
- `target_state`: Desired structure, module boundaries, and acceptance metrics. Example: "@org/auth, @org/core, @org/storage with <10K LOC each, independent deploy."

## Refactor Scope

Classify the request before planning. Scope determines how much evidence and rollback structure is required.

| Scope | Typical Work | Required Protection | Not Enough |
|-------|--------------|---------------------|------------|
| Local | Rename, extract function, simplify branch, remove duplication inside one file/module | Existing focused tests or added characterization tests | Multi-phase plan |
| Module | Split responsibilities, introduce interface, replace internal dependency, move files within one package | Module contract tests, import/caller inventory, rollback commit | "Clean up module" without boundary contract |
| Cross-module | Move ownership across packages/services, change shared utilities, dependency inversion | Caller matrix, compatibility layer, staged rollout, cross-package CI | Direct replacement with no adapter |
| Public contract | API/schema/event/SDK/CLI/config behavior changes | Versioning, deprecation, migration guide, contract tests | Breaking users under "refactor" label |
| Data/runtime | Schema migration, cache/key format, background jobs, queue semantics, persistence behavior | Backfill, dual-read/write, shadow validation, operational rollback | One-way migration before validation |
| Platform/org | Framework/runtime/build/deploy topology, repo/package strategy, ownership model | Pilot area, training/docs, release controls, rollback window | Big-bang migration across all teams |

If the request spans multiple rows, plan for the highest-risk row and explicitly list lower-risk subareas.

## Refactor Patterns

Choose the smallest pattern that controls the risk.

| Pattern | Use When | Compare Against | Validation Signal |
|---------|----------|-----------------|-------------------|
| Characterize then change | Existing behavior is unclear but must be preserved | Editing first and hoping tests catch regressions | Golden tests or snapshots fail before accidental behavior change |
| Extract interface | Callers need stable boundary before implementation moves | Moving concrete classes directly | Old and new implementations pass the same contract tests |
| Branch by abstraction | Implementation must swap gradually behind a stable API | Long-lived feature branch | Flagged adapter can route old/new paths independently |
| Strangler fig | Replacing a subsystem in slices | Big-bang rewrite | Traffic or callers move by route/use case with rollback |
| Dual-read/dual-write | Data or persistence behavior changes | Direct schema/storage cutover | Mismatch rate is measured and below threshold |
| Shadow traffic | New path can be evaluated without serving users | Serving unproven path | Shadow output/perf matches production path |
| Codemod campaign | Mechanical API/import/style change repeats across many files | Manual edits file-by-file | Codemod is tested on fixture and diff is reviewable |
| Compatibility shim | External callers cannot migrate at once | Immediate breaking change | Old and new callers work during deprecation window |
| Facade extraction | Subsystem has too many direct dependencies | Rewiring every caller at once | Callers depend on facade while internals change |
| Vertical slice pilot | Platform/framework migration is broad | Migrating all screens/services first | One representative slice validates toolchain and release path |

## Instructions

1. Classify scope using `Refactor Scope`; state the highest-risk scope and why.
2. Classify refactor type: local cleanup, boundary extraction, dependency inversion, subsystem decomposition, public contract migration, data/runtime migration, framework/platform migration, or mechanical codemod.
3. Compare at least two viable patterns from `Refactor Patterns`; choose one and reject the weaker option with a concrete risk reason.
4. Define the invariant behavior that must not change: APIs, data contracts, persistence semantics, performance budgets, security boundaries, user workflows, observability, and compatibility promises.
5. Map dependencies and risk: callers, owners, transitive imports, side effects, persistence, caches, background jobs, feature flags, deployments, and release cadence.
6. Identify incremental boundaries that can be changed independently. Prefer adapter layers, strangler patterns, dual paths, shims, and feature flags over big-bang rewrites.
7. Define phases with entry criteria, implementation scope, owned files/modules, exit criteria, validation commands or production signals, rollback path, and expected duration.
8. Specify test coverage before each risky move: characterization tests, contract tests, migration tests, performance baselines, data checks, compatibility tests, and smoke tests.
9. Include compatibility strategy: versioned interfaces, temporary shims, dual-write/read, shadow traffic, backfill, migration freeze windows, and deprecation timing.
10. State stop conditions that pause the refactor, such as error budget burn, latency regression, data mismatch, test coverage gap, unclear owner, or compatibility break.

## Output Standard

- Include `Scope Classification`, `Pattern Comparison`, `Current State`, `Target State`, `Invariants`, `Risk Register`, `Phases`, `Validation`, `Rollback`, and `Open Questions`.
- `Pattern Comparison` must compare at least two options in a table with `Option`, `Why It Fits`, `Risk`, and `Decision`.
- `Risk Register` must include impact, probability, detection signal, and mitigation.
- Every phase needs measurable exit criteria and a rollback path.
- Every phase must name the files/modules/services it owns or explicitly say discovery is required before ownership can be named.
- Call out irreversible steps separately and put them after reversible validation phases.
- Do not recommend a rewrite without explaining why incremental migration is insufficient.
- Do not use vague milestones like "clean up auth" without owned files/modules and acceptance criteria.

## Examples

Input: Monolithic 50K LOC Node.js service with tightly coupled auth/business/storage. Target: modular packages with independent deploy.

Output:

Scope Classification: Cross-module decomposition with public-ish internal contracts. Highest risk is callers depending on auth/storage side effects.

Pattern Comparison:

| Option | Why It Fits | Risk | Decision |
|--------|-------------|------|----------|
| Extract interface | Stabilizes auth boundary before moving code | May preserve poor abstractions if contract is copied blindly | Use first |
| Big-bang package split | Fast apparent cleanup | High regression risk across callers and deploy flow | Reject |
| Strangler by use case | Good after interface exists | Needs routing point per workflow | Use later for storage paths |

Phase 1 (Characterization and boundary inventory, 1 week): Map auth/business/storage callers and side effects. Add characterization tests for login, permission checks, token refresh, and storage writes. Exit: top 20 auth/storage call paths covered; no behavior changes. Rollback: revert tests/inventory only.

Phase 2 (Interface extraction, 1-2 weeks): Define `AuthProvider` and `StorageGateway` contracts; adapt legacy implementation behind interfaces. Exit: contract tests pass against legacy implementation; package imports only depend on interfaces. Rollback: legacy concrete imports remain available behind a flag.

Phase 3 (Dual-write validation, 2-3 weeks): Run new storage in shadow mode for selected write paths. Exit: 0 critical discrepancies and <0.1% non-critical mismatch over 48h representative traffic. Rollback: disable dual-write flag.

Phase 4 (Adapter swap, 1 week): Route selected workflows to new storage. Exit: error rate <0.1% increase, p99 unchanged, rollback tested in staging. Rollback: revert routing flag within 5 minutes.
