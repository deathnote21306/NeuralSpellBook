import SwiftUI

struct ChapterFinaleView: View {
    @ObservedObject var viewModel: GuidedJourneyViewModel
    let onReplay: () -> Void
    let onEnterFreePlay: () -> Void

    var body: some View {
        SpellbookPanel(
            chapterTitle: "Final · Evolution",
            chapterSubtitle: "The network stabilizes",
            objective: LessonChapter.evolution.objective
        ) {
            VStack(alignment: .leading, spacing: 12) {
                NextActionCard(
                    instruction: viewModel.nextActionInstruction,
                    buttonTitle: viewModel.showFinalButtons ? "Seal Complete" : viewModel.currentActionTitle,
                    systemImage: viewModel.nextActionSystemImage,
                    whyText: viewModel.nextActionWhy,
                    disabledReason: viewModel.nextActionDisabledReason
                ) {
                    viewModel.performPrimaryAction()
                }

                Text("Intelligence is repetition guided by correction.")
                    .font(Typography.section)
                    .foregroundStyle(Theme.gold)

                Label("Runes stabilize. Instability falls. The familiar evolves.", systemImage: "sparkles")
                    .font(Typography.caption)
                    .foregroundStyle(.white.opacity(0.84))

                if viewModel.showFinalButtons {
                    PrimaryButton(title: "Replay Guided Journey", systemImage: "arrow.counterclockwise") {
                        onReplay()
                    }
                    PrimaryButton(title: "Enter Free Play", systemImage: "wand.and.stars", prominent: false) {
                        onEnterFreePlay()
                    }
                }
            }
        }
    }
}
