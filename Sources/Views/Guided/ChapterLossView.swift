import SwiftUI

struct ChapterLossView: View {
    @ObservedObject var viewModel: GuidedJourneyViewModel

    var body: some View {
        SpellbookPanel(
            chapterTitle: "Chapter II · Instability",
            chapterSubtitle: "Loss",
            objective: LessonChapter.instability.objective
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

                Label("Instability = how wrong the spell is.", systemImage: "exclamationmark.triangle")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.warning)
            }
        }
    }
}
