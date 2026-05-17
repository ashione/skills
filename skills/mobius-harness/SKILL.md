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
3. Follow the delivery process in order. Do not skip a phase unless the task is explicitly too small for persisted artifacts; even then, preserve the same information in the final response.
4. Analyze requirements first:
   - Restate the goal, background, success criteria, scope, non-goals, risks, and open questions.
   - Ask the user only for high-impact intent or tradeoff decisions that cannot be discovered from the repo.
   - For long or risky tasks, create `.delivery/runs/<run-id>/requirements.md`.
5. Build a delivery plan:
   - Inspect the repository before deciding the implementation path.
   - Identify specialist skills to apply, such as `refactor-planner`, `api-design-review`, `test-case-generator`, `frontend-ux-polish`, `sql-query-optimizer`, `bug-triage`, or `team-subagent-orchestrator` when explicitly authorized.
   - Define implementation steps, validation commands, acceptance criteria, and delivery checkpoints.
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
   - Track CI/CD asynchronously until it passes, fails, or is canceled.
   - If CI/CD fails, inspect logs, summarize the failure, fix in-scope issues, and track the next run to a terminal state.
9. Deliver the result:
   - Produce a concise delivery report covering requirements, implementation, changed files, local validation, code review, sensitive information scan, PR or MR URL, CI/CD status, risks, and follow-ups.
   - For long or risky tasks, write `.delivery/runs/<run-id>/delivery-report.md`.
   - For short tasks, the final response may be the only report, but it must still cover the same delivery facts.

## Process Standard

Use these phase gates. Each phase may be split into smaller subphases when the work is large, risky, or blocked.

1. Requirements gate: goal, success criteria, scope, non-goals, risks, and open questions are explicit.
2. Plan gate: implementation path, affected areas, specialist skills, validation commands, and acceptance criteria are explicit.
3. Development gate: worktree or branch choice is recorded and unrelated user changes are protected.
4. Verification gate: local checks, diff review, and sensitive information scan are complete or explicitly marked unavailable with reason.
5. PR/MR gate: PR/MR URL or reason for not creating one is recorded.
6. CI/CD gate: terminal CI/CD state is recorded when remote checks exist.
7. Report gate: final delivery report is complete.

For every phase and subphase, maintain a status record with:

- Goal: what this phase or subphase must achieve.
- Checklist: objective exit checks for the phase or subphase.
- Todo List: remaining actions, each with owner or status when useful.
- Failure List: failed commands, blocked checks, rejected assumptions, CI/CD failures, or unresolved risks.

## Completion Standard

- A phase is complete only when every checklist item has evidence or an explicit unavailable reason.
- A delivery is complete only when requirements, implementation scope, changed files, validation, diff review, sensitive information scan, PR/MR state, CI/CD state, residual risks, and follow-ups are all reported.
- For Standard and Strict mode, persisted artifacts must be enough for another agent to resume without relying on conversation memory.
- Do not collapse requirements, planning, implementation, and verification into a single vague status update.
- Do not ask the user for decisions that can be answered by reading the repository or running safe local commands.
- Change List: decisions made, files changed, scope changes, requirement changes, validation changes, or follow-up changes.

When moving between phases, summarize the previous phase status record and carry forward unfinished Todo List and Failure List items.

Do not mark a phase, subphase, or delivery complete without evidence. Evidence can be commands and outputs, file paths, diffs, PR/MR URLs, CI/CD URLs, user decisions, or an explicit reason evidence is unavailable.

Use `draft`, `active`, `blocked`, `complete`, and `deferred` for phase status. If blocked, record the failure, try one safe minimal recovery, and ask the user only for the specific decision needed.

## Artifact Standard

For long or risky work, maintain `.delivery/runs/<run-id>/` as a Delivery Episode Package with:

- `requirements.md`: Goal, background, success criteria, scope, non-goals, risks, open questions, and user decisions.
- `plan.md`: Repo findings, selected specialist skills, implementation steps, validation strategy, acceptance criteria, rollback notes, and checkpoints.
- `verification.md`: Commands run, outcomes, local failures and fixes, diff review notes, sensitive information scan result, PR/MR URL, and CI/CD runs.
- `delivery-report.md`: Executive summary, changed files, implementation summary, validation summary, PR/MR and CI/CD status, risks, follow-ups, and release notes.

Each artifact must include status, timestamp or phase marker, evidence, and phase/subphase records using Goal, Checklist, Todo List, Failure List, and Change List. Use table records for Todo List, Failure List, and Change List so another agent can audit and resume the delivery.

When resuming, read the Delivery Episode Package first, identify the earliest incomplete phase or subphase, review Todo List, Failure List, and Change List, confirm git state, and continue from the first unmet gate.

## Examples

Input: Add a new API endpoint, open a PR, and make sure CI passes.

Output: Mobius Harness clarifies endpoint behavior and compatibility, applies API review and test generation, creates or reuses a safe worktree, implements the endpoint, runs local validation, reviews the diff, scans for sensitive information, commits, opens a PR, tracks CI/CD to a terminal state, and returns a delivery report with the PR URL and validation status.
