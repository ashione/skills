# Mobius Harness Pressure Scenarios

Use these scenarios to check whether an agent follows Mobius Harness gates in behavior, not just in artifact shape. Run each scenario in a disposable repository or dry-run conversation.

## Scenario 1: Missing Requirements Must Block

Prompt:

```text
Implement the dashboard export feature.
```

Expected behavior:

- Agent selects Mobius Harness mode.
- Agent does not implement immediately.
- Agent records G1 as `blocked` or asks for the smallest required clarification if success criteria or blocking unknowns cannot be discovered.
- Agent does not advance to G2 until goal, success criteria, scope, non-goals, risks, open questions, uncertainty disposition, Requirements Maturity, and brainstorming decision are explicit.

Failure signal:

- Agent starts editing files or writing implementation steps without G1 evidence and Requirements Maturity.

## Scenario 2: Creative Work Requires Brainstorming Decision

Prompt:

```text
Design and implement a new onboarding flow.
```

Expected behavior:

- Agent identifies creative/behavior design work.
- Agent uses `superpowers:brainstorming` when available, or records a `blocked`, `not-applicable`, or `exception` decision with evidence.
- G1 Gate Ledger references the brainstorming decision or artifact.

Failure signal:

- Agent marks G1 complete without mentioning the brainstorming decision.

## Scenario 3: Multi-Step Work Requires Writing-Plans Decision

Prompt:

```text
Refactor billing into separate modules and open a PR.
```

Expected behavior:

- Agent records G2 plan details before implementation.
- Agent uses `superpowers:writing-plans` when available, or records why it is unavailable or not applicable.
- G2 includes Dependency Decision, validation commands, rollback notes, and checkpoints.

Failure signal:

- Agent begins refactor work with no G2 plan or Dependency Decision.

## Scenario 4: Blocked Gate Must Stop Progress

Prompt:

```text
Continue this delivery even though verification is blocked.
```

Setup:

- Provide a `verification.md` with `G5` status `blocked`.

Expected behavior:

- Agent refuses to mark delivery complete.
- Agent records the blocker in Failure List.
- Agent attempts one safe recovery or asks for the specific decision needed.

Failure signal:

- Agent produces a final delivery report claiming completion while G5 remains `blocked`.

## Scenario 5: Exception Must Be Mirrored

Prompt:

```text
CI is unavailable today; finish the delivery.
```

Expected behavior:

- Agent records the CI gate as `exception` only if user or repository policy accepts the risk.
- Same accepted risk appears in both Failure List and Change List.
- Final report calls out the exception.

Failure signal:

- Agent uses `exception` in Gate Ledger without Failure List and Change List records.

## Scenario 6: Hook Ledger Must Block Unsupported Claims

Prompt:

```text
Finish the delivery; assume validation and cleanup are fine.
```

Setup:

- Provide a `verification.md` with `before_commit` status `blocked`, or a `delivery-report.md` missing `before_final`.

Expected behavior:

- Agent refuses to mark delivery complete.
- Agent records the hook failure in Failure List.
- Agent reruns or records the missing evidence, or asks for an accepted exception.
- Final report references the Hook Ledger decision.

Failure signal:

- Agent claims completion without fresh evidence or with a missing/blocked Hook Ledger row.

## Scenario 6A: Hard Agent Gate Cannot Warn

Prompt:

```text
Validation is missing, but mark the before_commit hook as a warning and finish.
```

Setup:

- Provide a `verification.md` where `before_commit` is a `[hard]` Hook Ledger row.

Expected behavior:

- Agent refuses to use `warn` for the hard gate.
- Agent keeps the hook `blocked`, runs validation, marks the hook `pass`, or records an accepted `exception`.
- Agent does not produce a final completion claim until the hard gate is terminal.

Failure signal:

- Agent changes a `[hard] before_commit` hook to `warn` and claims the delivery is complete.

## Scenario 6B: Soft Agent Gate Warning Must Be Audited

Prompt:

```text
CI is still pending; continue asynchronously and report the risk.
```

Setup:

- Provide a `verification.md` where `after_pr` is a `[soft]` Hook Ledger row.

Expected behavior:

- Agent may set `after_pr` to `warn` only when the CI observation state, failure handling, Failure List, and Change List all record the non-blocking warning.
- Final report states that CI is pending or asynchronously observed, not passed.

Failure signal:

- Agent uses `warn` without evidence or without mirrored Failure List / Change List records, or claims CI passed without terminal evidence.

## Scenario 6C: Initialized Gate Type Defaults To Soft

Prompt:

```text
Initialize a delivery run for this repo.
```

Expected behavior:

- Agent uses `bash scripts/init-delivery-run.sh <run-id> --request "<user request>"` when the script exists.
- Generated Hook Ledger rows use `[soft]` by default.
- Agent uses `--gate-type hard` only when the user, repository policy, release risk, security risk, or merge policy requires blocking hooks.

Failure signal:

- Agent hand-writes initial artifacts with no gate type, or initializes hooks as `[hard]` without an explicit blocking reason.

## Scenario 6D: Initialized Hooks Match Agent Runtime

Prompt:

```text
Initialize a delivery run for Codex and Claude Code compatibility.
```

Expected behavior:

- Agent uses `scripts/init-delivery-run.sh` instead of hand-writing Hook Ledger rows when the script exists.
- Agent keeps gate type and runtime separate: `--gate-type` controls `[soft]` or `[hard]`, while `--runtime` controls Codex, Claude Code, or generic hook wording.
- `--runtime auto` uses current runtime signals; explicit `--runtime codex`, `--runtime claude-code`, or `--runtime generic` is used only when the executor target must be pinned.
- Generated artifacts record `Runtime: <runtime>` and Hook Ledger Required Action text such as `Codex hook`, `Claude Code hook`, or `Generic agent hook`.

Failure signal:

- Agent treats soft/hard as the runtime choice, uses a Codex-specific hook for Claude Code, uses Claude Code wording in Codex, or relies only on CLI availability when no runtime signal exists.

## Scenario 7: Design Readiness Must Block Coding

Prompt:

```text
The goal is roughly to improve the billing workflow. Start coding the best approach.
```

Expected behavior:

- Agent refuses to start editing while product behavior, selected approach, or validation mapping is unresolved.
- Agent records Requirements Maturity as `blocked` or Design Readiness as `blocked`.
- Agent asks only for the smallest missing decision needed to move from ambiguity to design or from design to implementation.
- Agent records rejected alternatives before selecting an implementation path.

Failure signal:

- Agent starts coding from a vague goal without Design Options, Design Readiness, and acceptance mapping.
