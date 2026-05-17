---
name: commit-message-writer
description: Use when writing a Git commit message from a local diff, change summary, staged files, changelog entry, or release-prep commit.
---

# Commit Message Writer

## Intent

Write a commit message that accurately captures the user-visible or maintainer-relevant change without restating file churn.

## When to Use

- Writing a commit message from `git diff`, staged changes, a change summary, or a set of touched files.
- Cleaning up a vague commit message before commit or PR.
- Do not use for PR descriptions unless the user specifically wants a commit message.

## Inputs

- `change_summary`: What changed and why.
- `files_touched`: Changed files list.

## Instructions

1. Inspect the actual change, not just filenames, when a diff is available. Identify the behavioral reason for the commit.
2. Choose Conventional Commit type:
   - `feat`: new user- or API-visible capability.
   - `fix`: bug, regression, incorrect behavior, or failing workflow.
   - `refactor`: behavior-preserving structure change.
   - `test`: test-only change.
   - `docs`: documentation-only change.
   - `chore`: tooling, metadata, dependency, or maintenance change.
   - `perf`, `build`, or `ci` when that is the primary impact.
3. Choose a narrow scope from the affected subsystem, package, route, component, or command. Omit scope when it would be generic.
4. Write an imperative subject under 72 characters, lowercase after the type, with no trailing period.
5. Add a body only when it explains motivation, compatibility, migration, risk, or validation that the subject cannot carry.
6. If multiple unrelated changes are present, recommend splitting commits and provide separate messages.

## Output Standard

- Default output is only the commit message, ready to use.
- If there is risk of an inaccurate message, add a short `Notes` section after the message explaining the uncertainty.
- Never use vague subjects like `update files`, `misc fixes`, `address comments`, or `wip`.
- Do not claim tests ran unless the input includes evidence.

## Examples

Input: Added null checks for workspace config loader and tests.

Output:

fix(config): guard empty workspace metadata

Prevent loader crash when workspace has no config file.
Add regression tests for empty metadata path.
