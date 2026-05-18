#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -ne 1 ]]; then
  echo "usage: bash scripts/validate-delivery-run.sh .delivery/runs/<run-id>"
  exit 2
fi

run_dir="$1"

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
valid_statuses=" draft active blocked complete deferred "

status=0

for file in "${required_files[@]}"; do
  path="${run_dir}/${file}"

  if [[ ! -f "${path}" ]]; then
    echo "ERROR: missing required artifact: ${path}"
    status=1
    continue
  fi

  for marker in "Status:" "Phase:" "Evidence:" "## Phase State" "Gate Ledger"; do
    if ! grep -q -- "${marker}" "${path}"; then
      echo "ERROR: ${file} missing marker: ${marker}"
      status=1
    fi
  done

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

  while IFS=$'\t' read -r gate evidence; do
    [[ -n "${gate}" ]] || continue

    if [[ "${evidence}" == file:* ]]; then
      evidence_path="${evidence#file:}"
      if [[ ! -e "${evidence_path}" && ! -e "${run_dir}/${evidence_path}" ]]; then
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
  done < <(awk -F'|' '
    function trim(value) {
      gsub(/^[ \t]+|[ \t]+$/, "", value)
      return value
    }

    /^\|[ \t]*G[0-9]+[ \t]*\|/ {
      print trim($2) "\t" trim($6)
    }
  ' "${path}")
done

for gate in "${required_gates[@]}"; do
  if ! grep -R -q -E "^\|[[:space:]]*${gate}[[:space:]]*\|" "${run_dir}"; then
    echo "ERROR: missing Gate Ledger row for ${gate}"
    status=1
  fi
done

if [[ "${status}" -eq 0 ]]; then
  echo "Delivery run gates validated successfully."
fi

exit "${status}"
