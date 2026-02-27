import SwiftUI

struct SpellCanvasPlaceholderView: View {
    let width: CGFloat
    let height: CGFloat
    let label: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.03, green: 0.02, blue: 0.09), Color(red: 0.06, green: 0.03, blue: 0.16)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.25), lineWidth: 1)

            ZStack {
                Circle()
                    .fill(Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.20))
                    .frame(width: width * 0.28)
                    .blur(radius: 5)
                Circle()
                    .fill(Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.14))
                    .frame(width: width * 0.18)
                    .offset(x: width * 0.12, y: -height * 0.1)
                    .blur(radius: 4)
            }

            VStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color(red: 0.91, green: 0.72, blue: 0.29))
                Text("(Canvas placeholder)")
                    .font(.custom("AvenirNext-Regular", size: 13))
                    .foregroundStyle(.white.opacity(0.86))
                Text(label)
                    .font(.custom("AvenirNext-Regular", size: 11))
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
        .frame(width: width, height: height)
        .accessibilityLabel("Canvas placeholder")
    }
}
