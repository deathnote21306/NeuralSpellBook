import SwiftUI

struct TensorInspectorView: View {
    let tensor: TensorSummary

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(tensor.name)
                                .font(Typography.title)
                            Text("Shape: \(tensor.shape.map(String.init).joined(separator: " × "))")
                                .font(Typography.mono)
                                .foregroundStyle(.secondary)
                            Text(tensor.meaning)
                                .font(Typography.body)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Statistics")
                                .font(Typography.section)
                            statRow(title: "Min", value: tensor.minValue)
                            statRow(title: "Max", value: tensor.maxValue)
                            statRow(title: "Mean", value: tensor.meanValue)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sample Values")
                                .font(Typography.section)
                            let columns = [GridItem(.adaptive(minimum: 72))]
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(Array(tensor.samples.enumerated()), id: \.offset) { _, sample in
                                    Text(String(format: "%.3f", sample))
                                        .font(Typography.mono)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Tensor Inspector")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func statRow(title: String, value: Float) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(String(format: "%.4f", value))
                .font(Typography.mono)
        }
        .foregroundStyle(.white.opacity(0.92))
    }
}
