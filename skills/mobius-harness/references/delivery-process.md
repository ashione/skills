# Delivery Process Reference

Use this reference for trigger rules, execution modes, phase gates, phase state, blockers, and change control.

## Trigger and Mode Standard

Use Mobius Harness when a user asks to implement, deliver, create a PR/MR, follow CI/CD, handle a feature end-to-end, or turn a plan/spec into working software. Do not force Mobius Harness for narrow analysis requests such as isolated SQL tuning, API review, bug classification, or commit message writing unless the task expands into delivery.

Choose one mode at the start:

- `Lightweight`: small, low-risk changes. Persisted artifacts are optional, but the final response must include a compact Gate Ledger and the same delivery facts.
- `Standard`: normal code delivery. Create `.delivery/runs/<run-id>/`, maintain the four core artifacts, and keep a Gate Ledger for every phase.
- `Strict`: high-risk, release, security, migration, multi-module, or user-requested audit work. Persist every phase/subphase state transition, gate decision, and gate exception.

Generate `run-id` from the task name in kebab-case, for example `add-user-auth`. If it already exists, append a date or short sequence such as `add-user-auth-20260517` or `add-user-auth-2`. Avoid spaces, random long hashes, and non-descriptive ids.

## Delivery Process Standard

Mobius Harness follows these ordered phases. Each phase has an exit gate; do not move to the next phase until the gate is satisfied or the exception is explicitly recorded.

### Superpowers Planning Hooks

Mobius Harness may use Superpowers skills as phase-level quality gates, but the harness remains the accountable delivery loop.

| Situation | Required Decision |
|---|---|
| Creative work, new behavior, unclear product intent, UX shaping, or competing solution paths | Use `superpowers:brainstorming`, or record why it is not applicable. |
| Multi-step implementation, Standard mode, Strict mode, risky refactor, migration, or work that another agent may execute | Use `superpowers:writing-plans`, or record why it is not applicable. |
| Already-approved external spec or plan | Record the source artifact and mark the Superpowers step `not-applicable` unless new ambiguity appears. |

Record the decision in the relevant phase state:

- Requirements phase: brainstorming used, not applicable, blocked, or excepted.
- Plan phase: writing-plans used, not applicable, blocked, or excepted.
- Gate Ledger evidence: skill name, artifact path, user decision, or reason not applicable.

When Superpowers is available and used:

- Record `superpowers:brainstorming` output as a spec path, user approval decision, or final-response design section.
- Record `superpowers:writing-plans` output as a plan path or plan section that maps to `.delivery/runs/<run-id>/plan.md`.
- If the platform does not expose Superpowers, mark the decision `not-applicable` only when an equivalent repo spec or plan exists; otherwise use `blocked` or `exception`.

## Requirements and Design Maturity Standard

The agent must not start coding from vague intent. Requirements and design maturity are explicit phase controls, not writing style preferences.

Requirements phase must record:

- success criteria that can be verified,
- scope and non-goals,
- constraints and compatibility expectations,
- open questions and user decisions,
- uncertainty disposition: `blocking`, `accepted`, `deferred`, or `not-applicable`,
- `Requirements Maturity`: `ready-for-design` only when no blocking unknown remains.

Plan phase must record:

- at least one selected approach and the reason it was chosen,
- rejected alternatives with tradeoffs,
- affected areas and interfaces,
- acceptance criteria mapped to implementation and validation steps,
- validation strategy and rollback notes,
- `Design Readiness`: `ready-for-implementation` only when another agent can implement without inventing product behavior or architecture.

If requirements maturity or design readiness is not satisfied, keep the related gate or hook `blocked`. Ask the user only for the smallest decision needed to unblock.

## Dependency Decision Standard

Plan phase must classify dependency impact before implementation:

| Decision | Meaning | Required Evidence |
|---|---|---|
| `no-new-dependency` | Uses existing Markdown, templates, scripts, or platform-provided skills/plugins. | Existing file, skill, plugin, or command reference. |
| `existing-toolchain` | Uses tools already required by the repo or CI. | Command, workflow, or README reference plus fallback. |
| `new-dependency-required` | Adds package, binary, CI action, external service, MCP server, plugin install requirement, or platform-specific runtime capability. | Purpose, alternatives, install location, version constraint, validation command, CI/CD impact, and rollback notes. |

Record the Dependency Decision in `plan.md` and the `G2` Gate Ledger evidence. If the dependency cannot be installed or observed, keep G2 `blocked` unless the user or repository policy accepts an exception.

### Gate Enforcement Standard

Gates are blocking controls. They are not prose summaries or optional checklist items.

Allowed gate statuses:

| Status | Meaning | May Advance |
|---|---|---|
| `pass` | Required evidence exists and satisfies the gate. | Yes |
| `not-applicable` | Gate does not apply, and the reason is evidenced. | Yes |
| `exception` | Gate is not fully satisfied, but the user or repository policy accepted the risk. Failure List and Change List must both record it. | Yes |
| `blocked` | Required evidence is missing, failed, or unresolved. | No |

Gate rules:

- A phase or subphase cannot be marked `complete` while any related gate is `blocked`.
- A phase transition must include a Gate Ledger row with gate id, required evidence, status, evidence pointer, and exception record when relevant.
- A skipped command, missing artifact, unresolved question, failing CI job, or unavailable scanner is `blocked` until it is converted to `not-applicable` or `exception` with evidence.
- An exception must identify who or what accepted the risk: a user decision, repository instruction, documented policy, or explicit out-of-scope rationale.
- For `Standard` and `Strict` deliveries, run `bash scripts/validate-delivery-run.sh .delivery/runs/<run-id>` before the final report when the script exists. Record failure output in Failure List and do not complete the delivery until it passes or is explicitly excepted.

### CI/CD Follow-up Standard

CI/CD follow-up is asynchronous by default during small iterative PR/MR updates. The agent should push the update, record the head SHA, check URLs, and planned next observation, then return control to the user unless one of these conditions applies:

- the user explicitly asks to wait for CI/CD,
- the delivery is about to merge,
- the delivery is about to release,
- repository policy requires terminal checks before the next action,
- a previous observed check failed and the user chooses to wait for the fix run.

When waiting is not selected, record the CI/CD state as `async-observed` or `pending-observation` with evidence. Do not claim CI/CD passed until the current head SHA has terminal successful checks.

### Hook Enforcement Standard

Hooks are required controls inside phase gates for Standard and Strict deliveries. Use `hook-policy.md` for the required hook list, trigger timing, Codex-specific evidence rules, and executable hook safety.

Hook rules:

- A phase or subphase cannot be marked `complete` while any related hook is `blocked`.
- A hook row must include hook id, trigger, required action, status, evidence pointer, and failure handling when relevant.
- Missing skill activation evidence, missing tool reality evidence, skipped diff review, skipped sensitive scan, unobserved CI/CD, missing cleanup evidence, or missing local runtime sync is `blocked` until converted to `not-applicable` or `exception` with evidence.
- Executable repository hooks are optional; they require an explicit Dependency Decision and fail closed to `blocked`.

### Adversarial Review Standard

Every phase result must be challenged from multiple roles before it is treated as final. The Review Ledger records those challenges and their resolution.

Required review ids by artifact:

| Artifact | Required Reviews |
|---|---|
| `requirements.md` | `requirements_product`, `requirements_engineering`, `requirements_risk` |
| `plan.md` | `plan_architecture`, `plan_validation`, `plan_risk` |
| `verification.md` | `verification_implementation`, `verification_security`, `verification_ci` |
| `delivery-report.md` | `report_delivery`, `report_operations`, `report_user` |

Review rules:

- Each review row must identify the role, perspective, challenge, status, resolution, and evidence.
- Review status must be `pass`, `not-applicable`, `exception`, or `blocked`.
- A blocked review prevents that phase result from becoming final and prevents the next execution phase.
- An exception must identify who or what accepted the risk and must be mirrored in Failure List and Change List.
- The agent may perform the review itself unless the user explicitly asks for subagents, but it must use distinct perspectives rather than one generic self-review.

Large, risky, or blocked phases must be split into subphases. A subphase uses the same status record format as a phase, but with a narrower goal and checklist.

Recommended subphase naming:

- `requirements.discovery`
- `requirements.acceptance`
- `plan.repo-inspection`
- `plan.validation-strategy`
- `development.worktree`
- `implementation.backend`
- `implementation.frontend`
- `verification.local-checks`
- `verification.diff-review`
- `delivery.pr`
- `delivery.ci-followup`

| Gate | Phase | Required work | Exit gate |
|---|---|---|---|
| `G1` | Requirements | Clarify goal, background, success criteria, scope, non-goals, risks, open questions, user decisions, uncertainty disposition, Requirements Maturity, and the `superpowers:brainstorming` decision. | Requirements are specific enough to design, implement, and verify without unresolved blocking unknowns. |
| `G2` | Plan | Inspect the repo, compare design options, select an approach, record rejected alternatives, select specialist skills, define implementation steps, validation commands, acceptance criteria, rollback notes, checkpoints, Dependency Decision, Design Readiness, and the `superpowers:writing-plans` decision. | Another agent could implement from the plan without choosing strategy, product behavior, architecture, or dependency policy. |
| `G3` | Local Development | Follow `local-repo-development`, including worktree or branch selection and preservation of unrelated changes. | Worktree or branch, base ref, and dirty-state handling are recorded. |
| `G4` | Implementation | Make the scoped change and keep the diff coherent. | Changed files are intentional and mapped to acceptance criteria. |
| `G5` | Verification | Run local checks, review the diff, and scan for sensitive information. | Validation outcomes, diff review, sensitive scan, and unresolved risks are recorded. |
| `G6` | PR/MR | Commit and open PR/MR when applicable. | PR/MR URL or not-applicable reason is recorded. |
| `G7` | CI/CD | Record CI/CD check state when remote checks exist and choose async follow-up or terminal waiting by policy. | Terminal CI/CD state, async observation state, or not-applicable reason is recorded with evidence. |
| `G8` | Report | Summarize what was delivered and what remains. | Delivery report is complete and can be sent to the user or attached to PR/MR. |

## Phase State Standard

Every phase and subphase must record state with these sections:

- `Goal`: the concrete outcome this phase or subphase must achieve.
- `Checklist`: objective checks required to exit this phase or subphase.
- `Gate Ledger`: gate id, required evidence, status, evidence pointer, and exception detail.
- `Hook Ledger`: hook id, trigger, required action, status, evidence pointer, and failure handling.
- `Review Ledger`: review id, role, perspective, challenge, status, resolution, and evidence.
- `Todo List`: unfinished actions, preferably with status such as `todo`, `doing`, `blocked`, or `done`.
- `Failure List`: failed commands, blocked checks, rejected assumptions, CI/CD failures, defects found during review, or unresolved risks.
- `Change List`: decisions made, files changed, requirement changes, scope changes, validation changes, or follow-up changes.

Use these status values:

- Phase status: `draft`, `active`, `blocked`, `complete`, `deferred`.
- Todo status: `todo`, `doing`, `blocked`, `done`, `deferred`.
- Failure status: `open`, `investigating`, `fixed`, `accepted`, `deferred`.

When transitioning phases:

- mark checklist items as complete or explicitly deferred,
- update the related Gate Ledger row to `pass`, `not-applicable`, `exception`, or `blocked`,
- move unfinished Todo List items into the next phase,
- carry unresolved Failure List items forward until resolved or accepted,
- record scope or implementation changes in Change List,
- keep enough evidence for another agent to resume,
- do not mark a phase or subphase `complete` without evidence or an explicit accepted exception.

Recommended phase/subphase block:

```md
## <Phase or Subphase Name>

Status: draft | active | blocked | complete | deferred
Phase: <phase-name>
Updated: <timestamp or phase marker>
Evidence: <commands, files, links, PR/MR, CI/CD, or reason unavailable>

### Goal

### Checklist

- [ ] ...

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|

### Hook Ledger

| Hook | Trigger | Required Action | Status | Evidence | Failure Handling |
|---|---|---|---|---|---|

### Review Ledger

| Review | Role | Perspective | Challenge | Status | Resolution | Evidence |
|---|---|---|---|---|---|---|

### Todo List

| Item | Status | Owner | Evidence |
|---|---|---|---|

### Failure List

| Failure | Impact | Root Cause | Resolution | Status |
|---|---|---|---|---|

### Change List

| Change | Reason | Files/Links | Approval |
|---|---|---|---|
```

## Blocker and Change Control

When blocked:

1. Self-check discoverable causes first.
2. Record the issue in Failure List.
3. Attempt one minimal recovery action when safe.
4. If still blocked, ask the user for the specific decision needed.
5. Record the user decision or accepted risk in Change List.

Record a Change List item for any:

- scope change,
- acceptance criteria change,
- validation strategy change,
- dependency decision change,
- branch or worktree change,
- skipped gate or gate exception,
- accepted failing check,
- CI/CD failure accepted as out of scope,
- release or rollback change.
