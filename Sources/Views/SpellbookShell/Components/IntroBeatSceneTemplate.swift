import SwiftUI

struct IntroBeatSceneTemplate<CanvasContent: View>: View {
    let canvas: CanvasContent
    let tag: String
    let headline: String
    let bodyText: String
    let analogy: String
    let buttonTitle: String
    let onBegin: () -> Void

    init(
        @ViewBuilder canvas: () -> CanvasContent,
        tag: String,
        headline: String,
        bodyText: String,
        analogy: String,
        buttonTitle: String,
        onBegin: @escaping () -> Void
    ) {
        self.canvas = canvas()
        self.tag = tag
        self.headline = headline
        self.bodyText = bodyText
        self.analogy = analogy
        self.buttonTitle = buttonTitle
        self.onBegin = onBegin
    }

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .center, spacing: 0) {
                    Spacer(minLength: 20)

                    // ── Full-width illustration canvas ────────────────────────
                    canvas
                        .frame(maxWidth: .infinity)
                        .frame(height: max(200, min(320, geo.size.height * 0.31)))
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.03, green: 0.02, blue: 0.09),
                                    Color(red: 0.07, green: 0.04, blue: 0.18)
                                ],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.28), lineWidth: 1)
                        )
                        .shadow(color: Color(red: 0.36, green: 0.22, blue: 1.0).opacity(0.22), radius: 28, y: 10)
                        .padding(.horizontal, 16)

                    Spacer(minLength: 32)

                    // ── Chapter tag ───────────────────────────────────────────
                    Text(tag.uppercased())
                        .font(.custom("AvenirNext-DemiBold", size: 11))
                        .tracking(3.5)
                        .foregroundStyle(Color(red: 0.56, green: 0.43, blue: 0.16))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Spacer(minLength: 14)

                    // ── Headline ──────────────────────────────────────────────
                    Text(headline)
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.91, green: 0.72, blue: 0.29),
                                    Color(red: 0.63, green: 0.50, blue: 1.0),
                                    Color(red: 0.24, green: 0.84, blue: 0.75)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 22)

                    Spacer(minLength: 18)

                    // ── Body text ─────────────────────────────────────────────
                    Text(bodyText)
                        .font(.system(size: 17, weight: .light, design: .serif))
                        .foregroundStyle(Color(red: 0.87, green: 0.83, blue: 1.0).opacity(0.82))
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .frame(maxWidth: 540)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 24)

                    Spacer(minLength: 24)

                    // ── Analogy pill ──────────────────────────────────────────
                    Text(analogy)
                        .font(.system(size: 15, weight: .regular, design: .serif))
                        .italic()
                        .foregroundStyle(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.80))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.05),
                            in: Capsule(style: .continuous)
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.30), lineWidth: 1)
                        )
                        .padding(.horizontal, 24)

                    Spacer(minLength: 26)

                    // ── CTA button ────────────────────────────────────────────
                    SpellButton(title: buttonTitle, tone: .gold, isPulsing: true, action: onBegin)

                    Spacer(minLength: 36)
                }
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
    }
}
