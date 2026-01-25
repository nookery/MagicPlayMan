import MagicKit
import SwiftUI

// MARK: - Helper Views

extension MagicPlayManPreviewView {
    /// 下载进度视图
    func downloadingProgress(_ progress: Double, title: String) -> some View {
        VStack(spacing: 16) {
            ProgressView(
                "\(playMan.localization.downloading) \(title)",
                value: progress,
                total: 1.0
            )
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    /// 加载指示器视图
    func loadingIndicator(_ message: String) -> some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Helper Methods

extension MagicPlayManPreviewView {
    /// 显示 Toast 提示
    /// - Parameters:
    ///   - message: 提示消息
    ///   - icon: 图标名称
    ///   - style: Toast 样式
    func showToast(
        _ message: String,
        icon: String,
        style: MagicToast.Style = .info
    ) {
        withAnimation {
            toast = (message, icon, style)
        }

        // 2秒后自动隐藏
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                toast = nil
            }
        }
    }
}

