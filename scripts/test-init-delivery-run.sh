#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

tmp_dir="$(mktemp -d)"

cleanup() {
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

run_id="agent-gate-init"
run_dir="${tmp_dir}/.delivery/runs/${run_id}"
hard_run_id="agent-gate-init-hard"
hard_run_dir="${tmp_dir}/.delivery/runs/${hard_run_id}"
codex_run_id="agent-gate-init-codex"
codex_run_dir="${tmp_dir}/.delivery/runs/${codex_run_id}"
claude_run_id="agent-gate-init-claude"
claude_run_dir="${tmp_dir}/.delivery/runs/${claude_run_id}"
claude_alias_run_id="agent-gate-init-claude-alias"
claude_alias_run_dir="${tmp_dir}/.delivery/runs/${claude_alias_run_id}"
generic_run_id="agent-gate-init-generic"
generic_run_dir="${tmp_dir}/.delivery/runs/${generic_run_id}"
auto_codex_run_id="agent-gate-init-auto-codex"
auto_codex_run_dir="${tmp_dir}/.delivery/runs/${auto_codex_run_id}"
auto_claude_run_id="agent-gate-init-auto-claude"
auto_claude_run_dir="${tmp_dir}/.delivery/runs/${auto_claude_run_id}"

bash scripts/init-delivery-run.sh "${run_id}" --root "${tmp_dir}" --request "Initialize hook gates for a test delivery" >/dev/null

for file in requirements.md plan.md verification.md delivery-report.md; do
  if [[ ! -f "${run_dir}/${file}" ]]; then
    echo "ERROR: missing initialized artifact: ${file}"
    exit 1
  fi
done

for hook in before_requirements before_plan before_edit after_edit before_commit before_pr after_pr before_final; do
  if ! grep -R -q -E "^\| ${hook} \|" "${run_dir}"; then
    echo "ERROR: initialized run missing hook: ${hook}"
    exit 1
  fi
done

for hook in before_requirements before_plan before_edit after_edit before_commit before_pr after_pr before_final; do
  if ! grep -R -q -E "^\| ${hook} \|[^|]+\| \[soft\]" "${run_dir}"; then
    echo "ERROR: ${hook} hook did not default to a soft gate"
    exit 1
  fi
done

if ! grep -q -E '^Evidence: decision:Initialize hook gates for a test delivery$' "${run_dir}/requirements.md"; then
  echo "ERROR: request evidence was not written to requirements.md"
  exit 1
fi

dependency_pattern="- Decision: \`no-new-dependency\`"
if ! grep -q -F -- "${dependency_pattern}" "${run_dir}/plan.md"; then
  echo "ERROR: default Dependency Decision was not initialized"
  exit 1
fi

for file in requirements.md plan.md; do
  if ! grep -q -F "## Minimum Skill Dependencies" "${run_dir}/${file}"; then
    echo "ERROR: ${file} missing Minimum Skill Dependencies"
    exit 1
  fi
done

for file in requirements.md plan.md; do
  for skill in mobius-harness local-repo-development superpowers:brainstorming superpowers:writing-plans; do
    if ! grep -q -F "${skill}" "${run_dir}/${file}"; then
      echo "ERROR: initialized ${file} missing minimum skill dependency: ${skill}"
      exit 1
    fi
  done
done

if ! grep -q -E '^\| G1 \| requirements \| .*Minimum Skill Dependencies' "${run_dir}/requirements.md"; then
  echo "ERROR: G1 gate did not include minimum skill dependency evidence"
  exit 1
fi

if ! grep -q -E '^\| G2 \| plan \| .*Minimum Skill Dependencies' "${run_dir}/plan.md"; then
  echo "ERROR: G2 gate did not include minimum skill dependency evidence"
  exit 1
fi

if ! grep -q -E '^\| before_requirements \|[^|]+\| \[soft\].*Minimum Skill Dependencies' "${run_dir}/requirements.md"; then
  echo "ERROR: before_requirements hook did not include minimum skill dependency action"
  exit 1
fi

if ! grep -q -E '^\| before_plan \|[^|]+\| \[soft\].*Minimum Skill Dependencies' "${run_dir}/plan.md"; then
  echo "ERROR: before_plan hook did not include minimum skill dependency action"
  exit 1
fi

bash scripts/init-delivery-run.sh "${hard_run_id}" --root "${tmp_dir}" --request "Initialize hard hook gates" --gate-type hard >/dev/null

for hook in before_requirements before_plan before_edit after_edit before_commit before_pr after_pr before_final; do
  if ! grep -R -q -E "^\| ${hook} \|[^|]+\| \[hard\]" "${hard_run_dir}"; then
    echo "ERROR: ${hook} hook did not honor --gate-type hard"
    exit 1
  fi
done

bash scripts/init-delivery-run.sh "${codex_run_id}" --root "${tmp_dir}" --request "Initialize Codex hooks" --runtime codex >/dev/null

if ! grep -R -q "Codex hook" "${codex_run_dir}"; then
  echo "ERROR: --runtime codex did not generate Codex-specific hook actions"
  exit 1
fi

if ! grep -R -q "^Runtime: codex$" "${codex_run_dir}"; then
  echo "ERROR: --runtime codex did not record the runtime"
  exit 1
fi

bash scripts/init-delivery-run.sh "${claude_run_id}" --root "${tmp_dir}" --request "Initialize Claude Code hooks" --runtime claude-code >/dev/null

if ! grep -R -q "Claude Code hook" "${claude_run_dir}"; then
  echo "ERROR: --runtime claude-code did not generate Claude Code-specific hook actions"
  exit 1
fi

if ! grep -R -q "^Runtime: claude-code$" "${claude_run_dir}"; then
  echo "ERROR: --runtime claude-code did not record the runtime"
  exit 1
fi

bash scripts/init-delivery-run.sh "${claude_alias_run_id}" --root "${tmp_dir}" --request "Initialize Claude alias hooks" --runtime claude >/dev/null

if ! grep -R -q "Claude Code hook" "${claude_alias_run_dir}"; then
  echo "ERROR: --runtime claude did not generate Claude Code-specific hook actions"
  exit 1
fi

if ! grep -R -q "^Runtime: claude-code$" "${claude_alias_run_dir}"; then
  echo "ERROR: --runtime claude did not normalize to claude-code"
  exit 1
fi

bash scripts/init-delivery-run.sh "${generic_run_id}" --root "${tmp_dir}" --request "Initialize generic hooks" --runtime generic >/dev/null

if ! grep -R -q "Generic agent hook" "${generic_run_dir}"; then
  echo "ERROR: --runtime generic did not generate generic hook actions"
  exit 1
fi

env -i PATH="${PATH}" CODEX_SHELL=1 bash scripts/init-delivery-run.sh "${auto_codex_run_id}" --root "${tmp_dir}" --request "Auto-detect Codex hooks" --runtime auto >/dev/null

if ! grep -R -q "Codex hook" "${auto_codex_run_dir}"; then
  echo "ERROR: --runtime auto did not detect a Codex runtime from CODEX_SHELL"
  exit 1
fi

env -i PATH="${PATH}" CLAUDE_CODE=1 bash scripts/init-delivery-run.sh "${auto_claude_run_id}" --root "${tmp_dir}" --request "Auto-detect Claude Code hooks" --runtime auto >/dev/null

if ! grep -R -q "Claude Code hook" "${auto_claude_run_dir}"; then
  echo "ERROR: --runtime auto did not detect a Claude Code runtime from CLAUDE_CODE"
  exit 1
fi

if ! grep -R -q "^Runtime: claude-code$" "${auto_claude_run_dir}"; then
  echo "ERROR: --runtime auto did not record the auto-detected Claude Code runtime"
  exit 1
fi

set +e
invalid_gate_output="$(bash scripts/init-delivery-run.sh invalid-gate-type --root "${tmp_dir}" --gate-type strict 2>&1)"
invalid_gate_code="$?"
set -e

if [[ "${invalid_gate_code}" -eq 0 ]]; then
  echo "ERROR: init-delivery-run accepted an invalid gate type"
  exit 1
fi

if [[ "${invalid_gate_output}" != *"gate type must be soft or hard"* ]]; then
  echo "ERROR: invalid gate type failure used the wrong diagnostic"
  echo "${invalid_gate_output}"
  exit 1
fi

set +e
invalid_runtime_output="$(bash scripts/init-delivery-run.sh invalid-runtime --root "${tmp_dir}" --runtime desktop 2>&1)"
invalid_runtime_code="$?"
set -e

if [[ "${invalid_runtime_code}" -eq 0 ]]; then
  echo "ERROR: init-delivery-run accepted an invalid runtime"
  exit 1
fi

if [[ "${invalid_runtime_output}" != *"runtime must be auto, codex, claude-code, claude, or generic"* ]]; then
  echo "ERROR: invalid runtime failure used the wrong diagnostic"
  echo "${invalid_runtime_output}"
  exit 1
fi

set +e
overwrite_output="$(bash scripts/init-delivery-run.sh "${run_id}" --root "${tmp_dir}" 2>&1)"
overwrite_code="$?"
set -e

if [[ "${overwrite_code}" -eq 0 ]]; then
  echo "ERROR: init-delivery-run unexpectedly overwrote an existing run"
  exit 1
fi

if [[ "${overwrite_output}" != *"already exists"* ]]; then
  echo "ERROR: overwrite failure used the wrong diagnostic"
  echo "${overwrite_output}"
  exit 1
fi

echo "Delivery run initialization tests passed."
