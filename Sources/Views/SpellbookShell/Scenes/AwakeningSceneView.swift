import SwiftUI

struct AwakeningSceneView: View {
    let onActivate: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var quoteOpacity: Double = 0
    @State private var isNavigating = false
    @State private var rippleID: UUID? = nil

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("\"Intelligence is not born. It is trained.\"")
                .font(.system(size: 20, weight: .light, design: .serif))
                .italic()
                .foregroundStyle(Color(red: 0.78, green: 0.73, blue: 1.0).opacity(0.42))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
                .tracking(1.0)
                .opacity(quoteOpacity)
                .padding(.bottom, 24)

            Text("Neural Spellbook")
                .font(.system(size: 42, weight: .bold, design: .serif))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.91, green: 0.72, blue: 0.29),
                            Color(red: 0.63, green: 0.50, blue: 1.0),
                            Color(red: 0.24, green: 0.84, blue: 0.75)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .opacity(quoteOpacity)

            Text("THE LIVING NETWORK")
                .font(.custom("AvenirNext-DemiBold", size: 11))
                .tracking(7)
                .foregroundStyle(Color(red: 0.55, green: 0.43, blue: 0.16))
                .opacity(quoteOpacity)
                .padding(.bottom, 28)

            // Magic circle
            ZStack {
                if !reduceMotion {
                    MagicCircleView()
                        .frame(width: 214, height: 214)
                } else {
                    StaticMagicCircle()
                        .frame(width: 214, height: 214)
                }

                // Ripple on tap — each new UUID creates a fresh view that auto-animates on appear
                if let id = rippleID {
                    RippleCircleView()
                        .id(id)
                }
            }
            .contentShape(Circle())
            .onTapGesture {
                guard !isNavigating else { return }
                isNavigating = true
                rippleID = UUID()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    onActivate()
                }
            }
            .accessibilityLabel("Tap to begin the Neural Spellbook")
            .accessibilityAddTraits(.isButton)

            Text("✦ tap the circle to begin ✦")
                .font(.custom("AvenirNext-DemiBold", size: 11))
                .tracking(3.5)
                .foregroundStyle(Color(red: 0.36, green: 0.19, blue: 1.0).opacity(0.52))
                .textCase(.uppercase)
                .opacity(quoteOpacity)
                .padding(.top, 14)

            Spacer()
        }
        .padding(.horizontal, 20)
        .onAppear {
            withAnimation(.easeOut(duration: 1.4).delay(0.2)) {
                quoteOpacity = 1
            }
        }
    }
}

// MARK: - Ripple animation (new view per tap so onAppear always fires)

private struct RippleCircleView: View {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.70

    var body: some View {
        Circle()
            .stroke(Color(red: 0.36, green: 0.19, blue: 1.0).opacity(0.65), lineWidth: 2.5)
            .frame(width: 214, height: 214)
            .scaleEffect(scale)
            .opacity(opacity)
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(.easeOut(duration: 0.68)) {
                    scale = 2.4
                    opacity = 0
                }
            }
    }
}

// MARK: - Animated Magic Circle

private struct MagicCircleView: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                drawCircle(&ctx, size: size, t: t)
            }
        }
        .allowsHitTesting(false)
    }

    private func drawCircle(_ ctx: inout GraphicsContext, size: CGSize, t: TimeInterval) {
        let cx = size.width / 2
        let cy = size.height / 2
        let center = CGPoint(x: cx, y: cy)

        // Background glow
        ctx.fill(
            Path(ellipseIn: CGRect(x: cx - 103, y: cy - 103, width: 206, height: 206)),
            with: .radialGradient(
                Gradient(colors: [Color(red: 0.36, green: 0.19, blue: 1.0).opacity(0.28), .clear]),
                center: center, startRadius: 0, endRadius: 103
            )
        )

        // Outer ring — mana, 22s clockwise
        let p1 = CGFloat(t.truncatingRemainder(dividingBy: 22) / 22) * 450
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - 97, y: cy - 97, width: 194, height: 194)),
            with: .color(Color(red: 0.36, green: 0.19, blue: 1.0).opacity(0.5)),
            style: StrokeStyle(lineWidth: 1.1, dash: [6, 3], dashPhase: -p1)
        )

        // Middle ring — gold, 14s counter-clockwise
        let p2 = CGFloat(t.truncatingRemainder(dividingBy: 14) / 14) * 450
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - 74, y: cy - 74, width: 148, height: 148)),
            with: .color(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.30)),
            style: StrokeStyle(lineWidth: 0.65, dash: [10, 5], dashPhase: p2)
        )

        // Inner ring — spirit, 8s clockwise
        let p3 = CGFloat(t.truncatingRemainder(dividingBy: 8) / 8) * 450
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - 51, y: cy - 51, width: 102, height: 102)),
            with: .color(Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.22)),
            style: StrokeStyle(lineWidth: 0.45, dash: [3, 8], dashPhase: -p3)
        )

        // Cardinal + diagonal tick marks (fixed)
        let ticks: [(CGPoint, CGPoint)] = [
            (CGPoint(x: cx, y: cy - 97), CGPoint(x: cx, y: cy - 85)),
            (CGPoint(x: cx, y: cy + 85), CGPoint(x: cx, y: cy + 97)),
            (CGPoint(x: cx - 97, y: cy), CGPoint(x: cx - 85, y: cy)),
            (CGPoint(x: cx + 85, y: cy), CGPoint(x: cx + 97, y: cy)),
            (CGPoint(x: cx - 67, y: cy - 67), CGPoint(x: cx - 59, y: cy - 59)),
            (CGPoint(x: cx + 59, y: cy + 59), CGPoint(x: cx + 67, y: cy + 67)),
            (CGPoint(x: cx + 67, y: cy - 67), CGPoint(x: cx + 59, y: cy - 59)),
            (CGPoint(x: cx - 59, y: cy + 59), CGPoint(x: cx - 67, y: cy + 67))
        ]
        for (from, to) in ticks {
            var p = Path(); p.move(to: from); p.addLine(to: to)
            ctx.stroke(p, with: .color(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.35)), lineWidth: 0.65)
        }

        // Triangle 1 — mana, 14s counter-clockwise
        let a1 = -t.truncatingRemainder(dividingBy: 14) / 14 * .pi * 2
        var tri1 = Path()
        let t1pts = (0..<3).map { i -> CGPoint in
            let a = a1 + Double(i) * .pi * 2 / 3 - .pi / 2
            return CGPoint(x: cx + 50 * CGFloat(cos(a)), y: cy + 50 * CGFloat(sin(a)))
        }
        tri1.move(to: t1pts[0]); tri1.addLine(to: t1pts[1]); tri1.addLine(to: t1pts[2]); tri1.closeSubpath()
        ctx.stroke(tri1, with: .color(Color(red: 0.36, green: 0.19, blue: 1.0).opacity(0.32)), lineWidth: 0.85)

        // Triangle 2 — spirit, 22s clockwise, inverted
        let a2 = t.truncatingRemainder(dividingBy: 22) / 22 * .pi * 2
        var tri2 = Path()
        let t2pts = (0..<3).map { i -> CGPoint in
            let a = a2 + Double(i) * .pi * 2 / 3 + .pi / 2
            return CGPoint(x: cx + 50 * CGFloat(cos(a)), y: cy + 50 * CGFloat(sin(a)))
        }
        tri2.move(to: t2pts[0]); tri2.addLine(to: t2pts[1]); tri2.addLine(to: t2pts[2]); tri2.closeSubpath()
        ctx.stroke(tri2, with: .color(Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.22)), lineWidth: 0.65)

        // Pulsing center dot
        let phase = CGFloat(t.truncatingRemainder(dividingBy: 2.2) / 2.2) * 2 * .pi
        let r = 5.75 - 1.75 * CGFloat(cos(phase))
        let op = 0.7 + 0.3 * CGFloat((sin(phase) + 1) / 2)
        ctx.fill(
            Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
            with: .color(Color(red: 0.49, green: 0.38, blue: 1.0).opacity(Double(op)))
        )
    }
}

// MARK: - Static fallback for reduced motion

private struct StaticMagicCircle: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.36, green: 0.19, blue: 1.0).opacity(0.18))
                .frame(width: 206, height: 206)
            Circle()
                .stroke(Color(red: 0.36, green: 0.19, blue: 1.0).opacity(0.45), lineWidth: 1.1)
                .frame(width: 194, height: 194)
            Circle()
                .stroke(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.28), lineWidth: 0.7)
                .frame(width: 148, height: 148)
            Circle()
                .stroke(Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.20), lineWidth: 0.5)
                .frame(width: 102, height: 102)
            Circle()
                .fill(Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.75))
                .frame(width: 11, height: 11)
        }
        .allowsHitTesting(false)
    }
}
