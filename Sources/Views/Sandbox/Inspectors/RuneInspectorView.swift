import SwiftUI

struct RuneInspectorView: View {
    let rune: RuneSnapshot
    let onPin: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Capsule()
                .fill(Color.white.opacity(0.24))
                .frame(width: 50, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)

            Text(rune.name)
                .font(Typography.title)

            HStack {
                Label("Rune Charge", systemImage: "waveform")
                Spacer()
                Text(String(format: "%.4f", rune.activation))
                    .font(Typography.mono)
            }

            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Incoming Weight Summary")
                        .font(Typography.section)
                    if rune.incomingWeights.isEmpty {
                        Text("Input rune: no incoming weights.")
                            .font(Typography.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        let weights = rune.incomingWeights
                        let avg = weights.map { abs($0) }.reduce(0, +) / Float(weights.count)
                        let signedAverage = weights.reduce(0, +) / Float(weights.count)
                        Text("Average magnitude: \(String(format: "%.4f", avg))")
                            .font(Typography.mono)
                        Text(signedAverage >= 0 ? "Tends to push toward Sigil A." : "Tends to push toward Sigil B.")
                            .font(Typography.caption)
                            .foregroundStyle(.white.opacity(0.75))

                        HStack(spacing: 4) {
                            ForEach(Array(weights.enumerated()), id: \.offset) { _, w in
                                Rectangle()
                                    .fill(w >= 0 ? Theme.starlight : Theme.ember)
                                    .frame(width: 18, height: CGFloat(8 + min(32, abs(w) * 30)))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Tensor Shape")
                    .font(Typography.caption)
                    .foregroundStyle(.secondary)
                Text(rune.tensorShapeDescription)
                    .font(Typography.mono)
                Text(rune.meaning)
                    .font(Typography.body)
                    .foregroundStyle(.white.opacity(0.88))
            }

            PrimaryButton(title: "Pin this rune", systemImage: "pin.fill") {
                onPin()
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 22)
        .presentationDetents([.fraction(0.45), .fraction(0.7)])
        .presentationDragIndicator(.hidden)
    }
}
