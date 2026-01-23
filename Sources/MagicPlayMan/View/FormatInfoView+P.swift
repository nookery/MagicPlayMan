import SwiftUI

struct FormatInfoViewShowcase: View {
    var body: some View {
        FormatInfoView(formats: SupportedFormat.allFormats)
            .frame(width: 400)
    }
}

#Preview("FormatInfoView") {
    FormatInfoViewShowcase()
}
