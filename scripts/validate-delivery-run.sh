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

  if ! awk -F'|' -v file="${file}" '
    function trim(value) {
      gsub(/^[ \t]+|[ \t]+$/, "", value)
      return value
    }

    /^\|[ \t]*G[0-9]+[ \t]*\|/ {
      gate = trim($2)
      status_value = trim($5)
      evidence = trim($6)
      exception = trim($7)

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

      if (status_value == "exception" && (exception == "" || exception ~ /^<.*>$/)) {
        printf("ERROR: %s gate %s exception missing accepted-risk record\n", file, gate)
        invalid = 1
      }
    }

    END {
      exit invalid ? 1 : 0
    }
  ' "${path}"; then
    status=1
  fi
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
