import Foundation
import MagicKit
import SwiftUI

/// 播放列表项行视图
/// 显示播放列表中的单个媒体项，包括图标、标题和播放状态指示器
public struct PlaylistItemRow: View {
    /// 媒体资源 URL
    let asset: URL
    /// 是否正在播放
    let isPlaying: Bool

    public var body: some View {
        HStack(spacing: 12) {
            // 媒体类型图标
            Image(systemName: asset.isAudio ? "music.note" : "film")
                .font(.system(size: 24))
                .foregroundStyle(isPlaying ? Color.accentColor : .secondary)
                .frame(width: 32)

            // 标题和艺术家
            VStack(alignment: .leading, spacing: 4) {
                Text(asset.title)
                    .font(.headline)
                    .foregroundStyle(isPlaying ? Color.primary : .secondary)
            }

            Spacer()

            // 播放状态指示器
            if isPlaying {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundStyle(Color.accentColor)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview("MagicPlayMan") {
    MagicPlayMan.getPreviewView()
}
