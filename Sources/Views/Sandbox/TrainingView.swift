import SwiftUI

struct TrainingView: View {
    @ObservedObject var viewModel: SandboxViewModel
    @State private var showAdvanced = false

    private var boundaryResolutionBinding: Binding<Float> {
        Binding(
            get: { Float(viewModel.boundaryResolution) },
            set: { viewModel.boundaryResolution = Int($0.rounded()) }
        )
    }

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(
                    title: "Training",
                    subtitle: "Run, observe, then adjust one thing at a time",
                    systemImage: "waveform.path.ecg"
                )

                LabeledSliderRow(
                    title: "Mana Flow (LR)",
                    helper: "Learning rate = step size.",
                    value: $viewModel.learningRate,
                    range: 0.0005...0.3,
                    step: 0.0005,
                    format: "%.4f"
                )

                LabeledSliderRow(
                    title: "Focus (Batch)",
                    helper: "Batch size = samples used per update.",
                    value: $viewModel.batchSize,
                    range: 2...64,
                    step: 1,
                    format: "%.0f"
                )

                LabeledSliderRow(
                    title: "Ritual Speed",
                    helper: "How quickly auto-training steps run.",
                    value: $viewModel.speed,
                    range: 0.05...1,
                    step: 0.01,
                    format: "%.2f"
                )

                HStack(spacing: 8) {
                    PrimaryButton(title: viewModel.isPlaying ? "Pause" : "Play", systemImage: viewModel.isPlaying ? "pause.fill" : "play.fill") {
                        viewModel.togglePlayPause()
                    }
                    PrimaryButton(title: "Step", systemImage: "forward.frame.fill", prominent: false) {
                        viewModel.stepTraining()
                    }
                }

                HStack(spacing: 12) {
                    metric(title: "Step", value: "\(viewModel.currentStep)")
                    metric(title: "Loss", value: String(format: "%.3f", viewModel.lossHistory.last?.loss ?? 0))
                    metric(title: "Train", value: String(format: "%.2f", viewModel.trainAccuracy))
                    metric(title: "Val", value: String(format: "%.2f", viewModel.validationAccuracy))
                }

                LossChartView(points: viewModel.lossHistory)

                DisclosureGroup(isExpanded: $showAdvanced) {
                    VStack(spacing: 8) {
                        Toggle("Early stopping", isOn: $viewModel.earlyStoppingEnabled)
                            .toggleStyle(.switch)
                            .frame(minHeight: 44)

                        LabeledSliderRow(
                            title: "Boundary Grid",
                            helper: "Higher = smoother boundary, more compute.",
                            value: boundaryResolutionBinding,
                            range: 40...150,
                            step: 1,
                            format: "%.0f"
                        )
                    }
                    .padding(.top, 6)
                } label: {
                    SectionHeader(
                        title: "Advanced",
                        subtitle: "Performance and visualization detail",
                        systemImage: "speedometer"
                    )
                }

                if !viewModel.gradientMagnitudes.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Gradient Magnitudes")
                            .font(Typography.caption)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 6) {
                            ForEach(Array(viewModel.gradientMagnitudes.enumerated()), id: \.offset) { index, value in
                                VStack {
                                    Capsule()
                                        .fill(Theme.mint)
                                        .frame(width: 18, height: CGFloat(12 + min(65, value * 200)))
                                    Text("L\(index + 1)")
                                        .font(Typography.mono)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func metric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(Typography.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(Typography.mono)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
