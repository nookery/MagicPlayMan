import Foundation
import MagicKit
import SwiftUI

/// 播放列表内容视图
/// 显示播放列表中的所有媒体项，支持拖拽排序和删除操作
public struct PlaylistContentView: View, SuperLog {
    /// 播放管理器实例
    @ObservedObject var playMan: MagicPlayMan

    public var body: some View {
        List {
            ForEach(playMan.items, id: \.self) { asset in
                PlaylistItemRow(
                    asset: asset,
                    isPlaying: asset == playMan.currentAsset
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    Task {
                        await playMan.play(asset, reason: self.className)
                    }
                }
            }
            .onMove { from, to in
                playMan.moveInPlaylist(from: from.first ?? 0, to: to)
            }
            .onDelete { indexSet in
                for index in indexSet.sorted(by: >) {
                    playMan.removeFromPlaylist(at: index)
                }
            }
        }
        .listStyle(.plain)
        .background(.background)
    }
}

// MARK: - Preview

#Preview("MagicPlayMan") {
    MagicPlayMan.getPreviewView()
}

