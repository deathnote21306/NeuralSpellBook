import SwiftUI

struct HyperSceneView: View {
    let onNext: () -> Void
    let onOpenModal: (SpellModalKey) -> Void
    @Binding var mathReveal: Bool

    @State private var learningRate: Double = 10
    @State private var batchSize: Double = 32
    @State private var epochs: Double = 20
    @State private var experimentMessage: String = "Adjust the sliders then cast your experiment to see the consequences of each choice..."
    @State private var curveExplanation: String = "Each point shows loss after one training epoch. A healthy curve descends smoothly toward zero."
    @State private var runePulse = false

    private var lrValueText: String {
        String(format: "%.3f", learningRate / 1000)
    }

    private var curveParameters: HyperCurveParameters {
        HyperCurveParameters(lrRaw: Int(learningRate), batchSize: Int(batchSize), epochs: Int(epochs))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Ambient background reacting to training mode
                HyperAmbientView(mode: curveParameters.mode, finalLoss: curveParameters.finalLoss)

                VStack(spacing: 0) {

                    // ── HEADER ───────────────────────────────────────────────
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("CHAPTER IV")
                                .font(.custom("AvenirNext-DemiBold", size: 9.5))
                                .tracking(3.5)
                                .foregroundStyle(Color(red: 0.56, green: 0.43, blue: 0.16))
                            Text("The Power Sliders")
                                .font(.system(size: 22, weight: .bold, design: .serif))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(red: 0.91, green: 0.72, blue: 0.29), Color(red: 0.86, green: 0.85, blue: 1.0)],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                        }
                        Spacer()
                        // Mode badge
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(curveParameters.mode.rawValue.uppercased())
                                .font(.custom("AvenirNext-DemiBold", size: 14))
                                .foregroundStyle(tagTint)
                            Text(String(format: "Final Loss: %.3f", curveParameters.finalLoss))
                                .font(.custom("AvenirNext-DemiBold", size: 11))
                                .foregroundStyle(.white.opacity(0.40))
                        }
                        .animation(.easeInOut(duration: 0.25), value: curveParameters.mode.rawValue)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 10)

                    // ── SLIDERS ───────────────────────────────────────────────
                    VStack(spacing: 10) {
                        hyperSlider(name: "✦ Learning Rate", valueText: lrValueText,
                                    value: $learningRate, range: 1...100,
                                    tint: Color(red: 0.63, green: 0.50, blue: 1.0))
                        hyperSlider(name: "◈ Batch Size", valueText: "\(Int(batchSize))",
                                    value: $batchSize, range: 1...128,
                                    tint: Color(red: 0.24, green: 0.84, blue: 0.75))
                        hyperSlider(name: "⟳ Epochs", valueText: "\(Int(epochs))",
                                    value: $epochs, range: 1...200,
                                    tint: Color(red: 0.91, green: 0.72, blue: 0.29))
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 10)

                    // ── LOSS CURVE — HERO ─────────────────────────────────────
                    HyperLossCurveView(parameters: curveParameters)
                        .padding(.horizontal, 14)
                        .frame(height: max(120, geo.size.height * 0.30))
                        .padding(.bottom, 10)

                    // ── OBSERVATION ───────────────────────────────────────────
                    Text(experimentMessage)
                        .font(.system(size: 15, weight: .regular, design: .serif))
                        .foregroundStyle(.white.opacity(0.82))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 22)
                        .lineSpacing(3)
                        .padding(.bottom, 6)
                        .animation(.easeInOut(duration: 0.3), value: experimentMessage)

                    if mathReveal {
                        Text("mode=\(curveParameters.mode.rawValue) · finalLoss=\(String(format: "%.3f", curveParameters.finalLoss)) · noise=\(String(format: "%.3f", curveParameters.noiseAmplitude)) · decay=\(String(format: "%.2f", curveParameters.decayRate))")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.80))
                            .padding(.horizontal, 18)
                            .padding(.bottom, 6)
                    }

                    Spacer(minLength: 0)

                    // ── BOTTOM CONTROLS ───────────────────────────────────────
                    HStack(spacing: 10) {
                        SpellButton(title: "✦ What Do These Mean?", tone: .gold) { onOpenModal(.hyper) }
                        SpellButton(title: "⚡ Run Experiment", tone: .mana) { runExperiment() }
                        Spacer()
                        SpellButton(title: "Inspect the Runes →", tone: .spirit, isPulsing: true) { onNext() }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 90)
                }
            }
        }
        .onAppear {
            updatePreview()
            withAnimation(.easeInOut(duration: 1.7).repeatForever(autoreverses: true)) { runePulse = true }
        }
        .onChange(of: learningRate) { _, _ in updatePreview() }
        .onChange(of: batchSize) { _, _ in updatePreview() }
        .onChange(of: epochs) { _, _ in updatePreview() }
    }

    private var tagTint: Color {
        switch curveParameters.mode {
        case .explode: return Color(red: 0.85, green: 0.19, blue: 0.38)
        case .slow: return Color(red: 0.91, green: 0.72, blue: 0.29)
        case .normal: return curveParameters.finalLoss < 0.05 ? Color(red: 0.24, green: 0.84, blue: 0.75) : Color(red: 0.91, green: 0.72, blue: 0.29)
        }
    }

    private func hyperSlider(
        name: String,
        valueText: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        tint: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name)
                    .font(.system(size: 11, weight: .semibold, design: .serif))
                    .tracking(1.4)
                    .foregroundStyle(.white.opacity(0.88))
                Spacer()
                Text(valueText)
                    .font(.custom("AvenirNext-DemiBold", size: 14))
                    .foregroundStyle(Color(red: 0.91, green: 0.72, blue: 0.29))
            }

            Slider(value: value, in: range, step: 1)
                .tint(tint)

            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [tint.opacity(0.16), tint.opacity(0.02)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 6)
                .overlay(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(tint.opacity(0.9))
                        .frame(width: sliderFill(value: value.wrappedValue, range: range))
                }
        }
    }

    private func sliderFill(value: Double, range: ClosedRange<Double>) -> CGFloat {
        let span = max(1, range.upperBound - range.lowerBound)
        return CGFloat((value - range.lowerBound) / span) * 220
    }

    private func hyperTag(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.custom("AvenirNext-DemiBold", size: 11))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint.opacity(0.14), in: Capsule(style: .continuous))
            .overlay(
                Capsule(style: .continuous)
                    .stroke(tint.opacity(0.26), lineWidth: 1)
            )
    }

    private func updatePreview() {
        switch curveParameters.mode {
        case .explode:
            curveExplanation = "Chaotic curve: each weight update jumps past the optimum and makes things worse. Lower learning rate below 0.070."
        case .slow:
            curveExplanation = "Nearly flat curve: gradient steps exist but are too small. The ritual needs far more epochs to converge."
        case .normal:
            curveExplanation = "Each point shows loss after one training epoch. A healthy curve descends smoothly toward zero."
        }
    }

    private func runExperiment() {
        let lr = learningRate / 1000
        let params = curveParameters

        switch params.mode {
        case .explode:
            experimentMessage = "💥 Learning rate \(String(format: "%.3f", lr)) is too high. The optimizer overshoots the minimum on every step, so the loss oscillates and diverges."
            curveExplanation = "Chaotic curve: each weight update jumps past the optimum and makes things worse. Lower learning rate below 0.070."

        case .slow:
            let needed = max(1, Int(round((6 / max(learningRate, 1)) * epochs)))
            experimentMessage = "🌑 Learning rate \(String(format: "%.3f", lr)) is too low. After \(Int(epochs)) epochs the curve barely moved and would need roughly \(needed) effective epochs to converge."
            curveExplanation = "Nearly flat curve: gradient steps exist but are too small. Final loss \(String(format: "%.3f", params.finalLoss)) is still far from zero."

        case .normal:
            let batchQuality = batchSize < 8 ? "very noisy" : (batchSize < 24 ? "noisy" : (batchSize < 64 ? "balanced" : "stable"))
            let epochQuality = epochs < 15 ? "too few" : (epochs < 60 ? "moderate" : "ample")
            let quality = params.finalLoss < 0.05 ? "🟢 Excellent" : (params.finalLoss < 0.15 ? "🟡 Good" : "🟠 Moderate")
            experimentMessage = "\(quality) — lr=\(String(format: "%.3f", lr)), batch=\(Int(batchSize)) (\(batchQuality)), \(Int(epochs)) epochs (\(epochQuality)) → final loss \(String(format: "%.3f", params.finalLoss))"
            curveExplanation = "Speed \(String(format: "%.2f", params.decayRate)) · Noise \(String(format: "%.1f", params.noiseAmplitude * 100))%. \(batchSize < 8 ? "Small focus produces a jagged curve." : batchSize < 24 ? "Medium focus keeps some jitter alive." : "Large focus smooths the descent.")"
        }
    }
}

private struct HyperAmbientView: View {
    let mode: HyperCurveMode
    let finalLoss: Double

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                let pulse = CGFloat(0.78 + 0.22 * sin(t * 0.65))
                let modeColor: Color = mode == .explode
                    ? Color(red: 0.85, green: 0.19, blue: 0.38)
                    : mode == .slow
                    ? Color(red: 0.91, green: 0.72, blue: 0.29)
                    : (finalLoss < 0.08 ? Color(red: 0.24, green: 0.84, blue: 0.75) : Color(red: 0.63, green: 0.50, blue: 1.0))

                ctx.fill(
                    Path(ellipseIn: CGRect(x: -size.width * 0.05, y: size.height * 0.20,
                                           width: size.width * 0.65, height: size.height * 0.70)),
                    with: .radialGradient(
                        Gradient(colors: [modeColor.opacity(0.08 * pulse), .clear]),
                        center: CGPoint(x: size.width * 0.10, y: size.height * 0.60),
                        startRadius: 0, endRadius: size.width * 0.42
                    )
                )
                ctx.fill(
                    Path(ellipseIn: CGRect(x: size.width * 0.55, y: -size.height * 0.10,
                                           width: size.width * 0.55, height: size.height * 0.45)),
                    with: .radialGradient(
                        Gradient(colors: [Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.06 * pulse), .clear]),
                        center: CGPoint(x: size.width * 0.88, y: 0),
                        startRadius: 0, endRadius: size.width * 0.34
                    )
                )
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

private struct HyperLossCurveView: View {
    let parameters: HyperCurveParameters

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 0.014, green: 0.010, blue: 0.048).opacity(0.92))
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)

                Canvas { context, _ in
                    let points = parameters.makePoints(in: size)
                    drawGrid(context: &context, size: size)
                    drawCurve(context: &context, points: points, size: size)
                }
            }
        }
    }

    private func drawGrid(context: inout GraphicsContext, size: CGSize) {
        for index in 1..<4 {
            let y = size.height * CGFloat(index) / 4
            var line = Path()
            line.move(to: CGPoint(x: 0, y: y))
            line.addLine(to: CGPoint(x: size.width, y: y))
            context.stroke(line, with: .color(Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.08)), lineWidth: 0.5)

            let x = size.width * CGFloat(index) / 4
            var vertical = Path()
            vertical.move(to: CGPoint(x: x, y: 0))
            vertical.addLine(to: CGPoint(x: x, y: size.height))
            context.stroke(vertical, with: .color(Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.08)), lineWidth: 0.5)
        }

        context.draw(
            Text("LOSS").font(.custom("AvenirNext-DemiBold", size: 8)).foregroundStyle(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.35)),
            at: CGPoint(x: 8, y: 10),
            anchor: .leading
        )
        context.draw(
            Text("EPOCHS →").font(.custom("AvenirNext-DemiBold", size: 8)).foregroundStyle(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.35)),
            at: CGPoint(x: size.width - 6, y: size.height - 4),
            anchor: .trailing
        )
    }

    private func drawCurve(context: inout GraphicsContext, points: [CGPoint], size: CGSize) {
        guard let last = points.last else { return }

        var area = Path()
        area.move(to: CGPoint(x: 0, y: size.height))
        for point in points {
            area.addLine(to: point)
        }
        area.addLine(to: CGPoint(x: size.width, y: size.height))
        area.closeSubpath()
        context.fill(
            area,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.85, green: 0.19, blue: 0.38).opacity(0.12),
                    Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.02)
                ]),
                startPoint: CGPoint(x: size.width / 2, y: 0),
                endPoint: CGPoint(x: size.width / 2, y: size.height)
            )
        )

        var curve = Path()
        for (index, point) in points.enumerated() {
            if index == 0 {
                curve.move(to: point)
            } else {
                curve.addLine(to: point)
            }
        }

        context.stroke(
            curve,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.85, green: 0.19, blue: 0.38),
                    Color(red: 0.91, green: 0.72, blue: 0.29),
                    Color(red: 0.24, green: 0.84, blue: 0.75)
                ]),
                startPoint: .zero,
                endPoint: CGPoint(x: size.width, y: 0)
            ),
            lineWidth: 2.2
        )

        let dotColor: Color = parameters.finalLoss < 0.06 ? Color(red: 0.24, green: 0.84, blue: 0.75) : (parameters.finalLoss < 0.25 ? Color(red: 0.91, green: 0.72, blue: 0.29) : Color(red: 0.85, green: 0.19, blue: 0.38))
        context.fill(
            Path(ellipseIn: CGRect(x: last.x - 7, y: last.y - 7, width: 14, height: 14)),
            with: .radialGradient(
                Gradient(colors: [dotColor.opacity(0.75), .clear]),
                center: last,
                startRadius: 0,
                endRadius: 7
            )
        )
        context.fill(Path(ellipseIn: CGRect(x: last.x - 3, y: last.y - 3, width: 6, height: 6)), with: .color(dotColor))
        context.draw(
            Text("Final: \(String(format: "%.3f", parameters.finalLoss))")
                .font(.custom("AvenirNext-DemiBold", size: 9))
                .foregroundStyle(dotColor),
            at: CGPoint(x: size.width - 6, y: max(12, last.y - 10)),
            anchor: .trailing
        )
    }
}

private enum HyperCurveMode: String {
    case explode
    case slow
    case normal
}

private struct HyperCurveParameters {
    let lrRaw: Int
    let batchSize: Int
    let epochs: Int
    let mode: HyperCurveMode
    let finalLoss: Double
    let noiseAmplitude: Double
    let decayRate: Double

    init(lrRaw: Int, batchSize: Int, epochs: Int) {
        self.lrRaw = lrRaw
        self.batchSize = batchSize
        self.epochs = epochs

        if lrRaw > 70 {
            mode = .explode
            finalLoss = 0.6 + Double(lrRaw - 70) / 100
            noiseAmplitude = 0.3 + Double(lrRaw - 70) / 150
            decayRate = 0
        } else if lrRaw < 6 {
            mode = .slow
            decayRate = Double(lrRaw) / 6 * 0.8
            noiseAmplitude = 0.008
            finalLoss = max(0.55, 0.92 - Double(epochs) * decayRate * 0.003)
        } else {
            mode = .normal
            decayRate = Double(lrRaw - 6) / 64 * 5.0
            if batchSize < 6 {
                noiseAmplitude = 0.18
            } else if batchSize < 16 {
                noiseAmplitude = 0.10
            } else if batchSize < 40 {
                noiseAmplitude = 0.04
            } else {
                noiseAmplitude = 0.008
            }
            let bsBonus = log(Double(batchSize + 1)) / log(129) * 0.12
            let convergence = 1 - exp(-decayRate * (Double(epochs) / 50))
            finalLoss = max(0.015, (0.88 - bsBonus) * (1 - convergence) + 0.015)
        }
    }

    func makePoints(in size: CGSize) -> [CGPoint] {
        let seed = UInt64(max(1, lrRaw * 31 + batchSize * 17 + epochs * 13 + Int(finalLoss * 1000) * 7))
        var rng = SeededRandom(seed: seed)
        let pointCount = 140

        return (0...pointCount).map { index in
            let t = Double(index) / Double(pointCount)
            let random = Double(rng.nextFloat(in: -1...1))
            let loss: Double

            switch mode {
            case .explode:
                let base = 0.5 + noiseAmplitude * 1.2 * sin(t * 22 + 0.8) * exp(t * 0.8)
                loss = min(1.0, max(0.05, base + random * noiseAmplitude * 0.6))

            case .slow:
                let decay = 0.88 * exp(-decayRate * t * (Double(epochs) / 100)) + finalLoss * 0.12
                loss = min(1.0, max(0.01, decay + random * noiseAmplitude))

            case .normal:
                let noiseScale = noiseAmplitude * exp(-t * 2.5) + noiseAmplitude * 0.15
                let envelope = (0.88 - finalLoss) * exp(-decayRate * t) + finalLoss
                loss = min(1.0, max(0.01, envelope + random * noiseScale * 2))
            }

            return CGPoint(
                x: CGFloat(t) * size.width,
                y: size.height - CGFloat(loss) * size.height * 0.90 - 5
            )
        }
    }
}
