#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILLS_DIR="${REPO_ROOT}/skills"

if [[ ! -d "${SKILLS_DIR}" ]]; then
  echo "skills directory not found: ${SKILLS_DIR}"
  exit 1
fi

status=0

for skill_dir in "${SKILLS_DIR}"/*; do
  [[ -d "${skill_dir}" ]] || continue

  skill_id="$(basename "${skill_dir}")"
  skill_md="${skill_dir}/SKILL.md"
  skill_json="${skill_dir}/skill.json"

  if [[ ! -f "${skill_md}" ]]; then
    echo "ERROR ${skill_id}: missing SKILL.md"
    status=1
    continue
  fi

  if [[ ! -f "${skill_json}" ]]; then
    echo "ERROR ${skill_id}: missing skill.json"
    status=1
    continue
  fi

  json_id="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8"))["id"])' "${skill_json}" 2>/dev/null || true)"
  json_description="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8"))["description"])' "${skill_json}" 2>/dev/null || true)"

  if [[ -z "${json_id}" || -z "${json_description}" ]]; then
    echo "ERROR ${skill_id}: invalid skill.json or missing required fields"
    status=1
    continue
  fi

  if [[ "${json_id}" != "${skill_id}" ]]; then
    echo "ERROR ${skill_id}: skill.json id '${json_id}' does not match directory name"
    status=1
  fi

  frontmatter_name="$(sed -n '2s/^name: //p' "${skill_md}")"
  frontmatter_description="$(sed -n '3s/^description: //p' "${skill_md}")"

  if [[ "$(sed -n '1p' "${skill_md}")" != "---" ]]; then
    echo "ERROR ${skill_id}: SKILL.md missing opening frontmatter delimiter"
    status=1
  fi

  if [[ "$(sed -n '4p' "${skill_md}")" != "---" ]]; then
    echo "ERROR ${skill_id}: SKILL.md missing closing frontmatter delimiter"
    status=1
  fi

  if [[ "${frontmatter_name}" != "${skill_id}" ]]; then
    echo "ERROR ${skill_id}: SKILL.md frontmatter name '${frontmatter_name}' does not match directory name"
    status=1
  fi

  if [[ "${frontmatter_description}" != "${json_description}" ]]; then
    echo "ERROR ${skill_id}: SKILL.md frontmatter description does not match skill.json description"
    status=1
  fi
done

if [[ "${status}" -eq 0 ]]; then
  echo "All skills validated successfully."
fi

exit "${status}"
