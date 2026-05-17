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

## Local Development Workflow

- Identify whether the work is single-repo, monorepo/workspace, multi-repo, nested repo/submodule, or generated/vendor code before editing.
- Read applicable agent instruction files when present, including `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `GEMINI.MD`, `.cursorrules`, `.cursor/rules/*`, `.github/copilot-instructions.md`, `README.md`, `CONTRIBUTING.md`, and `DEVELOPMENT.md`.
- Look for relevant specs and docs before implementation: `docs/spec*`, requirements, PRDs, RFCs, ADRs, architecture docs, API schemas, migrations, runbooks, release docs, and CI workflows.
- Preserve unrelated user changes. Do not reset, checkout, or discard files unless explicitly asked.
- Update durable knowledge files when work changes lasting repository constraints. Use `AGENTS.md`, `README.md`, `docs/SKILL_SPEC.md`, skill docs, ADRs, or spec docs as appropriate.

## Validation

Run these before finishing skill changes:

```bash
bash scripts/validate-skills.sh
git diff --check
```

If validation cannot run, report the reason clearly.
