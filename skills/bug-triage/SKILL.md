---
name: bug-triage
description: Use when a bug report, crash, regression, failed test, or production symptom needs severity, reproducibility assessment, impact scope, suspected cause areas, and next diagnostic actions.
---

# Bug Triage

## Intent

Turn an ambiguous bug report into an actionable triage record with severity, reproducibility, impact, evidence gaps, and the next diagnostic step.

## When to Use

- User-reported bugs, crashes, regressions, flaky failures, production symptoms, or support escalations.
- Early triage before root-cause debugging or fix planning.
- Do not use when root cause is already proven and the task is simply implementation.

## Inputs

- `bug_report`: Bug report with observed symptoms.
- `system_context`: Runtime, version, and dependency context.

## Bug Classes

Classify the bug before severity. Class determines what evidence matters.

| Class | Primary Evidence | First Diagnostic Move | Escalate Fast If |
|-------|------------------|-----------------------|------------------|
| Crash/hang | Stack trace, dump, watchdog, reproduction path | Capture trace and minimal input/state | Startup, save, auth, or payment path blocked |
| Regression | Last known good version, changed commits, failing workflow | Bisect or compare release/config diff | Recent release affects broad audience |
| Data corruption/loss | Before/after records, audit logs, backups | Stop writes, preserve evidence, assess blast radius | Destructive or irreversible writes continue |
| Security/privacy | Access path, actor, exposed data, logs | Contain access, preserve audit trail, notify owner | Cross-tenant or sensitive data exposure |
| Performance | Latency, throughput, CPU/memory/I/O, plan/profile | Compare baseline and isolate bottleneck | SLO breach or cascading failure |
| Flaky/intermittent | Frequency, timing, environment, race signals | Collect repeated runs and timing/log correlation | CI/release gate blocked |
| UI/UX defect | Browser/device, viewport, interaction path, screenshot | Reproduce on supported matrix | Critical workflow is unusable |
| Integration failure | Dependency status, request/response, retry/error codes | Trace boundary call and fallback behavior | Data sync/payment/notification loss |

## Reproduction Strategy

| Repro Status | What to Do |
|--------------|------------|
| Always | Reduce to shortest deterministic path and add regression test target. |
| Intermittent | Run repeated attempts, collect timing, random seed, concurrency, logs, and environment deltas. |
| Environment-specific | Capture OS/browser/device/version/config/tenant/region and compare against a known-good environment. |
| Unknown | Define the minimum reproduction checklist before assigning root cause or fix. |

## Instructions

1. Classify bug class using `Bug Classes`; state why that class fits.
2. Extract the observable facts: affected user/action, exact symptom, expected behavior, first known occurrence, frequency, environment, version/build, logs/errors, recent changes, and affected scope.
3. Separate evidence from inference. Mark missing data explicitly instead of filling gaps with assumptions.
4. Assign severity using impact and urgency:
   - `S0`: system-wide outage, data loss/corruption, security exposure, or no viable workaround.
   - `S1`: major workflow blocked for many users or paid/customer-critical path broken.
   - `S2`: important function degraded, limited audience, workaround exists.
   - `S3`: minor defect, cosmetic issue, low impact, or rare edge case.
5. Assign confidence: `High` only with direct logs/repro steps; `Medium` with consistent symptoms; `Low` with sparse or conflicting evidence.
6. Assess reproducibility using `Reproduction Strategy`. Provide the shortest reproduction plan and expected observation.
7. List suspected cause areas in priority order, each with evidence for and against. Do not present guesses as root cause.
8. Define next actions: data to collect, owner type, test/log/query to run, mitigation if severity is S0/S1, and escalation trigger.

## Output Standard

- Format: `Summary`, `Bug Class`, `Severity`, `Impact`, `Reproducibility`, `Evidence`, `Suspected Areas`, `Next Actions`.
- Include at least one concrete command, test, log query, UI path, or diagnostic artifact when possible.
- State what would change the severity.
- Do not skip repro assessment.
- Do not propose code changes before the minimum evidence needed to avoid guessing.

## Examples

Input: App crashes when opening empty workspace.

Output: Summary: opening an empty workspace crashes before project metadata loads. Severity: S1 if this blocks startup for all new workspaces; S2 if existing workspaces still work. Reproducibility: Unknown until tested with a freshly created empty workspace on the reported build. Evidence: crash symptom only; no stack trace yet. Suspected Areas: workspace metadata loader, empty project index handling, startup route guard. Next Actions: reproduce with a new empty workspace, capture stack trace, add regression test for empty metadata path, then guard the loader if confirmed.
