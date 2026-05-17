---
name: local-repo-development
description: Use when making local code, docs, config, or test changes that need repository topology discovery, agent instruction files, project specs/docs, git worktree or branch setup, validation, review, secret scanning, commits, PR/MR submission, or CI/CD follow-up.
---

# Local Repo Development

## Intent

Follow a conservative local repository development workflow that first learns the repository topology and local agent/project constraints, then isolates feature work in git worktrees and gates commits with validation, review, and secret scanning.

## When to Use

- Any local code, docs, config, or test change in a git repository where repository-local instructions, branch/worktree hygiene, or validation gates matter.
- Multi-repository, monorepo, submodule, nested-repo, package-workspace, or service-stack changes.
- Commit preparation, PR/MR preparation, sensitive information checks, or CI/CD follow-up.
- Do not use for read-only code explanation unless the user asks for workflow guidance.

## Inputs

- `feature_name`: Short feature, fix, or task name used to identify the worktree and branch.
- `repo_path`: Local repository path, usually the current working directory.
- `commit_intent`: Optional summary of the changes that should be committed.
- `mr_url`: Optional merge request or pull request URL created for the work.

## Repository Topology

Classify the workspace before editing. The topology determines which instruction files, docs, and validation commands are authoritative.

| Topology | How to Detect | Required Handling |
|----------|---------------|-------------------|
| Single repo | One `git rev-parse --show-toplevel`, no nested `.git`, no workspace manifest covering siblings | Use root instructions plus nearest package/module instructions. |
| Monorepo/workspace | Root has workspace manifest such as `pnpm-workspace.yaml`, `package.json` workspaces, `turbo.json`, `nx.json`, `lerna.json`, `rush.json`, `Cargo.toml` workspace, `go.work`, `pyproject.toml` workspace, or Bazel files | Identify affected packages/apps and run package-scoped validation plus root-required gates. |
| Multi-repo task | User request, docs, scripts, or config references sibling repos/services; multiple git roots are needed | Treat each repo as separately owned: read its instructions/docs, preserve its dirty state, use separate branch/worktree decisions, and report per-repo validation. |
| Nested repo/submodule | `git submodule status`, nested `.git`, or `git rev-parse --show-superproject-working-tree` | Do not edit nested repo as if it were part of parent; inspect and report parent/submodule status separately. |
| Generated/vendor subtree | Paths under `vendor`, generated output, lockfile-only package cache, or docs marking generated code | Do not manually edit unless the repo instructions explicitly allow it; find the source generator instead. |

## Instruction Discovery

Before implementation, search from repo root to the target path for agent and human instruction files. Nearest path-specific instructions override broader ones unless they conflict with the user's explicit request.

Required names to check include:

- `AGENTS.md`
- `CLAUDE.md`
- `GEMINI.md`
- `GEMINI.MD`
- `.cursorrules`
- `.cursor/rules/*`
- `.github/copilot-instructions.md`
- `README.md` when it contains development, architecture, or contribution rules
- `CONTRIBUTING.md`
- `DEVELOPMENT.md`

For multi-repo work, repeat this discovery independently in every affected repository. Record which files were found, which apply to the touched paths, and any conflicts or missing guidance.

## Spec and Docs Discovery

Before deciding the implementation path, look for product, technical, and validation context that constrains the change.

| Artifact | Typical Names | Use For |
|----------|---------------|---------|
| Product/spec | `spec.md`, `SPECS.md`, `docs/spec*`, `requirements.md`, `prd.md`, `rfcs/*`, `adr/*` | Scope, acceptance criteria, non-goals, compatibility decisions. |
| Architecture | `docs/architecture*`, `ARCHITECTURE.md`, `docs/design*`, `adr/*` | Boundaries, ownership, data flow, dependency rules. |
| Development workflow | `CONTRIBUTING.md`, `DEVELOPMENT.md`, `docs/development*`, `Makefile`, task runner config | Install, test, lint, build, generated code. |
| API/data contracts | `openapi*`, `schema.graphql`, `proto/*`, `db/migrations`, `docs/api*` | Public contract and migration constraints. |
| Operational docs | `runbook*`, `docs/ops*`, `docs/release*`, `.github/workflows/*` | Release, CI/CD, deployment, rollback, incident constraints. |

Read only the relevant sections, but do not skip discovery. If no spec/docs exist for a risky change, state that and use repository code/tests as the source of truth.

## Knowledge Updates

Update repository knowledge or constraint files when the work reveals durable project facts that future agents should know.

Update candidates:

- `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, or equivalent agent instruction files for durable agent workflow constraints.
- `CONTRIBUTING.md` or `DEVELOPMENT.md` for build/test/dev workflow changes.
- `README.md` for user-facing setup or high-level project behavior.
- `docs/architecture*`, `adr/*`, or `docs/design*` for durable architectural decisions.
- `docs/spec*`, `requirements.md`, or RFC/ADR files for accepted product/spec changes.

Update only when the knowledge is durable, repo-specific, and useful for future work. Do not add transient task notes, private reasoning, secrets, local machine paths, or facts already documented elsewhere. If a constraint file exists and is stale because of the change, update it in the same repo before completion. For multi-repo work, update only the repo whose durable knowledge changed.

## Instructions

1. Confirm the current directory is inside a git repository with `git rev-parse --show-toplevel`. If it is not, stop and ask for the repository path.
2. Classify repository topology using `Repository Topology`. For multi-repo or nested-repo work, build a per-repo plan before editing any repo.
3. Run `Instruction Discovery` for every affected repo and target path. Read the applicable instruction files before choosing implementation or validation commands.
4. Run `Spec and Docs Discovery` for every affected repo. Identify the docs/specs/contracts/workflow files that constrain the change, or state that none were found.
5. Before editing, determine whether the current checkout is already a linked worktree for this task:
   - Inspect `git worktree list --porcelain`.
   - Inspect `git rev-parse --git-dir` and treat paths under `.git/worktrees/` as linked worktrees.
   - If already in a suitable linked worktree, continue there.
6. If not in a suitable linked worktree, create one before making changes:
   - Derive a kebab-case slug from `feature_name`.
   - Prefer base ref `origin/main`, then `origin/master`, then local `main`, local `master`, then `HEAD`.
   - Create a feature branch such as `feature/<slug>` or `fix/<slug>` based on task intent.
   - Place the worktree in a sibling directory such as `../<repo-name>-<slug>` unless the repo has a documented worktree location.
   - Use `git worktree add -b <branch> <path> <base-ref>`. If the branch or path already exists, choose a non-destructive unique name.
7. Never discard existing user changes while preparing the worktree. If the current repo or selected worktree has unrelated dirty files, keep them and work around them; ask only if they block the task.
8. Implement the requested change in the selected worktree using the discovered repository instructions, specs/docs, build conventions, style rules, and test conventions. In multi-repo work, keep each repo's constraints and validation separate.
9. When the change creates or invalidates durable repo knowledge, update the appropriate instruction/spec/docs file using `Knowledge Updates`.
10. Before committing, run a code review pass over the local diff:
   - Review `git diff HEAD` or the staged diff for bugs, regressions, missing tests, unsafe behavior, and unintended file churn.
   - Fix material findings before continuing.
11. Before committing, scan for sensitive information in the local repository changes:
   - Prefer an installed scanner such as `gitleaks detect --source . --no-git --redact` or `detect-secrets scan`.
   - If no scanner is available, do a focused fallback scan of changed files for common secret patterns such as API keys, private keys, tokens, passwords, `.env` values, and credentials.
   - Do not print secret values. Report only file paths, key names, and redacted evidence.
12. Stage only intentional files, then commit with a clear message after the code review and sensitive information scan pass. In multi-repo work, commit and report per repository unless the user explicitly asks for a different integration strategy. If any gate cannot be run, state that explicitly before committing.
13. After submitting a merge request or pull request, asynchronously track CI/CD until it reaches a terminal state:
   - Record the MR or PR URL and the branch name.
   - Check pipeline status with the repository's normal tool, such as GitHub checks, GitLab pipelines, or the project's CI dashboard.
   - Do not block unrelated work while waiting, but revisit the pipeline until it passes, fails, or is canceled.
   - If CI/CD fails, inspect the failing job logs, summarize the failure, and fix issues that are in scope for the change.
   - Report the final CI/CD state clearly, including any checks that could not be observed.

## Output Standard

- Record topology classification, affected repositories, applicable instruction files, relevant spec/docs files, selected repo root, branch, worktree status, changed files, validation commands, diff review result, sensitive information scan result, knowledge-file updates, commit hash when created, PR/MR URL when created, and CI/CD state when observed.
- State explicitly when a gate is skipped or unavailable and why.
- For multi-repo work, report the above per repository.
- Do not claim a clean worktree, successful test, secret scan, commit, push, PR/MR, or passing CI/CD without tool output or an observed artifact.
- Do not stage unrelated files.
- Do not discard or overwrite user changes to simplify the workflow.

## Examples

Input: Add a dashboard filter feature in `/repo/app`.

Output: Classified `/repo/app` as a monorepo package change, read root `AGENTS.md`, package `README.md`, and `docs/filters-spec.md`, confirmed current checkout was not a linked worktree, created `../app-dashboard-filter` from `origin/main` on branch `feature/dashboard-filter`, implemented the change under the package's test conventions, updated `docs/filters-spec.md` because the accepted filter behavior changed, reviewed the diff, ran validation and a secret scan, committed only the intended files, opened an MR, and asynchronously monitored CI/CD until the pipeline passed.
