import SwiftUI

public struct SelectionView: View {
    public let onContinueToSafety: () -> Void
    public let onBack: () -> Void

    @State private var selectedProfile = "Low Contrast + Veil"
    @State private var intensity = 0.5

    private let profiles = [
        "Low Contrast + Veil",
        "Tunnel Vision",
        "Motor Tremor + Latency"
    ]

    public init(
        onContinueToSafety: @escaping () -> Void,
        onBack: @escaping () -> Void
    ) {
        self.onContinueToSafety = onContinueToSafety
        self.onBack = onBack
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text("Choose Simulation")
                .font(.largeTitle)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 12) {
                Text("Profile")
                    .font(.headline)

                Picker("Profile", selection: $selectedProfile) {
                    ForEach(profiles, id: \.self) { profile in
                        Text(profile).tag(profile)
                    }
                }
                .pickerStyle(.segmented)

                Text("Intensity")
                    .font(.headline)
                    .padding(.top, 8)

                Slider(value: $intensity, in: 0...1)
                Text(String(format: "%.2f", intensity))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            HStack(spacing: 12) {
                Button("Back", action: onBack)
                    .buttonStyle(.bordered)

                Button("Continue", action: onContinueToSafety)
                    .buttonStyle(.borderedProminent)
            }

            Spacer()
        }
        .padding(24)
    }
}
