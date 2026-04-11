# Commit Message Writer

## Intent

Generate clean, conventional commit messages from code changes.

## Inputs

- `change_summary`: What changed and why.
- `files_touched`: Changed files list.

## Instructions

1. Infer commit type and scope using conventional commit style.
2. Write subject line under 72 characters.
3. Add body bullets only when needed for context.
4. Avoid vague verbs like update or fix stuff.

## Examples

Input: Added null checks for workspace config loader and tests.

Output:

fix(config): guard empty workspace metadata

Prevent loader crash when workspace has no config file.
Add regression tests for empty metadata path.
