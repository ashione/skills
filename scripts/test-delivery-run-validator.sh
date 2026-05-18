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

missing_requirements_maturity="$(copy_passing_fixture missing-requirements-maturity)"
perl -0pi -e 's/\n## Requirements Maturity\n\n- Maturity: `ready-for-design`\n- Blocking Unknowns: none\n- Maturity Evidence: decision:fixture requirements are fully specified\n//' "${missing_requirements_maturity}/requirements.md"
expect_failure "${missing_requirements_maturity}" "requirements.md missing marker: ## Requirements Maturity"

blocked_design_readiness="$(copy_passing_fixture blocked-design-readiness)"
perl -0pi -e 's/- Readiness: `ready-for-implementation`/- Readiness: `blocked`/' "${blocked_design_readiness}/plan.md"
expect_failure "${blocked_design_readiness}" "plan.md has invalid Design Readiness: blocked"

unaccepted_maturity_risk="$(copy_passing_fixture unaccepted-maturity-risk)"
perl -0pi -e 's/- Maturity: `ready-for-design`/- Maturity: `accepted-risk`/' "${unaccepted_maturity_risk}/requirements.md"
expect_failure "${unaccepted_maturity_risk}" "requirements.md Requirements Maturity accepted-risk requires G1 exception"

unaccepted_design_risk="$(copy_passing_fixture unaccepted-design-risk)"
perl -0pi -e 's/- Readiness: `ready-for-implementation`/- Readiness: `accepted-risk`/' "${unaccepted_design_risk}/plan.md"
expect_failure "${unaccepted_design_risk}" "plan.md Design Readiness accepted-risk requires G2 exception"

missing_hook_ledger="$(copy_passing_fixture missing-hook-ledger)"
perl -0pi -e 's/\n### Hook Ledger\n\n\| Hook \| Trigger \| Required Action \| Status \| Evidence \| Failure Handling \|\n\|---\|---\|---\|---\|---\|---\|\n\| before_plan \|[^\n]*\n//' "${missing_hook_ledger}/plan.md"
expect_failure "${missing_hook_ledger}" "plan.md missing marker: ### Hook Ledger"

blocked_hook="$(copy_passing_fixture blocked-hook)"
perl -0pi -e 's/\| before_commit \| before commit or PR\/MR preparation \| Run or record local validation, diff review, and sensitive information scan\. \| pass \| cmd:bash scripts\/validate-delivery-run\.sh examples\/delivery-runs\/passing \| \|/| before_commit | before commit or PR\/MR preparation | Run or record local validation, diff review, and sensitive information scan. | blocked | reason:intentional hook blocker | |/' "${blocked_hook}/verification.md"
expect_failure "${blocked_hook}" "verification.md hook before_commit is blocked"

misplaced_hook="$(copy_passing_fixture misplaced-hook)"
perl -0pi -e 's/\n\| before_plan \|[^\n]*\n//' "${misplaced_hook}/plan.md"
cat >> "${misplaced_hook}/requirements.md" <<'MISPLACED_HOOK'
| before_plan | before G2 completion | Misplaced hook row used to prove artifact ownership. | pass | decision:misplaced | |
MISPLACED_HOOK
expect_failure "${misplaced_hook}" "requirements.md has misplaced hook id: before_plan"

duplicate_hook="$(copy_passing_fixture duplicate-hook)"
cat >> "${duplicate_hook}/plan.md" <<'DUPLICATE_HOOK'
| before_plan | before G2 completion | Duplicate hook row used to prove package-level uniqueness. | pass | decision:duplicate | |
DUPLICATE_HOOK
expect_failure "${duplicate_hook}" "plan.md hook before_plan appears more than once"

echo "Delivery run validator regression tests passed."
