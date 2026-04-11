# Skills Hub

可复用的 Skill 仓库，统一维护技能提示词，软链接到任意 Agent 平台（Claude / Codex / OpenClaw）。

## 仓库结构

```text
.
├── docs/
│   └── SKILL_SPEC.md
├── scripts/
│   └── link_skills.sh
├── skills/
│   ├── api-design-review/
│   │   ├── SKILL.md
│   │   └── skill.json
│   ├── bug-triage/
│   │   ├── SKILL.md
│   │   └── skill.json
│   └── ...
└── README.md
```

## 使用

软链接到目标平台的 skill 目录：

```bash
bash scripts/link_skills.sh /path/to/claude/skills /path/to/codex/skills /path/to/openclaw/skills
```

脚本会把 `skills/` 下每个 skill 目录软链接过去，平台直接读取 `SKILL.md` 和 `skill.json`。

## Codex 兼容性

如果目标平台是本地 Codex，`SKILL.md` 顶部需要带 YAML frontmatter，至少包含：

```md
---
name: my-skill
description: One-line description.
---
```

- `name` 建议与 `skill.json.id` 和目录名保持一致。
- `description` 建议与 `skill.json.description` 保持一致。
- 仅有 `skill.json` 不足以保证 Codex 发现该 skill；Codex 本地发现逻辑会读取 `SKILL.md` 元数据。

本仓库内置的 `create-skill.sh` 已默认生成兼容 frontmatter。

## 新增 Skill

```bash
bash scripts/create-skill.sh my-new-skill
```

脚本会创建 `skills/my-new-skill/` 并生成 SKILL.md 和 skill.json 模板，填写 TODO 即可。

手动新增也可以：

1. 在 `skills/` 下新增目录，例如 `my-new-skill/`。
2. 新增 `SKILL.md`（人类可读标准文档）。
3. 新增 `skill.json`（机器可读结构化数据）。
4. 参考 [docs/SKILL_SPEC.md](docs/SKILL_SPEC.md) 填写字段。

## CI 验证

每次 push 和 PR 会自动检查：
- 每个 skill 目录包含 SKILL.md 和 skill.json。
- skill.json 语法正确且包含全部必需字段。
- skill.json 的 id 与目录名一致。
- `SKILL.md` frontmatter 中的 `name` / `description` 与 skill 元数据一致。

本地也可以先跑：

```bash
bash scripts/validate-skills.sh
```
