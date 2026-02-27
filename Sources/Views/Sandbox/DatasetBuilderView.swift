import SwiftUI

struct DatasetBuilderView: View {
    @ObservedObject var viewModel: SandboxViewModel
    @State private var showAdvanced = false

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(
                    title: "Dataset Builder",
                    subtitle: "Define what the network should learn from",
                    systemImage: "point.3.connected.trianglepath.dotted"
                )

                Picker("Type", selection: $viewModel.datasetType) {
                    ForEach(DatasetType.allCases) { kind in
                        Text(kind.rawValue).tag(kind)
                    }
                }
                .pickerStyle(.segmented)

                LabeledSliderRow(
                    title: "Point Count",
                    helper: "More points usually give smoother learning.",
                    value: $viewModel.pointCount,
                    range: 80...420,
                    step: 10,
                    format: "%.0f"
                )

                LabeledSliderRow(
                    title: "Noise",
                    helper: "Higher noise makes the task harder.",
                    value: $viewModel.noise,
                    range: 0...0.4,
                    step: 0.01,
                    format: "%.2f"
                )

                Toggle("Normalize Data", isOn: $viewModel.normalizeData)
                    .toggleStyle(.switch)
                    .frame(minHeight: 44)

                DisclosureGroup(isExpanded: $showAdvanced) {
                    VStack(spacing: 8) {
                        LabeledSliderRow(
                            title: "Seed",
                            helper: "Reproducible random generation.",
                            value: $viewModel.seed,
                            range: 1...999,
                            step: 1,
                            format: "%.0f"
                        )

                        LabeledSliderRow(
                            title: "Train Split",
                            helper: "Fraction used for training vs validation.",
                            value: $viewModel.trainSplit,
                            range: 0.55...0.9,
                            step: 0.01,
                            format: "%.2f"
                        )
                    }
                    .padding(.top, 6)
                } label: {
                    SectionHeader(
                        title: "Advanced",
                        subtitle: "Use when you want tighter control",
                        systemImage: "slider.horizontal.3"
                    )
                }

                HStack(spacing: 8) {
                    PrimaryButton(title: "Apply Dataset", systemImage: "arrow.triangle.2.circlepath") {
                        viewModel.regenerateDataset()
                    }

                    PrimaryButton(title: "Normalize Now", systemImage: "sparkles", prominent: false) {
                        viewModel.normalizeDatasetNow()
                    }
                }
            }
        }
    }
}
