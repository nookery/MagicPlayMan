import MagicKit
import SwiftUI

#if DEBUG && os(macOS)
struct ThumbnailViewShowcase: View {
    @State private var selectedCase: ThumbnailCase = .defaultIcon

    var body: some View {
        HSplitView {
            // 左侧案例列表
            VStack(alignment: .leading, spacing: 0) {
                Text("ThumbnailView")
                    .font(.headline)
                    .padding()

                Divider()

                ForEach(ThumbnailCase.allCases) { testCase in
                    CaseRow(
                        testCase: testCase,
                        isSelected: selectedCase == testCase
                    )
                    .onTapGesture {
                        selectedCase = testCase
                    }
                }

                Spacer()
            }
            .frame(width: 160)
            .background(Color.secondary.opacity(0.1))

            // 右侧展示区域
            VStack(spacing: 20) {
                selectedCase.previewView
                    .frame(height: 400)
                    .frame(maxWidth: .infinity)
                    .background(Color.secondary.opacity(0.05))
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 12) {
                    Text("说明")
                        .font(.headline)

                    Text(selectedCase.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let code = selectedCase.codeExample {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("代码示例")
                                .font(.subheadline)
                                .bold()

                            Text(code)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.primary)
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.primary.opacity(0.05))
                                .cornerRadius(4)
                        }
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .inScrollView()
        }
        .frame(width: 650, height: 600)
    }
}

// MARK: - Case Row

struct CaseRow: View {
    let testCase: ThumbnailCase
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: testCase.icon)
                .font(.title3)
                .foregroundStyle(isSelected ? .white : .secondary)
                .frame(width: 24)

            Text(testCase.title)
                .font(.subheadline)
                .foregroundStyle(isSelected ? .white : .primary)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? Color.blue : Color.clear)
        .contentShape(Rectangle())
    }
}

// MARK: - Thumbnail Case

enum ThumbnailCase: CaseIterable, Identifiable {
    case defaultIcon
    case loadedSuccess
    case customView
    case viewBuilder
    case emptyState
    case verboseMode

    var id: Self { self }

    var title: String {
        switch self {
        case .defaultIcon: return "默认图标"
        case .loadedSuccess: return "加载成功"
        case .customView: return "自定义默认视图"
        case .viewBuilder: return "视图构建器"
        case .emptyState: return "空状态"
        case .verboseMode: return "详细模式"
        }
    }

    var icon: String {
        switch self {
        case .defaultIcon: return "doc"
        case .loadedSuccess: return "checkmark.circle"
        case .customView: return "square.stack.3d.up"
        case .viewBuilder: return "paintbrush.pointed"
        case .emptyState: return "doc.questionmark"
        case .verboseMode: return "speaker.wave.2"
        }
    }

    var description: String {
        switch self {
        case .defaultIcon:
            return "使用 defaultImage 参数设置默认图标。当缩略图无法加载时显示此图标。"
        case .loadedSuccess:
            return "从 URL 成功加载缩略图。ThumbnailView 会自动异步加载并显示缩略图。"
        case .customView:
            return "使用 defaultView 参数自定义后备视图，可以创建完全自定义的默认显示内容。"
        case .viewBuilder:
            return "使用 defaultViewBuilder 参数创建自定义默认封面。这是一个闭包，可以返回任意视图，提供了最大的灵活性来设计默认封面。"
        case .emptyState:
            return "当 url 参数为 nil 时，显示内置的文档或音乐图标作为占位符。"
        case .verboseMode:
            return "启用 verbose 模式以查看详细的加载日志，方便调试和开发。"
        }
    }

    var previewView: some View {
        switch self {
        case .defaultIcon:
            ThumbnailView(defaultImage: Image(systemName: .iconDoc))
                .frame(height: 300)
                .frame(width: 300)
        case .loadedSuccess:
            ThumbnailView(url: .sample_web_mp3_kennedy, defaultImage: Image(systemName: .iconMusic))
                .frame(height: 300)
                .frame(width: 300)
        case .customView:
            ThumbnailView(url: .sample_invalid_url, defaultView: {
                VStack(spacing: 12) {
                    Image(systemName: .iconDoc)
                    Text(Localization.preview.noArtwork)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            })
            .frame(height: 300)
            .frame(width: 300)
        case .viewBuilder:
            ThumbnailView(
                url: .sample_invalid_url,
                defaultViewBuilder: {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)

                            Image(systemName: "music.note")
                                .font(.system(size: 50))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }

                        VStack(spacing: 4) {
                            Text("No Artwork")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Text("Custom Default Cover")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.secondary.opacity(0.1))
                    )
                }
            )
            .frame(height: 300)
            .frame(width: 300)
        case .emptyState:
            ThumbnailView(url: nil)
                .frame(height: 300)
                .frame(width: 300)
        case .verboseMode:
            ThumbnailView(url: .sample_web_mp3_kennedy, verbose: true, defaultImage: Image(systemName: .iconMusic))
                .frame(height: 300)
                .frame(width: 300)
        }
    }

    var codeExample: String? {
        switch self {
        case .defaultIcon:
            return """
ThumbnailView(
    defaultImage: Image(systemName: "doc")
)
"""
        case .loadedSuccess:
            return """
ThumbnailView(
    url: audioURL,
    defaultImage: Image(systemName: "music.note")
)
"""
        case .customView:
            return """
ThumbnailView(url: url, defaultView: {
    VStack {
        Image(systemName: "doc")
        Text("No Artwork")
    }
})
"""
        case .viewBuilder:
            return """
ThumbnailView(
    url: url,
    defaultViewBuilder: {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)

                Image(systemName: "music.note")
                    .font(.system(size: 50))
            }

            Text("No Artwork")
                .font(.headline)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
    }
)
"""
        case .emptyState:
            return """
ThumbnailView(url: nil)
"""
        case .verboseMode:
            return """
ThumbnailView(
    url: audioURL,
    verbose: true,
    defaultImage: Image(systemName: "music.note")
)
"""
        }
    }
}

#Preview("ThumbnailView") {
    ThumbnailViewShowcase()
}

#endif
