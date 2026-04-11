#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <target_dir_1> [target_dir_2 ...]"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_DIR="${REPO_ROOT}/skills"

if [[ ! -d "${SOURCE_DIR}" ]]; then
  echo "skills directory not found: ${SOURCE_DIR}"
  exit 1
fi

for target_dir in "$@"; do
  mkdir -p "${target_dir}"
  if [[ ! -w "${target_dir}" ]]; then
    echo "Error: ${target_dir} is not writable"
    exit 1
  fi
  count=0
  for skill_dir in "${SOURCE_DIR}"/*; do
    [[ -d "${skill_dir}" ]] || continue
    base_name="$(basename "${skill_dir}")"
    ln -sfn "${skill_dir}" "${target_dir}/${base_name}"
    count=$((count + 1))
  done
  echo "linked ${count} skills -> ${target_dir}"
done

echo "done"
