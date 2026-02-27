import SwiftUI

struct JourneyBreadcrumbView: View {
    let currentChapter: LessonChapter

    private let steps: [(LessonChapter, String)] = [
        (.firstSpell, "Forward"),
        (.instability, "Loss"),
        (.backprop, "Backprop"),
        (.manaControls, "Hyperparams"),
        (.inspect, "Inspect"),
        (.evolution, "Mastery")
    ]

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(
                    title: "Journey Map",
                    subtitle: "Data -> Forward -> Loss -> Backprop -> Update",
                    systemImage: "list.number"
                )

                VStack(alignment: .leading, spacing: 7) {
                    ForEach(steps, id: \.0.id) { step in
                        HStack(spacing: 8) {
                            Image(systemName: icon(for: step.0))
                                .foregroundStyle(color(for: step.0))
                            Text(step.1)
                                .font(Typography.body)
                                .foregroundStyle(color(for: step.0))
                            Spacer()
                        }
                    }
                }
            }
        }
    }

    private func icon(for chapter: LessonChapter) -> String {
        if chapter == currentChapter { return "largecircle.fill.circle" }
        if chapter.rawValue < currentChapter.rawValue { return "checkmark.circle.fill" }
        return "circle"
    }

    private func color(for chapter: LessonChapter) -> Color {
        if chapter == currentChapter { return Theme.gold }
        if chapter.rawValue < currentChapter.rawValue { return Theme.mint }
        return .white.opacity(0.65)
    }
}
