#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
usage: bash scripts/init-delivery-run.sh <run-id> [--root <repo-root>] [--request <text>] [--gate-type soft|hard] [--runtime auto|codex|claude-code|claude|generic]

Initializes a Mobius Harness Delivery Episode Package with Gate, Hook, and
Review Ledger rows under .delivery/runs/<run-id>/.

Gate type defaults to soft. Use --gate-type hard when every initialized hook
must block until it is pass, not-applicable, or exception.

Runtime defaults to auto. Auto-detection uses current agent-runtime environment
signals and falls back to generic when no dedicated runtime is evident.
EOF
}

if [[ "$#" -lt 1 ]]; then
  usage
  exit 2
fi

run_id="$1"
shift

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
default_root="$(cd "${script_dir}/.." && pwd)"
root="${default_root}"
request="delivery run initialized from scripts/init-delivery-run.sh"
gate_type="soft"
runtime="auto"

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --root)
      if [[ "$#" -lt 2 ]]; then
        echo "ERROR: --root requires a path"
        exit 2
      fi
      root="$2"
      shift 2
      ;;
    --request)
      if [[ "$#" -lt 2 ]]; then
        echo "ERROR: --request requires text"
        exit 2
      fi
      request="$2"
      shift 2
      ;;
    --gate-type | --gate-mode)
      if [[ "$#" -lt 2 ]]; then
        echo "ERROR: $1 requires soft or hard"
        exit 2
      fi
      gate_type="$2"
      shift 2
      ;;
    --runtime)
      if [[ "$#" -lt 2 ]]; then
        echo "ERROR: --runtime requires auto, codex, claude-code, claude, or generic"
        exit 2
      fi
      runtime="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown argument: $1"
      usage
      exit 2
      ;;
  esac
done

if [[ ! "${run_id}" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "ERROR: run-id must be kebab-case, for example add-user-auth"
  exit 2
fi

if [[ "${gate_type}" != "soft" && "${gate_type}" != "hard" ]]; then
  echo "ERROR: gate type must be soft or hard"
  exit 2
fi

if [[ "${runtime}" == "claude" ]]; then
  runtime="claude-code"
fi

if [[ "${runtime}" != "auto" && "${runtime}" != "codex" && "${runtime}" != "claude-code" && "${runtime}" != "generic" ]]; then
  echo "ERROR: runtime must be auto, codex, claude-code, claude, or generic"
  exit 2
fi

if [[ ! -d "${root}" ]]; then
  echo "ERROR: root directory not found: ${root}"
  exit 1
fi

mkdir -p "${root}/.delivery/runs"
run_dir="${root}/.delivery/runs/${run_id}"

if [[ -e "${run_dir}" ]]; then
  echo "ERROR: delivery run already exists: ${run_dir}"
  exit 1
fi

mkdir -p "${run_dir}"

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

detect_runtime() {
  local bundle_id
  bundle_id="$(printf '%s' "${__CFBundleIdentifier:-}" | tr '[:upper:]' '[:lower:]')"

  if [[ -n "${CODEX_SHELL:-}" || -n "${CODEX_CI:-}" || -n "${CODEX_THREAD_ID:-}" || "${bundle_id}" == *"codex"* ]]; then
    printf 'codex'
    return
  fi

  if [[ -n "${CLAUDECODE:-}" || -n "${CLAUDE_CODE:-}" || -n "${CLAUDE_SESSION_ID:-}" || -n "${CLAUDECODE_SESSION_ID:-}" || "${bundle_id}" == *"claude"* ]]; then
    printf 'claude-code'
    return
  fi

  printf 'generic'
}

if [[ "${runtime}" == "auto" ]]; then
  runtime="$(detect_runtime)"
fi

sanitize_cell() {
  local value="$1"
  value="${value//$'\r'/ }"
  value="${value//$'\n'/ }"
  value="${value//|//}"
  printf '%s' "${value}"
}

request_cell="$(sanitize_cell "${request}")"

hook_action() {
  local requirement="$1"

  case "${runtime}" in
    codex)
      printf '[%s] Codex hook: %s Record runtime:codex evidence including skill file loads, tool calls, sandbox/approval state, connector or plugin availability, command output, and explicit unavailable reasons.' "${gate_type}" "${requirement}"
      ;;
    claude-code)
      printf '[%s] Claude Code hook: %s Record runtime:claude-code evidence including skill invocation, tool output, Todo state, repo instruction reads, command output, and explicit unavailable reasons.' "${gate_type}" "${requirement}"
      ;;
    generic)
      printf '[%s] Generic agent hook: %s Record runtime:generic capability evidence, supported tool output, command output, and explicit unavailable reasons.' "${gate_type}" "${requirement}"
      ;;
    *)
      echo "ERROR: runtime must be auto, codex, claude-code, claude, or generic" >&2
      exit 2
      ;;
  esac
}

before_requirements_action="$(hook_action "Read user goal, repo instructions, relevant specs/docs, uncertainty disposition, Requirements Maturity, and brainstorming decision.")"
before_plan_action="$(hook_action "Record skill activation, tool reality, design options, selected approach, rejected alternatives, Dependency Decision, validation strategy, Design Readiness, and writing-plans decision.")"
before_edit_action="$(hook_action "Confirm Requirements Maturity and Design Readiness, repo/worktree state, dirty-state handling, affected paths, and preservation of unrelated changes.")"
after_edit_action="$(hook_action "Map changed files to acceptance criteria and check for unintended churn.")"
before_commit_action="$(hook_action "Run or record local validation, diff review, and sensitive information scan.")"
before_pr_action="$(hook_action "Record commit/head state, PR/MR body readiness, review status, and reason when no PR/MR is created.")"
after_pr_action="$(hook_action "Record PR/MR URL or not-applicable reason, CI/CD observation plan, terminal check state, and failure follow-up.")"
before_final_action="$(hook_action "Re-check evidence before claims, merge state, cleanup state, local runtime sync when applicable, risks, follow-ups, and release/version report.")"

cat > "${run_dir}/requirements.md" <<EOF
# Requirements

Status: active
Phase: requirements
Updated: ${timestamp}
Runtime: ${runtime}
Evidence: decision:${request_cell}

## Phase State

### Goal

Capture requirements before planning or editing.

### Checklist

- [ ] Goal is explicit.
- [ ] Success criteria are verifiable.
- [ ] Scope and non-goals are explicit.
- [ ] High-impact unknowns are resolved or recorded.
- [ ] Blocking unknowns are resolved or explicitly accepted.
- [ ] Requirements Maturity is \`ready-for-design\` or explicitly excepted.
- [ ] \`superpowers:brainstorming\` is used or marked not applicable with evidence.

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|
| G1 | requirements | Goal, success criteria, scope, non-goals, risks, open questions, user decisions, uncertainty disposition, Requirements Maturity, and brainstorming decision are explicit. | blocked | decision:${request_cell} | |

### Hook Ledger

| Hook | Trigger | Required Action | Status | Evidence | Failure Handling |
|---|---|---|---|---|---|
| before_requirements | before G1 completion | ${before_requirements_action} | blocked | decision:${request_cell} | |

### Review Ledger

| Review | Role | Perspective | Challenge | Status | Resolution | Evidence |
|---|---|---|---|---|---|---|
| requirements_product | Product | User intent and acceptance | Are success criteria specific and user-visible? | blocked | Requirements are not yet finalized. | decision:${request_cell} |
| requirements_engineering | Engineering | Feasibility and repo constraints | Can the repo support this without hidden assumptions? | blocked | Repository constraints are not yet finalized. | decision:${request_cell} |
| requirements_risk | Risk | Ambiguity and failure modes | Are blocking unknowns resolved or explicitly accepted? | blocked | Blocking unknowns must be resolved or accepted. | decision:${request_cell} |

### Todo List

| Item | Status | Owner | Evidence |
|---|---|---|---|
| Complete requirements | todo | agent | decision:${request_cell} |

### Failure List

| Failure | Impact | Root Cause | Resolution | Status |
|---|---|---|---|---|

### Change List

| Change | Reason | Files/Links | Approval |
|---|---|---|---|
| Initialized delivery run | Start Mobius Harness episode | file:.delivery/runs/${run_id}/requirements.md | decision:${request_cell} |

## Goal

TBD

## Background

TBD

## Success Criteria

TBD

## Scope

TBD

## Non-Goals

TBD

## Risks

TBD

## Open Questions

TBD

## User Decisions

${request_cell}

## Uncertainty Register

| Unknown | Impact | Disposition | Evidence |
|---|---|---|---|
| Requirements details | Blocks design until clarified | blocking | decision:${request_cell} |

## Requirements Maturity

- Maturity: \`blocked\`
- Blocking Unknowns: requirements not finalized
- Maturity Evidence: decision:${request_cell}

## Superpowers Decisions

- Brainstorming: blocked until requirements decision is recorded.
EOF

cat > "${run_dir}/plan.md" <<EOF
# Plan

Status: draft
Phase: plan
Updated: ${timestamp}
Runtime: ${runtime}
Evidence: file:.delivery/runs/${run_id}/requirements.md

## Phase State

### Goal

Define the implementation plan after G1 is resolved.

### Checklist

- [ ] Affected areas are identified.
- [ ] Specialist skills are selected or rejected with reason.
- [ ] Implementation steps are ordered.
- [ ] Design options and rejected alternatives are recorded.
- [ ] Design Readiness is \`ready-for-implementation\` or explicitly excepted.
- [ ] Validation strategy covers success criteria.
- [ ] Rollback or mitigation notes are recorded.
- [ ] Dependency Decision is recorded.
- [ ] \`superpowers:writing-plans\` is used or marked not applicable with evidence.

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|
| G2 | plan | Repo findings, design options, selected approach, rejected alternatives, affected areas, specialist skills, Superpowers planning decision, Dependency Decision, implementation steps, validation commands, acceptance criteria, Design Readiness, rollback notes, and checkpoints are recorded. | blocked | file:.delivery/runs/${run_id}/requirements.md | |

### Hook Ledger

| Hook | Trigger | Required Action | Status | Evidence | Failure Handling |
|---|---|---|---|---|---|
| before_plan | before G2 completion | ${before_plan_action} | blocked | file:.delivery/runs/${run_id}/plan.md | |

### Review Ledger

| Review | Role | Perspective | Challenge | Status | Resolution | Evidence |
|---|---|---|---|---|---|---|
| plan_architecture | Architecture | Boundaries and alternatives | Is the selected approach justified against alternatives? | blocked | Plan is not yet selected. | file:.delivery/runs/${run_id}/plan.md |
| plan_validation | Validation | Acceptance and tests | Does validation prove every acceptance criterion? | blocked | Validation is not yet mapped. | file:.delivery/runs/${run_id}/plan.md |
| plan_risk | Risk | Rollback and dependency impact | Are rollback, dependency, and migration risks explicit? | blocked | Risk handling is not yet finalized. | file:.delivery/runs/${run_id}/plan.md |

### Todo List

| Item | Status | Owner | Evidence |
|---|---|---|---|
| Complete plan | todo | agent | file:.delivery/runs/${run_id}/plan.md |

### Failure List

| Failure | Impact | Root Cause | Resolution | Status |
|---|---|---|---|---|

### Change List

| Change | Reason | Files/Links | Approval |
|---|---|---|---|
| Initialized plan artifact | Start G2 after requirements | file:.delivery/runs/${run_id}/plan.md | decision:${request_cell} |

## Repo Findings

TBD

## Specialist Skills

TBD

## Superpowers Decisions

- Brainstorming: see requirements.md
- Writing Plans: blocked until G1 is complete.

## Design Options

| Option | Tradeoff | Decision | Evidence |
|---|---|---|---|

## Design Readiness

- Readiness: \`blocked\`
- Selected Approach: TBD
- Rejected Alternatives: TBD
- Acceptance Mapping: TBD
- Start Gate: file:.delivery/runs/${run_id}/plan.md

## Dependency Decision

- Decision: \`no-new-dependency\`
- Reason: Initialization uses repository Markdown artifacts and existing shell tooling.
- Evidence: file:.delivery/runs/${run_id}/plan.md
- Fallback: Maintain artifacts manually if this script is unavailable.

## Implementation Steps

TBD

## Validation Strategy

TBD

## Acceptance Criteria

TBD

## Rollback Notes

TBD

## Checkpoints

TBD
EOF

cat > "${run_dir}/verification.md" <<EOF
# Verification

Status: draft
Phase: verification
Updated: ${timestamp}
Runtime: ${runtime}
Evidence: file:.delivery/runs/${run_id}/plan.md

## Phase State

### Goal

Record local development, implementation, verification, PR/MR, and CI/CD evidence.

### Checklist

- [ ] Worktree or branch and base ref are recorded.
- [ ] Changed files are intentional and mapped to acceptance criteria.
- [ ] Local validation commands are run or marked unavailable with reason.
- [ ] Diff review is complete.
- [ ] Sensitive information scan is complete.
- [ ] PR/MR state is recorded or marked not applicable.
- [ ] CI/CD terminal state is recorded or marked not applicable.

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|
| G3 | local-development | Worktree or branch, base ref, and dirty-state handling are recorded. | blocked | file:.delivery/runs/${run_id}/verification.md | |
| G4 | implementation | Changed files are intentional and mapped to acceptance criteria. | blocked | file:.delivery/runs/${run_id}/verification.md | |
| G5 | verification | Local commands, command results, diff review, sensitive information scan, and unresolved risks are recorded. | blocked | file:.delivery/runs/${run_id}/verification.md | |
| G6 | pr-mr | PR/MR URL or not-applicable reason is recorded. | blocked | file:.delivery/runs/${run_id}/verification.md | |
| G7 | ci-cd | Terminal CI/CD state, async observation state, or not-applicable reason is recorded. | blocked | file:.delivery/runs/${run_id}/verification.md | |

### Hook Ledger

| Hook | Trigger | Required Action | Status | Evidence | Failure Handling |
|---|---|---|---|---|---|
| before_edit | before editing files | ${before_edit_action} | blocked | file:.delivery/runs/${run_id}/verification.md | |
| after_edit | after editing files | ${after_edit_action} | blocked | file:.delivery/runs/${run_id}/verification.md | |
| before_commit | before commit or PR/MR preparation | ${before_commit_action} | blocked | file:.delivery/runs/${run_id}/verification.md | |
| before_pr | before PR/MR creation or not-applicable decision | ${before_pr_action} | blocked | file:.delivery/runs/${run_id}/verification.md | |
| after_pr | after PR/MR creation or not-applicable decision | ${after_pr_action} | blocked | file:.delivery/runs/${run_id}/verification.md | |

### Review Ledger

| Review | Role | Perspective | Challenge | Status | Resolution | Evidence |
|---|---|---|---|---|---|---|
| verification_implementation | Implementation | Diff and requirements fit | Do changed files map cleanly to accepted requirements? | blocked | Implementation has not been verified. | file:.delivery/runs/${run_id}/verification.md |
| verification_security | Security | Secrets and unsafe behavior | Were sensitive data and unsafe operations checked? | blocked | Sensitive information scan has not run. | file:.delivery/runs/${run_id}/verification.md |
| verification_ci | CI/CD | Remote checks and async policy | Is CI/CD state recorded without unsupported pass claims? | blocked | CI/CD state has not been observed. | file:.delivery/runs/${run_id}/verification.md |

### Todo List

| Item | Status | Owner | Evidence |
|---|---|---|---|
| Complete verification | todo | agent | file:.delivery/runs/${run_id}/verification.md |

### Failure List

| Failure | Impact | Root Cause | Resolution | Status |
|---|---|---|---|---|

### Change List

| Change | Reason | Files/Links | Approval |
|---|---|---|---|
| Initialized verification artifact | Start G3-G7 evidence record | file:.delivery/runs/${run_id}/verification.md | decision:${request_cell} |

## Local Commands

| Command | Result | Evidence |
|---|---|---|

## Command Results

TBD

## Diff Review

### Requirements Compliance

TBD

### Implementation Quality

TBD

### Test Adequacy

TBD

### Security and Sensitive Information

TBD

## Sensitive Information Scan

TBD

## PR/MR

TBD

## CI/CD

TBD

## Unresolved Risks

TBD
EOF

cat > "${run_dir}/delivery-report.md" <<EOF
# Delivery Report

Status: draft
Phase: report
Updated: ${timestamp}
Runtime: ${runtime}
Evidence: file:.delivery/runs/${run_id}/delivery-report.md

## Phase State

### Goal

Summarize completed delivery evidence after G1-G7 are terminal.

### Checklist

- [ ] Requirements result is summarized.
- [ ] Implementation and changed files are summarized.
- [ ] Validation, review, and sensitive scan are summarized.
- [ ] PR/MR and CI/CD state are summarized.
- [ ] Risks and follow-ups are explicit.
- [ ] Version or release report notes are recorded when applicable.

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|
| G8 | report | Final delivery report includes requirements, implementation, changed files, validation, review, sensitive scan, PR/MR, CI/CD, risks, follow-ups, and version or release report notes. | blocked | file:.delivery/runs/${run_id}/delivery-report.md | |

### Hook Ledger

| Hook | Trigger | Required Action | Status | Evidence | Failure Handling |
|---|---|---|---|---|---|
| before_final | before final delivery report | ${before_final_action} | blocked | file:.delivery/runs/${run_id}/delivery-report.md | |

### Review Ledger

| Review | Role | Perspective | Challenge | Status | Resolution | Evidence |
|---|---|---|---|---|---|---|
| report_delivery | Delivery | User-facing result | Does the report answer what changed and what remains? | blocked | Delivery report is not complete. | file:.delivery/runs/${run_id}/delivery-report.md |
| report_operations | Operations | CI/CD, cleanup, and release | Are async CI, cleanup, and release/version notes explicit? | blocked | Operations evidence is not complete. | file:.delivery/runs/${run_id}/delivery-report.md |
| report_user | User Advocate | Clarity and unsupported claims | Are claims backed by evidence and easy to act on? | blocked | Final claims are not yet backed. | file:.delivery/runs/${run_id}/delivery-report.md |

### Todo List

| Item | Status | Owner | Evidence |
|---|---|---|---|
| Complete delivery report | todo | agent | file:.delivery/runs/${run_id}/delivery-report.md |

### Failure List

| Failure | Impact | Root Cause | Resolution | Status |
|---|---|---|---|---|

### Change List

| Change | Reason | Files/Links | Approval |
|---|---|---|---|
| Initialized delivery report artifact | Start G8 report record | file:.delivery/runs/${run_id}/delivery-report.md | decision:${request_cell} |

## Summary

TBD

## Requirements Result

TBD

## Implementation Summary

TBD

## Changed Files

TBD

## Validation Summary

TBD

## PR/MR and CI/CD

TBD

## Risks and Follow-ups

TBD

## Release Notes

TBD

## Version or Release Report

TBD
EOF

echo "Initialized delivery run: ${run_dir}"
echo "Gate type: ${gate_type}"
echo "Runtime: ${runtime}"
echo "Next: complete G1 in ${run_dir}/requirements.md before planning or editing."
