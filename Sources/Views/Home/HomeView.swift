import SwiftUI

struct HomeView: View {
    let onStartGuided: () -> Void
    let onStartFreePlay: () -> Void
    let onOpenHelp: () -> Void

    @State private var floating = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ParticlesBackground(density: 120, speed: 0.18)

            GeometryReader { proxy in
                let wide = proxy.size.width > 940

                VStack(spacing: 20) {
                    topHero

                    if wide {
                        HStack(spacing: 14) {
                            spellbookGlyph
                                .frame(maxWidth: proxy.size.width * 0.45)
                            modeCards
                                .frame(maxWidth: proxy.size.width * 0.5)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        VStack(spacing: 14) {
                            spellbookGlyph
                            modeCards
                        }
                    }

                    footerBar
                }
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                floating = true
            }
        }
    }

    private var topHero: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("\u{1F30C} Neural Spellbook")
                    .font(Typography.hero)
                    .foregroundStyle(.white)
                Text("The Living Network")
                    .font(Typography.title)
                    .foregroundStyle(Theme.gold)
                Text("Learn neural networks in a clear sequence: Data -> Forward -> Loss -> Backprop -> Improvement.")
                    .font(Typography.body)
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
    }

    private var modeCards: some View {
        VStack(spacing: 12) {
            GlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(
                        title: "Guided Journey (3-4 min)",
                        subtitle: "Best for first-time learners",
                        systemImage: "map"
                    )
                    Text("You get one clear next action in each chapter, plus short explanations of why each step matters.")
                        .font(Typography.body)
                        .foregroundStyle(.white.opacity(0.86))
                    PrimaryButton(title: "Start Guided Journey", systemImage: "book.fill") {
                        onStartGuided()
                    }
                }
            }

            GlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(
                        title: "Free Play Sandbox",
                        subtitle: "Best for experimenting",
                        systemImage: "wand.and.stars"
                    )
                    Text("Adjust controls, run training, inspect runes and tensors, and use diagnostics fixes when things go wrong.")
                        .font(Typography.body)
                        .foregroundStyle(.white.opacity(0.86))
                    PrimaryButton(title: "Enter Free Play", systemImage: "sparkles", prominent: false) {
                        onStartFreePlay()
                    }
                }
            }
        }
    }

    private var footerBar: some View {
        HStack {
            Button("Help & About", action: onOpenHelp)
                .buttonStyle(.bordered)
                .tint(.white)
            Spacer()
            Text("Offline. No login. No tracking.")
                .font(Typography.caption)
                .foregroundStyle(.white.opacity(0.72))
        }
    }

    private var spellbookGlyph: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [Theme.starlight.opacity(0.35), Theme.nebula.opacity(0.1)], startPoint: .top, endPoint: .bottom))
                .frame(width: 320, height: 320)
                .blur(radius: 8)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LinearGradient(colors: [Color(red: 0.28, green: 0.18, blue: 0.14), Color(red: 0.18, green: 0.11, blue: 0.10)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 250, height: 170)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Theme.gold.opacity(0.45), lineWidth: 2)
                )
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: 42, weight: .medium))
                        .foregroundStyle(Theme.gold)
                )
                .shadow(color: .black.opacity(0.35), radius: 22, x: 0, y: 14)
                .offset(y: floating ? -10 : 10)
        }
        .frame(height: 340)
    }
}
