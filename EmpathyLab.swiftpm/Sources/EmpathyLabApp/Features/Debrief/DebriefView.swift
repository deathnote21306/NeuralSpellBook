import SwiftUI

public struct DebriefView: View {
    public let onBackHome: () -> Void

    public init(onBackHome: @escaping () -> Void) {
        self.onBackHome = onBackHome
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text("3 Rules to Remember")
                .font(.largeTitle)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                ruleCard(title: "Contrast", body: "Use clear text contrast and visual hierarchy.")
                ruleCard(title: "Targets", body: "Make touch targets large and well spaced.")
                ruleCard(title: "Feedback", body: "Give clear status updates and offer undo.")
            }

            Button("Back to Home", action: onBackHome)
                .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding(24)
    }

    private func ruleCard(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
