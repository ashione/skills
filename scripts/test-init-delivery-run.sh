#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

tmp_dir="$(mktemp -d)"
git_tmp_dir="$(mktemp -d)"
tracked_settings_dir="$(mktemp -d)"

cleanup() {
  rm -rf "${tmp_dir}"
  rm -rf "${git_tmp_dir}"
  rm -rf "${tracked_settings_dir}"
}
trap cleanup EXIT

run_id="agent-gate-init"
run_dir="${tmp_dir}/.delivery/runs/${run_id}"
hook_dir="${tmp_dir}/.delivery/hooks"
hook_config="${hook_dir}/config.json"
claude_settings="${tmp_dir}/.claude/settings.json"
codex_settings="${tmp_dir}/.codex/settings.json"
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

mkdir -p "${tmp_dir}/.claude"
cat > "${claude_settings}" <<'JSON'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "rtk hook claude"
          }
        ]
      }
    ]
  }
}
JSON

bash scripts/init-delivery-run.sh "${run_id}" --root "${tmp_dir}" --request "Initialize hook gates for a test delivery" --runtime generic >/dev/null

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

if [[ ! -f "${hook_config}" ]]; then
  echo "ERROR: missing initialized hook config: ${hook_config}"
  exit 1
fi

for expected in '"schema_version": 1' "\"run_id\": \"${run_id}\"" '"gate_type": "soft"' '"runtime":'; do
  if ! grep -q -F "${expected}" "${hook_config}"; then
    echo "ERROR: hook config missing expected field: ${expected}"
    exit 1
  fi
done

for settings in "${claude_settings}" "${codex_settings}"; do
  if [[ ! -f "${settings}" ]]; then
    echo "ERROR: missing runtime hook settings: ${settings}"
    exit 1
  fi

  if ! python3 - "${settings}" <<'PY'
import json
import sys

settings = json.load(open(sys.argv[1], encoding="utf-8"))
entries = settings.get("hooks", {}).get("PreToolUse", [])
for entry in entries:
    if entry.get("matcher") != "Bash":
        continue
    for hook in entry.get("hooks", []):
        if hook == {"type": "command", "command": ".delivery/hooks/agent_gate.sh"}:
            raise SystemExit(0)
raise SystemExit(1)
PY
  then
    echo "ERROR: runtime hook settings missing Mobius PreToolUse Bash command: ${settings}"
    exit 1
  fi
done

if ! python3 - "${claude_settings}" <<'PY'
import json
import sys

settings = json.load(open(sys.argv[1], encoding="utf-8"))
commands = [
    hook.get("command")
    for entry in settings.get("hooks", {}).get("PreToolUse", [])
    if entry.get("matcher") == "Bash"
    for hook in entry.get("hooks", [])
]
raise SystemExit(0 if "rtk hook claude" in commands and ".delivery/hooks/agent_gate.sh" in commands else 1)
PY
then
  echo "ERROR: runtime hook settings did not preserve existing Bash gate command"
  exit 1
fi

for hook in before_requirements before_plan before_edit after_edit before_commit before_pr after_pr before_final; do
  if ! grep -R -q -E "^\| ${hook} \|[^|]+\| \[soft\]" "${run_dir}"; then
    echo "ERROR: ${hook} hook did not default to a soft gate"
    exit 1
  fi

  hook_script="${hook_dir}/${hook}.sh"
  if [[ ! -x "${hook_script}" ]]; then
    echo "ERROR: missing executable hook gate script: ${hook_script}"
    exit 1
  fi

  if ! grep -q -F "hook_id=\"${hook}\"" "${hook_script}"; then
    echo "ERROR: hook gate script does not identify its hook: ${hook}"
    exit 1
  fi

  set +e
  blocked_hook_output="$("${hook_script}" 2>&1)"
  blocked_hook_code="$?"
  set -e

  if [[ "${blocked_hook_code}" -eq 0 ]]; then
    echo "ERROR: blocked initialized hook unexpectedly passed: ${hook}"
    exit 1
  fi

  if [[ "${blocked_hook_output}" != *"is blocked"* ]]; then
    echo "ERROR: blocked initialized hook used wrong diagnostic for ${hook}"
    echo "${blocked_hook_output}"
    exit 1
  fi
done

if [[ ! -x "${hook_dir}/agent_gate.sh" ]]; then
  echo "ERROR: missing executable runtime agent gate script"
  exit 1
fi

if ! printf '{"tool_input":{"command":"ls"}}' | "${hook_dir}/agent_gate.sh" | grep -q -F "Mobius hook gate skipped"; then
  echo "ERROR: runtime agent gate did not skip ungated Bash command"
  exit 1
fi

set +e
agent_gate_output="$(printf '{"tool_input":{"command":"git commit -m test"}}' | "${hook_dir}/agent_gate.sh" 2>&1)"
agent_gate_code="$?"
set -e

if [[ "${agent_gate_code}" -eq 0 ]]; then
  echo "ERROR: runtime agent gate unexpectedly allowed blocked commit command"
  exit 1
fi

if [[ "${agent_gate_output}" != *"before_commit is blocked"* ]]; then
  echo "ERROR: runtime agent gate used wrong diagnostic for blocked commit"
  echo "${agent_gate_output}"
  exit 1
fi

set +e
pr_gate_output="$(printf '{"tool_input":{"command":"gh pr create --fill"}}' | "${hook_dir}/agent_gate.sh" 2>&1)"
pr_gate_code="$?"
set -e

if [[ "${pr_gate_code}" -eq 0 ]]; then
  echo "ERROR: runtime agent gate unexpectedly allowed blocked PR command"
  exit 1
fi

if [[ "${pr_gate_output}" != *"before_pr is blocked"* ]]; then
  echo "ERROR: runtime agent gate used wrong diagnostic for blocked PR command"
  echo "${pr_gate_output}"
  exit 1
fi

perl -0pi -e 's/(\| before_requirements \|[^\n]*\| )blocked( \| decision:Initialize hook gates for a test delivery \| \|)/${1}pass${2}/' "${run_dir}/requirements.md"

if ! "${hook_dir}/before_requirements.sh" | grep -q -F "Mobius hook before_requirements satisfied: pass"; then
  echo "ERROR: satisfied hook gate script did not pass"
  exit 1
fi

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

if ! grep -q -F "## Issue and Prior Attempts" "${run_dir}/requirements.md"; then
  echo "ERROR: requirements.md missing Issue and Prior Attempts"
  exit 1
fi

if ! grep -q -F "Prior Attempt Search:" "${run_dir}/requirements.md"; then
  echo "ERROR: requirements.md missing prior attempt search field"
  exit 1
fi

if ! grep -q -F "## Prior Attempt Comparison" "${run_dir}/plan.md"; then
  echo "ERROR: plan.md missing Prior Attempt Comparison"
  exit 1
fi

if ! grep -q -F "Freshness Evidence:" "${run_dir}/plan.md"; then
  echo "ERROR: plan.md missing freshness evidence field"
  exit 1
fi

for file in requirements.md plan.md; do
  for skill in mobius-harness local-repo-development superpowers:brainstorming superpowers:writing-plans; do
    if ! grep -q -F "${skill}" "${run_dir}/${file}"; then
      echo "ERROR: initialized ${file} missing minimum skill dependency: ${skill}"
      exit 1
    fi
  done
done

if ! grep -q -E '^\| G1 \| requirements \| .*Issue and Prior Attempts.*Minimum Skill Dependencies' "${run_dir}/requirements.md"; then
  echo "ERROR: G1 gate did not include issue/prior attempt and minimum skill dependency evidence"
  exit 1
fi

if ! grep -q -E '^\| G2 \| plan \| .*prior attempt comparison.*Minimum Skill Dependencies' "${run_dir}/plan.md"; then
  echo "ERROR: G2 gate did not include prior attempt comparison and minimum skill dependency evidence"
  exit 1
fi

if ! grep -q -F "## Validation Prerequisites" "${run_dir}/plan.md"; then
  echo "ERROR: plan.md missing Validation Prerequisites"
  exit 1
fi

if ! grep -q -E '^\| G2 \| plan \| .*Validation Prerequisites' "${run_dir}/plan.md"; then
  echo "ERROR: G2 gate did not include validation prerequisite evidence"
  exit 1
fi

if ! grep -q -E '^\| before_requirements \|[^|]+\| \[soft\].*prior PR or attempt search.*Minimum Skill Dependencies' "${run_dir}/requirements.md"; then
  echo "ERROR: before_requirements hook did not include prior attempt and minimum skill dependency actions"
  exit 1
fi

if ! grep -q -E '^\| before_plan \|[^|]+\| \[soft\].*Minimum Skill Dependencies.*prior attempt comparison.*Validation Prerequisites' "${run_dir}/plan.md"; then
  echo "ERROR: before_plan hook did not include minimum skill dependency, prior attempt comparison, and validation prerequisite actions"
  exit 1
fi

bash scripts/init-delivery-run.sh "${hard_run_id}" --root "${tmp_dir}" --request "Initialize hard hook gates" --gate-type hard >/dev/null

for expected in "\"run_id\": \"${hard_run_id}\"" '"gate_type": "hard"'; do
  if ! grep -q -F "${expected}" "${hook_config}"; then
    echo "ERROR: hard hook config missing expected field: ${expected}"
    exit 1
  fi
done

for hook in before_requirements before_plan before_edit after_edit before_commit before_pr after_pr before_final; do
  if ! grep -R -q -E "^\| ${hook} \|[^|]+\| \[hard\]" "${hard_run_dir}"; then
    echo "ERROR: ${hook} hook did not honor --gate-type hard"
    exit 1
  fi
done

bash scripts/init-delivery-run.sh "${codex_run_id}" --root "${tmp_dir}" --request "Initialize Codex hooks" --runtime codex >/dev/null

for expected in "\"run_id\": \"${codex_run_id}\"" '"runtime": "codex"'; do
  if ! grep -q -F "${expected}" "${hook_config}"; then
    echo "ERROR: Codex hook config missing expected field: ${expected}"
    exit 1
  fi
done

if [[ ! -f "${codex_settings}" ]]; then
  echo "ERROR: --runtime codex did not generate Codex settings"
  exit 1
fi

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

for expected in "\"run_id\": \"${generic_run_id}\"" '"runtime": "generic"'; do
  if ! grep -q -F "${expected}" "${hook_config}"; then
    echo "ERROR: generic hook config missing expected field: ${expected}"
    exit 1
  fi
done

if ! grep -R -q "Generic agent hook" "${generic_run_dir}"; then
  echo "ERROR: --runtime generic did not generate generic hook actions"
  exit 1
fi

git -C "${git_tmp_dir}" init -q
bash scripts/init-delivery-run.sh git-ignored-scaffold --root "${git_tmp_dir}" --request "Initialize ignored scaffold in target repo" --runtime generic >/dev/null

git_status="$(git -C "${git_tmp_dir}" status --short)"
if [[ -n "${git_status}" ]]; then
  echo "ERROR: initialized scaffold should be locally excluded from target repo status"
  echo "${git_status}"
  exit 1
fi

git_exclude="$(git -C "${git_tmp_dir}" rev-parse --path-format=absolute --git-path info/exclude)"
for ignored_path in ".delivery/" ".claude/settings.json" ".codex/settings.json"; do
  if ! grep -q -F "${ignored_path}" "${git_exclude}"; then
    echo "ERROR: target repo local exclude missing generated scaffold path: ${ignored_path}"
    exit 1
  fi
done

for ignored_path in ".claude/settings.local.json" ".codex/settings.local.json"; do
  if ! grep -q -F "${ignored_path}" "${git_exclude}"; then
    echo "ERROR: target repo local exclude missing local runtime settings path: ${ignored_path}"
    exit 1
  fi
done

git -C "${tracked_settings_dir}" init -q
mkdir -p "${tracked_settings_dir}/.claude"
cat > "${tracked_settings_dir}/.claude/settings.json" <<'JSON'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "rtk hook claude"
          }
        ]
      }
    ]
  }
}
JSON
git -C "${tracked_settings_dir}" add .claude/settings.json
git -C "${tracked_settings_dir}" -c user.name="Mobius Test" -c user.email="mobius@example.invalid" commit -q -m "track claude settings"

bash scripts/init-delivery-run.sh tracked-settings-local --root "${tracked_settings_dir}" --request "Initialize without modifying tracked settings" --runtime claude-code >/dev/null

if ! git -C "${tracked_settings_dir}" diff --quiet -- .claude/settings.json; then
  echo "ERROR: initialization modified tracked target repo Claude settings"
  exit 1
fi

if [[ ! -f "${tracked_settings_dir}/.claude/settings.local.json" ]]; then
  echo "ERROR: initialization did not write local Claude settings fallback"
  exit 1
fi

tracked_settings_status="$(git -C "${tracked_settings_dir}" status --short)"
if [[ -n "${tracked_settings_status}" ]]; then
  echo "ERROR: initialized scaffold or local settings should not appear in target repo status"
  echo "${tracked_settings_status}"
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
