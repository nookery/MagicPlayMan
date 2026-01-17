import MagicKit
import SwiftUI
import MagicUI

struct ErrorOverlay: View {
    let error: PlaybackState.PlaybackError
    let asset: MagicAsset
    let onRetry: () -> Void

    @Environment(\.localization) private var loc

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)

            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.red)

                Text(loc.failedToLoadMedia)
                    .font(.headline)

                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                MagicButton.simple(
                    icon: "arrow.clockwise",
                    title: loc.tryAgain,
                    shape: .capsule,
                    action: onRetry
                )
            }
            .padding()
        }
    }

    private var errorMessage: String {
        switch error {
        case .noAsset:
            return loc.noMediaSelected
        case .invalidAsset:
            return loc.invalidOrCorrupted
        case let .networkError(message):
            return "\(loc.networkError): \(message)"
        case let .playbackError(message):
            return "\(loc.playbackError): \(message)"
        case let .unsupportedFormat(ext):
            return "\(loc.unsupportedFormat): \(ext)"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ErrorOverlay(
            error: .invalidAsset,
            asset: .init(url: .documentsDirectory, metadata: .init(title: "Test")),
            onRetry: {}
        )
        .frame(height: 200)

        ErrorOverlay(
            error: .networkError("Connection timeout"),
            asset: .init(url: .documentsDirectory, metadata: .init(title: "Test")),
            onRetry: {}
        )
        .frame(height: 200)
    }
    .padding()
}
