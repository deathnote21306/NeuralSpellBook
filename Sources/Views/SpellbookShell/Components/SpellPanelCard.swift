import SwiftUI

struct SpellPanelCard<Content: View>: View {
    let title: String?
    let content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title {
                Text(title)
                    .font(.custom("AvenirNext-DemiBold", size: 13))
                    .tracking(1.5)
                    .foregroundStyle(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.88))
                    .textCase(.uppercase)
            }
            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color(red: 0.10, green: 0.06, blue: 0.21).opacity(0.95), Color(red: 0.04, green: 0.03, blue: 0.12).opacity(0.98)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.25), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 16, y: 8)
    }
}
