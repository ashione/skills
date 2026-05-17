# Skills Hub

可复用的 Skill Suite 仓库，统一维护技能提示词，软链接到任意 Agent 平台（Claude / Codex / OpenClaw）。

## Mobius Harness

`mobius-harness` 是本仓库的端到端交付主入口。用户可以用它驱动同一个 agent 完成完整软件交付流程：

1. 需求分析
2. 交付计划
3. 本地 worktree 开发
4. 实现与本地验证
5. PR/MR 创建与 CI/CD 跟踪
6. 交付报告

其他 skills 是 Mobius Harness 可按需调用的专业能力，例如：

- `local-repo-development`：单仓/多仓拓扑识别、仓库级 agent 指令与 spec/docs 发现、worktree、提交前 review、敏感信息扫描、CI/CD 跟踪
- `refactor-planner`：按重构范围和范式对比生成低风险阶段计划
- `api-design-review`：按 API 形态和变更风险审查契约
- `test-case-generator`：按测试范围和 case family 生成可执行测试矩阵
- `frontend-ux-polish`：按界面类型和审计维度打磨前端体验
- `bug-triage`：按 bug class、复现策略、严重度和证据进行分级
- `incident-postmortem`：按 incident class 和 cause analysis 生成复盘
- `commit-message-writer`：提交信息生成

## Skill 标准

本仓库的 skill 不是泛用提示词集合，而是可复用的工作标准。新增或修改 skill 时必须满足：

- `SKILL.md` 和 `skill.json` 必须同步更新；`description` 必须完全一致。
- `description` 使用 `Use when...` 写法，只描述触发条件，不总结执行流程。
- 非平凡 skill 必须包含适用范围、分类矩阵或决策表，例如重构范围、API surface、SQL workload、测试 scope、UI surface、bug/incident class。
- 指令必须可执行，避免只写“保持一致”“优化体验”“注意风险”这类无对象标准。
- 输出标准必须明确必填章节、证据要求、反例约束和不能宣称的内容。
- 示例必须体现期望输出形态；不要只给一句泛化结论。
- 复杂细节优先放在 `references/`，`SKILL.md` 保留核心触发、分类、流程和产出标准。

本仓库已有的专业 skills 都应遵循“先分类，再选择范式，再输出可验证结果”的原则。

## 本地开发约束

本仓库自身也遵循 `local-repo-development` 的规则：

- 修改前先读取仓库级约束文件，包括 `AGENTS.md`、`README.md`、`docs/SKILL_SPEC.md`，以及相关 skill 自身的 `SKILL.md` / `skill.json`。
- 如果任务涉及 Mobius Harness，还应按需读取 `docs/HARNESS.md` 和 `skills/mobius-harness/references/` 下的相关文件。
- 每个 skill 目录都视为独立能力单元；修改正文时必须判断是否需要同步 `skill.json` 的结构化字段、instructions、examples。
- 当一次修改产生了新的持久标准，应更新 `README.md`、`AGENTS.md`、`docs/SKILL_SPEC.md` 或相关 skill 文档，不能只留在对话里。

长任务默认可在本地维护 Delivery Episode Package：

```text
.delivery/runs/<run-id>/
  requirements.md
  plan.md
  verification.md
  delivery-report.md
```

`.delivery/runs/` 默认不提交到 git。

交付过程必须遵循 Mobius Harness 的阶段门禁。任务开始时选择 `Lightweight`、`Standard` 或 `Strict` 模式；大任务可拆成子阶段。每个阶段和子阶段都必须记录 Goal、Checklist、Todo List、Failure List 和 Change List。任何 complete 状态都必须有 evidence。交付产物必须遵循 [docs/HARNESS.md](docs/HARNESS.md) 中的 artifact 标准。

如果交付被中断，后续 agent 应先读取 `.delivery/runs/<run-id>/`，找到最早未完成的阶段或子阶段，再基于 Todo List、Failure List、Change List 和当前 git 状态继续执行。

## 仓库结构

```text
.
├── docs/
│   ├── HARNESS.md
│   └── SKILL_SPEC.md
├── AGENTS.md
├── scripts/
│   ├── create-skill.sh
│   ├── link_skills.sh
│   └── validate-skills.sh
├── skills/
│   ├── mobius-harness/
│   │   ├── SKILL.md
│   │   ├── skill.json
│   │   └── references/
│   │       ├── delivery-process.md
│   │       ├── artifact-interface.md
│   │       ├── artifact-templates.md
│   │       └── governance-and-reporting.md
│   ├── local-repo-development/
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
5. 按本 README 的 Skill 标准补充适用范围、分类/决策表、输出标准和示例。
6. 如果新增或修改了仓库级约束，更新 [AGENTS.md](AGENTS.md)。

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
