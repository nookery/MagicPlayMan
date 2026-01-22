import AVFoundation
import Combine
import Foundation
import MagicKit
import MediaPlayer
import OSLog
import SwiftUI

public extension MagicPlayMan {
    /// 初始化播放器
    /// - Parameters:
    ///   - cacheDirectory: 自定义缓存目录。如果为 nil，则使用系统默认缓存目录
    ///   - playlistEnabled: 是否启用播放列表，默认为 true
    ///   - verbose: 是否启用详细日志模式，默认为 false
    ///   - locale: 本地化设置，默认为中文
    convenience init(
        cacheDirectory: URL? = nil,
        playlistEnabled: Bool = true,
        verbose: Bool = false,
        locale: Locale = Locale(identifier: "zh_CN")
    ) {
        self.init()

        // 设置本地化
        self.localization = Localization(locale: locale)

        if verbose {
            os_log("\(self.t)Localization: \(locale.identifier)")
        }

        // 设置详细日志模式
        self.verbose = verbose
        if verbose {
            os_log("\(self.t)Verbose mode enabled")
        }

        // 初始化缓存，如果失败则禁用缓存功能
        do {
            self.cache = try AssetCache(directory: cacheDirectory)
            if let cacheDir = self.cache?.directory {
                if verbose {
                    os_log("\(self.t)Cache directory: \(cacheDir.path)")
                }
            }
        } catch {
            self.cache = nil
            if verbose {
                os_log("\(self.t)Cache disabled")
            }
        }

        // 完成初始化后再设置其他内容
        setupPlayer()
        setupObservers()
        setupRemoteControl()

        // 设置播放列表状态
        Task {
            await self.setPlaylistEnabled(playlistEnabled)
        }

        // 修改监听方式
        _playlist.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self = self else { return }
                Task { @MainActor in
                    self.setItems(items)
                }
            }
            .store(in: &cancellables)

        _playlist.$currentIndex
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                guard let self = self else { return }
                Task { @MainActor in
                    self.setCurrentIndex(index)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Internal Setup Methods

internal extension MagicPlayMan {
    /// 设置播放器
    func setupPlayer() {
        timeObserver = _player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self = self else { return }
            // 🔧 移除多余的Task包装，避免线程竞态
            // 时间观察器已经在.main队列上运行，不需要额外的@MainActor包装
            let currentTime = time.seconds
            let progress = self.duration > 0 ? currentTime / self.duration : 0

            // 更新内部状态并发送通知
            self.setCurrentTime(currentTime)
            self.setProgress(progress)
        }
    }

    /// 设置观察者
    func setupObservers() {
        // 监听播放状态
        _player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                Task { @MainActor in
                    switch status {
                    case .playing:
                        if case .loading = self.state {
                            self.setState(.playing)
                        }
                    case .paused:
                        if case .playing = self.state {
                            self.setState(self.currentTime == 0 ? .stopped : .paused)
                        }
                    case .waitingToPlayAtSpecifiedRate:
                        if case .playing = self.state {
                            self.setState(.loading(.buffering))
                        }
                    @unknown default:
                        break
                    }
                }
            }
            .store(in: &cancellables)

        // 监听缓冲状态
        _player.publisher(for: \.currentItem?.isPlaybackBufferEmpty)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                guard let self = self else { return }
                if let isEmpty = isEmpty {
                    Task { @MainActor in
                        if isEmpty, case .playing = self.state {
                            self.setState(.loading(.buffering))
                        } else if !isEmpty, case .loading(.buffering) = self.state {
                            self.setState(.playing)
                        }
                    }
                }
            }
            .store(in: &cancellables)

        // 监听播放完成
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }

                if let currentAsset = self.currentURL {
                    if verbose {
                        os_log("\(self.t)播放完成：\(currentAsset.title)")
                    }

                    // 如果是单曲循环模式，重新播放当前曲目
                    if self.playMode == .loop {
                        if verbose {
                            os_log("\(self.t)单曲循环模式，重新播放：\(currentAsset.title)")
                        }
                        Task { @MainActor in
                            self.seek(time: 0)
                            self.setState(.playing)
                        }
                        return
                    }

                    if !self.isPlaylistEnabled {
                        // 如果播放列表被禁用，通知调用者播放完成
                        if verbose {
                            os_log("\(self.t)播放列表已禁用，等待订阅者处理下一首")
                        }
                        Task { @MainActor in
                            self.setState(.stopped)
                        }
                        self.events.onNextRequested.send(currentAsset)
                    } else if let nextAsset = self._playlist.playNext(mode: self.playMode) {
                        // 如果播放列表启用，播放下一首
                        if verbose {
                            os_log("\(self.t)播放列表已启用，即将播放下一首：\(nextAsset.title)")
                        }
                        Task {
                            await self.loadFromURL(nextAsset)
                        }
                    } else {
                        if verbose {
                            os_log("\(self.t)播放列表已到末尾")
                        }
                        Task { @MainActor in
                            self.setState(.stopped)
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
}

#Preview("MagicPlayMan") {
    MagicPlayMan.PreviewView()
}
