# Hook Policy Reference

Use this reference when a delivery needs Claude Code, Codex, or similar agent-runtime enforcement points around skill use, tool reality, worktree hygiene, review, CI/CD, cleanup, or local runtime sync.

## Hook Model

Hooks are auditable controls that run inside the existing Mobius phase gates. Gates decide whether a phase may advance; hooks record the required action that must happen before or after a risky agent operation.

Hooks start as declarative records. Do not execute arbitrary repository hook scripts unless a repository explicitly defines them and the plan records a `new-dependency-required` or `existing-toolchain` Dependency Decision with validation and rollback notes.

Every Standard and Strict Delivery Episode Package must include a Hook Ledger table in each persisted phase artifact:

| Hook | Trigger | Required Action | Status | Evidence | Failure Handling |
|---|---|---|---|---|---|

Every Hook Ledger `Required Action` must start with an agent gate mode:

- `[hard]`: blocking gate. Claude Code, Codex, or the executor must not advance when required evidence is missing, failed, or unresolved.
- `[soft]`: advisory gate. The executor may continue on a warning, but must record evidence, failure handling, and the same warning in Failure List and Change List.

Initialization defaults to `[soft]`. Use `[hard]` only when a user decision, repository policy, release gate, security constraint, merge policy, or high-risk operation must block progress until resolved. Gate strength is independent from runtime-specific hook wording: `[soft] Codex hook: ...` and `[hard] Codex hook: ...` differ only in enforcement semantics, while Codex, Claude Code, and generic hook text differ in evidence expectations.

Hook statuses use this terminal model:

- `pass`: required action ran or was recorded with evidence.
- `not-applicable`: action does not apply and the reason is evidenced.
- `warn`: soft gate produced a warning; the phase may advance only when evidence, failure handling, Failure List, and Change List record the non-blocking risk.
- `exception`: action was not fully satisfied, but the user or repository policy accepted the risk; mirror it in Failure List and Change List.
- `blocked`: required action is missing, failed, or unresolved; the phase must not advance.

Hard gates cannot use `warn`. Soft gates cannot be silently ignored; a soft-gate warning without Failure List and Change List records is invalid.

## Agent Runtime Gate Model

Mobius Harness supports both Claude Code and Codex by keeping gate semantics in the Markdown ledger instead of depending on a runtime-specific hook API.

| Runtime | Runtime Evidence | Hard Gate Behavior | Soft Gate Behavior |
|---|---|---|---|
| Claude Code | Skill/tool invocation, repo instruction reads, Todo state, command output, PR/MR evidence, or explicit unavailable reason. | Stop before the next phase or risky action until the ledger row is `pass`, `not-applicable`, or accepted `exception`. | Continue only with `warn` evidence and mirrored Failure List / Change List rows. |
| Codex | Skill file load, tool availability, sandbox/approval state, command output, browser/subagent availability, PR/MR evidence, or explicit unavailable reason. | Stop before edits, commits, final claims, or other gated transitions when evidence is missing. | Continue on advisory checks such as async CI observation only after recording the warning. |
| Other agent runtime | Runtime capability statement plus evidence prefix accepted by the artifact interface. | Follow the same hard gate blocking model. | Follow the same soft gate warning model. |

Record the runtime under the phase evidence or Hook Ledger evidence when it affects the gate result. If a runtime cannot enforce a hard gate, keep the hook `blocked` or record an accepted `exception`; do not downgrade a hard gate to `warn`.

## Runtime-Specific Hook Initialization

When the repository provides `scripts/init-delivery-run.sh`, initialize Standard or Strict artifacts with:

```bash
bash scripts/init-delivery-run.sh <run-id> --request "<user request>" [--gate-type soft|hard] [--runtime auto|codex|claude-code|claude|generic]
```

Use `--runtime auto` by default. Auto-detection should rely on current agent-runtime environment signals, not merely whether both CLIs are installed on the machine. Codex signals include `CODEX_SHELL`, `CODEX_CI`, `CODEX_THREAD_ID`, or a Codex bundle identifier. Claude Code signals include `CLAUDECODE`, `CLAUDE_CODE`, `CLAUDE_SESSION_ID`, `CLAUDECODE_SESSION_ID`, or a Claude bundle identifier. If no dedicated runtime is evident, initialize generic hook actions.

Pin the runtime explicitly when the artifact is being prepared for a different executor than the current one, or when a repository policy requires a named evidence model:

| Runtime Flag | Hook Wording | Evidence Focus |
|---|---|---|
| `--runtime codex` | `Codex hook` | Skill file loads, tool calls, sandbox/approval state, connector or plugin availability, command output, and explicit unavailable reasons. |
| `--runtime claude-code` | `Claude Code hook` | Skill invocation, tool output, Todo state, repo instruction reads, command output, and explicit unavailable reasons. |
| `--runtime claude` | `Claude Code hook` | Input alias for `--runtime claude-code`; generated artifacts still record `Runtime: claude-code`. |
| `--runtime generic` | `Generic agent hook` | Runtime capability statement, supported tool output, command output, and explicit unavailable reasons. |

The runtime flag must not silently change the gate type. Use `--gate-type hard` only for blocking semantics and `--gate-type soft` for advisory semantics.

## Required Hooks

For Standard and Strict deliveries, the combined artifacts must contain exactly one terminal row for each hook below.

| Hook | Trigger | Required Action | Owning Artifact |
|---|---|---|---|
| `before_requirements` | before G1 completion | `[soft]` Read the user goal, applicable repo instructions, relevant specs/docs, uncertainty disposition, Requirements Maturity, and whether `superpowers:brainstorming` is used, not applicable, unavailable, or excepted. | `requirements.md` |
| `before_plan` | before G2 completion | `[soft]` Record skill activation, tool reality, design options, selected approach, rejected alternatives, Dependency Decision, validation strategy, Design Readiness, and `superpowers:writing-plans` decision. | `plan.md` |
| `before_edit` | before editing files | `[soft]` Confirm Requirements Maturity and Design Readiness are satisfied, repo/worktree state, dirty-state handling, affected paths, and preservation of unrelated user changes. | `verification.md` |
| `after_edit` | after editing files | `[soft]` Map changed files to acceptance criteria and check for unintended churn before validation or commit. | `verification.md` |
| `before_commit` | before commit or PR/MR preparation | `[soft]` Run or record local validation, diff review, and sensitive information scan. | `verification.md` |
| `before_pr` | before PR/MR creation or not-applicable decision | `[soft]` Record commit/head state, PR/MR body readiness, review status, and reason when no PR/MR is created. | `verification.md` |
| `after_pr` | after PR/MR creation or not-applicable decision | `[soft]` Record PR/MR URL or not-applicable reason, CI/CD observation plan, terminal check state, and failure follow-up. | `verification.md` |
| `before_final` | before final delivery report | `[soft]` Re-check evidence before claims, merge state, cleanup state, local runtime sync when applicable, risks, follow-ups, and release/version report. | `delivery-report.md` |

## Claude Code and Codex Hook Rules

Use these rules when Claude Code, Codex, or a similar agent runtime is the executor:

- Skill activation evidence must name the skill and show that its instructions were loaded or that a fallback was recorded.
- Tool reality evidence must identify relevant tool availability, such as `gh`, browser tools, subagents, network access, sandbox mode, approval policy, and current working directory when they affect the plan.
- Claude Code evidence can cite skill invocation, tool output, Todo state, and repository instruction reads; Codex evidence can cite skill file loads, tool calls, sandbox/approval state, command output, and connector or plugin availability.
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
