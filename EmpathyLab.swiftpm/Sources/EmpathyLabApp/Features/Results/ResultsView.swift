import SwiftUI

public struct ResultsView: View {
    public let onTryFix: () -> Void
    public let onBackHome: () -> Void

    public init(
        onTryFix: @escaping () -> Void,
        onBackHome: @escaping () -> Void
    ) {
        self.onTryFix = onTryFix
        self.onBackHome = onBackHome
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text("Results")
                .font(.largeTitle)
                .fontWeight(.semibold)

            HStack(spacing: 12) {
                metricCard(title: "Time", value: "42s")
                metricCard(title: "Errors", value: "5")
                metricCard(title: "Undo", value: "2")
            }

            Button("Try the Fix", action: onTryFix)
                .buttonStyle(.borderedProminent)

            Button("Back to Home", action: onBackHome)
                .buttonStyle(.bordered)

            Spacer()
        }
        .padding(24)
    }

    private func metricCard(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
