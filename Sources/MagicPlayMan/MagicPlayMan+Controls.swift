import AVFoundation
import Foundation
import MagicKit
import OSLog
import SwiftUI

public extension MagicPlayMan {
    /// 添加资源到播放列表
    /// - Parameter asset: 要添加到播放列表的媒体资源URL
    func append(_ asset: URL) {
        guard isPlaylistEnabled else {
            if verbose { os_log("\(self.t)Cannot append: playlist is disabled") }
            return
        }
        playlist.append(asset)
    }

    /// 设置播放模式
    /// - Parameter mode: 要设置的播放模式
    func changePlayMode(_ mode: MagicPlayMode) {
        Task {
            await setPlayMode(mode)
        }
        os_log("\(self.t)Playback mode set to: \(mode.displayName)")
    }

    /// 清理所有缓存
    /// 清除媒体资源缓存，释放磁盘空间
    func clearCache() {
        do {
            try cache?.clear()
            os_log("\(self.t)🗑️ Cache cleared")
        } catch {
            if verbose { os_log("\(self.t)❌ Failed to clear cache: \(error.localizedDescription)") }
        }
    }

    /// 清空播放列表
    /// 移除播放列表中的所有媒体资源
    func clearPlaylist() {
        guard isPlaylistEnabled else {
            if verbose { os_log("\(self.t)Cannot clear: playlist is disabled") }
            return
        }
        playlist.clear()
    }

    /// 禁用播放列表功能
    /// 禁用播放列表后，保留当前播放的资源（如果有），清除其他资源
    func disablePlaylist() async {
        guard isPlaylistEnabled else { return }

        await setPlaylistEnabled(false)
        os_log("\(self.t)Playlist disabled")

        // 如果禁用播放列表，保留当前播放的资源
        if let currentAsset = currentURL {
            await setItems([currentAsset])
            await setCurrentIndex(0)
        } else {
            await setItems([])
            await setCurrentIndex(-1)
        }
    }

    /// 启用播放列表功能
    /// 启用后可以添加多个媒体资源并进行列表播放
    func enablePlaylist() async {
        guard !isPlaylistEnabled else { return }

        await setPlaylistEnabled(true)
        os_log("\(self.t)Playlist enabled")
    }

    /// 移动播放列表中的资源
    /// - Parameters:
    ///   - from: 源位置索引
    ///   - to: 目标位置索引
    func moveInPlaylist(from: Int, to: Int) {
        guard isPlaylistEnabled else {
            if verbose { os_log("\(self.t)Cannot move: playlist is disabled") }
            return
        }
        playlist.move(from: from, to: to)
    }

    /// 播放下一首
    /// 根据播放列表状态和导航订阅者决定播放行为
    func next() {
        if self.verbose {
            os_log("\(self.t)➡️ 下一首，当前是否有Asset -> \(self.hasAsset)")
        }
        guard hasAsset else { return }

        if isPlaylistEnabled {
            if self.verbose {
                os_log("\(self.t)➡️ 下一首，播放列表已启用")
            }
            if let nextAsset = _playlist.playNext(mode: playMode) {
                if self.verbose {
                    os_log("\(self.t)➡️ 下一首，播放列表已启用且下一个是：\(nextAsset.title)")
                }
                Task {
                    await loadFromURL(nextAsset, reason: self.className + ".next")
                }
            } else {
                if self.verbose {
                    os_log("\(self.t)➡️ 下一首，播放列表已启用但没有 NextAsset")
                }
            }
        } else if events.hasNavigationSubscribers {
            if self.verbose {
                os_log("\(self.t)➡️ 下一首，播放列表已禁用且有 NavigationSubscribers")
            }

            // 如果播放列表被禁用但有订阅者，发送请求下一首事件
            if let currentAsset = currentAsset {
                if self.verbose {
                    os_log("\(self.t)➡️ 请求下一首")
                }
                events.onNextRequested.send(currentAsset)
            }
        } else {
            if self.verbose {
                os_log("\(self.t)➡️ 下一首，播放列表已禁用且无 NavigationSubscribers")
            }
        }
    }

    /// 暂停播放
    /// - Parameters:
    ///   - reason: 更新原因
    func pause(reason: String) {
        guard hasAsset else { return }

        if self.verbose {
            os_log("\(self.t)⏸️ (\(reason)) Pause")
        }

        _player.pause()
    }

    /// 开始播放当前加载的媒体资源，如果已播放完毕则从头开始播放
    /// - Parameters:
    ///   - reason: 更新原因
    func play(reason: String) {
        guard hasAsset else {
            os_log(.error, "\(self.t)Cannot play: no asset loaded")
            return
        }

        if currentTime == duration {
            self.seek(time: 0, reason: self.className + ".play")
        }

        // 让内核开始播放，MagicPlayMan初始化时监听了内核状态
        _player.play()
    }

    /// 加载并播放一个 URL
    /// - Parameters:
    ///   - url: 要播放的媒体 URL
    ///   - autoPlay: 是否自动开始播放，默认为 true
    ///   - reason: 更新原因
    @MainActor
    func play(_ url: URL, autoPlay: Bool = true, reason: String) async {
        if self.verbose {
            os_log("\(self.t)📢 (\(reason)) Play: \(url.title), AutoPlay: \(autoPlay)")
        }
        self.setCurrentURL(url)

        // 检查 URL 是否有效
        guard url.isFileURL || url.isNetworkURL else {
            if verbose { os_log("\(self.t)Invalid URL scheme: \(url.scheme ?? "nil")") }
            await stop(reason: reason + "invalidURL")
            setState(.failed(.playbackError("Invalid URL scheme")), reason: reason + ".play")
            return
        }

        // 判断媒体类型
        if url.isVideo == false && url.isAudio == false {
            if verbose { os_log("\(self.t)Unsupported media type: \(url.pathExtension)") }
            await stop(reason: reason)
            setState(.failed(.unsupportedFormat(url.pathExtension)), reason: reason + ".play")
            return
        }

        // 加载资源
        await loadFromURL(url, autoPlay: autoPlay, reason: reason + ".play")

        if isPlaylistEnabled {
            append(url)
        }
    }

    /// 播放上一首
    /// 根据播放列表状态和导航订阅者决定播放行为
    func previous() {
        guard hasAsset else { return }

        if isPlaylistEnabled {
            if let previousAsset = _playlist.playPrevious(mode: playMode) {
                if self.verbose {
                    os_log("\(self.t)上一首，播放列表已启用且上一个的是：\(previousAsset.title)")
                }
                Task {
                    await loadFromURL(previousAsset, reason: self.className + ".previous")
                }
            }
        } else if events.hasNavigationSubscribers {
            // 如果播放列表被禁用但有订阅者，发送请求上一首事件
            if let currentAsset = currentURL {
                events.onPreviousRequested.send(currentAsset)
            }
        }
    }

    /// 从播放列表中移除指定索引的资源
    /// - Parameter index: 要移除的资源在播放列表中的索引位置
    func removeFromPlaylist(at index: Int) {
        guard isPlaylistEnabled else {
            if verbose { os_log("\(self.t)Cannot remove: playlist is disabled") }
            return
        }
        playlist.remove(at: index)
    }

    /// 跳转到指定时间
    /// - Parameters:
    ///   - time: 目标时间位置（秒）
    ///   - reason: 更新原因
    func seek(time: TimeInterval, reason: String) {
        guard hasAsset else {
            os_log(.error, "\(self.t)⚠️ Cannot seek: no asset loaded")
            return
        }

        let targetTime = CMTime(seconds: time, preferredTimescale: 600)
        if verbose {
            os_log("\(self.t)⏩ (\(reason)) Seeking to \(Int(time))s")
        }
        _player.seek(to: targetTime)

        // 更新 Now Playing Info 中的播放时间，否则控制中心/锁屏界面的进度条不会更新
        updateNowPlayingInfo(includeThumbnail: true, reason: reason + ".seek")
    }

    /// 设置当前资源的喜欢状态
    /// - Parameters:
    ///   - isLiked: 是否喜欢
    ///   - reason: 更新原因
    func setLike(_ isLiked: Bool, reason: String) {
        guard let asset = currentURL else {
            if verbose { os_log("\(self.t)⚠️ Cannot set like: no asset loaded") }
            return
        }

        var newLikedAssets = likedAssets
        if isLiked {
            newLikedAssets.insert(asset)
            if verbose {
                os_log("\(self.t)❤️ (\(reason)) Added to liked: \(asset.title)")
            }
        } else {
            newLikedAssets.remove(asset)
            if verbose {
                os_log("\(self.t)💔 (\(reason)) Removed from liked: \(asset.title)")
            }
        }

        Task {
            await setLikedAssets(newLikedAssets)
        }
        // 通知订阅者喜欢状态变化
        events.onLikeStatusChanged.send((asset: asset, isLiked: isLiked))
        updateNowPlayingInfo(includeThumbnail: false, reason: reason + ".setLike")
    }

    /// 静音控制
    /// - Parameter muted: 是否启用静音模式
    func setMuted(_ muted: Bool) {
        _player.isMuted = muted
        os_log("\(self.t)\(muted ? "🔇 Audio muted" : "🔊 Audio unmuted")")
    }

    /// 设置详细日志模式
    /// - Parameter enabled: 是否启用详细的调试日志输出
    func setVerboseMode(_ enabled: Bool) {
        self.verbose = enabled
        os_log("\(self.t)🔍 Verbose mode \(enabled ? "enabled" : "disabled")")
    }

    /// 调整音量
    /// - Parameter volume: 目标音量值，范围 0.0-1.0
    func setVolume(_ volume: Float) {
        _player.volume = max(0, min(1, volume))
        os_log("\(self.t)🔊 Volume set to \(Int(volume * 100))%")
    }

    /// 快退指定时间
    /// - Parameter seconds: 快退的秒数，默认为10秒
    func skipBackward(_ seconds: TimeInterval = 10) {
        seek(time: max(currentTime - seconds, 0), reason: "skipBackward")
        os_log("\(self.t)⏪ Skipped backward \(Int(seconds))s")
    }

    /// 快进指定时间
    /// - Parameter seconds: 快进的秒数，默认为10秒
    func skipForward(_ seconds: TimeInterval = 10) {
        seek(time: currentTime + seconds, reason: "skipForward")
        os_log("\(self.t)⏩ Skipped forward \(Int(seconds))s")
    }

    /// 停止播放
    /// 停止当前播放并将播放位置重置到开始位置
    @MainActor
    func stop(reason: String) async {
        _player.pause()
        await _player.seek(to: .zero)

        if self.verbose {
            os_log("\(self.t)⏹️ (\(reason)) Stopped playback")
        }
    }

    /// 切换当前资源的喜欢状态
    /// 在喜欢和不喜欢之间切换当前播放资源的喜欢状态
    func toggleLike() {
        guard let asset = currentURL else { return }
        setLike(!likedAssets.contains(asset), reason: "toggleLike")
    }

    /// 切换播放状态
    /// 根据当前播放状态在播放/暂停之间切换，如果当前正在播放则暂停，如果当前已暂停或停止则开始播放
    /// - Parameter reason: 切换操作的原因描述
    func toggle(reason: String) {
        switch state {
        case .playing:
            pause(reason: reason)
        case .paused, .stopped:
            play(reason: reason)
        case .loading, .failed, .idle, .willPlay:
            // 在这些状态下不执行任何操作
            if verbose { os_log("\(self.t)Cannot toggle playback in current state: \(self.state.stateText)") }
            break
        }
    }
}

#Preview("MagicPlayMan") {
    MagicPlayMan
        .PreviewView()
}
