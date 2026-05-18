#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -ne 1 ]]; then
  echo "usage: bash scripts/validate-delivery-run.sh .delivery/runs/<run-id>"
  exit 2
fi

run_dir="$1"
repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
gate_list_file="$(mktemp)"
hook_list_file="$(mktemp)"

# shellcheck disable=SC2317
cleanup() {
  rm -f "${gate_list_file}" "${hook_list_file}"
}
trap cleanup EXIT

if [[ ! -d "${run_dir}" ]]; then
  echo "ERROR: delivery run directory not found: ${run_dir}"
  exit 1
fi

required_files=(
  "requirements.md"
  "plan.md"
  "verification.md"
  "delivery-report.md"
)

required_gates=(G1 G2 G3 G4 G5 G6 G7 G8)
required_hooks=(
  before_requirements
  before_plan
  before_edit
  after_edit
  before_commit
  before_pr
  after_pr
  before_final
)
valid_statuses=" draft active blocked complete deferred "

status=0

record_error() {
  echo "ERROR: $*"
  status=1
}

require_marker() {
  local path="$1"
  local file="$2"
  local marker="$3"

  if ! grep -q -F -- "${marker}" "${path}"; then
    record_error "${file} missing marker: ${marker}"
  fi
}

require_section() {
  local path="$1"
  local file="$2"
  local section="$3"

  require_marker "${path}" "${file}" "## ${section}"
}

field_value() {
  local path="$1"
  local field="$2"

  sed -n "s/^[[:space:]]*-[[:space:]]*${field}:[[:space:]]*//p" "${path}" | head -n 1
}

gate_status() {
  local path="$1"
  local gate="$2"

  awk -F'|' -v target_gate="${gate}" '
    function trim(value) {
      gsub(/^[ \t]+|[ \t]+$/, "", value)
      return value
    }

    /^\|[ \t]*G[0-9]+[ \t]*\|/ {
      if (trim($2) == target_gate) {
        print trim($5)
        exit
      }
    }
  ' "${path}"
}

require_field_value() {
  local path="$1"
  local file="$2"
  local field="$3"
  local value

  value="$(field_value "${path}" "${field}")"
  if [[ -z "${value}" || "${value}" == *"<"* || "${value}" == *">"* ]]; then
    record_error "${file} missing ${field} decision value"
  fi
}

require_artifact_sections() {
  local path="$1"
  local file="$2"
  local sections=()

  case "${file}" in
    requirements.md)
      sections=(
        "Goal"
        "Background"
        "Success Criteria"
        "Scope"
        "Non-Goals"
        "Risks"
        "Open Questions"
        "User Decisions"
        "Uncertainty Register"
        "Requirements Maturity"
        "Superpowers Decisions"
      )
      ;;
    plan.md)
      sections=(
        "Repo Findings"
        "Specialist Skills"
        "Superpowers Decisions"
        "Design Options"
        "Design Readiness"
        "Dependency Decision"
        "Implementation Steps"
        "Validation Strategy"
        "Acceptance Criteria"
        "Rollback Notes"
        "Checkpoints"
      )
      ;;
    verification.md)
      sections=(
        "Local Commands"
        "Command Results"
        "Diff Review"
        "Sensitive Information Scan"
        "PR/MR"
        "CI/CD"
        "Unresolved Risks"
      )
      ;;
    delivery-report.md)
      sections=(
        "Summary"
        "Requirements Result"
        "Implementation Summary"
        "Changed Files"
        "Validation Summary"
        "PR/MR and CI/CD"
        "Risks and Follow-ups"
        "Release Notes"
        "Version or Release Report"
      )
      ;;
  esac

  for section in "${sections[@]}"; do
    require_section "${path}" "${file}" "${section}"
  done

  if [[ "${file}" == "verification.md" ]]; then
    require_marker "${path}" "${file}" "### Requirements Compliance"
    require_marker "${path}" "${file}" "### Implementation Quality"
    require_marker "${path}" "${file}" "### Test Adequacy"
    require_marker "${path}" "${file}" "### Security and Sensitive Information"
  fi
}

require_decision_content() {
  local path="$1"
  local file="$2"
  local decision
  local evidence_value
  local maturity
  local readiness
  local maturity_evidence
  local start_gate

  case "${file}" in
    requirements.md)
      require_field_value "${path}" "${file}" "Brainstorming"
      require_field_value "${path}" "${file}" "Blocking Unknowns"
      require_field_value "${path}" "${file}" "Maturity Evidence"

      maturity="$(field_value "${path}" "Maturity")"
      maturity="${maturity//\`/}"
      if [[ "${maturity}" != "ready-for-design" && "${maturity}" != "accepted-risk" ]]; then
        record_error "${file} has invalid Requirements Maturity: ${maturity:-<missing>}"
      elif [[ "${maturity}" == "accepted-risk" && "$(gate_status "${path}" "G1")" != "exception" ]]; then
        record_error "${file} Requirements Maturity accepted-risk requires G1 exception"
      fi

      maturity_evidence="$(field_value "${path}" "Maturity Evidence")"
      case "${maturity_evidence}" in
        cmd:* | file:* | url:* | decision:* | reason:*) ;;
        *) record_error "${file} Requirements Maturity evidence must start with cmd:, file:, url:, decision:, or reason:" ;;
      esac
      ;;
    plan.md)
      require_field_value "${path}" "${file}" "Writing Plans"
      require_field_value "${path}" "${file}" "Selected Approach"
      require_field_value "${path}" "${file}" "Rejected Alternatives"
      require_field_value "${path}" "${file}" "Acceptance Mapping"
      require_field_value "${path}" "${file}" "Start Gate"
      require_field_value "${path}" "${file}" "Reason"
      require_field_value "${path}" "${file}" "Evidence"
      require_field_value "${path}" "${file}" "Fallback"

      readiness="$(field_value "${path}" "Readiness")"
      readiness="${readiness//\`/}"
      if [[ "${readiness}" != "ready-for-implementation" && "${readiness}" != "accepted-risk" ]]; then
        record_error "${file} has invalid Design Readiness: ${readiness:-<missing>}"
      elif [[ "${readiness}" == "accepted-risk" && "$(gate_status "${path}" "G2")" != "exception" ]]; then
        record_error "${file} Design Readiness accepted-risk requires G2 exception"
      fi

      start_gate="$(field_value "${path}" "Start Gate")"
      case "${start_gate}" in
        cmd:* | file:* | url:* | decision:* | reason:*) ;;
        *) record_error "${file} Design Readiness Start Gate must start with cmd:, file:, url:, decision:, or reason:" ;;
      esac

      decision="$(field_value "${path}" "Decision")"
      decision="${decision//\`/}"
      if [[ "${decision}" != "no-new-dependency" && "${decision}" != "existing-toolchain" && "${decision}" != "new-dependency-required" ]]; then
        record_error "${file} has invalid Dependency Decision: ${decision:-<missing>}"
      fi

      evidence_value="$(field_value "${path}" "Evidence")"
      case "${evidence_value}" in
        cmd:* | file:* | url:* | decision:* | reason:*) ;;
        *) record_error "${file} Dependency Decision evidence must start with cmd:, file:, url:, decision:, or reason:" ;;
      esac
      ;;
  esac
}

is_required_gate() {
  local gate="$1"

  case " ${required_gates[*]} " in
    *" ${gate} "*) return 0 ;;
    *) return 1 ;;
  esac
}

is_required_hook() {
  local hook="$1"

  case " ${required_hooks[*]} " in
    *" ${hook} "*) return 0 ;;
    *) return 1 ;;
  esac
}

is_expected_hook_for_file() {
  local file="$1"
  local hook="$2"

  case "${file}:${hook}" in
    requirements.md:before_requirements) return 0 ;;
    plan.md:before_plan) return 0 ;;
    verification.md:before_edit) return 0 ;;
    verification.md:after_edit) return 0 ;;
    verification.md:before_commit) return 0 ;;
    verification.md:before_pr) return 0 ;;
    verification.md:after_pr) return 0 ;;
    delivery-report.md:before_final) return 0 ;;
    *) return 1 ;;
  esac
}

for file in "${required_files[@]}"; do
  path="${run_dir}/${file}"

  if [[ ! -f "${path}" ]]; then
    echo "ERROR: missing required artifact: ${path}"
    status=1
    continue
  fi

  for marker in "Status:" "Phase:" "Updated:" "Evidence:" "## Phase State" "### Goal" "### Checklist" "### Gate Ledger" "### Hook Ledger" "### Todo List" "### Failure List" "### Change List"; do
    require_marker "${path}" "${file}" "${marker}"
  done

  require_artifact_sections "${path}" "${file}"
  require_decision_content "${path}" "${file}"

  artifact_status="$(sed -n 's/^Status:[[:space:]]*//p' "${path}" | head -n 1)"
  if [[ -z "${artifact_status}" ]]; then
    echo "ERROR: ${file} missing top-level Status value"
    status=1
  elif [[ "${valid_statuses}" != *" ${artifact_status} "* ]]; then
    echo "ERROR: ${file} has invalid Status: ${artifact_status}"
    status=1
  elif [[ "${artifact_status}" != "complete" ]]; then
    echo "ERROR: ${file} must be Status: complete for final delivery validation"
    status=1
  fi

  if grep -q -E '^[[:space:]]*-[[:space:]]+\[[[:space:]]\]' "${path}"; then
    echo "ERROR: ${file} has incomplete checklist items"
    status=1
  fi

  if ! awk -F'|' -v file="${file}" '
    function trim(value) {
      gsub(/^[ \t]+|[ \t]+$/, "", value)
      return value
    }

    /^### Failure List/ {
      section = "failure"
      next
    }

    /^### Change List/ {
      section = "change"
      next
    }

    /^### / {
      section = ""
    }

    section == "failure" && /^\|/ {
      for (gate in exception_gate) {
        if ($0 ~ gate) {
          failure_has[gate] = 1
        }
      }
    }

    section == "change" && /^\|/ {
      for (gate in exception_gate) {
        if ($0 ~ gate) {
          change_has[gate] = 1
        }
      }
    }

    /^\|[ \t]*G[0-9]+[ \t]*\|/ {
      gate = trim($2)
      status_value = trim($5)
      evidence = trim($6)
      exception = trim($7)

      if (seen_gate[gate]) {
        printf("ERROR: %s gate %s appears more than once\n", file, gate)
        invalid = 1
      }
      seen_gate[gate] = 1

      if (status_value != "pass" && status_value != "not-applicable" && status_value != "exception" && status_value != "blocked") {
        printf("ERROR: %s gate %s has invalid status: %s\n", file, gate, status_value)
        invalid = 1
      }

      if (status_value == "blocked") {
        printf("ERROR: %s gate %s is blocked\n", file, gate)
        invalid = 1
      }

      if (evidence == "" || evidence ~ /^<.*>$/) {
        printf("ERROR: %s gate %s missing evidence\n", file, gate)
        invalid = 1
      }

      if (evidence !~ /^(cmd|file|url|decision|reason):/) {
        printf("ERROR: %s gate %s evidence must start with cmd:, file:, url:, decision:, or reason:\n", file, gate)
        invalid = 1
      }

      if (status_value == "exception" && (exception == "" || exception ~ /^<.*>$/)) {
        printf("ERROR: %s gate %s exception missing accepted-risk record\n", file, gate)
        invalid = 1
      }

      if (status_value == "exception") {
        exception_gate[gate] = 1
      }
    }

    END {
      for (gate in exception_gate) {
        if (!failure_has[gate]) {
          printf("ERROR: %s gate %s exception not recorded in Failure List\n", file, gate)
          invalid = 1
        }
        if (!change_has[gate]) {
          printf("ERROR: %s gate %s exception not recorded in Change List\n", file, gate)
          invalid = 1
        }
      }
      exit invalid ? 1 : 0
    }
  ' "${path}"; then
    status=1
  fi

  if ! awk -F'|' -v file="${file}" '
    function trim(value) {
      gsub(/^[ \t]+|[ \t]+$/, "", value)
      return value
    }

    /^### Failure List/ {
      section = "failure"
      next
    }

    /^### Change List/ {
      section = "change"
      next
    }

    /^### / {
      section = ""
    }

    section == "failure" && /^\|/ {
      for (hook in exception_hook) {
        if ($0 ~ hook) {
          failure_has[hook] = 1
        }
      }
    }

    section == "change" && /^\|/ {
      for (hook in exception_hook) {
        if ($0 ~ hook) {
          change_has[hook] = 1
        }
      }
    }

    /^\|[ \t]*(before|after)_[a-z_]+[ \t]*\|/ {
      hook = trim($2)
      status_value = trim($5)
      evidence = trim($6)
      failure_handling = trim($7)

      if (seen_hook[hook]) {
        printf("ERROR: %s hook %s appears more than once\n", file, hook)
        invalid = 1
      }
      seen_hook[hook] = 1

      if (status_value != "pass" && status_value != "not-applicable" && status_value != "exception" && status_value != "blocked") {
        printf("ERROR: %s hook %s has invalid status: %s\n", file, hook, status_value)
        invalid = 1
      }

      if (status_value == "blocked") {
        printf("ERROR: %s hook %s is blocked\n", file, hook)
        invalid = 1
      }

      if (evidence == "" || evidence ~ /^<.*>$/) {
        printf("ERROR: %s hook %s missing evidence\n", file, hook)
        invalid = 1
      }

      if (evidence !~ /^(cmd|file|url|decision|reason):/) {
        printf("ERROR: %s hook %s evidence must start with cmd:, file:, url:, decision:, or reason:\n", file, hook)
        invalid = 1
      }

      if (status_value == "exception" && (failure_handling == "" || failure_handling ~ /^<.*>$/)) {
        printf("ERROR: %s hook %s exception missing failure handling\n", file, hook)
        invalid = 1
      }

      if (status_value == "exception") {
        exception_hook[hook] = 1
      }
    }

    END {
      for (hook in exception_hook) {
        if (!failure_has[hook]) {
          printf("ERROR: %s hook %s exception not recorded in Failure List\n", file, hook)
          invalid = 1
        }
        if (!change_has[hook]) {
          printf("ERROR: %s hook %s exception not recorded in Change List\n", file, hook)
          invalid = 1
        }
      }
      exit invalid ? 1 : 0
    }
  ' "${path}"; then
    status=1
  fi

  while IFS=$'\t' read -r gate evidence; do
    [[ -n "${gate}" ]] || continue

    if [[ "${evidence}" == file:* ]]; then
      evidence_path="${evidence#file:}"
      if [[ ! -e "${evidence_path}" && ! -e "${repo_root}/${evidence_path}" && ! -e "${run_dir}/${evidence_path}" ]]; then
        echo "ERROR: ${file} gate ${gate} file evidence not found: ${evidence_path}"
        status=1
      fi
    elif [[ "${evidence}" == url:* ]]; then
      evidence_url="${evidence#url:}"
      if [[ ! "${evidence_url}" =~ ^https?:// ]]; then
        echo "ERROR: ${file} gate ${gate} URL evidence must start with http:// or https://"
        status=1
      fi
    fi

    if ! is_required_gate "${gate}"; then
      echo "ERROR: ${file} has unexpected gate id: ${gate}"
      status=1
    fi
    printf '%s\n' "${gate}" >> "${gate_list_file}"
  done < <(awk -F'|' '
    function trim(value) {
      gsub(/^[ \t]+|[ \t]+$/, "", value)
      return value
    }

    /^\|[ \t]*G[0-9]+[ \t]*\|/ {
      print trim($2) "\t" trim($6)
    }
  ' "${path}")

  while IFS=$'\t' read -r hook evidence; do
    [[ -n "${hook}" ]] || continue

    if [[ "${evidence}" == file:* ]]; then
      evidence_path="${evidence#file:}"
      if [[ ! -e "${evidence_path}" && ! -e "${repo_root}/${evidence_path}" && ! -e "${run_dir}/${evidence_path}" ]]; then
        echo "ERROR: ${file} hook ${hook} file evidence not found: ${evidence_path}"
        status=1
      fi
    elif [[ "${evidence}" == url:* ]]; then
      evidence_url="${evidence#url:}"
      if [[ ! "${evidence_url}" =~ ^https?:// ]]; then
        echo "ERROR: ${file} hook ${hook} URL evidence must start with http:// or https://"
        status=1
      fi
    fi

    if ! is_required_hook "${hook}"; then
      echo "ERROR: ${file} has unexpected hook id: ${hook}"
      status=1
    elif ! is_expected_hook_for_file "${file}" "${hook}"; then
      echo "ERROR: ${file} has misplaced hook id: ${hook}"
      status=1
    fi
    printf '%s\n' "${hook}" >> "${hook_list_file}"
  done < <(awk -F'|' '
    function trim(value) {
      gsub(/^[ \t]+|[ \t]+$/, "", value)
      return value
    }

    /^\|[ \t]*(before|after)_[a-z_]+[ \t]*\|/ {
      print trim($2) "\t" trim($6)
    }
  ' "${path}")
done

for gate in "${required_gates[@]}"; do
  gate_count="$(grep -c -E "^${gate}$" "${gate_list_file}" || true)"
  if [[ "${gate_count}" -eq 0 ]]; then
    echo "ERROR: missing Gate Ledger row for ${gate}"
    status=1
  elif [[ "${gate_count}" -gt 1 ]]; then
    echo "ERROR: Gate Ledger row for ${gate} appears more than once in delivery run"
    status=1
  fi
done

for hook in "${required_hooks[@]}"; do
  hook_count="$(grep -c -E "^${hook}$" "${hook_list_file}" || true)"
  if [[ "${hook_count}" -eq 0 ]]; then
    echo "ERROR: missing Hook Ledger row for ${hook}"
    status=1
  elif [[ "${hook_count}" -gt 1 ]]; then
    echo "ERROR: Hook Ledger row for ${hook} appears more than once in delivery run"
    status=1
  fi
done

if [[ "${status}" -eq 0 ]]; then
  echo "Delivery run gates and hooks validated successfully."
fi

exit "${status}"
