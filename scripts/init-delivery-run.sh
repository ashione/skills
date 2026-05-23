#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
usage: bash scripts/init-delivery-run.sh <run-id> [--root <repo-root>] [--request <text>] [--gate-type soft|hard] [--runtime auto|codex|claude-code|claude|generic]

Initializes a Mobius Harness Delivery Episode Package with Gate, Hook, and
Review Ledger rows under .delivery/runs/<run-id>/, plus executable hook gate
scripts and config under .delivery/hooks/.

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

install_local_git_excludes() {
  local git_top
  local exclude_path
  local root_relative

  if ! git_top="$(git -C "${root}" rev-parse --show-toplevel 2>/dev/null)"; then
    return
  fi

  exclude_path="$(git -C "${root}" rev-parse --path-format=absolute --git-path info/exclude)"
  mkdir -p "$(dirname "${exclude_path}")"

  root_relative="$(
    ROOT_PATH="${root}" GIT_TOP="${git_top}" python3 <<'PY'
import os

root = os.path.realpath(os.environ["ROOT_PATH"])
git_top = os.path.realpath(os.environ["GIT_TOP"])
rel = os.path.relpath(root, git_top)
print("" if rel == "." else rel.strip("/") + "/")
PY
  )"

  {
    echo ""
    echo "# Mobius Harness generated local scaffold"
    echo "${root_relative}.delivery/"
    echo "${root_relative}.claude/settings.json"
    echo "${root_relative}.claude/settings.local.json"
    echo "${root_relative}.codex/settings.json"
    echo "${root_relative}.codex/settings.local.json"
  } | while IFS= read -r line; do
    if [[ -z "${line}" ]]; then
      continue
    fi
    if [[ -f "${exclude_path}" ]] && grep -q -F "${line}" "${exclude_path}"; then
      continue
    fi
    printf '%s\n' "${line}" >> "${exclude_path}"
  done
}

install_local_git_excludes

mkdir -p "${root}/.delivery/runs"
run_dir="${root}/.delivery/runs/${run_id}"
hook_dir="${root}/.delivery/hooks"
claude_dir="${root}/.claude"
codex_dir="${root}/.codex"

if [[ -e "${run_dir}" ]]; then
  echo "ERROR: delivery run already exists: ${run_dir}"
  exit 1
fi

mkdir -p "${run_dir}"
mkdir -p "${hook_dir}"

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

before_requirements_action="$(hook_action "Read user goal, repo instructions, relevant specs/docs, issue context, prior PR or attempt search, Minimum Skill Dependencies, uncertainty disposition, Requirements Maturity, and brainstorming decision.")"
before_plan_action="$(hook_action "Record skill activation, Minimum Skill Dependencies, tool reality, prior attempt comparison, design options, selected approach, rejected alternatives, Dependency Decision, validation strategy, Validation Prerequisites, Design Readiness, and writing-plans decision.")"
before_edit_action="$(hook_action "Confirm Requirements Maturity and Design Readiness, repo/worktree state, dirty-state handling, affected paths, and preservation of unrelated changes.")"
after_edit_action="$(hook_action "Map changed files to acceptance criteria and check for unintended churn.")"
before_commit_action="$(hook_action "Run or record local validation, diff review, and sensitive information scan.")"
before_pr_action="$(hook_action "Record commit/head state, PR/MR body readiness, review status, and reason when no PR/MR is created.")"
after_pr_action="$(hook_action "Record PR/MR URL or not-applicable reason, CI/CD observation plan, terminal check state, and failure follow-up.")"
before_final_action="$(hook_action "Re-check evidence before claims, merge state, cleanup state, local runtime sync when applicable, risks, follow-ups, and release/version report.")"

write_hook_gate_script() {
  local hook_id="$1"
  local artifact_name="$2"
  local script_path="${hook_dir}/${hook_id}.sh"

  if [[ -e "${script_path}" ]] && ! grep -q -F "Generated by Mobius Harness" "${script_path}"; then
    echo "ERROR: refusing to overwrite non-Mobius hook script: ${script_path}"
    exit 1
  fi

  cat > "${script_path}" <<EOF
#!/usr/bin/env bash
set -euo pipefail

# Generated by Mobius Harness. Safe to regenerate with init-delivery-run.sh.
hook_id="${hook_id}"
artifact_name="${artifact_name}"

repo_root="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")/../.." && pwd)"
config_path="\${repo_root}/.delivery/hooks/config.json"

if [[ ! -f "\${config_path}" ]]; then
  echo "ERROR: Mobius hook config not found: \${config_path}" >&2
  exit 1
fi

config_value() {
  local key="\$1"
  awk -F'"' -v key="\${key}" '\$0 ~ "\"" key "\":" { print \$4; exit }' "\${config_path}"
}

run_id="\${MOBIUS_RUN_ID:-\$(config_value run_id)}"

if [[ -z "\${run_id}" ]]; then
  echo "ERROR: Mobius hook config missing run_id" >&2
  exit 1
fi

artifact_path="\${MOBIUS_ARTIFACT:-\${repo_root}/.delivery/runs/\${run_id}/\${artifact_name}}"

if [[ ! -f "\${artifact_path}" ]]; then
  echo "ERROR: Mobius hook artifact not found for \${hook_id}: \${artifact_path}" >&2
  exit 1
fi

row="\$(
  awk -F'|' -v target_hook="\${hook_id}" '
    function trim(value) {
      gsub(/^[ \t]+|[ \t]+$/, "", value)
      return value
    }
    /^### Hook Ledger$/ {
      in_hook_ledger = 1
      next
    }
    /^### / && in_hook_ledger {
      in_hook_ledger = 0
    }
    in_hook_ledger && /^\\|/ {
      hook = trim(\$2)
      if (hook == target_hook) {
        print
        exit
      }
    }
  ' "\${artifact_path}"
)"

if [[ -z "\${row}" ]]; then
  echo "ERROR: Mobius hook \${hook_id} missing from \${artifact_path}" >&2
  exit 1
fi

status="\$(printf '%s\n' "\${row}" | awk -F'|' '{ value=\$5; gsub(/^[ \t]+|[ \t]+$/, "", value); print value }')"
action="\$(printf '%s\n' "\${row}" | awk -F'|' '{ value=\$4; gsub(/^[ \t]+|[ \t]+$/, "", value); print value }')"

if [[ "\${action}" != "[soft]"* && "\${action}" != "[hard]"* ]]; then
  echo "ERROR: Mobius hook \${hook_id} missing gate mode prefix in \${artifact_path}" >&2
  exit 1
fi

case "\${status}" in
  pass | not-applicable | exception)
    echo "Mobius hook \${hook_id} satisfied: \${status}"
    ;;
  warn)
    if [[ "\${action}" == "[soft]"* ]]; then
      echo "Mobius hook \${hook_id} warning accepted by soft gate"
    else
      echo "ERROR: Mobius hook \${hook_id} hard gate cannot use warn" >&2
      exit 1
    fi
    ;;
  blocked)
    echo "ERROR: Mobius hook \${hook_id} is blocked in \${artifact_path}" >&2
    exit 1
    ;;
  *)
    echo "ERROR: Mobius hook \${hook_id} has invalid status '\${status}' in \${artifact_path}" >&2
    exit 1
    ;;
esac
EOF

  chmod 0755 "${script_path}"
}

cat > "${hook_dir}/agent_gate.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Generated by Mobius Harness. Runtime settings call this command hook.
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
hook_dir="${repo_root}/.delivery/hooks"

input="$(cat || true)"

extract_command() {
  python3 -c '
import json
import sys

try:
    payload = json.loads(sys.stdin.read() or "{}")
except json.JSONDecodeError:
    print("")
    raise SystemExit(0)

tool_input = payload.get("tool_input") or payload.get("toolInput") or {}
command = tool_input.get("command") or payload.get("command") or ""
print(command if isinstance(command, str) else "")
' <<<"${input}"
}

command="$(extract_command)"

case "${command}" in
  git\ commit* | *" git commit"*)
    exec "${hook_dir}/before_commit.sh"
    ;;
  gh\ pr\ create* | *" gh pr create"* | gh\ pr\ edit* | *" gh pr edit"*)
    exec "${hook_dir}/before_pr.sh"
    ;;
  gh\ pr\ merge* | *" gh pr merge"* | gh\ release\ create* | *" gh release create"*)
    exec "${hook_dir}/before_final.sh"
    ;;
  *)
    echo "Mobius hook gate skipped: no matching gated command"
    ;;
esac
EOF
chmod 0755 "${hook_dir}/agent_gate.sh"

install_runtime_hook_settings() {
  local settings_dir="$1"
  local settings_path="${settings_dir}/settings.json"
  local git_top
  local tracked_check_path

  mkdir -p "${settings_dir}"

  if git_top="$(git -C "${root}" rev-parse --show-toplevel 2>/dev/null)"; then
    tracked_check_path="$(
      SETTINGS_PATH="${settings_path}" GIT_TOP="${git_top}" python3 <<'PY'
import os

settings_path = os.path.realpath(os.environ["SETTINGS_PATH"])
git_top = os.path.realpath(os.environ["GIT_TOP"])
print(os.path.relpath(settings_path, git_top))
PY
    )"

    if git -C "${root}" ls-files --error-unmatch "${tracked_check_path}" >/dev/null 2>&1; then
      settings_path="${settings_dir}/settings.local.json"
    fi
  fi

  SETTINGS_PATH="${settings_path}" python3 <<'PY'
import json
import os
from pathlib import Path

settings_path = Path(os.environ["SETTINGS_PATH"])
hook_entry = {
    "type": "command",
    "command": ".delivery/hooks/agent_gate.sh",
}
target = {
    "matcher": "Bash",
    "hooks": [hook_entry],
}

if settings_path.exists():
    try:
        data = json.loads(settings_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise SystemExit(f"ERROR: invalid runtime settings JSON: {settings_path}: {exc}") from exc
else:
    data = {}

if not isinstance(data, dict):
    raise SystemExit(f"ERROR: runtime settings root must be a JSON object: {settings_path}")

hooks = data.setdefault("hooks", {})
if not isinstance(hooks, dict):
    raise SystemExit(f"ERROR: runtime settings hooks must be a JSON object: {settings_path}")

pre_tool_use = hooks.setdefault("PreToolUse", [])
if not isinstance(pre_tool_use, list):
    raise SystemExit(f"ERROR: runtime settings hooks.PreToolUse must be an array: {settings_path}")

for item in pre_tool_use:
    if not isinstance(item, dict):
        continue
    if item.get("matcher") != target["matcher"]:
        continue
    item_hooks = item.setdefault("hooks", [])
    if not isinstance(item_hooks, list):
        raise SystemExit(f"ERROR: runtime settings PreToolUse hooks must be an array: {settings_path}")
    if not any(isinstance(hook, dict) and hook.get("type") == hook_entry["type"] and hook.get("command") == hook_entry["command"] for hook in item_hooks):
        item_hooks.append(hook_entry)
    break
else:
    pre_tool_use.append(target)

settings_path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
PY
}

cat > "${hook_dir}/config.json" <<EOF
{
  "schema_version": 1,
  "generated_by": "scripts/init-delivery-run.sh",
  "run_id": "${run_id}",
  "run_dir": ".delivery/runs/${run_id}",
  "gate_type": "${gate_type}",
  "runtime": "${runtime}",
  "hooks": [
    {
      "id": "before_requirements",
      "trigger": "before G1 completion",
      "script": ".delivery/hooks/before_requirements.sh",
      "artifact": ".delivery/runs/${run_id}/requirements.md"
    },
    {
      "id": "before_plan",
      "trigger": "before G2 completion",
      "script": ".delivery/hooks/before_plan.sh",
      "artifact": ".delivery/runs/${run_id}/plan.md"
    },
    {
      "id": "before_edit",
      "trigger": "before editing files",
      "script": ".delivery/hooks/before_edit.sh",
      "artifact": ".delivery/runs/${run_id}/verification.md"
    },
    {
      "id": "after_edit",
      "trigger": "after editing files",
      "script": ".delivery/hooks/after_edit.sh",
      "artifact": ".delivery/runs/${run_id}/verification.md"
    },
    {
      "id": "before_commit",
      "trigger": "before commit or PR/MR preparation",
      "script": ".delivery/hooks/before_commit.sh",
      "artifact": ".delivery/runs/${run_id}/verification.md"
    },
    {
      "id": "before_pr",
      "trigger": "before PR/MR creation or not-applicable decision",
      "script": ".delivery/hooks/before_pr.sh",
      "artifact": ".delivery/runs/${run_id}/verification.md"
    },
    {
      "id": "after_pr",
      "trigger": "after PR/MR creation or not-applicable decision",
      "script": ".delivery/hooks/after_pr.sh",
      "artifact": ".delivery/runs/${run_id}/verification.md"
    },
    {
      "id": "before_final",
      "trigger": "before final delivery report",
      "script": ".delivery/hooks/before_final.sh",
      "artifact": ".delivery/runs/${run_id}/delivery-report.md"
    }
  ]
}
EOF

write_hook_gate_script "before_requirements" "requirements.md"
write_hook_gate_script "before_plan" "plan.md"
write_hook_gate_script "before_edit" "verification.md"
write_hook_gate_script "after_edit" "verification.md"
write_hook_gate_script "before_commit" "verification.md"
write_hook_gate_script "before_pr" "verification.md"
write_hook_gate_script "after_pr" "verification.md"
write_hook_gate_script "before_final" "delivery-report.md"

case "${runtime}" in
  codex)
    install_runtime_hook_settings "${codex_dir}"
    ;;
  claude-code)
    install_runtime_hook_settings "${claude_dir}"
    ;;
  generic)
    install_runtime_hook_settings "${claude_dir}"
    install_runtime_hook_settings "${codex_dir}"
    ;;
esac

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
- [ ] Linked issues, existing PRs, fork commits, or previous attempts are searched or marked not applicable with evidence.
- [ ] Blocking unknowns are resolved or explicitly accepted.
- [ ] Minimum Skill Dependencies are checked, including required Superpowers decisions.
- [ ] Requirements Maturity is \`ready-for-design\` or explicitly excepted.
- [ ] \`superpowers:brainstorming\` is used or marked not applicable with evidence.

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|
| G1 | requirements | Goal, success criteria, scope, non-goals, risks, open questions, user decisions, Issue and Prior Attempts, Minimum Skill Dependencies, uncertainty disposition, Requirements Maturity, and brainstorming decision are explicit. | blocked | decision:${request_cell} | |

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

## Issue and Prior Attempts

- Prior Attempt Search: blocked until linked issues, existing PRs, fork commits, issue comments, and related branches are searched or marked not applicable.
- Prior Attempt Evidence: decision:${request_cell}

| Source | Finding | Difference or Reuse Decision | Evidence |
|---|---|---|---|

## Minimum Skill Dependencies

| Skill | Minimum Requirement | Dependency Class | Evidence | Fallback |
|---|---|---|---|---|
| mobius-harness | Primary delivery loop and artifact contract. | no-new-dependency | file:skills/mobius-harness/SKILL.md | blocked until available |
| local-repo-development | Repo topology, instruction discovery, validation, commit, and PR workflow. | no-new-dependency | file:skills/local-repo-development/SKILL.md | record equivalent local workflow or exception |
| superpowers:brainstorming | Required for creative work, behavior shaping, unclear intent, or competing solution paths. | no-new-dependency | reason:platform-provided skill dependency checked at runtime | not-applicable only with fixed requirements; otherwise blocked or exception |
| superpowers:writing-plans | Required for Standard or Strict delivery, multi-step work, risky changes, or handoff plans. | no-new-dependency | reason:platform-provided skill dependency checked at runtime | not-applicable only for trivial plans; otherwise blocked or exception |

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
- [ ] Minimum Skill Dependencies are checked and carried forward from requirements.
- [ ] Implementation steps are ordered.
- [ ] Prior attempts are compared against the selected approach or marked not applicable with evidence.
- [ ] Design options and rejected alternatives are recorded.
- [ ] Design Readiness is \`ready-for-implementation\` or explicitly excepted.
- [ ] Validation strategy covers success criteria.
- [ ] Validation prerequisites are recorded before validation commands.
- [ ] Rollback or mitigation notes are recorded.
- [ ] Dependency Decision is recorded.
- [ ] \`superpowers:writing-plans\` is used or marked not applicable with evidence.

### Gate Ledger

| Gate | Phase | Required Evidence | Status | Evidence | Exception |
|---|---|---|---|---|---|
| G2 | plan | Repo findings, prior attempt comparison, design options, selected approach, rejected alternatives, affected areas, specialist skills, Minimum Skill Dependencies, Superpowers planning decision, Dependency Decision, implementation steps, validation commands, Validation Prerequisites, acceptance criteria, Design Readiness, rollback notes, and checkpoints are recorded. | blocked | file:.delivery/runs/${run_id}/requirements.md | |

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

## Minimum Skill Dependencies

| Skill | Minimum Requirement | Dependency Class | Evidence | Fallback |
|---|---|---|---|---|
| mobius-harness | Primary delivery loop and artifact contract. | no-new-dependency | file:skills/mobius-harness/SKILL.md | blocked until available |
| local-repo-development | Repo topology, instruction discovery, validation, commit, and PR workflow. | no-new-dependency | file:skills/local-repo-development/SKILL.md | record equivalent local workflow or exception |
| superpowers:brainstorming | Requirements-phase design support when applicable. | no-new-dependency | reason:platform-provided skill dependency checked at runtime | not-applicable only with fixed requirements; otherwise blocked or exception |
| superpowers:writing-plans | Plan-phase support for Standard or Strict delivery and multi-step work. | no-new-dependency | reason:platform-provided skill dependency checked at runtime | not-applicable only for trivial plans; otherwise blocked or exception |

## Superpowers Decisions

- Brainstorming: see requirements.md
- Writing Plans: blocked until G1 is complete.

## Prior Attempt Comparison

- Prior Attempt Disposition: blocked until existing attempts are compared or marked not applicable.
- Freshness Evidence: file:.delivery/runs/${run_id}/plan.md

| Attempt | Useful Elements | Differences from Selected Approach | Action |
|---|---|---|---|

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

## Validation Prerequisites

| Prerequisite | Applies To | Evidence | Fallback |
|---|---|---|---|
| Repository setup or generated artifacts | Validation commands that require setup before they can run cleanly | reason:none identified yet | record failed command, run the prerequisite, and rerun the validation command |

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
echo "Initialized hook gates: ${hook_dir}"
echo "Gate type: ${gate_type}"
echo "Runtime: ${runtime}"
echo "Next: complete G1 in ${run_dir}/requirements.md before planning or editing."
