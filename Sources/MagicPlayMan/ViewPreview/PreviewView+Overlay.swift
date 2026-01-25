import MagicKit
import MagicUI
import SwiftUI

// MARK: - Overlay Components

extension MagicPlayManPreviewView {
    /// 加载状态覆盖层
    func LoadingOverlay(state: PlaybackState.LoadingState, assetTitle: String) -> some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)

            switch state {
            case let .downloading(progress):
                downloadingProgress(progress, title: assetTitle)
            case .buffering:
                loadingIndicator(playMan.localization.buffering)
            case .preparing:
                loadingIndicator(playMan.localization.preparing)
            case .connecting:
                loadingIndicator(playMan.localization.connecting)
            }
        }
    }

    /// 错误覆盖层
    func ErrorOverlay(error: PlaybackState.PlaybackError, asset: URL, onRetry: @escaping () -> Void) -> some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)

            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.red)

                Text(playMan.localization.failedToLoadMedia)
                    .font(.headline)

                Text(error.localizedDescription(localization: playMan.localization))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                MagicButton.simple(
                    icon: "arrow.clockwise",
                    title: playMan.localization.tryAgain,
                    style: .primary,
                    shape: .capsule,
                    action: onRetry
                )
            }
            .padding()
        }
    }

    /// Toast 提示视图
    func toastView(_ toast: (message: String, icon: String, style: MagicToast.Style)) -> some View {
        MagicToast(
            message: toast.message,
            icon: toast.icon,
            style: toast.style
        )
        .padding(.top, 20)
    }
}

