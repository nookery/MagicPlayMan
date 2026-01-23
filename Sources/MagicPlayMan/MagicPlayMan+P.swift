import MagicKit
import SwiftUI

struct MagicPlayManShowcase: View {
    var body: some View {
        TabView {
            // 完整预览
            VStack(spacing: 12) {
                Text("完整预览界面")
                    .font(.headline)
                    .padding(.top)

                MagicPlayMan.PreviewView()
                    .frame(width: 500, height: 700)

                Text("包含完整的播放器功能演示")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .tabItem {
                Label("完整界面", systemImage: "play.rectangle")
            }

            // 基本初始化
            VStack(spacing: 12) {
                Text("基本初始化")
                    .font(.headline)
                    .padding(.top)

                VStack(alignment: .leading, spacing: 8) {
                    Text("使用默认配置初始化：")
                        .font(.subheadline)
                        .bold()

                    CodeBlock(code: """
// 基本初始化
let player = MagicPlayMan()

// 带默认封面图
let player = MagicPlayMan(
    defaultArtwork: Image("default-cover")
)
""")
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)

                Text("MagicPlayMan 支持多种初始化配置")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .tabItem {
                Label("初始化", systemImage: "gear")
            }

            // 默认封面图功能
            VStack(spacing: 12) {
                Text("默认封面图功能")
                    .font(.headline)
                    .padding(.top)

                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(
                        icon: "photo",
                        title: "AudioContentView",
                        description: "支持传入 defaultArtwork 参数"
                    )

                    FeatureRow(
                        icon: "photo.on.rectangle",
                        title: "AudioPlayerView",
                        description: "支持传入 defaultArtwork 参数"
                    )

                    FeatureRow(
                        icon: "photo.stack",
                        title: "优先级",
                        description: "外部 > 本地 > 默认"
                    )
                }
                .padding()
            }
            .tabItem {
                Label("封面图", systemImage: "photo.artframe")
            }

            // 默认 Artwork 实例（跳转到详细展示）
            VStack(spacing: 12) {
                Text("默认 Artwork 实例")
                    .font(.headline)
                    .padding(.top)

                VStack(spacing: 16) {
                    Text("👉 查看完整的默认封面图展示")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("包含多个 Tab：")
                        .font(.caption)
                        .bold()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("• AudioContentView 示例")
                        Text("• AudioPlayerView 示例")
                        Text("• 优先级说明")
                        Text("• 初始化方法")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding()
            }
            .tabItem {
                Label("实例", systemImage: "play.square.stack")
            }

            // 视图功能
            VStack(spacing: 12) {
                Text("视图功能")
                    .font(.headline)
                    .padding(.top)

                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(
                        icon: "eye",
                        title: "makeMediaView()",
                        description: "根据资源类型自动适配"
                    )

                    FeatureRow(
                        icon: "star",
                        title: "makeHeroView()",
                        description: "主要展示视图，支持默认图"
                    )

                    FeatureRow(
                        icon: "list.bullet",
                        title: "makePlaylistView()",
                        description: "播放列表视图"
                    )

                    FeatureRow(
                        icon: "slider.horizontal.3",
                        title: "makeProgressView()",
                        description: "进度条视图"
                    )
                }
                .padding()
            }
            .tabItem {
                Label("视图", systemImage: "rectangle.stack")
            }

            // 控制按钮
            VStack(spacing: 12) {
                Text("控制按钮")
                    .font(.headline)
                    .padding(.top)

                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(
                        icon: "playpause",
                        title: "播放控制",
                        description: "播放/暂停、上一曲、下一曲"
                    )

                    FeatureRow(
                        icon: "backward.end",
                        title: "快进快退",
                        description: "Forward/Rewind 按钮"
                    )

                    FeatureRow(
                        icon: "repeat",
                        title: "播放模式",
                        description: "顺序、随机、单曲循环"
                    )

                    FeatureRow(
                        icon: "heart",
                        title: "收藏功能",
                        description: "喜欢/取消喜欢"
                    )
                }
                .padding()
            }
            .tabItem {
                Label("控制", systemImage: "remote.gen2")
            }

            // 订阅系统
            VStack(spacing: 12) {
                Text("订阅系统")
                    .font(.headline)
                    .padding(.top)

                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(
                        icon: "bell",
                        title: "事件订阅",
                        description: "订阅播放器各种事件"
                    )

                    FeatureRow(
                        icon: "list.bullet.rectangle",
                        title: "订阅者列表",
                        description: "查看所有订阅者"
                    )

                    FeatureRow(
                        icon: "waveform",
                        title: "状态变化",
                        description: "播放状态、进度等"
                    )
                }
                .padding()
            }
            .tabItem {
                Label("订阅", systemImage: "bell.badge")
            }
        }
        .frame(width: 600, height: 700)
    }
}

// MARK: - Helper Views

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .bold()

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct CodeBlock: View {
    let code: String

    var body: some View {
        Text(code)
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(.primary)
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.primary.opacity(0.05))
            .cornerRadius(4)
    }
}

#Preview("MagicPlayMan Showcase") {
    MagicPlayManShowcase()
}

#Preview("MagicPlayMan Artwork Showcase") {
    MagicPlayManArtworkShowcase()
}
