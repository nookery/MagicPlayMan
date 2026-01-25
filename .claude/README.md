# MagicPlayMan Claude 配置

这个目录包含了 Claude Code (AI 编程助手) 的配置文件，用于帮助 AI 更好地理解和管理 MagicPlayMan 项目。

## 目录结构

```
.claude/
├── MAGICPLAYMAN_GUIDE.md    # 项目开发指南
├── settings.json              # Claude 设置和权限
├── settings.local.json        # 本地覆盖设置
├── agents/                    # AI 代理配置
├── commands/                  # 自定义命令（/commit, /plan 等）
├── hooks/                     # Git 钩子
└── skills/                    # 技能文件（规范和最佳实践）
```

## 主要文件说明

### MAGICPLAYMAN_GUIDE.md
- 项目概述和架构
- 开发原则和规范
- 核心模式（状态管理、日志记录等）
- Emoji 选择指南

### settings.json
- 权限配置（允许执行的命令）
- 启用的插件
- MCP 服务器配置

### commands/
- `commit.md` - 智能生成 git commit message
- `plan.md` - 功能规划命令
- `swift-check.md` - 代码规范检查

### skills/
- `swiftui-standards.md` - SwiftUI 开发标准规范

## 使用方式

这些配置会自动被 Claude Code 读取和使用，无需手动操作。当你在 Claude Code 中与项目交互时：

1. **开发指南** - 自动遵循 MAGICPLAYMAN_GUIDE.md 中的规范
2. **提交代码** - 使用 `/commit` 命令自动生成规范的 commit message
3. **代码检查** - 使用 `/swift-check` 检查代码是否符合规范
4. **功能规划** - 使用 `/plan` 在开发前进行功能规划

## 自定义配置

### 本地覆盖
创建 `settings.local.json` 可以覆盖全局设置：

```json
{
  "permissions": {
    "allow": [
      "额外的权限..."
    ]
  }
}
```

### 添加新命令
在 `commands/` 目录创建 `.md` 文件，然后使用 `/<命令名>` 调用。

### 更新技能
编辑 `skills/` 目录下的 `.md` 文件来更新开发规范。

## 注意事项

- ⚠️ 不要提交敏感信息到这个目录
- ⚠️ settings.local.json 应该在 .gitignore 中
- ✅ 定期更新 MAGICPLAYMAN_GUIDE.md 以保持与项目同步
- ✅ 根据团队需求调整配置
