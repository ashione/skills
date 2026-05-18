# Mobius Harness

Mobius Harness is the delivery orchestration entrypoint for this skill suite. It is not a test harness for this repository. It is a user-facing software delivery harness that guides one agent from requirements analysis through implementation, validation, PR or MR submission, CI/CD tracking, and final reporting.

## Primary Skill

Use `mobius-harness` when a user asks for an end-to-end software delivery outcome rather than a single narrow analysis task.

The loop is:

```text
requirements -> plan -> local development -> validation -> PR/MR + CI/CD -> delivery report
```

Every transition is controlled by a gate. A gate is not satisfied by prose alone; it needs a Gate Ledger row with required evidence, status, evidence pointer, and any accepted exception. Every phase result also needs a Review Ledger with multi-role adversarial challenges resolved before the result is treated as final.

## Delivery Episode Package

For long or risky tasks, Mobius Harness records work as a Delivery Episode Package under:

```text
.delivery/runs/<run-id>/
  requirements.md
  plan.md
  verification.md
  delivery-report.md
```

These files are execution artifacts and `.delivery/runs/` is ignored by git by default. A Delivery Episode Package is the durable record of the delivery: requirements, plan, state transitions, evidence, failures, changes, verification, PR/MR, CI/CD, and final report.

For short tasks, the final response may replace persisted artifacts, but it still needs to include the same facts: requirements, implementation summary, validation, review, sensitive information scan, PR or MR URL when present, CI/CD state, risks, and follow-ups.

## Reference Map

Detailed standards live with the `mobius-harness` skill so agents can load only the reference they need:

- [delivery-process.md](../skills/mobius-harness/references/delivery-process.md): trigger rules, modes, phase gates, status records, subphases, blockers, and change control.
- [artifact-interface.md](../skills/mobius-harness/references/artifact-interface.md): Delivery Episode Package layout, required sections, and evidence format.
- [hook-policy.md](../skills/mobius-harness/references/hook-policy.md): Codex-oriented hook triggers, required hook evidence, failure handling, and executable hook safety.
- [artifact-templates.md](../skills/mobius-harness/references/artifact-templates.md): canonical Markdown templates for persisted delivery artifacts.
- [governance-and-reporting.md](../skills/mobius-harness/references/governance-and-reporting.md): specialist skill matrix, definition of done, safety boundaries, PR/MR body, version report, resume protocol, and borrowed principles.

## Summary Standard

Mobius Harness must:

- select `Lightweight`, `Standard`, or `Strict` mode at the start,
- follow ordered blocking gates from requirements to final report,
- split large, risky, or blocked work into subphases,
- maintain Goal, Checklist, Gate Ledger, Review Ledger, Todo List, Failure List, and Change List for each phase or subphase,
- maintain a Hook Ledger for Standard and Strict deliveries so Codex-specific controls are evidenced before risky transitions,
- default PR/MR CI/CD follow-up to asynchronous observation during small iterative updates unless the user requests full waiting, the delivery is about to merge or release, or policy requires terminal checks,
- record Superpowers spec/plan artifacts or fallback decisions when those skills are used or unavailable,
- record Requirements Maturity before design and Design Readiness before implementation,
- record a Dependency Decision before implementation,
- require evidence before marking any phase or delivery complete,
- stop at any `blocked` gate until evidence is added, the gate is marked `not-applicable`, or an explicit `exception` is recorded,
- run `bash scripts/validate-delivery-run.sh .delivery/runs/<run-id>` before completing Standard or Strict deliveries when persisted artifacts exist,
- follow `local-repo-development` for worktree, branch, commit, PR/MR, and CI/CD handling,
- produce a delivery report that can be sent to the user or attached to a PR/MR.

## Specialist Skills

Mobius Harness can apply other skills as needed:

- `local-repo-development` for worktree setup, safe commits, PR/MR workflow, and CI/CD tracking.
- `refactor-planner` for phased refactors.
- `api-design-review` for API contracts and compatibility.
- `test-case-generator` for focused test plans.
- `frontend-ux-polish` for UI implementation review.
- `bug-triage` for severity, reproduction, and likely root cause.
- `commit-message-writer` for conventional commit messages.
- `team-subagent-orchestrator` only when the user explicitly authorizes delegation.
- `superpowers:brainstorming` for creative work, feature shaping, unclear product intent, or competing solution paths.
- `superpowers:writing-plans` for Standard or Strict deliveries that need a multi-step executable implementation plan.

## Completion Rule

Mobius Harness should not consider a delivery complete until it has clarified high-impact ambiguity, inspected the repository, followed the local repository workflow, run relevant validation, reviewed the diff, scanned for sensitive information, recorded PR/MR and CI/CD state when applicable, and produced a delivery report.

For Standard and Strict deliveries, the Delivery Episode Package must contain terminal Gate Ledger rows for `G1` through `G8`, terminal Hook Ledger rows for the required hooks in `hook-policy.md`, and terminal Review Ledger rows for the required reviews in `delivery-process.md`: `pass`, `not-applicable`, or `exception`. Any `blocked` gate, hook, or review means the delivery is not complete.

Committed fixtures under `examples/delivery-runs/` demonstrate passing, accepted-exception, and blocked delivery packages. CI runs the validator regression script against those fixtures and generated negative cases so gate, hook, and adversarial review behavior remains executable.

Behavior pressure scenarios live in `examples/pressure-scenarios/mobius-harness.md`. Use them to check whether an agent actually stops at missing requirements, missing plans, blocked gates, blocked hooks, blocked reviews, unsupported completion claims, synchronous CI waiting without a trigger, and unmirrored exceptions.
