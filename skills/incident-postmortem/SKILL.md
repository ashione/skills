---
name: incident-postmortem
description: Use when writing a blameless postmortem for an outage, degradation, data incident, security incident, missed SLA, or operational near miss.
---

# Incident Postmortem

## Intent

Create a blameless incident record that explains what happened, who was affected, why existing safeguards failed, and which preventive actions will reduce recurrence.

## When to Use

- Production outages, degradations, data incidents, security incidents, missed SLAs, failed releases, or serious near misses.
- After immediate mitigation, when the goal is learning and prevention.
- Do not use for live incident command; use it after or during a retrospective phase.

## Inputs

- `incident_log`: Incident events and timestamps.
- `impact`: User/business impact statement.

## Incident Classes

Classify the incident before writing causes and actions.

| Class | Extra Evidence Required | Prevention Focus |
|-------|-------------------------|------------------|
| Availability outage | Error rate, latency, saturation, dependency status | Redundancy, load shedding, rollout guardrails, alert timing |
| Performance degradation | p95/p99, throughput, resource graphs, slow traces | Capacity, query/profile budgets, backpressure, autoscaling |
| Data loss/corruption | Affected records, write path, restore point, audit log | Write controls, validation, backups, replay/repair tooling |
| Security/privacy | Exposed data, access path, actor, containment time | Access control, detection, auditability, disclosure workflow |
| Failed release/change | Change diff, rollout timeline, canary signal, rollback path | Release gates, canary coverage, feature flags, ownership |
| Dependency/vendor | Upstream status, retry/fallback behavior, contracts | Circuit breakers, fallback modes, dependency SLOs |
| Near miss | What almost failed, detection source, avoided impact | Earlier detection, safer defaults, rehearsal/runbook gaps |

## Cause Analysis

Use these distinctions consistently:

| Term | Meaning |
|------|---------|
| Trigger | The immediate event that started the incident. |
| Root cause | The system condition that made the trigger harmful. |
| Contributing factor | A condition that increased likelihood, duration, or impact. |
| Detection gap | Why the team did not know sooner or with enough detail. |
| Response gap | Why mitigation took longer or required ad hoc decisions. |
| Recovery factor | What helped reduce duration or impact. |

## Instructions

1. Classify incident class using `Incident Classes`; collect the class-specific extra evidence.
2. Normalize the incident facts: service, start/end time, detection source, severity, affected users/regions, customer/business impact, and data/security impact if any.
3. Build a chronological timeline from first signal through full recovery. Mark uncertain timestamps as approximate.
4. Separate trigger, root cause, contributing factors, detection gaps, response gaps, and recovery factors using `Cause Analysis`. Avoid person-blame language.
5. Analyze why existing controls did not prevent, detect, or limit the incident. Include monitoring, tests, rollout controls, runbooks, ownership, dependency assumptions, and rollback capability.
6. Document what went well, what went poorly, and where responders lacked data or authority.
7. Define corrective actions with owner, due date, success metric, and verification method. Split immediate mitigations from durable prevention.
8. Identify follow-up risks that remain after the proposed actions.

## Output Standard

- Required sections: `Summary`, `Incident Class`, `Impact`, `Timeline`, `Trigger`, `Root Cause`, `Contributing Factors`, `Detection and Response`, `What Worked`, `What Failed`, `Actions`, `Residual Risk`.
- Every action must be measurable and assigned to an owner role or team.
- At least one action must address prevention, one detection/alerting or diagnosis, and one response/recovery unless already covered with evidence.
- Include customer-facing wording only if requested; keep the internal postmortem precise.
- Do not use blame language such as "operator error" without describing the system condition that allowed the error.
- Do not mark root cause final when the evidence only supports a hypothesis.

## Examples

Input: Database CPU spike caused 45-min API outage.

Output: Summary: API requests failed for 45 minutes after a release increased database CPU saturation. Impact: affected API users during the incident window; quantify request failure rate and customer count if available. Root Cause: hot query path lacked an index required by the new access pattern. Contributing Factors: release canary did not include production-like query volume; alert fired after saturation. Actions: add the index, add query budget checks in CI, expand canary metrics to include DB CPU and slow-query rate, and verify with a replay or load test before closing.
