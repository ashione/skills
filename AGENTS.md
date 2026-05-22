# Repository Instructions

This repository maintains reusable agent skills. Treat every skill as executable process documentation, not a generic prompt.

## Read First

Before changing files, read the relevant constraints:

- `README.md` for repository purpose and skill standards.
- `docs/SKILL_SPEC.md` for required skill structure and validation rules.
- The target skill's `SKILL.md` and `skill.json`.
- `docs/HARNESS.md` and `skills/mobius-harness/references/*` when changing Mobius Harness behavior.

## Skill Editing Rules

- Keep `SKILL.md` and `skill.json` synchronized.
- `SKILL.md` frontmatter `name` must match the directory name and `skill.json.id`.
- `SKILL.md` frontmatter `description` must exactly match `skill.json.description`.
- Descriptions must start with `Use when...` and describe triggering conditions only. Do not summarize the workflow in the description.
- For nontrivial skills, include concrete scope classification, decision tables, risk classes, or pattern comparisons. A skill should force the agent to distinguish cases before acting.
- Instructions must be actionable and evidence-based. Avoid vague rules such as "improve quality", "ensure consistency", or "handle edge cases" unless the exact objects and checks are named.
- Output standards must define required sections, evidence requirements, and explicit anti-patterns.
- Examples must show the expected output shape, not just a one-line conclusion.
- Add reference files only when details are too large for `SKILL.md`; keep references one level below the skill directory and link them from `SKILL.md`.
- Mobius Harness phases must include adversarial Review Ledger checks with multiple roles or perspectives before phase results are treated as final.
- Mobius Harness issue-driven deliveries must include `Issue and Prior Attempts` in requirements and `Prior Attempt Comparison` in plan. Search linked issues, existing PRs, fork commits, issue comments, and related branches when available; mark the section not applicable only with evidence.
- Mobius Harness Hook Ledger rows are agent-runtime gates for Claude Code, Codex, or similar executors. Required Action values must start with `[hard]` or `[soft]`; hard gates cannot use `warn`, while soft-gate warnings must be mirrored in Failure List and Change List.
- Mobius Harness requirements and plan artifacts must include Minimum Skill Dependencies, including `mobius-harness`, `local-repo-development`, `superpowers:brainstorming`, and `superpowers:writing-plans` with dependency class, evidence, and fallback.
- Mobius Harness plan artifacts must include Validation Prerequisites for setup, generated artifacts, migrations, fixtures, or environment state required before validation commands can run cleanly.
- When initializing a Mobius Harness Delivery Episode Package, use `scripts/init-delivery-run.sh`; generated hook gates default to `[soft]` unless the user or repository policy explicitly requires `[hard]`. Keep gate strength separate from runtime-specific hook wording: use `--runtime auto` by default, or pin `--runtime codex`, `--runtime claude-code`, `--runtime claude`, or `--runtime generic` when the executor must be explicit; `claude` normalizes to `claude-code` in generated artifacts.

## Local Development Workflow

- Identify whether the work is single-repo, monorepo/workspace, multi-repo, nested repo/submodule, or generated/vendor code before editing.
- Read applicable agent instruction files when present, including `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `GEMINI.MD`, `.cursorrules`, `.cursor/rules/*`, `.github/copilot-instructions.md`, `README.md`, `CONTRIBUTING.md`, and `DEVELOPMENT.md`.
- Look for relevant specs and docs before implementation: `docs/spec*`, requirements, PRDs, RFCs, ADRs, architecture docs, API schemas, migrations, runbooks, release docs, and CI workflows.
- Preserve unrelated user changes. Do not reset, checkout, or discard files unless explicitly asked.
- Update durable knowledge files when work changes lasting repository constraints. Use `AGENTS.md`, `README.md`, `docs/SKILL_SPEC.md`, skill docs, ADRs, or spec docs as appropriate.
- For small PR/MR iterations, CI/CD waiting is asynchronous by default. Wait synchronously only when the user requests it, when merging or releasing, or when repository policy requires terminal checks.

## Validation

Run these before finishing skill changes:

```bash
bash scripts/validate-skills.sh
git diff --check
```

If validation cannot run, report the reason clearly.
