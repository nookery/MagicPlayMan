# MagicPlayMan 开发指南

本文档整合了 MagicPlayMan Swift Package 的所有开发规范和最佳实践。

## 项目概述

MagicPlayMan 是一个 Swift Package Library，提供完整的媒体播放管理功能。

### 核心功能模块

- **播放控制** - 播放、暂停、停止、seek 等基础播放控制
- **播放列表管理** - 支持顺序、循环、随机等播放模式
- **资源缓存** - 自动缓存媒体资源，支持断点续传
- **远程控制** - 系统媒体控制中心和锁屏界面集成
- **状态管理** - 基于 Combine 的响应式状态系统
- **UI 组件** - 可重用的 SwiftUI 播放控制组件

### 技术栈

- **Swift** - 5.9+
- **SwiftUI** - UI 框架
- **Combine** - 响应式编程
- **Async/Await** - 异步操作
- **AVFoundation** - 媒体播放
- **MediaPlayer** - 远程控制
- **OSLog** - 日志记录

### 平台支持

- macOS 14.0+
- iOS 17.0+

## 开发原则

### 第一步：理解项目架构

在开发任何功能前：

1. 查看项目根目录的 README.md
2. 理解模块化目录结构：
   - `Sources/MagicPlayMan/` - 源代码
   - `Sources/MagicPlayMan/MagicPlayMan.swift` - 核心类
   - `Sources/MagicPlayMan/MagicPlayMan+*.swift` - 按功能分类的扩展
   - `Sources/MagicPlayMan/Models/` - 数据模型（PlaybackState, Localization 等）
   - `Sources/MagicPlayMan/View/` - SwiftUI 视图组件
3. 理解基于 Combine 的状态管理
4. 查看现有代码的组织模式

### 第二步：代码编写规范

**文件组织：**
- 核心类在 `MagicPlayMan.swift` 中
- 使用扩展分离功能：`MagicPlayMan+Controls.swift`、`MagicPlayMan+Remote.swift` 等
- 相关扩展使用统一的命名前缀：`MagicPlayMan+<功能名>.swift`
- 视图组件放在 `View/` 目录
- 数据模型放在 `Models/` 目录

**代码质量：**
- 添加详细的中文代码注释
- 使用 `public` 标记公共 API
- 使用 `internal` 隐藏内部实现
- 实现 SuperLog 协议进行日志记录
- 添加适当的错误处理
- 使用 `@MainActor` 确保 UI 更新在主线程

**命名规范：**
- 使用清晰、描述性的名称
- 扩展命名：`MagicPlayMan+<功能>.swift`
- 方法名使用动词开头（`play`、`pause`、`seek`）
- 布尔值使用 `is`、`has` 前缀（`isLoading`、`hasAsset`）

### 第三步：遵循规范

必须遵循以下规范（详见 swiftui-standards skill）：

1. **代码组织** - 扩展分离、相关目录、MARK 分组
2. **MARK 分组顺序** - Properties → Computed Properties → Initialization → Actions → Setters → Event Handlers → Preview
3. **SuperLog 协议** - emoji + verbose + self.t
4. **状态管理** - 基于 @Published 和 Combine
5. **异步操作** - 使用 async/await
6. **预览代码** - 多场景预览

## 核心模式

### 1. SuperLog 日志协议

所有需要日志的类型必须实现 SuperLog 协议：

```swift
struct MyView: View, SuperLog {
    nonisolated static let emoji = "🎧"
    nonisolated static let verbose = false

    func someFunction() {
        if Self.verbose {
            os_log("\(self.t)Detailed debug information")
        }
        os_log("\(self.t)Important operation completed")
    }
}
```

**协议要求：**
- `nonisolated static let emoji` - 独特的 emoji 标识
- `nonisolated static let verbose` - 详细日志控制开关
- 使用 `self.t` 作为日志前缀（自动包含 emoji 和类型名）

### 2. 状态管理模式

使用 `@Published` 属性发布状态变化：

```swift
public class MagicPlayMan: ObservableObject {
    @Published public private(set) var state: PlaybackState = .idle
    @Published public private(set) var currentTime: TimeInterval = 0
    @Published public private(set) var progress: Double = 0
}
```

状态更新通过专门的 Setters 方法：

```swift
@MainActor
func setState(_ newValue: PlaybackState, reason: String) {
    let oldValue = state
    state = newValue

    if oldValue != newValue {
        sendStateChanged(state: newValue)
    }
}
```

### 3. MARK 分组规范

```swift
// MARK: - Properties
// MARK: - Computed Properties
// MARK: - Initialization
// MARK: - Actions
// MARK: - Setters
// MARK: - Event Handlers
// MARK: - Preview
```

### 4. 异步操作模式

```swift
// 使用 async/await
func loadFromURL(_ url: URL, autoPlay: Bool = true, reason: String) async {
    await setState(.loading(.preparing), reason: reason)

    guard url.isFileExist else {
        await setState(.failed(.invalidAsset), reason: reason)
        return
    }

    await downloadAndCache(url, reason: reason)

    let item = AVPlayerItem(url: url)
    _player.replaceCurrentItem(with: item)
}
```

### 5. 错误处理模式

使用 PlaybackError 枚举：

```swift
public enum PlaybackError: LocalizedError, Equatable {
    case noAsset
    case invalidAsset
    case networkError(String)
    case playbackError(String)
    case unsupportedFormat(String)
    case invalidURL(String)
}
```

## 开发工作流

1. **规划阶段** - 使用 `/plan` 命令规划复杂功能
2. **开发阶段** - 遵循本指南的规范
3. **构建验证** - 运行 `swift build` 验证代码
4. **检查阶段** - 使用代码审查和规范检查
5. **提交阶段** - 使用 `/commit` 命令生成 commit message

## 关键注意事项

### Swift Package 特定

- ✅ 没有 AppDelegate 或 SceneDelegate
- ✅ 使用 `#if DEBUG` 条件编译预览代码
- ✅ 公共 API 必须标记为 `public`
- ✅ 内部实现使用 `internal` 或 `private`
- ✅ 注意 `@MainActor` 和线程安全

### 播放器开发

- ✅ 使用 `@Published` 发布状态变化
- ✅ 在主线程更新 UI 相关状态
- ✅ 使用 Combine 的 `sink` 处理事件流
- ✅ 在 `onDisappear` 或 `deinit` 中清理资源
- ✅ 使用 `[weak self]` 避免循环引用

### 远程控制集成

- ✅ 设置 MPRemoteCommandCenter
- ✅ 更新 MPNowPlayingInfoCenter
- ✅ 处理系统媒体键事件
- ✅ 支持 macOS 和 iOS 平台差异

### 性能优化

- ✅ 使用 AssetCache 缓存媒体资源
- ✅ 延迟加载缩略图和元数据
- ✅ 使用 `.throttle` 限制更新频率
- ✅ 取消不需要的 Task
- ✅ 避免在 View 中创建新对象

### 内存管理

- ✅ 在 `deinit` 或清理方法中取消 Combine 订阅
- ✅ 使用 `[weak self]` 避免循环引用
- ✅ 及时释放不需要的资源
- ✅ 注意 `@Published` 属性的内存占用

## 依赖管理

MagicPlayMan 使用的依赖：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/nookery/MagicKit.git", from: "1.0.0"),
    .package(url: "https://github.com/nookery/MagicUI.git", from: "1.0.0"),
]
```

## 常见命令

```bash
# 构建验证
swift build

# 运行测试
swift test

# 清理构建
swift package clean

# 在 Xcode 中打开
open Package.swift
```

## Emoji 选择指南

### 播放控制
- `🎧` - MagicPlayMan 核心类
- `▶️` - 播放相关
- `⏸️` - 暂停相关
- `⏩` - 快进/seek
- `⏪` - 快退

### UI 相关
- `🌿` - View 组件
- `🖼️` - 缩略图/封面
- `📋` - 播放列表

### 数据相关
- `💾` - 缓存存储
- `🔄` - 状态同步
- `⬇️` - 下载

### 系统相关
- `⚙️` - 系统配置
- `🔔` - 通知
- `📻` - 远程控制

## 参考资料

- [Swift Package Manager](https://www.swift.org/package-manager/)
- [AVFoundation](https://developer.apple.com/documentation/avfoundation/)
- [MediaPlayer](https://developer.apple.com/documentation/mediaplayer/)
- [SwiftUI](https://developer.apple.com/documentation/swiftui/)
- [Combine](https://developer.apple.com/documentation/combine/)
