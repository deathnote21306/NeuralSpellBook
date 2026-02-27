import SwiftUI

struct ChapterForwardView: View {
    @ObservedObject var viewModel: GuidedJourneyViewModel

    var body: some View {
        SpellbookPanel(
            chapterTitle: "Chapter I · The First Spell",
            chapterSubtitle: "Forward pass",
            objective: LessonChapter.firstSpell.objective
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

                Label("Meaning: forward pass turns glyphs into a prediction.", systemImage: "sparkles")
                    .font(Typography.caption)
                    .foregroundStyle(.white.opacity(0.86))

                Toggle("Show rune values", isOn: $viewModel.sandbox.showRuneNumbers)
                    .toggleStyle(.switch)
            }
        }
    }
}
