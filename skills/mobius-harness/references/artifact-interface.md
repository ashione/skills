# Artifact Interface Reference

Use this reference for Delivery Episode Package files, required sections, and evidence rules.

## Delivery Episode Package

For long or risky tasks, Mobius Harness records work under:

```text
.delivery/runs/<run-id>/
  requirements.md
  plan.md
  verification.md
  delivery-report.md
```

These files are execution artifacts and `.delivery/runs/` is ignored by git by default.

For short tasks, the final response may replace persisted artifacts, but it still needs to include the same facts: requirements, implementation summary, validation, review, sensitive information scan, PR or MR URL when present, CI/CD state, risks, and follow-ups.

## Artifact Standard

Use Markdown for all persisted artifacts. Every artifact must include:

- `Status`: one of `draft`, `active`, `blocked`, `complete`, `deferred`.
- `Phase`: matching the current delivery phase.
- `Updated`: timestamp or clear phase marker.
- `Evidence`: links, commands, file paths, PR/MR URL, CI/CD URL, or explicit reason when evidence is unavailable.
- Phase/subphase records using `Goal`, `Checklist`, `Gate Ledger`, `Hook Ledger`, `Review Ledger`, `Todo List`, `Failure List`, and `Change List`.

Evidence is mandatory. A completed phase, subphase, or final delivery without evidence is invalid.

When Hook Ledger actions use runtime-specific wording, record `Runtime: codex`, `Runtime: claude-code`, or `Runtime: generic` near the artifact header or in the Hook Ledger evidence. The runtime label names the evidence model; it does not decide whether the hook is a soft or hard gate.

## Gate Ledger

Every persisted phase/subphase record must include a Gate Ledger table:

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|

Gate rules:

- Use gate ids `G1` through `G8` from `delivery-process.md`.
- `Status` must be one of `pass`, `not-applicable`, `exception`, or `blocked`.
- `Evidence` must point to commands, files, diffs, PR/MR URLs, CI/CD URLs, user decisions, or a reason evidence is unavailable.
- `Exception` is required when `Status` is `exception`; record the same accepted risk in Failure List and Change List.
- A `blocked` gate prevents phase completion and final delivery completion.
- For Standard and Strict deliveries, the combined artifacts must contain exactly one terminal row for every gate from `G1` through `G8`.

## Hook Ledger

Every persisted phase/subphase record must include a Hook Ledger table:

| Hook | Trigger | Required Action | Status | Evidence | Failure Handling |
|---|---|---|---|---|---|

Hook rules:

- Use hook ids from `hook-policy.md`.
- `Required Action` must start with `[hard]` or `[soft]`.
- `Required Action` should also name the runtime-specific hook wording when it matters, such as `Codex hook`, `Claude Code hook`, or `Generic agent hook`.
- `Status` must be one of `pass`, `warn`, `not-applicable`, `exception`, or `blocked`.
- `warn` is valid only for `[soft]` hooks; it must record evidence, failure handling, and matching Failure List and Change List rows.
- `Evidence` must use the same evidence prefixes as Gate Ledger evidence.
- `Failure Handling` is required when `Status` is `exception`; record the same accepted risk in Failure List and Change List.
- `Failure Handling` is required when `Status` is `warn`; record the same warning in Failure List and Change List.
- A `blocked` hook prevents phase completion and final delivery completion.
- For Standard and Strict deliveries, the combined artifacts must contain exactly one terminal row for every required hook from `hook-policy.md`.

## Review Ledger

Every persisted phase/subphase record must include a Review Ledger table:

| Review | Role | Perspective | Challenge | Status | Resolution | Evidence |
|---|---|---|---|---|---|---|

Review rules:

- Use review ids from `delivery-process.md`.
- `Status` must be one of `pass`, `not-applicable`, `exception`, or `blocked`.
- `Evidence` must use the same evidence prefixes as Gate Ledger evidence.
- `Resolution` is required for every review and must state how the challenge was handled.
- `Resolution` must identify accepted risk when `Status` is `exception`; record the same accepted risk in Failure List and Change List.
- A `blocked` review prevents phase completion and final delivery completion.
- The combined artifacts must contain exactly one terminal row for every required review id from `delivery-process.md`.

Evidence format:

- Commands: `cmd:<command>` plus result, short output summary, and failure log path or excerpt when relevant.
- Files: `file:<repo-relative-path>`.
- PR/MR or CI/CD URLs: `url:<https-url>`, plus branch, status, job name, or terminal state.
- User decisions: `decision:<quoted or summarized decision>`.
- Reasons or not-applicable cases: `reason:<explicit reason>`.
- Sensitive data: record key names or file paths only; never record secret values.

## Required Sections

### requirements.md

- `Phase State`
- `Gate Ledger`
- `Hook Ledger`
- `Review Ledger`
- `Superpowers Decisions`
- `Goal`
- `Background`
- `Success Criteria`
- `Scope`
- `Non-Goals`
- `Risks`
- `Open Questions`
- `User Decisions`
- `Issue and Prior Attempts`
- `Minimum Skill Dependencies`
- `Uncertainty Register`
- `Requirements Maturity`

### plan.md

- `Phase State`
- `Gate Ledger`
- `Hook Ledger`
- `Review Ledger`
- `Repo Findings`
- `Specialist Skills`
- `Minimum Skill Dependencies`
- `Superpowers Decisions`
- `Prior Attempt Comparison`
- `Design Options`
- `Design Readiness`
- `Dependency Decision`
- `Implementation Steps`
- `Validation Strategy`
- `Validation Prerequisites`
- `Acceptance Criteria`
- `Rollback Notes`
- `Checkpoints`

### verification.md

- `Phase State`
- `Gate Ledger`
- `Hook Ledger`
- `Review Ledger`
- `Local Commands`
- `Command Results`
- `Diff Review`
  - `Requirements Compliance`
  - `Implementation Quality`
  - `Test Adequacy`
  - `Security and Sensitive Information`
- `Sensitive Information Scan`
- `PR/MR`
- `CI/CD`
- `Unresolved Risks`

### delivery-report.md

- `Phase State`
- `Gate Ledger`
- `Hook Ledger`
- `Review Ledger`
- `Summary`
- `Requirements Result`
- `Implementation Summary`
- `Changed Files`
- `Validation Summary`
- `PR/MR and CI/CD`
- `Risks and Follow-ups`
- `Release Notes`
- `Version or Release Report`

## Templates

Use `artifact-templates.md` when creating new persisted Delivery Episode Package files or when a phase needs a canonical table layout.

## Example Fixtures

Committed examples live under `examples/delivery-runs/`:

- `passing`: complete Delivery Episode Package that must pass validation.
- `exception`: complete package with an accepted exception mirrored in Failure List and Change List.
- `blocked`: negative fixture that must fail validation because G1 is blocked.
