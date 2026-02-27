import SwiftUI

public struct StatusChip: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let systemImage: String
    public let tint: Color

    public init(title: String, systemImage: String, tint: Color) {
        self.title = title
        self.systemImage = systemImage
        self.tint = tint
    }
}

public struct StatusChipsRow: View {
    public let chips: [StatusChip]

    public init(chips: [StatusChip]) {
        self.chips = chips
    }

    public var body: some View {
        if chips.isEmpty {
            EmptyView()
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(chips) { chip in
                        HStack(spacing: 6) {
                            Image(systemName: chip.systemImage)
                            Text(chip.title)
                        }
                        .font(Typography.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(chip.tint.opacity(0.28), in: Capsule(style: .continuous))
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(chip.tint.opacity(0.7), lineWidth: 1)
                        )
                    }
                }
            }
            .frame(minHeight: 36)
        }
    }
}
