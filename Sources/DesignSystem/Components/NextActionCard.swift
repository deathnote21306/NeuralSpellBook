import SwiftUI

public struct NextActionCard: View {
    public let instruction: String
    public let buttonTitle: String
    public let systemImage: String
    public let whyText: String
    public let disabledReason: String?
    public let action: () -> Void

    @State private var showWhy = false

    public init(
        instruction: String,
        buttonTitle: String,
        systemImage: String,
        whyText: String,
        disabledReason: String? = nil,
        action: @escaping () -> Void
    ) {
        self.instruction = instruction
        self.buttonTitle = buttonTitle
        self.systemImage = systemImage
        self.whyText = whyText
        self.disabledReason = disabledReason
        self.action = action
    }

    public var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Label("Do this now", systemImage: "wand.and.stars")
                    .font(Typography.section)
                    .foregroundStyle(Theme.gold)

                Text(instruction)
                    .font(Typography.caption)
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(2)

                PrimaryButton(title: buttonTitle, systemImage: systemImage) {
                    action()
                }
                .disabled(disabledReason != nil)
                .opacity(disabledReason == nil ? 1 : 0.55)
                .accessibilityLabel("Do this now: \(buttonTitle)")

                if let disabledReason {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                        Text(disabledReason)
                            .font(Typography.caption)
                    }
                    .foregroundStyle(Theme.warning)
                }

                Button("Why?") {
                    showWhy = true
                }
                .font(Typography.caption)
                .buttonStyle(.plain)
                .foregroundStyle(Theme.starlight)
                .accessibilityLabel("Why this action matters")
            }
        }
        .sheet(isPresented: $showWhy) {
            WhySheet(title: "Why this step", explanation: whyText)
        }
    }
}
