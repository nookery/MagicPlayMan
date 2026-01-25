import MagicKit
import SwiftUI

// MARK: - Toolbar Components

extension MagicPlayManPreviewView {
    /// 顶部工具栏
    var toolbarView: some View {
        HStack {
            leadingToolbarItems
            Spacer()
            trailingToolbarItems
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    /// 左侧工具栏项
    var leadingToolbarItems: some View {
        HStack {
            playMan.makeMediaPickerButton()
        }
    }

    /// 右侧工具栏项
    var trailingToolbarItems: some View {
        HStack {
            playMan.makePlayPauseButtonView()
            playMan.makePlayModeButtonView()
            playMan.makePlaylistButtonView()
            playMan.makePlaylistToggleButtonView()
            playMan.makeSubscribersButtonView()
            playMan.makeLikeButtonView()
        }
    }
}

