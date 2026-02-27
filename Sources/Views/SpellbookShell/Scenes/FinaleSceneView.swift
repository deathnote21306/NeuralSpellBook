import SwiftUI

struct FinaleSceneView: View {
    let onRestart: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var orbScale = 1.0
    @State private var outerSpin = false
    @State private var innerSpin = false
    @State private var orbGlyph = "✨"
    @State private var cycleTask: Task<Void, Never>?

    private let sequence = ["🌀", "✦", "🌟", "◈", "✨", "⭐", "💫", "✦", "✨"]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Spacer(minLength: 24)

                ZStack {
                    Circle()
                        .stroke(Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.28), lineWidth: 1)
                        .frame(width: 130, height: 130)
                        .rotationEffect(.degrees(outerSpin ? 360 : 0))
                    Circle()
                        .stroke(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.18), lineWidth: 1)
                        .frame(width: 96, height: 96)
                        .rotationEffect(.degrees(innerSpin ? -360 : 0))

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.63, green: 0.50, blue: 1.0),
                                    Color(red: 0.49, green: 0.38, blue: 1.0),
                                    Color(red: 0.10, green: 0.03, blue: 0.30)
                                ],
                                center: .topLeading,
                                startRadius: 4,
                                endRadius: 52
                            )
                        )
                        .frame(width: 86, height: 86)
                        .overlay(
                            Text(orbGlyph)
                                .font(.system(size: 34))
                                .transition(.opacity)
                        )
                        .scaleEffect(orbScale)
                        .shadow(color: Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.52), radius: 26)
                }

                HStack(spacing: 8) {
                    finaleTag("◈ Converged", tint: Color(red: 0.24, green: 0.84, blue: 0.75))
                    finaleTag("Loss: 0.008", tint: Color(red: 0.24, green: 0.84, blue: 0.75))
                    finaleTag("100 Epochs", tint: Color(red: 0.63, green: 0.50, blue: 1.0))
                }
                .multilineTextAlignment(.center)

                Text("\"Intelligence is repetition\nguided by correction.\"")
                    .font(.system(size: 38, weight: .bold, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.91, green: 0.72, blue: 0.29),
                                Color(red: 0.24, green: 0.84, blue: 0.75),
                                Color(red: 0.63, green: 0.50, blue: 1.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)

                SpellPanelCard {
                    VStack(alignment: .center, spacing: 10) {
                        Text("The Spellbook Closes")
                            .font(.system(size: 11, weight: .semibold, design: .serif))
                            .tracking(2.2)
                            .foregroundStyle(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.9))

                        Text("You have witnessed the complete cycle: forward pass → loss → backprop → convergence. This loop, repeated millions of times, is what gives every AI its knowledge.")
                            .font(.system(size: 18, weight: .regular, design: .serif))
                            .foregroundStyle(.white.opacity(0.84))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                }
                .frame(maxWidth: 500)

                SpellButton(title: "✦ Read From The Beginning", tone: .gold, action: onRestart)

                Spacer(minLength: 90)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .onAppear(perform: startFinale)
        .onDisappear {
            cycleTask?.cancel()
            cycleTask = nil
        }
    }

    private func finaleTag(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.custom("AvenirNext-DemiBold", size: 11))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(tint.opacity(0.16), in: Capsule(style: .continuous))
            .overlay(
                Capsule(style: .continuous)
                    .stroke(tint.opacity(0.26), lineWidth: 1)
            )
            .foregroundStyle(.white)
    }

    private func startFinale() {
        outerSpin = false
        innerSpin = false
        orbScale = 1.0

        if !reduceMotion {
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                outerSpin = true
            }
            withAnimation(.linear(duration: 9).repeatForever(autoreverses: false)) {
                innerSpin = true
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                orbScale = 1.05
            }
        }

        cycleTask?.cancel()
        cycleTask = Task {
            let totalCycles = reduceMotion ? 4 : 15
            for index in 0..<totalCycles {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        orbGlyph = sequence[index % sequence.count]
                    }
                }
                try? await Task.sleep(nanoseconds: 260_000_000)
            }
            await MainActor.run {
                orbGlyph = "✨"
            }
        }
    }
}
