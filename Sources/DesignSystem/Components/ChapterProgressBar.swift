import SwiftUI

public struct ChapterProgressBar: View {
    public let progress: Float
    public let label: String

    public init(progress: Float, label: String) {
        self.progress = progress
        self.label = label
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(Typography.caption)
                .foregroundStyle(Color.white.opacity(0.85))
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.14))
                    Capsule()
                        .fill(LinearGradient(colors: [Theme.mint, Theme.starlight], startPoint: .leading, endPoint: .trailing))
                        .frame(width: proxy.size.width * CGFloat(MathHelpers.clamp(progress, min: 0, max: 1)))
                        .animation(.easeInOut(duration: 0.35), value: progress)
                }
            }
            .frame(height: 10)
        }
    }
}
