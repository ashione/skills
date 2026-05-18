# Governance and Reporting Reference

Use this reference for specialist skill selection, completion gates, safety boundaries, PR/MR content, version reports, resume behavior, and borrowed principles.

## Specialist Skill Matrix

Mobius Harness should actively consider specialist skills:

| Situation | Skill |
|---|---|
| Creative work, feature shaping, behavior design, unclear product intent, competing solution paths | `superpowers:brainstorming` |
| Multi-step implementation plan, Standard or Strict delivery, risky handoff to another agent | `superpowers:writing-plans` |
| API contract, compatibility, status codes, auth, versioning | `api-design-review` |
| Refactor, migration, module split, rollback planning | `refactor-planner` |
| Bug, crash, regression, unclear reproduction | `bug-triage` |
| Test strategy, edge cases, regression coverage | `test-case-generator` |
| UI or frontend behavior, responsive layout, visual polish | `frontend-ux-polish` |
| SQL latency, indexes, query plans | `sql-query-optimizer` |
| Commit message | `commit-message-writer` |
| Worktree, branch, commit, PR/MR, CI/CD | `local-repo-development` |
| Multi-agent work | `team-subagent-orchestrator`, only with explicit user authorization |

## Definition of Done

Delivery is done only when:

- success criteria are met or explicitly marked unmet,
- Superpowers brainstorming and writing-plans decisions are recorded for requirements and plan gates,
- Gate Ledger rows `G1` through `G8` are all `pass`, `not-applicable`, or `exception`,
- no Gate Ledger row is `blocked`,
- local validation is complete or unavailable with reason,
- diff review is complete,
- sensitive information scan is complete,
- PR/MR state is recorded or not applicable with reason,
- CI/CD terminal state is recorded or not applicable with reason,
- `bash scripts/validate-delivery-run.sh .delivery/runs/<run-id>` passes for Standard and Strict deliveries when the script exists, or its unavailability is recorded as an exception,
- open failures are fixed, accepted, or deferred,
- delivery report is complete.

## Safety Boundaries

Mobius Harness must not:

- publish to production without explicit authorization,
- bypass failing CI/CD without recording accepted risk,
- advance past a blocked gate,
- mark an exception without recording the accepted risk in Failure List and Change List,
- delete or overwrite unrelated user changes,
- commit secrets or print secret values,
- run destructive operations without explicit authorization,
- hide unresolved failures in the final report.

## PR/MR and Version Report Standard

PR/MR body should include:

- `Summary`
- `Validation`
- `Gate Ledger`
- `Risk`
- `Rollback`
- `Delivery Episode`
- `CI/CD Follow-up`

Version or release report should include:

- version or tag,
- change summary,
- changed skills or modules,
- compatibility notes,
- migration notes,
- rollback notes,
- post-release checks.

## Resume Protocol

When resuming a delivery:

1. Read `.delivery/runs/<run-id>/` first.
2. Identify the earliest incomplete phase or subphase.
3. Review Todo List, Failure List, and Change List.
4. Confirm current git branch/worktree and dirty state.
5. Continue from the first unmet gate, not from the beginning.

## Borrowed Principles

Mobius Harness intentionally absorbs proven ideas from other agent workflow and harness systems while remaining a delivery skill suite, not an eval harness:

- Superpowers: enforce design-before-code, small executable tasks, worktrees, TDD/review pressure, and evidence over claims.
- AI Harness Engineering: treat the harness as the runtime substrate that controls task state, observability, verification, permissions, failure attribution, and intervention recording.
- Trace/eval frameworks such as agentevals, DeepEval, Inspect, and Strands: record the episode once, keep reusable evidence, separate execution from review, and make failures auditable.

Mobius translates those ideas into delivery artifacts: phase state, evidence, failure attribution, verification records, PR/MR state, CI/CD state, and a final delivery report.
