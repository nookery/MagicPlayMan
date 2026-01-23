import Foundation
import SwiftUI

/// 本地化字符串管理
public struct Localization {
    private let locale: Locale

    public init(locale: Locale) {
        self.locale = locale
    }

    // MARK: - Common
    public var retry: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "重试"
        default: return "Retry"
        }
    }

    public var loading: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "加载中"
        default: return "Loading"
        }
    }

    public var error: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "错误"
        default: return "Error"
        }
    }

    // MARK: - Audio Content
    public var noArtworkAvailable: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "无专辑封面"
        default: return "No artwork available"
        }
    }

    public var failedToLoadArtwork: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "加载封面失败"
        default: return "Failed to load artwork"
        }
    }

    // MARK: - Format Info
    public var supportedFormats: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "支持的格式"
        default: return "Supported Formats"
        }
    }

    // MARK: - Error / Loading
    public var failedToLoadMedia: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "加载媒体失败"
        default: return "Failed to Load Media"
        }
    }

    // MARK: - Playlist
    public var noItemsInPlaylist: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "播放列表为空"
        default: return "No Items in Playlist"
        }
    }

    public var addSomeMediaFiles: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "添加一些媒体文件开始使用"
        default: return "Add some media files to get started"
        }
    }

    // MARK: - Thumbnail
    public var noArtwork: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "无封面"
        default: return "No Artwork"
        }
    }

    // MARK: - Subscribers
    public var eventSubscribers: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "事件订阅者"
        default: return "Event Subscribers"
        }
    }

    public var noSubscribersRegistered: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "当前没有订阅者"
        default: return "No subscribers are currently registered."
        }
    }

    public var noSubscribers: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "无订阅者"
        default: return "No Subscribers"
        }
    }

    public var since: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "始于"
        default: return "Since"
        }
    }

    // MARK: - Play Mode
    public var lightMode: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "浅色模式"
        default: return "Light Mode"
        }
    }

    public var darkMode: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "深色模式"
        default: return "Dark Mode"
        }
    }

    // MARK: - Buttons
    public var differentSizes: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "不同尺寸"
        default: return "Different Sizes"
        }
    }

    // MARK: - Playback State
    public var nowPlaying: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "正在播放"
        default: return "Now Playing"
        }
    }

    // MARK: - Loading States
    public var buffering: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "缓冲中..."
        default: return "Buffering..."
        }
    }

    public var preparing: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "准备中..."
        default: return "Preparing..."
        }
    }

    public var connecting: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "连接中..."
        default: return "Connecting..."
        }
    }

    public var downloading: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "正在下载"
        default: return "Downloading"
        }
    }

    // MARK: - Error Messages
    public var tryAgain: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "重试"
        default: return "Try Again"
        }
    }

    public var noMediaSelected: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "未选择媒体"
        default: return "No media selected"
        }
    }

    public var selectMediaToPlay: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "选择一个媒体文件开始播放"
        default: return "Select a media file to play"
        }
    }

    public var invalidOrCorrupted: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "媒体文件无效或已损坏"
        default: return "The media file is invalid or corrupted"
        }
    }

    public var networkError: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "网络错误"
        default: return "Network error"
        }
    }

    public var playbackError: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "播放错误"
        default: return "Playback error"
        }
    }

    public var unsupportedFormat: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "不支持的格式"
        default: return "Unsupported format"
        }
    }

    // MARK: - Playback State Text
    public var ready: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "就绪"
        default: return "Ready"
        }
    }

    public var playing: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "播放中"
        default: return "Playing"
        }
    }

    public var paused: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "已暂停"
        default: return "Paused"
        }
    }

    public var stopped: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "已停止"
        default: return "Stopped"
        }
    }

    public var failed: String {
        switch locale.language.languageCode?.identifier {
        case "zh": return "失败"
        default: return "Failed"
        }
    }
}

// MARK: - SwiftUI Environment Key

struct LocalizationKey: EnvironmentKey {
    static let defaultValue = Localization(locale: Locale(identifier: "zh_CN"))
}

public extension EnvironmentValues {
    var localization: Localization {
        get { self[LocalizationKey.self] }
        set { self[LocalizationKey.self] = newValue }
    }
}

public extension View {
    /// 设置本地化配置
    /// - Parameter localization: 本地化配置对象
    /// - Returns: 应用本地化配置的视图
    func localization(_ localization: Localization) -> some View {
        environment(\.localization, localization)
    }
}
