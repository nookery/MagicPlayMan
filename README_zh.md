# MagicPlayMan

[![中文](https://img.shields.io/badge/中文-README-blue)](README.md)

一个基于SwiftUI的音频播放功能库。

## 功能特性

- **音频播放**: 支持多种音频格式的播放
- **播放列表管理**: 创建和管理播放列表
- **媒体资源缓存**: 智能缓存媒体文件，提高播放性能
- **播放控制**: 完整的播放控制功能（播放、暂停、快进、快退等）
- **播放模式**: 支持顺序播放、随机播放、单曲循环等模式
- **Now Playing信息**: 集成系统媒体控制中心
- **缩略图生成**: 自动生成媒体文件的缩略图
- **格式支持**: 支持多种音频格式

## 安装

### Swift Package Manager

将MagicPlayMan作为依赖项添加到您的`Package.swift`中：

```swift
dependencies: [
    .package(url: "https://github.com/nookery/MagicPlayMan.git", branch: "main")
]
```

或者直接在Xcode中添加：

1. 转到文件 → 添加包...
2. 输入仓库URL：`https://github.com/nookery/MagicPlayMan.git`
3. 选择您要使用的版本

然后在目标依赖项中添加：

```swift
.product(name: "MagicPlayMan", package: "MagicPlayMan")
```

## 使用方法

### 基本播放器使用

```swift
import SwiftUI
import MagicPlayMan

struct ContentView: View {
    @StateObject private var player = MagicPlayMan()

    var body: some View {
        VStack {
            // 播放控制按钮
            HStack {
                PlayPauseButton()
                PreviousButton()
                NextButton()
            }

            // 进度条
            ProgressView(value: player.progress)

            // 播放列表
            PlaylistView()
        }
        .environmentObject(player)
    }
}
```

### 播放媒体文件

```swift
import MagicPlayMan

let player = MagicPlayMan()

// 播放本地文件
let url = URL(fileURLWithPath: "/path/to/audio.mp3")
try await player.load(url: url)

// 播放远程媒体
let remoteURL = URL(string: "https://example.com/audio.mp3")!
try await player.load(url: remoteURL)
```

### 播放列表管理

```swift
import MagicPlayMan

let player = MagicPlayMan()

// 添加媒体到播放列表
let asset1 = MagicAsset(url: URL(string: "audio1.mp3")!)
let asset2 = MagicAsset(url: URL(string: "audio2.mp3")!)

player.playlist.add(asset1)
player.playlist.add(asset2)

// 开始播放
try await player.play()
```

## 组件

### 核心组件

- `MagicPlayMan` - 主要的播放器类，管理播放状态和控制
- `MagicAsset` - 媒体资源类，包含媒体文件信息和元数据
- `Playlist` - 播放列表类，管理播放队列
- `PlaybackState` - 播放状态枚举
- `PlayMode` - 播放模式枚举（顺序、随机、单曲循环等）

### UI组件

- `PlayPauseButton` - 播放/暂停按钮
- `PreviousButton` - 上一首按钮
- `NextButton` - 下一首按钮
- `ProgressView` - 播放进度条
- `PlaylistView` - 播放列表视图
- `ThumbnailView` - 媒体缩略图视图
- `VolumeControl` - 音量控制

### 缓存和存储

- `AssetCache` - 媒体资源缓存管理器
- `ThumbnailCache` - 缩略图缓存管理器

## 播放模式

MagicPlayMan支持多种播放模式：

- `.sequential` - 顺序播放
- `.shuffle` - 随机播放
- `.repeatOne` - 单曲循环
- `.repeatAll` - 列表循环

```swift
// 设置播放模式
player.playMode = .shuffle

// 切换播放模式
player.togglePlayMode()
```

## 高级功能

### Now Playing集成

MagicPlayMan自动集成到系统的Now Playing信息中心：

```swift
// 更新Now Playing信息
player.updateNowPlayingInfo()
```

### 媒体缓存

```swift
// 预加载媒体文件
try await player.preload(asset: asset)

// 检查缓存状态
let isCached = AssetCache.shared.isCached(asset.url)
```

### 自定义UI

所有UI组件都可以通过SwiftUI的ViewModifier进行自定义：

```swift
PlayPauseButton()
    .buttonStyle(CustomPlayButtonStyle())
    .foregroundColor(.blue)
```

## 要求

- iOS 17.0+
- macOS 14.0+
- Swift 5.9+

## 许可证

本项目采用MIT许可证 - 详见LICENSE文件。
