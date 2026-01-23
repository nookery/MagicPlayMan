import MagicKit
import SwiftUI

struct MagicPlayManArtworkShowcase: View {
    var body: some View {
        AudioContentView(
            asset: .init(
                url: .sample_temp_mp3,
                metadata: .init(
                    title: "示例歌曲",
                    artist: "示例歌手",
                    album: "示例专辑"
                )
            ),
            defaultArtwork: Image.videoDocument
        )
        .magicCentered()
        .frame(width: 500, height: 700)
        .inScrollView()
        .frame(width: 500, height: 700)
    }
}

#Preview("MagicPlayMan Artwork") {
    MagicPlayManArtworkShowcase()
}
