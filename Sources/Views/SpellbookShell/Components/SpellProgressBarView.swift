import SwiftUI

struct SpellProgressBarView: View {
    let progress: CGFloat

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.49, green: 0.38, blue: 1.0), Color(red: 0.91, green: 0.72, blue: 0.29), Color(red: 0.24, green: 0.84, blue: 0.75)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, min(1, progress)) * proxy.size.width)
                    .shadow(color: Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.6), radius: 8)
            }
        }
        .frame(height: 2)
        .animation(.easeInOut(duration: 0.6), value: progress)
        .accessibilityLabel("Scene progress")
    }
}
