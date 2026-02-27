import SwiftUI

public struct SectionHeader: View {
    public let title: String
    public let subtitle: String
    public let systemImage: String

    public init(title: String, subtitle: String, systemImage: String) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .foregroundStyle(Theme.mint)
                Text(title)
                    .font(Typography.section)
                    .foregroundStyle(.white)
            }
            Text(subtitle)
                .font(Typography.caption)
                .foregroundStyle(.white.opacity(0.72))
        }
    }
}
