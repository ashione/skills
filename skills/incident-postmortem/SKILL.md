---
name: incident-postmortem
description: Create a clear, blameless postmortem with timeline, causes, and preventive actions.
---

# Incident Postmortem

## Intent

Create a clear, blameless postmortem with timeline, causes, and preventive actions.

## Inputs

- `incident_log`: Incident events and timestamps.
- `impact`: User/business impact statement.

## Instructions

1. Build a timeline from detection to full recovery.
2. Separate trigger from root cause and contributing factors.
3. Define short-term mitigations and long-term fixes.
4. Assign measurable follow-up actions with owners.

## Examples

Input: Database CPU spike caused 45-min API outage.

Output: Root cause: missing index on hot query path after release; actions include adding index, query budget checks in CI, and release canary guardrails.
