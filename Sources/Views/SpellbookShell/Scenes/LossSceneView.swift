import SwiftUI

struct LossSceneView: View {
    let onNext: () -> Void
    let onOpenModal: (SpellModalKey) -> Void

    @State private var predictedValue: Double = 0.27
    private let truthValue: Double = 1.00

    private var loss: Double { pow(truthValue - predictedValue, 2) }

    private var meterColor: Color {
        if loss < 0.06 { return Color(red: 0.24, green: 0.84, blue: 0.75) }
        if loss < 0.25 { return Color(red: 0.91, green: 0.72, blue: 0.29) }
        return Color(red: 0.85, green: 0.19, blue: 0.38)
    }

    private var meterMessage: String {
        if loss < 0.06 { return "Loss is near zero — convergence achieved!" }
        if loss < 0.25 { return "Getting closer. Drag prediction toward 1.00." }
        return "High error. Drag prediction right toward truth."
    }

    private var verdict: String {
        if loss < 0.01 { return "✓ Near-perfect. This is convergence." }
        if loss < 0.06 { return "✓ Excellent — a trained network looks like this." }
        if loss < 0.15 { return "△ Improving. Keep moving toward truth." }
        if loss < 0.35 { return "✕ Significant error. Learning is needed." }
        return "✕ Catastrophic. Far from truth."
    }

    private var dynamicFormula: String {
        let error = truthValue - predictedValue
        return "Loss = (Truth − Pred)²\n= (\(String(format: "%.2f", truthValue)) − \(String(format: "%.2f", predictedValue)))²\n= (\(String(format: "%.3f", error)))²\n= \(String(format: "%.4f", loss))"
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Animated ambient background reacting to loss
                LossAmbientBackgroundView(loss: loss)

                VStack(spacing: 0) {

                    // ── HEADER ────────────────────────────────────────────────
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("CHAPTER II")
                                .font(.custom("AvenirNext-DemiBold", size: 9.5))
                                .tracking(3.5)
                                .foregroundStyle(Color(red: 0.56, green: 0.43, blue: 0.16))
                            Text("The Spell Fails — Loss")
                                .font(.system(size: 22, weight: .bold, design: .serif))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(red: 0.91, green: 0.72, blue: 0.29), Color(red: 0.86, green: 0.85, blue: 1.0)],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                        }
                        Spacer()
                        // Giant live loss number
                        VStack(alignment: .trailing, spacing: 1) {
                            Text(String(format: "%.4f", loss))
                                .font(.system(size: 36, weight: .bold, design: .monospaced))
                                .foregroundStyle(meterColor)
                                .animation(.linear(duration: 0.08), value: loss)
                            Text("LOSS")
                                .font(.custom("AvenirNext-DemiBold", size: 9))
                                .tracking(3)
                                .foregroundStyle(.white.opacity(0.30))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 10)

                    // ── INSTRUCTION ───────────────────────────────────────────
                    HStack {
                        Text("⚠  DRAG THE PREDICTION — FEEL THE LOSS CHANGE")
                            .font(.custom("AvenirNext-DemiBold", size: 11))
                            .tracking(1.4)
                            .foregroundStyle(meterColor.opacity(0.88))
                        Spacer()
                        Text(verdict)
                            .font(.custom("AvenirNext-DemiBold", size: 11))
                            .tracking(0.5)
                            .foregroundStyle(meterColor.opacity(0.88))
                            .animation(.easeInOut(duration: 0.3), value: verdict)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)

                    // ── HERO: INTERACTIVE BARS ────────────────────────────────
                    LossBarsInteractiveView(predictedValue: $predictedValue, truthValue: truthValue)
                        .padding(.horizontal, 14)

                    // ── STATS ROW ─────────────────────────────────────────────
                    HStack(spacing: 0) {
                        lossStatCell(label: "PREDICTED", value: String(format: "%.2f", predictedValue), color: meterColor)
                        Spacer()
                        lossStatCell(label: "LOSS", value: String(format: "%.4f", loss), color: meterColor)
                        Spacer()
                        lossStatCell(label: "TRUTH", value: "1.00", color: Color(red: 0.24, green: 0.84, blue: 0.75))
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .animation(.linear(duration: 0.08), value: predictedValue)

                    // ── INSTABILITY METER ─────────────────────────────────────
                    LossInstabilityMeterView(loss: loss, meterColor: meterColor)
                        .padding(.horizontal, 14)
                        .padding(.bottom, 4)

                    Text(meterMessage)
                        .font(.custom("AvenirNext-Regular", size: 13))
                        .foregroundStyle(.white.opacity(0.55))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)

                    // ── LOSS LANDSCAPE ────────────────────────────────────────
                    LossLandscapeCanvasView(
                        predictedValue: predictedValue,
                        truthValue: truthValue,
                        loss: loss
                    )
                    .padding(.horizontal, 14)
                    .frame(height: max(90, geo.size.height * 0.16))
                    .padding(.bottom, 10)

                    Spacer(minLength: 0)

                    // ── BOTTOM ROW: FORMULA + CONTROLS ───────────────────────
                    HStack(alignment: .top, spacing: 12) {
                        // Live formula block
                        VStack(alignment: .leading, spacing: 4) {
                            Text("⟳ LIVE FORMULA")
                                .font(.custom("AvenirNext-DemiBold", size: 9))
                                .tracking(1.6)
                                .foregroundStyle(Color(red: 0.63, green: 0.50, blue: 1.0).opacity(0.80))
                            Text(dynamicFormula)
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundStyle(Color(red: 0.63, green: 0.50, blue: 1.0))
                                .lineSpacing(3)
                                .animation(.linear(duration: 0.08), value: predictedValue)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.07),
                            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.22), lineWidth: 1)
                        )

                        // Action buttons
                        VStack(spacing: 8) {
                            SpellButton(title: "✦ Deep Dive", tone: .gold) {
                                onOpenModal(.loss)
                            }
                            SpellButton(title: "Perform the Ritual →", tone: .spirit, isPulsing: true) {
                                onNext()
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 90)
                }
            }
        }
    }

    @ViewBuilder
    private func lossStatCell(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.custom("AvenirNext-DemiBold", size: 9))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.35))
        }
    }
}

// MARK: - Animated ambient background

private struct LossAmbientBackgroundView: View {
    let loss: Double

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                drawAmbient(&ctx, size: size, t: t, loss: loss)
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    private func drawAmbient(_ ctx: inout GraphicsContext, size: CGSize, t: TimeInterval, loss: Double) {
        let pulse = CGFloat(0.80 + 0.20 * sin(t * 0.65))
        let lossColor: Color = loss < 0.06
            ? Color(red: 0.24, green: 0.84, blue: 0.75)
            : loss < 0.25
            ? Color(red: 0.91, green: 0.72, blue: 0.29)
            : Color(red: 0.85, green: 0.19, blue: 0.38)

        // Primary loss-reactive orb (bottom left)
        ctx.fill(
            Path(ellipseIn: CGRect(x: -size.width * 0.15, y: size.height * 0.38,
                                   width: size.width * 0.70, height: size.height * 0.70)),
            with: .radialGradient(
                Gradient(colors: [lossColor.opacity(0.10 * pulse), .clear]),
                center: CGPoint(x: size.width * 0.12, y: size.height * 0.72),
                startRadius: 0, endRadius: size.width * 0.48
            )
        )

        // Secondary mana accent (top right)
        ctx.fill(
            Path(ellipseIn: CGRect(x: size.width * 0.50, y: -size.height * 0.10,
                                   width: size.width * 0.60, height: size.height * 0.45)),
            with: .radialGradient(
                Gradient(colors: [Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.06 * pulse), .clear]),
                center: CGPoint(x: size.width * 0.88, y: 0),
                startRadius: 0, endRadius: size.width * 0.36
            )
        )

        // Subtle horizontal scan line at loss level
        let scanY = size.height * 0.30 + CGFloat(loss) * size.height * 0.20
        var scanLine = Path()
        scanLine.move(to: CGPoint(x: 0, y: scanY))
        scanLine.addLine(to: CGPoint(x: size.width, y: scanY))
        ctx.stroke(scanLine, with: .color(lossColor.opacity(0.04 * pulse)), lineWidth: 1)
    }
}

// MARK: - Instability meter (extracted)

private struct LossInstabilityMeterView: View {
    let loss: Double
    let meterColor: Color

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("INSTABILITY")
                    .font(.custom("AvenirNext-DemiBold", size: 9))
                    .tracking(2.5)
                    .foregroundStyle(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.65))
                Spacer()
                Text("Perfect ← → Worst")
                    .font(.custom("AvenirNext-DemiBold", size: 9))
                    .tracking(1)
                    .foregroundStyle(.white.opacity(0.28))
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(.white.opacity(0.06))
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: loss < 0.06
                                    ? [Color(red: 0.24, green: 0.84, blue: 0.75), Color(red: 0.24, green: 0.84, blue: 0.75)]
                                    : loss < 0.25
                                    ? [Color(red: 0.91, green: 0.72, blue: 0.29), Color(red: 1.0, green: 0.42, blue: 0.21)]
                                    : [Color(red: 1.0, green: 0.42, blue: 0.21), Color(red: 0.85, green: 0.19, blue: 0.38)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, min(1, loss)) * proxy.size.width)
                        .shadow(color: meterColor.opacity(0.40), radius: 6, x: 0, y: 0)
                }
            }
            .frame(height: 8)
            .animation(.linear(duration: 0.10), value: loss)
        }
    }
}

// MARK: - Horizontal bars interactive canvas

private struct LossBarsInteractiveView: View {
    @Binding var predictedValue: Double
    let truthValue: Double

    private let padL: CGFloat = 96
    private let padR: CGFloat = 52
    private let barH: CGFloat = 38
    private let spacing: CGFloat = 32

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let barW = max(1, size.width - padL - padR)
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(red: 0.014, green: 0.010, blue: 0.048).opacity(0.92))
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                Canvas { context, _ in
                    drawBars(context: &context, size: size)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let localX = value.location.x - padL
                        predictedValue = max(0.01, min(0.99, Double(localX / barW)))
                    }
            )
        }
        .frame(height: 220)
    }

    private func drawBars(context: inout GraphicsContext, size: CGSize) {
        let barW = size.width - padL - padR
        let totalH = 2 * barH + spacing
        let ty = (size.height - totalH) / 2 - 8
        let py = ty + barH + spacing

        let loss = pow(1.0 - predictedValue, 2)
        let col: Color = loss < 0.05 ? Color(red: 0.24, green: 0.84, blue: 0.75)
                       : loss < 0.20 ? Color(red: 0.91, green: 0.72, blue: 0.29)
                       : Color(red: 0.85, green: 0.19, blue: 0.38)
        let tc = Color(red: 0.24, green: 0.84, blue: 0.75)

        // — TRUTH bar (full) —
        let trect = CGRect(x: padL, y: ty, width: barW, height: barH)
        context.fill(Path(roundedRect: trect, cornerRadius: 7), with: .color(tc.opacity(0.07)))
        context.fill(
            Path(roundedRect: trect, cornerRadius: 7),
            with: .linearGradient(
                Gradient(colors: [tc.opacity(0.94), tc.opacity(0.50)]),
                startPoint: CGPoint(x: padL, y: 0),
                endPoint: CGPoint(x: padL + barW, y: 0)
            )
        )
        context.stroke(Path(roundedRect: trect, cornerRadius: 7),
                       with: .color(tc.opacity(0.40)), lineWidth: 1.5)
        // Sheen on truth bar
        context.fill(
            Path(roundedRect: CGRect(x: padL + 4, y: ty + 3, width: barW - 8, height: barH * 0.28), cornerRadius: 3),
            with: .color(.white.opacity(0.08))
        )

        context.draw(
            Text("TRUTH").font(.custom("AvenirNext-DemiBold", size: 10)).foregroundStyle(tc.opacity(0.70)),
            at: CGPoint(x: padL / 2, y: ty + barH / 2), anchor: .center
        )
        context.draw(
            Text("1.00").font(.custom("AvenirNext-DemiBold", size: 14)).foregroundStyle(tc.opacity(0.92)),
            at: CGPoint(x: padL + barW + padR / 2, y: ty + barH / 2), anchor: .center
        )

        // — PREDICTED bar (variable) —
        let predW = max(10, CGFloat(predictedValue) * barW)
        let ptrack = CGRect(x: padL, y: py, width: barW, height: barH)
        let pfill  = CGRect(x: padL, y: py, width: predW, height: barH)
        context.fill(Path(roundedRect: ptrack, cornerRadius: 7), with: .color(col.opacity(0.07)))
        context.fill(
            Path(roundedRect: pfill, cornerRadius: 7),
            with: .linearGradient(
                Gradient(colors: [col.opacity(0.94), col.opacity(0.52)]),
                startPoint: CGPoint(x: padL, y: 0),
                endPoint: CGPoint(x: padL + predW, y: 0)
            )
        )
        context.stroke(Path(roundedRect: ptrack, cornerRadius: 7),
                       with: .color(col.opacity(0.28)), lineWidth: 1.5)
        // Sheen on predicted bar
        if predW > 12 {
            context.fill(
                Path(roundedRect: CGRect(x: padL + 4, y: py + 3, width: predW - 8, height: barH * 0.28), cornerRadius: 3),
                with: .color(.white.opacity(0.08))
            )
        }

        context.draw(
            Text("PREDICTED").font(.custom("AvenirNext-DemiBold", size: 10)).foregroundStyle(col.opacity(0.70)),
            at: CGPoint(x: padL / 2, y: py + barH / 2), anchor: .center
        )
        context.draw(
            Text(String(format: "%.2f", predictedValue)).font(.custom("AvenirNext-DemiBold", size: 14)).foregroundStyle(col.opacity(0.92)),
            at: CGPoint(x: padL + barW + padR / 2, y: py + barH / 2), anchor: .center
        )

        // Drag handle
        let hx = padL + predW
        let hy = py + barH / 2
        context.fill(
            Path(ellipseIn: CGRect(x: hx - 16, y: hy - 16, width: 32, height: 32)),
            with: .radialGradient(
                Gradient(colors: [col.opacity(0.50), .clear]),
                center: CGPoint(x: hx, y: hy), startRadius: 0, endRadius: 16
            )
        )
        context.fill(Path(ellipseIn: CGRect(x: hx - 6, y: hy - 6, width: 12, height: 12)),
                     with: .color(col))
        context.stroke(Path(ellipseIn: CGRect(x: hx - 6, y: hy - 6, width: 12, height: 12)),
                       with: .color(.white.opacity(0.88)), lineWidth: 1.8)

        // Error gap visualization
        if loss > 0.003 {
            let errorX = padL + predW
            let errorEndX = padL + barW
            if errorEndX > errorX + 8 {
                let errW = errorEndX - errorX
                context.fill(
                    Path(roundedRect: CGRect(x: errorX, y: ty + 1, width: errW, height: barH - 2), cornerRadius: 4),
                    with: .color(col.opacity(0.14))
                )
                context.stroke(
                    Path(roundedRect: CGRect(x: errorX + 1, y: ty + 2, width: errW - 2, height: barH - 4), cornerRadius: 3),
                    with: .color(col.opacity(0.55)),
                    style: StrokeStyle(lineWidth: 1.2, dash: [4, 3])
                )
                let midErrX = errorX + errW / 2
                var conn = Path()
                conn.move(to: CGPoint(x: midErrX, y: ty + barH))
                conn.addLine(to: CGPoint(x: midErrX, y: py))
                context.stroke(conn, with: .color(col.opacity(0.32)),
                               style: StrokeStyle(lineWidth: 1.2, dash: [3, 3]))
                context.draw(
                    Text(String(format: "Δ %.3f", loss))
                        .font(.custom("AvenirNext-DemiBold", size: 10))
                        .foregroundStyle(col.opacity(0.90)),
                    at: CGPoint(x: midErrX, y: ty + barH + spacing / 2), anchor: .center
                )
            }
        } else {
            context.draw(
                Text("✓ Perfect").font(.custom("AvenirNext-DemiBold", size: 11)).foregroundStyle(tc.opacity(0.92)),
                at: CGPoint(x: padL + barW * 0.75, y: ty + barH + spacing / 2), anchor: .center
            )
        }

        context.draw(
            Text("← drag anywhere to adjust prediction →")
                .font(.custom("AvenirNext-Regular", size: 8))
                .foregroundStyle(.white.opacity(0.16)),
            at: CGPoint(x: padL + barW / 2, y: size.height - 6), anchor: .center
        )
    }
}

// MARK: - Loss landscape

private struct LossLandscapeCanvasView: View {
    let predictedValue: Double
    let truthValue: Double
    let loss: Double

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(red: 0.014, green: 0.010, blue: 0.048).opacity(0.88))
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                Canvas { context, _ in
                    drawLandscape(context: &context, size: size)
                }
            }
        }
    }

    private func drawLandscape(context: inout GraphicsContext, size: CGSize) {
        let pad: (l: CGFloat, r: CGFloat, t: CGFloat, b: CGFloat) = (24, 12, 12, 22)
        let width  = max(40, size.width - pad.l - pad.r)
        let height = max(20, size.height - pad.t - pad.b)

        // Axis labels
        context.draw(Text("loss").font(.custom("AvenirNext-DemiBold", size: 8)).foregroundStyle(.white.opacity(0.22)),
                     at: CGPoint(x: pad.l - 3, y: pad.t + 8), anchor: .trailing)
        context.draw(Text("prediction →").font(.custom("AvenirNext-DemiBold", size: 8)).foregroundStyle(.white.opacity(0.18)),
                     at: CGPoint(x: pad.l + width / 2, y: size.height - 3))

        // Axis lines
        var axis = Path()
        axis.move(to: CGPoint(x: pad.l, y: pad.t))
        axis.addLine(to: CGPoint(x: pad.l, y: pad.t + height))
        axis.addLine(to: CGPoint(x: pad.l + width, y: pad.t + height))
        context.stroke(axis, with: .color(.white.opacity(0.08)), lineWidth: 1)

        // Build curve points
        var pts: [CGPoint] = []
        for step in 0...100 {
            let t = Double(step) / 100
            let x = pad.l + width * CGFloat(t)
            let sampleLoss = pow(truthValue - t, 2)
            let y = pad.t + height - height * CGFloat(sampleLoss) * 0.92
            pts.append(CGPoint(x: x, y: y))
        }

        // Area fill under curve
        var area = Path()
        area.move(to: CGPoint(x: pad.l, y: pad.t + height))
        for pt in pts { area.addLine(to: pt) }
        area.addLine(to: CGPoint(x: pad.l + width, y: pad.t + height))
        area.closeSubpath()
        context.fill(area, with: .linearGradient(
            Gradient(colors: [
                Color(red: 0.85, green: 0.19, blue: 0.38).opacity(0.14),
                Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.08),
                Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.12)
            ]),
            startPoint: CGPoint(x: pad.l, y: 0),
            endPoint: CGPoint(x: pad.l + width, y: 0)
        ))

        // Curve stroke
        var curve = Path()
        curve.move(to: pts[0])
        for pt in pts.dropFirst() { curve.addLine(to: pt) }
        context.stroke(
            curve,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.85, green: 0.19, blue: 0.38).opacity(0.85),
                    Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.75),
                    Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.92)
                ]),
                startPoint: CGPoint(x: pad.l, y: 0),
                endPoint: CGPoint(x: pad.l + width, y: 0)
            ),
            lineWidth: 2.5
        )

        // User's position dot
        let dotX = pad.l + width * CGFloat(predictedValue)
        let dotY = pad.t + height - height * CGFloat(loss) * 0.92
        let dotPoint = CGPoint(x: dotX, y: dotY)
        let dotColor = loss < 0.05 ? Color(red: 0.24, green: 0.84, blue: 0.75)
                     : loss < 0.20 ? Color(red: 0.91, green: 0.72, blue: 0.29)
                     : Color(red: 0.85, green: 0.19, blue: 0.38)

        // Drop line
        var drop = Path()
        drop.move(to: dotPoint)
        drop.addLine(to: CGPoint(x: dotX, y: pad.t + height))
        context.stroke(drop, with: .color(dotColor.opacity(0.22)),
                       style: StrokeStyle(lineWidth: 1, dash: [2, 2]))

        // Dot glow
        context.fill(
            Path(ellipseIn: CGRect(x: dotX - 18, y: dotY - 18, width: 36, height: 36)),
            with: .radialGradient(
                Gradient(colors: [dotColor.opacity(0.70), .clear]),
                center: dotPoint, startRadius: 0, endRadius: 18
            )
        )
        // Dot core
        context.fill(
            Path(ellipseIn: CGRect(x: dotX - 5, y: dotY - 5, width: 10, height: 10)),
            with: .color(dotColor)
        )
        context.stroke(
            Path(ellipseIn: CGRect(x: dotX - 5, y: dotY - 5, width: 10, height: 10)),
            with: .color(.white.opacity(0.80)), lineWidth: 1.5
        )

        // Loss annotation next to dot
        if loss > 0.02 {
            context.draw(
                Text(String(format: "%.3f", loss))
                    .font(.custom("AvenirNext-DemiBold", size: 9))
                    .foregroundStyle(dotColor.opacity(0.85)),
                at: CGPoint(x: dotX + 14, y: dotY - 4)
            )
        }

        // Global minimum marker
        let minX = pad.l + width * CGFloat(truthValue)
        context.draw(
            Text("min").font(.custom("AvenirNext-DemiBold", size: 8)).foregroundStyle(Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.50)),
            at: CGPoint(x: minX, y: pad.t + height - 4), anchor: .center
        )
    }
}
