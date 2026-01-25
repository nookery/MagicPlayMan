import MagicKit
import SwiftUI

extension MagicPlayManPreviewView {
    /// 主内容区域
    var mainContentArea: some View {
        VStack(spacing: 0) {
            contentWithSidebar
            controlsSection
        }
        .background(LinearGradient.aurora.opacity(0.1))
    }

    /// 带侧边栏的内容区域
    var contentWithSidebar: some View {
        HStack(spacing: 0) {
            mainContent
                .frame(maxWidth: .infinity)

            if showPlaylist {
                playlistSidebar
            }
        }
    }

    /// 主内容视图
    var mainContent: some View {
        ZStack {
            playMan.makeMediaView()

            if case let .loading(loadingState) = playMan.state, let asset = playMan.currentAsset {
                LoadingOverlay(state: loadingState, assetTitle: asset.title)
            }

            if case let .failed(error) = playMan.state, let assetURL = playMan.currentAsset {
                ErrorOverlay(
                    error: error,
                    asset: assetURL
                ) {
                    Task {
                        await playMan.play(assetURL, reason: "PreviewView")
                    }
                }
            }
        }
        .infinite()
        .background(LinearGradient.winter)
    }

    /// 播放列表侧边栏
    var playlistSidebar: some View {
        playMan.makePlaylistView()
            .frame(width: 300)
            .background(.ultraThinMaterial)
            .transition(.move(edge: .trailing))
    }
}

// MARK: - Preview

#Preview("MagicPlayMan") {
    MagicPlayManPreviewView()
        .frame(width: 600, height: 700)
}
