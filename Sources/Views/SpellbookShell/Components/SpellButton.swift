import SwiftUI

enum SpellButtonTone {
    case mana
    case gold
    case spirit
    case danger

    var border: Color {
        switch self {
        case .mana: return Color(red: 0.49, green: 0.38, blue: 1.0)
        case .gold: return Color(red: 0.91, green: 0.72, blue: 0.29)
        case .spirit: return Color(red: 0.24, green: 0.84, blue: 0.75)
        case .danger: return Color(red: 0.85, green: 0.19, blue: 0.38)
        }
    }
}

struct SpellButton: View {
    let title: String
    var tone: SpellButtonTone = .mana
    var isPulsing: Bool = false
    var action: () -> Void

    @State private var pulse: Bool = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("AvenirNext-DemiBold", size: 13))
                .tracking(1.0)
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .frame(minHeight: 44)
                .background(Color.black.opacity(0.26), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(tone.border.opacity(0.7), lineWidth: 1)
                )
                .shadow(color: tone.border.opacity(pulse ? 0.45 : 0.14), radius: pulse ? 18 : 8)
                .scaleEffect(pulse ? 1.01 : 1)
        }
        .buttonStyle(.plain)
        .onAppear {
            guard isPulsing else { return }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}
