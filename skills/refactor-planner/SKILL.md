# Refactor Planner

## Intent

Design a low-risk phased refactor plan with checkpoints and rollback strategy.

## Inputs

- `current_code_summary`: Architecture pattern, LOC estimate, module dependencies, tech debt, and pain points. Example: "Monolithic 50K LOC Node.js service, tight auth/storage coupling, 35% test coverage."
- `target_state`: Desired structure, module boundaries, and acceptance metrics. Example: "@org/auth, @org/core, @org/storage with <10K LOC each, independent deploy."

## Instructions

1. Identify seams for incremental extraction.
2. Define milestones with acceptance criteria and duration estimates.
3. Specify test coverage needed before each phase.
4. Include rollback and compatibility strategy per phase.
5. State validation method for each phase transition (e.g. dual-write, shadow traffic, canary).

## Examples

Input: Monolithic 50K LOC Node.js service with tightly coupled auth/business/storage. Target: modular packages with independent deploy.

Output:

Phase 1 (Interface extraction, 1-2 weeks): Define AuthProvider interface contract. Acceptance: 80% test coverage on auth boundary. Rollback: legacy auth remains active.

Phase 2 (Dual-write validation, 2-3 weeks): Run new storage in shadow mode. Acceptance: 0 discrepancies over 48h production traffic.

Phase 3 (Adapter swap, 1 week): Switch to new storage. Acceptance: error rate <0.1% increase, p99 latency unchanged. Rollback: revert flag within 5 minutes.
