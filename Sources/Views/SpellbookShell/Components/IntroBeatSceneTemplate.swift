import SwiftUI

// MARK: - Game-style level intro card

struct IntroBeatSceneTemplate<CanvasContent: View>: View {
    let canvas: CanvasContent
    let chapterNumber: Int     // 1–5
    let chapterTitle: String   // 2–4 words, ALL CAPS feel
    let missionText: String    // 1 sentence – what the user will DO
    let whyText: String        // 1 sentence – why it matters globally
    let buttonTitle: String
    let onBegin: () -> Void

    init(
        @ViewBuilder canvas: () -> CanvasContent,
        chapterNumber: Int,
        chapterTitle: String,
        missionText: String,
        whyText: String,
        buttonTitle: String,
        onBegin: @escaping () -> Void
    ) {
        self.canvas = canvas()
        self.chapterNumber = chapterNumber
        self.chapterTitle = chapterTitle
        self.missionText = missionText
        self.whyText = whyText
        self.buttonTitle = buttonTitle
        self.onBegin = onBegin
    }

    // Staggered entrance
    @State private var showCanvas  = false
    @State private var showBadge   = false
    @State private var showTitle   = false
    @State private var showMission = false
    @State private var showWhy     = false
    @State private var showButton  = false

    // Per-chapter accent palette
    private let roman  = ["I", "II", "III", "IV", "V"]
    private let accents: [Color] = [
        Color(red: 0.91, green: 0.72, blue: 0.29),  // I   gold
        Color(red: 0.85, green: 0.19, blue: 0.38),  // II  crimson
        Color(red: 1.00, green: 0.42, blue: 0.21),  // III ember
        Color(red: 0.63, green: 0.50, blue: 1.00),  // IV  mana
        Color(red: 0.24, green: 0.84, blue: 0.75),  // V   spirit
    ]

    private let spirit = Color(red: 0.24, green: 0.84, blue: 0.75)
    private let void   = Color(red: 0.03, green: 0.01, blue: 0.09)

    private var accent: Color {
        accents.indices.contains(chapterNumber - 1) ? accents[chapterNumber - 1] : accents[0]
    }
    private var numeral: String {
        roman.indices.contains(chapterNumber - 1) ? roman[chapterNumber - 1] : "I"
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {

                // ── CANVAS BLOCK (top ~44%) ────────────────────────────────
                ZStack(alignment: .topLeading) {

                    // Illustration
                    canvas
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Accent color wash
                    accent.opacity(0.05)
                        .allowsHitTesting(false)

                    // Bottom fade into content area
                    LinearGradient(
                        colors: [.clear, void],
                        startPoint: UnitPoint(x: 0.5, y: 0.65),
                        endPoint: .bottom
                    )
                    .allowsHitTesting(false)

                    // Watermark numeral — bottom-right ghost
                    Text(numeral)
                        .font(.system(size: 160, weight: .black, design: .rounded))
                        .foregroundStyle(accent.opacity(0.07))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding(.trailing, 10)
                        .padding(.bottom, -24)
                        .allowsHitTesting(false)

                    // Chapter badge — top-left
                    HStack(spacing: 7) {
                        Circle().fill(accent).frame(width: 7, height: 7)
                        Text("CHAPTER  \(numeral)")
                            .font(.custom("AvenirNext-DemiBold", size: 11))
                            .tracking(3.0)
                            .foregroundStyle(accent)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(void.opacity(0.80), in: Capsule(style: .continuous))
                    .overlay(Capsule(style: .continuous).stroke(accent.opacity(0.50), lineWidth: 1))
                    .padding(18)
                    .opacity(showBadge ? 1 : 0)
                    .offset(y: showBadge ? 0 : -10)
                    .animation(.spring(response: 0.40, dampingFraction: 0.78), value: showBadge)
                }
                .frame(maxWidth: .infinity)
                .frame(height: max(220, geo.size.height * 0.44))
                .clipped()
                .opacity(showCanvas ? 1 : 0)
                .animation(.easeIn(duration: 0.50), value: showCanvas)

                // ── CONTENT BLOCK (bottom ~56%) ────────────────────────────
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 0) {

                        // Chapter title
                        Text(chapterTitle)
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(3)
                            .padding(.horizontal, 24)
                            .padding(.top, 22)
                            .opacity(showTitle ? 1 : 0)
                            .offset(y: showTitle ? 0 : 18)
                            .animation(.spring(response: 0.50, dampingFraction: 0.76), value: showTitle)

                        Spacer(minLength: 18)

                        // Mission pill
                        IntroPill(icon: "🎯", label: "YOU WILL",
                                  body: missionText, accent: accent)
                            .padding(.horizontal, 20)
                            .opacity(showMission ? 1 : 0)
                            .offset(y: showMission ? 0 : 16)
                            .animation(.spring(response: 0.50, dampingFraction: 0.76), value: showMission)

                        Spacer(minLength: 12)

                        // Why pill
                        IntroPill(icon: "⚡", label: "WHY IT MATTERS",
                                  body: whyText, accent: spirit)
                            .padding(.horizontal, 20)
                            .opacity(showWhy ? 1 : 0)
                            .offset(y: showWhy ? 0 : 16)
                            .animation(.spring(response: 0.50, dampingFraction: 0.76), value: showWhy)

                        Spacer(minLength: 30)

                        // Big START button
                        Button(action: onBegin) {
                            HStack(spacing: 10) {
                                Text(buttonTitle)
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .black))
                            }
                            .foregroundStyle(void)
                            .padding(.vertical, 18)
                            .frame(maxWidth: .infinity)
                            .background(accent, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: accent.opacity(0.50), radius: 20, y: 6)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                        .opacity(showButton ? 1 : 0)
                        .scaleEffect(showButton ? 1 : 0.88)
                        .animation(.spring(response: 0.52, dampingFraction: 0.70), value: showButton)

                        Spacer(minLength: 48)
                    }
                }
                .scrollIndicators(.hidden)
                .background(void)
            }
        }
        .onAppear {
            // Staggered entrance — each element slides/fades in after the previous
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { showCanvas  = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) { showBadge   = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.42) { showTitle   = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.56) { showMission = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.70) { showWhy     = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.86) { showButton  = true }
        }
    }
}

// MARK: - Reusable info pill

private struct IntroPill: View {
    let icon: String
    let label: String
    let body: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(icon).font(.system(size: 14))
                Text(label)
                    .font(.custom("AvenirNext-DemiBold", size: 10))
                    .tracking(2.5)
                    .foregroundStyle(accent)
            }
            Text(body)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.white.opacity(0.88))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(accent.opacity(0.07),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(accent.opacity(0.24), lineWidth: 1)
        )
    }
}
