import SwiftUI

struct ChapterBackpropView: View {
    @ObservedObject var viewModel: GuidedJourneyViewModel

    var body: some View {
        SpellbookPanel(
            chapterTitle: "Chapter III · Backprop Ritual",
            chapterSubtitle: "Gradients guide correction",
            objective: LessonChapter.backprop.objective
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

                Toggle("Step Mode", isOn: $viewModel.stepModeEnabled)
                    .toggleStyle(.switch)

                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(
                            title: "Ritual Sequence",
                            subtitle: "Omen -> thread update -> boundary shift",
                            systemImage: "arrowshape.turn.up.backward.2"
                        )
                        stepRow(title: "1. Omen (gradient)", active: viewModel.backpropStep == 0)
                        stepRow(title: "2. Threads update", active: viewModel.backpropStep == 1)
                        stepRow(title: "3. Barrier shifts", active: viewModel.backpropStep >= 2)
                        Text("Gradient = direction to improve.")
                            .font(Typography.caption)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }
            }
        }
    }

    private func stepRow(title: String, active: Bool) -> some View {
        HStack {
            Image(systemName: active ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(active ? Theme.mint : .secondary)
            Text(title)
                .font(Typography.body)
        }
        .foregroundStyle(.white.opacity(0.9))
    }
}
