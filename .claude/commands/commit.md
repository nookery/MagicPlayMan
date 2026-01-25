# 智能生成 Commit Message

自动分析代码更改并生成符合规范的提交信息（Conventional Commits 格式）。

## 工作流程

1. **检查 Git 状态**
   - 运行 `git status` 查看当前仓库状态
   - 识别已暂存和未暂存的更改

2. **分析代码差异**
   - 运行 `git diff --staged` 查看已暂存的更改
   - 如果没有暂存的更改，运行 `git diff` 查看未暂存的更改
   - 分析以下内容：
     - 修改的文件类型（核心类、扩展、视图、模型等）
     - 代码变更的性质（新增、修改、删除、重构等）
     - 影响范围和重要性

3. **查看提交历史**
   - 运行 `git log -10 --oneline` 查看最近 10 条提交
   - 了解项目的 commit message 风格和约定

4. **生成 Commit Message**
   - 基于 Conventional Commits 规范：

     ```text
     <type>(<scope>): <subject>

     <body>

     <footer>
     ```

   - **Type（类型）**：
     - `feat`: 新功能
     - `fix`: 修复 bug
     - `docs`: 文档变更
     - `style`: 代码格式（不影响代码运行的变动）
     - `refactor`: 重构（既不是新增功能，也不是修复 bug）
     - `perf`: 性能优化
     - `test`: 增加测试
     - `chore`: 构建过程或辅助工具的变动
     - `revert`: 回滚之前的 commit

   - **Scope（范围）**：
     - `player`: 播放器核心功能
     - `controls`: 播放控制相关
     - `playlist`: 播放列表相关
     - `remote`: 远程控制/锁屏界面
     - `cache`: 缓存系统
     - `state`: 状态管理
     - `ui`: UI 组件相关
     - `localization`: 多语言支持
     - `models`: 数据模型
     - 或其他合适的模块名称

   - **Subject（主题）**：
     - 简洁描述（不超过 50 字符）
     - 不以句号结尾
     - 使用祈使句（如 "add" 而非 "added" 或 "adds"）

   - **Body（正文）**：
     - 详细描述更改内容
     - 说明 "为什么" 而非 "是什么"
     - 每行限制在 72 字符以内

   - **Footer（脚注）**：
     - 关联的 Issue
     - Breaking Changes 说明
     - 其他参考信息

5. **显示建议**
   - 展示生成的 commit message
   - 展示更改的文件列表
   - 展示代码差异摘要

6. **执行确认**
   - 询问用户是否使用生成的 commit message
   - 如果确认，执行：
     - `git add` （如果需要）
     - `git commit -m "message"`
   - 如果需要修改，允许用户编辑

## Commit Message 模板

### 简单更改

```text
feat(controls): add skip forward button

Add a button to skip forward 10 seconds in playback.
```

### 中等更改

```text
feat(remote): update now playing info after seek

Fix the progress bar in Control Center not updating after
seek operations. Update MPNowPlayingInfoCenter immediately
when playback position changes.

- Call updateNowPlayingInfo in seek method
- Separate thumbnail loading from time update
- Ensure control center syncs with actual playback position
```

### 复杂更改

```text
refactor(state): add willPlay state for better control

Introduce a new playback state to indicate media is ready
but hasn't started playing yet. This allows better UI state
management and user feedback.

- Add .willPlay case to PlaybackState enum
- Update state transitions in setupObservers
- Add localization strings for new state
- Update all state handling code
- Maintain backward compatibility
```

### Bug 修复

```text
fix(thumbnail): reload thumbnail when asset download completes

Fix thumbnails not updating when remote assets finish
downloading. Monitor url.isDownloaded changes and trigger
thumbnail reload automatically.

- Add downloadState tracking variable
- Implement .onChange listener for isDownloaded
- Use Tuple2 for task id to support state changes
- Add verbose logging for download events
```

## 示例输出

```text
📝 建议的 Commit Message:

feat(controls): add skip backward functionality

Implement skip backward to jump back 10 seconds in playback.
Uses the existing seek infrastructure for consistent behavior.

- Add skipBackward method in MagicPlayMan+Controls
- Integrate with remote command center
- Add SkipBackwardButton view component
- Update localization strings

Modified files:
  + Sources/MagicPlayMan/MagicPlayMan+Controls.swift (modified)
  + Sources/MagicPlayMan/View/SkipBackwardButton.swift (new)
  + Sources/MagicPlayMan/Models/Localization.swift (modified)

是否使用此 commit message？(y/n/edit)
```

## 注意事项

- ✅ 使用中文或英文的 commit message（根据项目约定）
- ✅ 始终分析实际的代码差异
- ✅ 遵循项目的现有 commit 风格
- ✅ 使用清晰、描述性的语言
- ✅ 保持 subject 简洁（< 50 字符）
- ✅ 在 body 中解释 "为什么" 而非 "是什么"
- ❌ 不要在没有用户确认的情况下执行 commit
- ❌ 不要忽略 staging area 的状态
- ❌ 不要生成过于通用的 commit message

## MagicPlayMan 项目约定

### Commit Message 风格

MagicPlayMan 使用简洁的 Conventional Commits 格式：

```text
feat(controls): add skip forward functionality

fix(remote): resolve control center progress not updating

refactor(state): improve playback state transitions

perf(cache): optimize asset cache key generation

docs(guide): update development guidelines

chore(deps): update MagicKit dependency
```

### 常用 Scope

- `player` - 播放器核心功能
- `controls` - 播放控制（播放、暂停、seek等）
- `playlist` - 播放列表管理
- `remote` - 远程控制和锁屏界面
- `cache` - 资源缓存系统
- `state` - 播放状态管理
- `ui` - UI 组件和视图
- `localization` - 多语言支持
- `models` - 数据模型
- `thumbnail` - 缩略图处理

## 相关命令

- 使用 `/plan` 在实现复杂功能前进行规划
- 使用 `/code-review` 在 commit 前审查代码
