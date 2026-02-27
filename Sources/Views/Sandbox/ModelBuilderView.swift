import SwiftUI

struct ModelBuilderView: View {
    @ObservedObject var viewModel: SandboxViewModel
    @State private var showAdvanced = false

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(
                    title: "Model Builder",
                    subtitle: "Shape the network before training",
                    systemImage: "brain"
                )

                Stepper("Hidden Layers: \(viewModel.hiddenLayerCount)", value: $viewModel.hiddenLayerCount, in: 1...3)
                    .frame(minHeight: 44)

                LabeledSliderRow(
                    title: "Width L1",
                    helper: "Units in hidden layer 1.",
                    value: $viewModel.hiddenWidth1,
                    range: 2...32,
                    step: 1,
                    format: "%.0f"
                )
                if viewModel.hiddenLayerCount >= 2 {
                    LabeledSliderRow(
                        title: "Width L2",
                        helper: "Units in hidden layer 2.",
                        value: $viewModel.hiddenWidth2,
                        range: 2...32,
                        step: 1,
                        format: "%.0f"
                    )
                }
                if viewModel.hiddenLayerCount >= 3 {
                    LabeledSliderRow(
                        title: "Width L3",
                        helper: "Units in hidden layer 3.",
                        value: $viewModel.hiddenWidth3,
                        range: 2...32,
                        step: 1,
                        format: "%.0f"
                    )
                }

                Picker("Activation", selection: $viewModel.activation) {
                    ForEach(ActivationKind.allCases) { kind in
                        Text(kind.rawValue).tag(kind)
                    }
                }
                .pickerStyle(.segmented)

                DisclosureGroup(isExpanded: $showAdvanced) {
                    VStack(spacing: 8) {
                        Picker("Output", selection: $viewModel.outputMode) {
                            ForEach(OutputMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)

                        Picker("Optimizer", selection: $viewModel.optimizer) {
                            ForEach(OptimizerKind.allCases) { kind in
                                Text(kind.rawValue).tag(kind)
                            }
                        }
                        .pickerStyle(.segmented)

                        LabeledSliderRow(
                            title: "Dropout",
                            helper: "Reduces overfitting by dropping units.",
                            value: $viewModel.dropout,
                            range: 0...0.5,
                            step: 0.01,
                            format: "%.2f"
                        )

                        LabeledSliderRow(
                            title: "L2",
                            helper: "Penalty for large weights.",
                            value: $viewModel.l2,
                            range: 0...0.01,
                            step: 0.0001,
                            format: "%.4f"
                        )

                        LabeledSliderRow(
                            title: "Grad Clip",
                            helper: "Caps very large gradient updates.",
                            value: $viewModel.gradientClip,
                            range: 0...3,
                            step: 0.1,
                            format: "%.1f"
                        )
                    }
                    .padding(.top, 6)
                } label: {
                    SectionHeader(
                        title: "Advanced",
                        subtitle: "Regularization and optimizer controls",
                        systemImage: "slider.horizontal.3"
                    )
                }

                PrimaryButton(title: "Apply Model", systemImage: "hammer") {
                    viewModel.rebuildModel()
                }
            }
        }
    }
}
