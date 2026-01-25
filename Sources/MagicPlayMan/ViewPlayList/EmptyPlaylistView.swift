import Foundation
import SwiftUI

/// 空播放列表视图
/// 当播放列表为空时显示的占位视图
public struct EmptyPlaylistView: View {
    /// 本地化环境变量
    @Environment(\.localization) private var loc

    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text(loc.noItemsInPlaylist)
                    .font(.headline)

                Text(loc.addSomeMediaFiles)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
}

// MARK: - Preview

#Preview("MagicPlayMan") {
    MagicPlayMan.getPreviewView()
}

