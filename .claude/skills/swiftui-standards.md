---
name: swiftui-standards
description: Swift Package 开发标准规范，包括代码组织、MARK 分组、日志记录、预览代码和异步操作的统一规范。
---

# Swift Package 开发标准规范

本技能确保所有 MagicPlayMan Swift Package 代码遵循项目的统一开发规范。

## 何时使用

- 编写新的 SwiftUI 视图或组件
- 重构现有 Swift 代码
- 添加播放器扩展或工具类
- 实现异步操作
- 组织代码结构

## 核心规范

### 1. 代码组织原则

**文件组织：**
- 使用扩展分离功能：`MagicPlayMan+<功能名>.swift`
- 相关功能组织在同一扩展文件中
- 视图组件放在 `View/` 目录
- 数据模型放在 `Models/` 目录

**目录结构示例：**
```
Sources/MagicPlayMan/
├── MagicPlayMan.swift              # 核心类
├── MagicPlayMan+Controls.swift      # 播放控制扩展
├── MagicPlayMan+Remote.swift        # 远程控制扩展
├── MagicPlayMan+PlaylistView.swift  # 播放列表视图
├── Models/                          # 数据模型
│   ├── PlaybackState.swift
│   ├── Localization.swift
│   └── MagicAsset.swift
└── View/                            # 视图组件
    ├── PlayPauseButtonView.swift
    ├── MagicProgressView.swift
    └── ThumbnailView.swift
```

### 2. MARK 分组规范

所有 Swift 文件必须按以下顺序使用 MARK 分组：

```swift
// MARK: - Properties           - 属性声明
// MARK: - Computed Properties  - 计算属性
// MARK: - Initialization       - 初始化方法
// MARK: - Body                - SwiftUI View 主体
// MARK: - Actions             - 用户交互触发的行为
// MARK: - Setters             - 状态/属性的集中更新方法
// MARK: - Event Handler       - 事件处理函数
// MARK: - Preview             - 多尺寸预览（仅 View 文件）
```

**示例模板（View）：**
```swift
import SwiftUI

struct PlayPauseButtonView: View {
    // MARK: - Properties

    @ObservedObject var man: MagicPlayMan
    let size: MagicButton.Size

    // MARK: - Computed Properties

    private var disabledReason: String? {
        if !man.hasAsset {
            return "No media loaded"
        }
        return nil
    }

    // MARK: - Initialization

    init(man: MagicPlayMan, size: MagicButton.Size = .regular) {
        self.man = man
        self.size = size
    }

    // MARK: - Body

    var body: some View {
        MagicButton.simple(
            icon: man.state == .playing ? .iconPauseFill : .iconPlayFill,
            style: .primary,
            size: size,
            shape: .circle,
            disabledReason: disabledReason,
            action: {
                man.toggle(reason: self.className)
            }
        )
    }
}
```

### 3. SuperLog 日志协议

**所有需要日志的类型必须实现 SuperLog 协议：**

```swift
struct MyView: View, SuperLog {
    nonisolated static let emoji = "🌿"
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

**日志级别：**
```swift
// 总是输出（重要操作）
os_log("\(self.t)Operation completed")

// 仅开发时输出（调试信息）
if Self.verbose {
    os_log("\(self.t)Detailed debug information")
}
```

### 4. 异步操作规范

**使用 async/await 处理异步操作：**

```swift
// 在后台线程执行耗时操作
private func processData() async {
    await Task.detached(priority: .utility) {
        // CPU 密集型工作
    }.value
}

// MainActor 更新 UI
@MainActor
func updateUI(_ result: String) {
    self.statusText = result
}
```

**在 SwiftUI View 中：**
```swift
var body: some View {
    VStack {
        if isLoading {
            ProgressView()
        }
    }
    .task {
        await loadData()
    }
}
```

### 5. 错误处理规范

**定义项目特定的错误类型：**

```swift
enum ViewError: Error {
    case fileNotFound
    case invalidURL
    case thumbnailGenerationFailed(Error)
    case downloadFailed(Error?)
}
```

**使用 do-catch 处理错误：**
```swift
do {
    let result = try await operation()
    await setState(result)
} catch URLError.cancelled {
    // 任务被取消，忽略
} catch {
    await setError(ViewError.operationFailed(error))
}
```

### 6. 预览代码规范

**每个 View 文件底部必须添加预览：**

```swift
#if DEBUG
#Preview("Default") {
    MyComponent()
}

#Preview("With Content") {
    MyComponent(content: "Example")
        .frame(width: 300, height: 200)
}

#Preview("Dark Mode") {
    MyComponent()
        .preferredColorScheme(.dark)
}
#endif
```

**非 View 组件使用静态工厂方法：**
```swift
extension Configuration {
    static var default: Configuration {
        Configuration()
    }

    static var sample: Configuration {
        Configuration(items: ["Item 1", "Item 2"])
    }
}
```

## Emoji 选择指南

### 播放控制
- `🎧` - MagicPlayMan 核心类
- `▶️` - 播放相关
- `⏸️` - 暂停相关
- `⏩` - 快进/seek
- `⏪` - 快退
- `⏹️` - 停止

### UI 相关
- `🌿` - View 组件
- `🖼️` - 缩略图/封面
- `📋` - 播放列表
- `📊` - 进度条

### 数据相关
- `💾` - 缓存存储
- `🔄` - 状态同步
- `⬇️` - 下载

### 系统相关
- `⚙️` - 系统配置
- `🔔` - 通知
- `📻` - 远程控制
- `🌍` - 本地化

## 播放器开发特定

### 状态管理

使用 `@Published` 发布状态变化：

```swift
public class MagicPlayMan: ObservableObject {
    @Published public private(set) var state: PlaybackState = .idle
    @Published public private(set) var currentTime: TimeInterval = 0
    @Published public private(set) var progress: Double = 0
}
```

状态更新通过专门的 Setters：

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

### 异步加载

```swift
func loadFromURL(_ url: URL, autoPlay: Bool = true, reason: String) async {
    await setState(.loading(.preparing), reason: reason)

    guard url.isFileExist else {
        await setState(.failed(.invalidAsset), reason: reason)
        return
    }

    await downloadAndCache(url, reason: reason)
    // ...
}
```

## 内存管理最佳实践

**避免循环引用：**
```swift
// ❌ 错误：强引用导致循环引用
class MyClass {
    var closure: (() -> Void)?

    func setup() {
        closure = {
            self.doSomething()
        }
    }
}

// ✅ 正确：使用捕获列表
class MyClass {
    var closure: (() -> Void)?

    func setup() {
        closure = { [weak self] in
            self?.doSomething()
        }
    }
}
```

**取消 Combine 订阅：**
```swift
private var cancellables = Set<AnyCancellable>()

func setupSubscriptions() {
    publisher
        .sink { [weak self] value in
            self?.update(value)
        }
        .store(in: &cancellables)
}

func cleanup() {
    cancellables.removeAll()
}
```

**在 View 中使用 onDisappear：**
```swift
var body: some View {
    content
        .onDisappear {
            cleanup()
        }
}
```

## Swift Package 特定注意事项

### 访问控制

- ✅ 公共 API 使用 `public`
- ✅ 内部实现使用 `internal` 或 `private`
- ✅ 使用 `fileprivate` 仅在同一文件内共享

```swift
public struct MyComponent {
    // 公共属性
    public let configuration: Configuration

    // 内部属性
    private var state: InternalState

    // 公共方法
    public func update() async {
        // 实现细节
    }
}
```

### 条件编译

```swift
#if DEBUG
// 调试代码
let verbose = true
#endif

#if os(macOS)
// macOS 特定代码
#endif

#if os(iOS)
// iOS 特定代码
#endif
```

### 没有应用级功能

Swift Package 没有：
- ❌ AppDelegate
- ❌ SceneDelegate
- ❌ Info.plist
- ❌ 应用生命周期

## 最佳实践

### 代码组织
- ✅ 使用扩展分离不同功能模块
- ✅ 保持 MARK 分组顺序统一
- ✅ 语义化命名：`playXxx`、`pauseXxx`、`setXxx`
- ✅ 状态更新集中在 Setters 分组

### 异步操作
- ✅ 使用 `async/await` 而非闭包回调
- ✅ 使用 `Task { @MainActor in ... }` 更新 UI
- ✅ 使用 `@MainActor` 标记 UI 更新方法
- ✅ 检查 `Task.isCancelled` 避免不必要工作

### 日志记录
- ✅ 通过 emoji 快速过滤日志：`log stream | grep "🎧"`
- ✅ 使用 `verbose` 控制调试级别
- ✅ 避免记录敏感信息
- ✅ 使用 `nonisolated static` 优化性能

### 预览代码
- ✅ 提供多种场景预览
- ✅ 使用静态工厂方法创建测试数据
- ✅ 设置合适的 frame 尺寸
- ✅ 使用 `#if DEBUG` 条件编译

## 注意事项

1. **线程安全**：UI 更新操作使用 `@MainActor` 或 `Task { @MainActor in ... }`
2. **内存管理**：避免循环引用，及时释放资源
3. **错误处理**：定义清晰的错误类型，妥善处理失败
4. **性能优化**：使用缓存，限制更新频率，取消不需要的任务
5. **日志过滤**：利用 emoji 快速定位问题类型
6. **状态管理**：通过 @Published 和 Combine 实现响应式更新
7. **远程控制**：正确处理系统媒体控制和锁屏界面

遵循此规范可以显著提升代码的可读性、可维护性和开发体验。
