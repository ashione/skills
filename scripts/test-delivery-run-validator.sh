#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

tmp_dir="$(mktemp -d)"

cleanup() {
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

expect_failure() {
  local run_dir="$1"
  local expected="$2"
  local output
  local exit_code

  set +e
  output="$(bash scripts/validate-delivery-run.sh "${run_dir}" 2>&1)"
  exit_code="$?"
  set -e

  if [[ "${exit_code}" -eq 0 ]]; then
    echo "ERROR: ${run_dir} unexpectedly passed"
    exit 1
  fi

  if [[ "${output}" != *"${expected}"* ]]; then
    echo "ERROR: ${run_dir} failed for the wrong reason"
    echo "Expected diagnostic: ${expected}"
    echo "${output}"
    exit 1
  fi
}

copy_passing_fixture() {
  local name="$1"
  local target="${tmp_dir}/${name}"

  cp -R examples/delivery-runs/passing "${target}"
  printf '%s\n' "${target}"
}

bash scripts/validate-delivery-run.sh examples/delivery-runs/passing
bash scripts/validate-delivery-run.sh examples/delivery-runs/exception

expect_failure examples/delivery-runs/blocked "requirements.md gate G1 is blocked"

missing_brainstorming="$(copy_passing_fixture missing-brainstorming)"
perl -0pi -e 's/\n## Superpowers Decisions\n\n- Brainstorming: not-applicable, because this is a fixed validation fixture\.\n//' "${missing_brainstorming}/requirements.md"
expect_failure "${missing_brainstorming}" "requirements.md missing marker: ## Superpowers Decisions"

missing_writing_plans="$(copy_passing_fixture missing-writing-plans)"
perl -0pi -e 's/^- Writing Plans:.*\n//m' "${missing_writing_plans}/plan.md"
expect_failure "${missing_writing_plans}" "plan.md missing Writing Plans decision value"

missing_dependency="$(copy_passing_fixture missing-dependency)"
perl -0pi -e 's/\n## Dependency Decision\n\n- Decision:.*?\n\n## Implementation Steps/\n## Implementation Steps/s' "${missing_dependency}/plan.md"
expect_failure "${missing_dependency}" "plan.md missing marker: ## Dependency Decision"

duplicate_gate="$(copy_passing_fixture duplicate-gate)"
cat >> "${duplicate_gate}/requirements.md" <<'DUPLICATE_GATE'
| G2 | plan | Duplicate row used to prove package-level uniqueness. | pass | decision:duplicate | |
DUPLICATE_GATE
expect_failure "${duplicate_gate}" "Gate Ledger row for G2 appears more than once in delivery run"

missing_release_report="$(copy_passing_fixture missing-release-report)"
perl -0pi -e 's/\n## Version or Release Report\n\nreason:fixture has no versioned release\.\n//' "${missing_release_report}/delivery-report.md"
expect_failure "${missing_release_report}" "delivery-report.md missing marker: ## Version or Release Report"

echo "Delivery run validator regression tests passed."
