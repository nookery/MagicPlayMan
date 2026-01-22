import AVFoundation
import Foundation
import MagicKit
import MediaPlayer
import OSLog
import SwiftUI

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

// 平台相关的类型别名
#if os(macOS)
    typealias PlatformImage = NSImage
#else
    typealias PlatformImage = UIImage
#endif

extension MagicPlayMan {
    func setupRemoteControl() {
        #if os(iOS)
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true)
                if verbose {
                    os_log("\(self.t)Audio session setup successful")
                }
            } catch {
                if verbose {
                    os_log("\(self.t)Failed to setup audio session: \(error.localizedDescription)")
                }
            }
        #endif

        let commandCenter = MPRemoteCommandCenter.shared()

        // 播放/暂停
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self else {
                return .commandFailed
            }

            if self.state != .playing {
                if self.verbose {
                    os_log("\(self.t)Remote command: Play")
                }
                self.play(reason: "commandCenter.playCommand")
                return .success
            }

            if self.verbose {
                os_log("\(self.t)Play command ignored: Already playing")
            }
            return .commandFailed
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self = self else {
                return .commandFailed
            }

            if self.state == .playing {
                if self.verbose {
                    os_log("\(self.t)Remote command: Pause")
                }
                self.pause(reason: self.className + ".commandCenter.pauseCommand")
                return .success
            }

            if self.verbose {
                os_log("\(self.t)Pause command ignored: Not playing")
            }
            return .commandFailed
        }

        // 上一首/下一首
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            guard let self = self else {
                return .commandFailed
            }

            if self.verbose {
                os_log("\(self.t)Remote command: Previous track")
            }
            if self.isPlaylistEnabled {
                self.previous()
            } else {
                if let asset = self.currentAsset {
                    self.events.onPreviousRequested.send(asset)
                }
            }
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            guard let self = self else {
                return .commandFailed
            }

            if self.verbose {
                os_log("\(self.t)Remote command: Next track")
            }
            if self.isPlaylistEnabled {
                self.next()
            } else {
                if let asset = self.currentAsset {
                    self.events.onNextRequested.send(asset)
                }
            }
            return .success
        }

        // 快进/快退
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            guard let self = self else {
                return .commandFailed
            }

            if self.verbose {
                os_log("\(self.t)Remote command: Skip forward")
            }
            self.skipForward()
            return .success
        }

        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            guard let self = self else {
                return .commandFailed
            }

            if self.verbose {
                os_log("\(self.t)Remote command: Skip backward")
            }
            self.skipBackward()
            return .success
        }

        // 进度控制
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self,
                  let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }

            let time = TimeInterval(event.positionTime)
            if self.verbose {
                os_log("\(self.t)Remote command: Seek to \(time.displayFormat)")
            }
            self.seek(time: time, reason: self.className + ".commandCenter.changePlaybackPositionCommand")
            return .success
        }

        // 喜欢/取消喜欢
        if #available(iOS 13.0, macOS 10.15, *) {
            commandCenter.likeCommand.isActive = true // 启用喜欢按钮
            commandCenter.likeCommand.localizedTitle = "Like" // 设置按钮标题
            commandCenter.likeCommand.localizedShortTitle = "Like" // 设置短标题

            commandCenter.likeCommand.addTarget { [weak self] _ in
                guard let self = self else {
                    return .commandFailed
                }

                if self.verbose {
                    os_log("\(self.t)Remote command: Toggle like")
                }
                self.toggleLike()
                return .success
            }
        }

        if verbose {
            os_log("\(self.t)✅ Remote control setup completed")
        }
    }

    /// 更新Now Playing信息中心
    /// - Parameter info: 要设置的媒体信息字典
    private func updateNowPlayingCenter(with info: [String: Any]) {
        DispatchQueue.main.async {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
            self.nowPlayingInfo = info
        }
    }

    /// 更新系统Now Playing信息中心
    /// - Parameters:
    ///   - includeThumbnail: 是否包含媒体缩略图，默认为true
    ///   - reason: 更新原因
    func updateNowPlayingInfo(includeThumbnail: Bool = true, reason: String) {
        guard let asset = currentAsset else {
            if verbose {
                os_log("\(self.t)Clearing now playing info: No asset")
            }
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }

        if verbose {
            os_log("\(self.t)🖼️ (\(reason)) Updating now playing info for: \(asset.title)")
        }

        var info: [String: Any] = [
            MPMediaItemPropertyTitle: asset.title,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: state == .playing ? 1.0 : 0.0,
        ]

        // 设置媒体类型
        info[MPMediaItemPropertyMediaType] = asset.isAudio ?
            MPMediaType.music.rawValue : MPMediaType.movie.rawValue

        // 更新Now Playing信息（异步处理）
        Task {
            // 根据参数决定是否添加缩略图
            if includeThumbnail {
                do {
                    if let (platformImage, _) = try await asset.platformThumbnail(
                        size: CGSize(width: 600, height: 600), verbose: verbose && false, reason: self.className + ".updateNowPlayingInfo"
                    ), let platformImage = platformImage {
                        info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
                            boundsSize: platformImage.size,
                            requestHandler: { _ in platformImage }
                        )
                    }
                } catch {
                    // 缩略图加载失败，使用不带缩略图的info
                }
            }

            // 统一更新Now Playing信息中心
            self.updateNowPlayingCenter(with: info)
        }
    }
}

// MARK: - Preview

#Preview("MagicPlayMan") {
    MagicPlayMan.PreviewView()
}
