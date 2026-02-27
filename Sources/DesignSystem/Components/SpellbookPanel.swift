import SwiftUI

public struct SpellbookPanel<Content: View>: View {
    public let chapterTitle: String
    public let chapterSubtitle: String
    public let objective: String
    private let content: Content

    public init(
        chapterTitle: String,
        chapterSubtitle: String,
        objective: String,
        @ViewBuilder content: () -> Content
    ) {
        self.chapterTitle = chapterTitle
        self.chapterSubtitle = chapterSubtitle
        self.objective = objective
        self.content = content()
    }

    public var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(chapterTitle)
                        .font(Typography.title)
                        .foregroundStyle(.white)
                    Text(chapterSubtitle)
                        .font(Typography.caption)
                        .foregroundStyle(Color.white.opacity(0.78))
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Ritual Goal", systemImage: "target")
                            .font(Typography.caption)
                            .foregroundStyle(Theme.mint)
                        Text(objective)
                            .font(Typography.caption)
                            .foregroundStyle(.white.opacity(0.9))
                            .lineLimit(2)
                    }
                }

                content
            }
        }
    }
}
