import SwiftUI

struct ChapterInspectView: View {
    @ObservedObject var viewModel: GuidedJourneyViewModel

    var body: some View {
        SpellbookPanel(
            chapterTitle: "Chapter V · Pause & Inspect",
            chapterSubtitle: "Glass box moment",
            objective: LessonChapter.inspect.objective
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

                Label("Meaning: inspect runes to see how decisions are formed.", systemImage: "magnifyingglass")
                    .font(Typography.caption)
                    .foregroundStyle(.white.opacity(0.86))

                if let pinned = viewModel.sandbox.pinnedRune {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Pinned Rune")
                                .font(Typography.caption)
                                .foregroundStyle(.secondary)
                            Text(pinned.name)
                                .font(Typography.section)
                            Text(String(format: "Activation %.4f", pinned.activation))
                                .font(Typography.mono)
                        }
                    }
                }
            }
        }
    }
}
