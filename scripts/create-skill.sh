#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <skill-id>"
  echo "Example: $0 my-new-skill"
  exit 1
fi

SKILL_ID="$1"

# Validate kebab-case
if [[ ! "$SKILL_ID" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "Error: skill id must be kebab-case (e.g. my-new-skill)"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TARGET="${REPO_ROOT}/skills/${SKILL_ID}"

if [[ -d "${TARGET}" ]]; then
  echo "Error: skills/${SKILL_ID}/ already exists"
  exit 1
fi

mkdir -p "${TARGET}"

# Generate SKILL.md
cat > "${TARGET}/SKILL.md" <<EOF
# ${SKILL_ID}

## Intent

TODO: Describe what this skill does in one sentence.

## Inputs

- \`input_1\`: TODO: describe format and example.

## Instructions

1. TODO: First actionable step.
2. TODO: Second actionable step.
3. TODO: Third actionable step.

## Examples

Input: TODO: realistic input.

Output: TODO: concrete output.
EOF

# Generate skill.json
cat > "${TARGET}/skill.json" <<EOF
{
  "id": "${SKILL_ID}",
  "title": "${SKILL_ID}",
  "description": "TODO: one-line description.",
  "version": "1.0.0",
  "tags": ["TODO"],
  "input_schema": {
    "input_1": "string — TODO: format guidance"
  },
  "instructions": [
    "TODO: First actionable step.",
    "TODO: Second actionable step.",
    "TODO: Third actionable step."
  ],
  "examples": [
    {
      "input": "TODO: realistic input.",
      "output": "TODO: concrete output."
    }
  ]
}
EOF

echo "Created skills/${SKILL_ID}/"
echo "  SKILL.md  — fill in the TODO sections"
echo "  skill.json — fill in the TODO sections"
