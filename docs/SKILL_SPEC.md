# Skill Spec

所有 Skill 使用统一 JSON 格式，编码为 UTF-8。

目录结构要求：

```text
skills/
  <skill-id>/
    SKILL.md
    skill.json
```

说明：

- `SKILL.md` 是人类可读标准文档，必须存在。
- `skill.json` 是机器可读结构化数据。
- 若目标平台包含本地 Codex，`SKILL.md` 顶部还应包含 YAML frontmatter，至少提供 `name` 和 `description`。

## 必需字段

- `id` (string): 全局唯一，kebab-case，与目录名一致。
- `title` (string): Skill 标题。
- `description` (string): 能力简述。
- `version` (string): 语义化版本，例如 `1.0.0`。
- `tags` (string[]): 分类标签，建议 5-7 个。
- `input_schema` (object): 输入说明，每个字段附带格式引导。
- `instructions` (string[]): 执行指令列表，按顺序生效。
- `examples` (object[]): 示例。
  - `input` (string)
  - `output` (string)

## 最小示例

```json
{
  "id": "example-skill",
  "title": "Example Skill",
  "description": "A short capability description.",
  "version": "1.0.0",
  "tags": ["example"],
  "input_schema": {
    "task": "string"
  },
  "instructions": [
    "Read the task intent.",
    "Produce a clear and practical result."
  ],
  "examples": [
    {
      "input": "Write a release note for this bugfix.",
      "output": "Fixed a crash when opening empty project folders."
    }
  ]
}
```

## 风格建议

- 保持指令可执行，避免空泛表述。
- 每个 Skill 聚焦单一目标。
- 示例输入输出尽量贴近真实场景。

## SKILL.md 标准结构

推荐在文档最顶部加入 frontmatter，便于 Codex 之类的平台发现：

```md
---
name: <skill-id>
description: <one-line description>
---
```

每个 `SKILL.md` 至少包含以下标题：

- `# <Skill Title>`
- `## Intent`
- `## Inputs`
- `## Instructions`
- `## Examples`

## 可选扩展字段

复杂 skill（如多轮编排、有状态流程）可以在 skill.json 中添加额外字段。常见扩展：

| 类别 | 字段示例 | 用途 |
|------|----------|------|
| 生命周期 | `lifecycle`, `iteration_loop` | 定义阶段和循环步骤 |
| 消息模板 | `role_charter_template`, `status_report_template`, `heartbeat_template`, `probe_template`, `adjustment_template` | 标准化团队通信格式 |
| 记录模板 | `agent_todo_template`, `agent_finished_log_template`, `retro_report_template`, `lessons_ledger_entry` | 任务跟踪和回顾 |
| 规则 | `leader_decision_priority`, `leader_anti_patterns`, `failure_recovery`, `persistence_rules`, `context_management` | 决策框架和约束 |
| 枚举 | `task_board_statuses`, `adjustment_types` | 状态值和类型定义 |

扩展字段规则：
- 普通 skill 不需要这些字段，只用必需字段即可。
- 扩展字段必须在 SKILL.md 中有对应的人类可读说明。
- `additionalProperties: true` — skill.json 允许任意额外字段。
