import SwiftUI

struct SceneHeaderBadgeView: View {
    let chapter: String
    let title: String

    var body: some View {
        VStack(spacing: 5) {
            Text(chapter)
                .font(.system(size: 13, weight: .semibold, design: .serif))
                .tracking(3)
                .foregroundStyle(Color(red: 0.56, green: 0.43, blue: 0.16))
                .textCase(.uppercase)
            Text(title)
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.91, green: 0.72, blue: 0.29), Color(red: 0.86, green: 0.85, blue: 1.0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}
