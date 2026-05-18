# Hook Policy Reference

Use this reference when a delivery needs Codex-specific enforcement points around skill use, tool reality, worktree hygiene, review, CI/CD, cleanup, or local runtime sync.

## Hook Model

Hooks are auditable controls that run inside the existing Mobius phase gates. Gates decide whether a phase may advance; hooks record the required action that must happen before or after a risky agent operation.

Hooks start as declarative records. Do not execute arbitrary repository hook scripts unless a repository explicitly defines them and the plan records a `new-dependency-required` or `existing-toolchain` Dependency Decision with validation and rollback notes.

Every Standard and Strict Delivery Episode Package must include a Hook Ledger table in each persisted phase artifact:

| Hook | Trigger | Required Action | Status | Evidence | Failure Handling |
|---|---|---|---|---|---|

Hook statuses use the same terminal model as gates:

- `pass`: required action ran or was recorded with evidence.
- `not-applicable`: action does not apply and the reason is evidenced.
- `exception`: action was not fully satisfied, but the user or repository policy accepted the risk; mirror it in Failure List and Change List.
- `blocked`: required action is missing, failed, or unresolved; the phase must not advance.

## Required Hooks

For Standard and Strict deliveries, the combined artifacts must contain exactly one terminal row for each hook below.

| Hook | Trigger | Required Action | Owning Artifact |
|---|---|---|---|
| `before_requirements` | before G1 completion | Read the user goal, applicable repo instructions, relevant specs/docs, uncertainty disposition, Requirements Maturity, and whether `superpowers:brainstorming` is used, not applicable, unavailable, or excepted. | `requirements.md` |
| `before_plan` | before G2 completion | Record skill activation, tool reality, design options, selected approach, rejected alternatives, Dependency Decision, validation strategy, Design Readiness, and `superpowers:writing-plans` decision. | `plan.md` |
| `before_edit` | before editing files | Confirm Requirements Maturity and Design Readiness are satisfied, repo/worktree state, dirty-state handling, affected paths, and preservation of unrelated user changes. | `verification.md` |
| `after_edit` | after editing files | Map changed files to acceptance criteria and check for unintended churn before validation or commit. | `verification.md` |
| `before_commit` | before commit or PR/MR preparation | Run or record local validation, diff review, and sensitive information scan. | `verification.md` |
| `before_pr` | before PR/MR creation or not-applicable decision | Record commit/head state, PR/MR body readiness, review status, and reason when no PR/MR is created. | `verification.md` |
| `after_pr` | after PR/MR creation or not-applicable decision | Record PR/MR URL or not-applicable reason, CI/CD observation plan, terminal check state, and failure follow-up. | `verification.md` |
| `before_final` | before final delivery report | Re-check evidence before claims, merge state, cleanup state, local runtime sync when applicable, risks, follow-ups, and release/version report. | `delivery-report.md` |

## Codex-Specific Hook Rules

Use these rules when Codex or a similar agent runtime is the executor:

- Skill activation evidence must name the skill and show that its instructions were loaded or that a fallback was recorded.
- Tool reality evidence must identify relevant tool availability, such as `gh`, browser tools, subagents, network access, sandbox mode, approval policy, and current working directory when they affect the plan.
- Worktree cleanup evidence must distinguish merged PR/MR state from ancestry checks, because squash merges can leave the original branch tip outside `main`.
- Completion claims require fresh evidence from the current turn or current delivery artifact. A prior statement is not evidence.
- Local runtime sync is required when the repository change is meant to affect locally available Codex skills; record the link command and symlink target.

## Executable Hook Safety

Executable hooks are optional and must be introduced deliberately. If a repository adds scripts such as `.delivery/hooks/before-commit.sh`, the plan must record:

- script path and owner,
- why a declarative Hook Ledger is insufficient,
- dependency classification,
- validation command,
- timeout or failure handling,
- rollback path,
- secret-handling constraints.

Executable hook failures default to `blocked`. Skipping a hook requires `not-applicable` evidence or an accepted `exception`.
