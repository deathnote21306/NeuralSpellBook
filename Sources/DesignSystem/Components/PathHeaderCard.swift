import SwiftUI

public struct PathHeaderCard: View {
    public let title: String
    public let goal: String
    public let progressText: String
    public let progressValue: Float
    public let hint: String

    public init(title: String, goal: String, progressText: String, progressValue: Float, hint: String) {
        self.title = title
        self.goal = goal
        self.progressText = progressText
        self.progressValue = progressValue
        self.hint = hint
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(Typography.title)
                        .foregroundStyle(.white)
                    Text(goal)
                        .font(Typography.caption)
                        .foregroundStyle(.white.opacity(0.78))
                        .lineLimit(2)
                }
                Spacer(minLength: 10)
                Text(progressText)
                    .font(Typography.caption)
                    .foregroundStyle(Theme.gold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1), in: Capsule(style: .continuous))
            }

            ChapterProgressBar(progress: progressValue, label: "Journey progress")
                .frame(maxWidth: 260)

            Label(hint, systemImage: "arrow.right.circle")
                .font(Typography.caption)
                .foregroundStyle(Theme.mint)
                .lineLimit(2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). Goal: \(goal). Next: \(hint).")
    }
}
