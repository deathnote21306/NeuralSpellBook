import SwiftUI

struct ChapterManaControlsView: View {
    @ObservedObject var viewModel: GuidedJourneyViewModel
    @State private var showAdvanced = false

    var body: some View {
        SpellbookPanel(
            chapterTitle: "Chapter IV · Mana Controls",
            chapterSubtitle: "Hyperparameters",
            objective: LessonChapter.manaControls.objective
        ) {
            VStack(alignment: .leading, spacing: 10) {
                NextActionCard(
                    instruction: viewModel.nextActionInstruction,
                    buttonTitle: viewModel.currentActionTitle,
                    systemImage: viewModel.nextActionSystemImage,
                    whyText: viewModel.nextActionWhy,
                    disabledReason: viewModel.nextActionDisabledReason
                ) {
                    viewModel.performPrimaryAction()
                }

                LabeledSliderRow(
                    title: "Mana Flow (LR)",
                    helper: "Learning rate = step size.",
                    value: $viewModel.sandbox.learningRate,
                    range: 0.0005...0.3,
                    step: 0.0005,
                    format: "%.4f"
                )

                LabeledSliderRow(
                    title: "Focus (Batch)",
                    helper: "Batch size = points used per update.",
                    value: $viewModel.sandbox.batchSize,
                    range: 2...64,
                    step: 1,
                    format: "%.0f"
                )

                LabeledSliderRow(
                    title: "Ritual Repetitions",
                    helper: "Controls auto-training pace.",
                    value: $viewModel.sandbox.speed,
                    range: 0.05...1,
                    step: 0.01,
                    format: "%.2f"
                )

                DisclosureGroup(isExpanded: $showAdvanced) {
                    VStack(spacing: 8) {
                        LabeledSliderRow(
                            title: "Protection Rune (Dropout)",
                            helper: "Randomly hides units to reduce overfitting.",
                            value: $viewModel.sandbox.dropout,
                            range: 0...0.5,
                            step: 0.01,
                            format: "%.2f"
                        )
                        LabeledSliderRow(
                            title: "Protection Rune (L2)",
                            helper: "Keeps weights from growing too large.",
                            value: $viewModel.sandbox.l2,
                            range: 0...0.01,
                            step: 0.0001,
                            format: "%.4f"
                        )
                    }
                    .padding(.top, 6)
                } label: {
                    SectionHeader(
                        title: "Advanced controls",
                        subtitle: "Use only when you are ready",
                        systemImage: "slider.horizontal.3"
                    )
                }
            }
        }
    }
}
