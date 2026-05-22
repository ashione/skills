---
name: mobius-harness
description: Use when a software delivery request spans requirements, planning, implementation, validation, PR/MR handling, CI/CD tracking, or delivery reporting.
---

# Mobius Harness

## Intent

Orchestrate a single agent through the full software delivery loop: clarify requirements, plan the change, implement safely, validate locally, submit a PR or MR, track CI/CD, and produce a delivery report.

## When to Use

- Feature, bugfix, refactor, migration, release, or operational change requests that require more than a single local edit.
- Work where requirements, implementation, validation, review, PR/MR, or CI/CD state must be tracked as one delivery loop.
- Do not use for simple read-only questions, one-command lookups, or narrowly scoped edits where the final response can carry all state without loss.

## References

Load references only when needed:

- `references/delivery-process.md`: read when choosing mode, managing phases/subphases, status records, blockers, or change control.
- `references/artifact-interface.md`: read when defining `.delivery/runs/<run-id>/` files, required sections, or evidence records.
- `references/hook-policy.md`: read when applying Claude Code/Codex hook controls, soft gates, hard gates, skills, tools, worktrees, review, CI/CD, cleanup, or local runtime sync.
- `references/artifact-templates.md`: read only when a persisted artifact needs a canonical Markdown template.
- `references/governance-and-reporting.md`: read when selecting specialist skills, deciding completion, writing PR/MR or release reports, resuming delivery, or handling safety boundaries.

## Inputs

- `request`: User's feature, bugfix, refactor, or delivery goal.
- `repo_path`: Local repository path, usually the current working directory.
- `constraints`: Optional scope, timeline, compatibility, testing, release, or governance constraints.
- `run_id`: Optional kebab-case id for persisted delivery artifacts.

## Instructions

1. Treat Mobius Harness as the primary entrypoint for end-to-end delivery work. Keep one agent accountable for the whole loop unless the user explicitly asks for delegation.
2. Select `Lightweight`, `Standard`, or `Strict` mode at the start. Use persisted `.delivery/runs/<run-id>/` artifacts for Standard and Strict work.
   - For Standard and Strict deliveries, initialize missing persisted artifacts with `bash scripts/init-delivery-run.sh <run-id> --request "<user request>" [--gate-type soft|hard] [--runtime auto|codex|claude-code|claude|generic]` when that script exists.
   - Use the initialization default `[soft]` unless the user, repository policy, release risk, security risk, or merge gate requires `[hard]`.
   - Keep gate strength separate from runtime-specific hook wording: use `--runtime auto` by default, or pin `codex`, `claude-code`, `claude`, or `generic` when the executor must be explicit; `claude` normalizes to `claude-code` in generated artifacts.
   - Treat initialized artifacts as a starting state with blocked gate, hook, and review rows; do not treat initialization as final validation.
3. Follow the delivery process in order. Treat each phase gate as a blocking gate, not as a reminder. Do not move to the next phase until the current gate is `pass`, `not-applicable`, or an explicitly recorded `exception`.
   - For Standard and Strict deliveries, maintain a Hook Ledger for required hook controls from `references/hook-policy.md`.
   - Classify each Hook Ledger required action as `[hard]` or `[soft]`: hard gates block when unresolved; soft gates may use `warn` only with evidence, failure handling, and mirrored Failure List / Change List records.
   - Treat `blocked` hooks like `blocked` gates; do not advance until they pass, become not applicable, or are explicitly excepted.
   - Maintain a Review Ledger for each phase and do not publish that phase's final result or start execution until multi-role adversarial review is resolved.
4. Analyze requirements first:
   - Restate the goal, background, success criteria, scope, non-goals, risks, and open questions.
   - When the request references an issue, bug report, PR, branch, fork, commit, or previous fix, search discoverable prior attempts and record their evidence. If no prior attempt applies or the source cannot be searched, record the reason explicitly.
   - Treat prior attempts as design evidence, not copy instructions: identify reusable tests or ideas, stale assumptions, behavioral differences, and fresh verification needed before adopting them.
   - Classify uncertainties as blocking, accepted, deferred, or not applicable; do not design or implement while blocking unknowns remain.
   - Record Minimum Skill Dependencies for `mobius-harness`, `local-repo-development`, `superpowers:brainstorming`, and `superpowers:writing-plans`; mark Superpowers dependencies used, not applicable, unavailable, blocked, or excepted before implementation starts.
   - Record Requirements Maturity as `ready-for-design` only when success criteria, scope, non-goals, constraints, risks, open questions, and user decisions are specific enough to choose an implementation approach.
   - Use `superpowers:brainstorming` before creative work, behavior design, feature shaping, or ambiguous requirement decisions; record whether it was used, not applicable, or blocked.
   - Ask the user only for high-impact intent or tradeoff decisions that cannot be discovered from the repo.
   - For long or risky tasks, create `.delivery/runs/<run-id>/requirements.md`.
5. Build a delivery plan:
   - Inspect the repository before deciding the implementation path.
   - Identify specialist skills to apply, such as `refactor-planner`, `api-design-review`, `test-case-generator`, `frontend-ux-polish`, `sql-query-optimizer`, `bug-triage`, or `team-subagent-orchestrator` when explicitly authorized.
   - Carry forward Minimum Skill Dependencies from requirements and update evidence or fallback handling when a required skill is unavailable.
   - When `superpowers:brainstorming` or `superpowers:writing-plans` is used, record the resulting spec or plan artifact path; when unavailable, record fallback handling as `blocked`, `not-applicable`, or `exception`.
   - Use `superpowers:writing-plans` when the delivery needs a multi-step executable plan, especially for Standard or Strict mode.
   - Compare credible design options before selecting an approach; record rejected alternatives and why they were rejected.
   - Compare any discovered prior attempts against the selected approach, including API or dependency freshness checks when the earlier attempt depends on time-sensitive behavior.
   - Record Design Readiness as `ready-for-implementation` only when selected approach, affected areas, acceptance mapping, validation strategy, rollback notes, and start gate are explicit.
   - Record a Dependency Decision: `no-new-dependency`, `existing-toolchain`, or `new-dependency-required`, with reason, evidence, and fallback.
   - Define implementation steps, validation commands, validation prerequisites, acceptance criteria, and delivery checkpoints.
   - For long or risky tasks, create `.delivery/runs/<run-id>/plan.md`.
6. Develop locally using `local-repo-development`:
   - Confirm the current directory is a git repository.
   - Determine whether the current checkout is already a suitable linked worktree.
   - If not, create a task worktree from `origin/main`, then `origin/master`, then local `main` or `master`, then `HEAD`.
   - Preserve unrelated user changes.
7. Implement and validate:
   - Make the smallest coherent change that satisfies the accepted plan.
   - Run the repository's relevant tests, type checks, builds, linters, or focused validation commands.
   - Before committing, review the diff for requirements compliance, implementation quality, test adequacy, security, regressions, unsafe behavior, and unintended churn.
   - Before committing, scan changed files for sensitive information. Prefer installed scanners such as `gitleaks` or `detect-secrets`; otherwise run a focused fallback scan. Do not print secret values.
   - Record validation details in `.delivery/runs/<run-id>/verification.md` for long or risky tasks.
8. Submit and track:
   - Use `commit-message-writer` to produce a clear conventional commit message when committing.
   - Create the PR or MR when requested or when delivery requires review.
   - Default to asynchronous CI/CD follow-up during small iterative PR updates: record the check URLs, head SHA, and next observation point without blocking the user.
   - Wait synchronously for CI/CD only when the user requests full waiting, when merging, when releasing, or when a gate explicitly requires terminal CI/CD evidence.
   - If CI/CD fails when observed, inspect logs, summarize the failure, fix in-scope issues, and decide with the user whether to wait for the next run or continue asynchronously.
9. Deliver the result:
   - Produce a concise delivery report covering requirements, implementation, changed files, local validation, code review, sensitive information scan, PR or MR URL, CI/CD status, risks, and follow-ups.
   - For long or risky tasks, write `.delivery/runs/<run-id>/delivery-report.md`.
   - For short tasks, the final response may be the only report, but it must still cover the same delivery facts.

## Gate Contract

Mobius Harness gates are enforcement points. A gate is satisfied only when its required evidence exists in a Gate Ledger row and the row has an allowed terminal status.

Allowed gate statuses:

- `pass`: required evidence exists and the phase may advance.
- `not-applicable`: the gate does not apply, with evidence explaining why.
- `exception`: the gate is not fully satisfied, but the user or repository policy accepted the risk; record the reason in Failure List and the approval or policy basis in Change List.
- `blocked`: the gate is not satisfied and the agent must not advance.

Every phase/subphase must maintain a Gate Ledger with:

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|

For Standard and Strict deliveries, every phase/subphase must also maintain a Hook Ledger:

| Hook | Trigger | Required Action | Status | Evidence | Failure Handling |
|---|---|---|---|---|---|

Hook `Required Action` values must start with `[hard]` or `[soft]`. Hook statuses are `pass`, `warn`, `not-applicable`, `exception`, or `blocked`; `warn` is valid only for `[soft]` hooks and must be mirrored in Failure List and Change List.

Every phase/subphase must maintain a Review Ledger:

| Review | Role | Perspective | Challenge | Status | Resolution | Evidence |
|---|---|---|---|---|---|---|

Before moving phases, answer the gate decision in the ledger:

1. What exact evidence proves this gate is satisfied?
2. If evidence is missing, is it unavailable, not applicable, or a true blocker?
3. If using an exception, where is the accepted risk recorded?
4. What unfinished Todo List or Failure List items carry forward?
5. Which hooks were triggered for this phase, and what evidence proves each hook ran or was not applicable?
6. Which review roles challenged the phase result, and how were their blocking findings resolved?

For `Standard` and `Strict` deliveries, run `bash scripts/validate-delivery-run.sh .delivery/runs/<run-id>` before marking the delivery complete when that script exists in the repository. If the script is unavailable, record that as a gate exception with reason.

## Process Standard

Use these phase gates. Each phase may be split into smaller subphases when the work is large, risky, or blocked.

1. `G1 Requirements`: goal, success criteria, scope, non-goals, risks, open questions, Minimum Skill Dependencies, uncertainty disposition, Requirements Maturity, and Superpowers brainstorming decision are explicit.
2. `G2 Plan`: design options, selected approach, rejected alternatives, affected areas, specialist skills, Minimum Skill Dependencies, Superpowers planning decision, Dependency Decision, validation commands, Validation Prerequisites, acceptance criteria, and Design Readiness are explicit.
3. `G3 Local Development`: worktree or branch choice is recorded and unrelated user changes are protected.
4. `G4 Implementation`: changed files are intentional and mapped to accepted requirements.
5. `G5 Verification`: local checks, diff review, and sensitive information scan are complete or explicitly marked unavailable with reason.
6. `G6 PR/MR`: PR/MR URL or reason for not creating one is recorded.
7. `G7 CI/CD`: terminal CI/CD state, async observation state, or not-applicable reason is recorded when remote checks exist.
8. `G8 Report`: final delivery report is complete and includes all unresolved risks or follow-ups.

For every phase and subphase, maintain a status record with:

- Goal: what this phase or subphase must achieve.
- Checklist: objective exit checks for the phase or subphase.
- Gate Ledger: phase gate decisions with status and evidence.
- Hook Ledger: Claude Code/Codex controls for skill activation, tool reality, soft and hard gates, worktree hygiene, review, CI/CD, cleanup, and local runtime sync.
- Review Ledger: multi-role adversarial checks of the phase result before advancing.
- Todo List: remaining actions, each with owner or status when useful.
- Failure List: failed commands, blocked checks, rejected assumptions, CI/CD failures, or unresolved risks.
- Change List: decisions made, files changed, scope changes, requirement changes, validation changes, or follow-up changes.

## Completion Standard

- A phase is complete only when every checklist item has evidence or an explicit unavailable reason.
- A phase cannot be `complete` while its Gate Ledger has any `blocked` row.
- A Standard or Strict phase cannot be `complete` while any required Hook Ledger row is `blocked` or missing.
- A phase cannot be `complete` while any required Review Ledger row is `blocked` or missing.
- Requirements and plan phases must record whether `superpowers:brainstorming` and `superpowers:writing-plans` were used, skipped as not applicable, unavailable, or excepted with accepted risk.
- Requirements and plan phases must record Minimum Skill Dependencies, including Superpowers dependency handling and fallback.
- Requirements phases must record Requirements Maturity and cannot advance to design while blocking unknowns remain.
- Requirements phases must record Issue and Prior Attempts when the work is driven by an issue, bug report, PR, branch, fork, commit, or previous fix; mark it not applicable only with evidence.
- Plan phases must record Design Readiness and cannot advance to implementation while the selected approach, acceptance mapping, or validation strategy is unresolved.
- Plan phases must record Prior Attempt Comparison when G1 found existing attempts, including reuse decisions, rejected assumptions, and fresh verification for time-sensitive behavior.
- Plan phases must record Dependency Decision, including evidence and fallback for unavailable tooling or platform skills.
- Plan phases must record Validation Prerequisites for setup, generated artifacts, migrations, fixtures, or environment state required before validation commands can run cleanly.
- A delivery is complete only when requirements, implementation scope, changed files, validation, diff review, sensitive information scan, PR/MR state, CI/CD state, residual risks, and follow-ups are all reported.
- A delivery cannot be `complete` until gates `G1` through `G8` are `pass`, `not-applicable`, or `exception`.
- A Standard or Strict delivery cannot be `complete` until required hooks from `hook-policy.md` are `pass`, `not-applicable`, `exception`, or valid soft-gate `warn`.
- A delivery cannot be `complete` until required adversarial reviews are `pass`, `not-applicable`, or `exception`.
- For Standard and Strict mode, persisted artifacts must be enough for another agent to resume without relying on conversation memory.
- Do not collapse requirements, planning, implementation, and verification into a single vague status update.
- Do not ask the user for decisions that can be answered by reading the repository or running safe local commands.

When moving between phases, summarize the previous phase status record and carry forward unfinished Todo List and Failure List items.

Do not mark a phase, subphase, or delivery complete without evidence. Evidence can be commands and outputs, file paths, diffs, PR/MR URLs, CI/CD URLs, user decisions, or an explicit reason evidence is unavailable.

Use `draft`, `active`, `blocked`, `complete`, and `deferred` for phase status. If blocked, record the failure, try one safe minimal recovery, and ask the user only for the specific decision needed.

## Artifact Standard

For long or risky work, maintain `.delivery/runs/<run-id>/` as a Delivery Episode Package with:

- `requirements.md`: Goal, background, success criteria, scope, non-goals, risks, open questions, user decisions, and Issue and Prior Attempts.
- `plan.md`: Repo findings, prior attempt comparison, selected specialist skills, Minimum Skill Dependencies, Superpowers artifact paths or fallback, Dependency Decision, implementation steps, validation strategy, Validation Prerequisites, acceptance criteria, rollback notes, and checkpoints.
- `verification.md`: Commands run, outcomes, local failures and fixes, diff review notes, sensitive information scan result, PR/MR URL, and CI/CD runs.
- `delivery-report.md`: Executive summary, changed files, implementation summary, validation summary, PR/MR and CI/CD status, risks, follow-ups, release notes, and version or release report notes when applicable.

When the repository provides `scripts/init-delivery-run.sh`, prefer it to hand-writing the initial files so Gate Ledger, Hook Ledger, Review Ledger, soft/hard hook mode rows, and runtime-specific hook wording are generated consistently. The initialization default is soft and runtime auto-detection; choose hard only when the gate must block progress until resolved, and pin the runtime only when Codex, Claude Code, or generic evidence semantics must be explicit.

Each artifact must include status, timestamp or phase marker, evidence, and phase/subphase records using Goal, Checklist, Gate Ledger, Hook Ledger, Review Ledger, Todo List, Failure List, and Change List. Use table records for Gate Ledger, Hook Ledger, Review Ledger, Todo List, Failure List, and Change List so another agent can audit and resume the delivery.

When resuming, read the Delivery Episode Package first, identify the earliest incomplete phase or subphase, review Todo List, Failure List, and Change List, confirm git state, and continue from the first unmet gate.

## Examples

Input: Add a new API endpoint, open a PR, and make sure CI passes.

Output: Mobius Harness clarifies endpoint behavior and compatibility, applies API review and test generation, creates or reuses a safe worktree, implements the endpoint, runs local validation, reviews the diff, scans for sensitive information, commits, opens a PR, tracks CI/CD to a terminal state, and returns a delivery report with the PR URL and validation status.
