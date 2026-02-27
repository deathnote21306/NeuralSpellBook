import SwiftUI

struct SpellModalOverlayView: View {
    let modal: SpellModalKey
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.84))
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(modal.title)
                                .font(.system(size: 28, weight: .bold, design: .serif))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.91, green: 0.72, blue: 0.29),
                                            Color(red: 0.63, green: 0.50, blue: 1.0)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )

                            Text(modal.subtitle.uppercased())
                                .font(.system(size: 10, weight: .semibold, design: .serif))
                                .tracking(3)
                                .foregroundStyle(Color(red: 0.56, green: 0.43, blue: 0.16))
                        }

                        Spacer()

                        Button("✕ CLOSE", action: onClose)
                            .font(.custom("AvenirNext-DemiBold", size: 11))
                            .tracking(1.6)
                            .foregroundStyle(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.82))
                    }

                    ForEach(modal.sections) { section in
                        switch section.kind {
                        case .text:
                            VStack(alignment: .leading, spacing: 6) {
                                if let title = section.title {
                                    Text(title.uppercased())
                                        .font(.system(size: 11, weight: .semibold, design: .serif))
                                        .tracking(2.3)
                                        .foregroundStyle(Color(red: 0.24, green: 0.84, blue: 0.75))
                                }
                                Text(section.body)
                                    .font(.system(size: 18, weight: .regular, design: .serif))
                                    .foregroundStyle(.white.opacity(0.84))
                                    .lineSpacing(5)
                            }

                        case .formula:
                            Text(section.body)
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .foregroundStyle(Color(red: 0.63, green: 0.50, blue: 1.0))
                                .lineSpacing(4)
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.16), lineWidth: 1)
                                )

                        case .callout:
                            Text(section.body)
                                .font(.system(size: 16, weight: .regular, design: .serif))
                                .italic()
                                .foregroundStyle(Color(red: 0.24, green: 0.84, blue: 0.75))
                                .lineSpacing(4)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.05), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.18), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(24)
            }
            .frame(maxWidth: 700, maxHeight: 620)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.09, green: 0.05, blue: 0.20).opacity(0.97),
                        Color(red: 0.03, green: 0.02, blue: 0.10).opacity(0.98)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.24), lineWidth: 1)
            )
            .shadow(color: Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.25), radius: 30, y: 12)
            .padding(.horizontal, 20)
        }
        .transition(.opacity)
    }
}
