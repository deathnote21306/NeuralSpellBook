import SwiftUI

struct LivingStageView: View {
    @ObservedObject var viewModel: SandboxViewModel
    @ObservedObject private var stageController: SpellStageController
    var reducedMotion: Bool

    @State private var sigilPulse = false

    init(viewModel: SandboxViewModel, reducedMotion: Bool) {
        self.viewModel = viewModel
        self.reducedMotion = reducedMotion
        _stageController = ObservedObject(wrappedValue: viewModel.spellStage)
    }

    private var layerSizes: [Int] {
        let output = viewModel.outputMode == .sigmoid ? 1 : 2
        return [2] + viewModel.hiddenSizes + [output]
    }

    private var lossValue: Float {
        viewModel.lossHistory.last?.loss ?? 0
    }

    var body: some View {
        GeometryReader { proxy in
            let stageHeight = max(360, min(560, proxy.size.height * 0.76))

            VStack(spacing: 12) {
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Label("Spell Stage", systemImage: "sparkles.rectangle.stack")
                                .font(Typography.section)
                            Spacer()
                            Text(stageController.spellIntentLine)
                                .font(Typography.caption)
                                .foregroundStyle(Theme.mint)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }

                        ZStack(alignment: .topLeading) {
                            StageSigilFrame()
                                .stroke(Theme.gold.opacity(0.26), lineWidth: 1.2)

                            GeometryReader { stageProxy in
                                let totalWidth = stageProxy.size.width
                                let minRuneWidth: CGFloat = 190
                                let preferredGlyph = totalWidth * 0.58
                                let glyphWidth = min(
                                    max(250, preferredGlyph),
                                    max(250, totalWidth - minRuneWidth - 12)
                                )
                                HStack(spacing: 12) {
                                    glyphField
                                        .frame(width: glyphWidth, height: stageProxy.size.height)
                                    runeField
                                        .frame(width: max(minRuneWidth, totalWidth - glyphWidth - 12), height: stageProxy.size.height)
                                }
                            }
                            .padding(12)

                            spellHUD
                                .padding(12)

                            if let sigil = stageController.outputSigil {
                                outputSigilBadge(sigil)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                    .scaleEffect(sigilPulse ? 1 : 0.86)
                                    .opacity(sigilPulse ? 1 : 0.65)
                            }

                            hintChip
                                .padding(12)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

                            if stageController.inspectMode {
                                Color.black.opacity(0.16)
                                    .allowsHitTesting(false)
                            }

                            ManaTurbulenceOverlay(
                                state: stageController.manaState,
                                intensity: stageController.manaTurbulence,
                                reducedMotion: reducedMotion
                            )
                            .allowsHitTesting(false)
                        }
                        .frame(maxWidth: .infinity, minHeight: stageHeight, maxHeight: stageHeight)
                    }
                }

                if !viewModel.feedbackCards.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.feedbackCards, id: \.self) { card in
                                chip(text: card, color: Theme.warning)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .onChange(of: stageController.outputSigilToken) { _, _ in
            withAnimation(.spring(response: 0.28, dampingFraction: 0.62)) {
                sigilPulse = true
            }
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000)
                withAnimation(.easeOut(duration: 0.25)) {
                    sigilPulse = false
                }
            }
        }
        .onChange(of: viewModel.showRuneInspector) { _, isPresented in
            if !isPresented {
                stageController.exitInspectMode()
            }
        }
    }

    private var glyphField: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                DecisionBoundaryCanvas(
                    values: viewModel.decisionBoundary,
                    resolution: viewModel.boundaryResolution,
                    chaosLevel: viewModel.instabilityLevel,
                    morphIntensity: stageController.boundaryMorphIntensity,
                    lossPulseToken: stageController.lossPulseToken,
                    lossPulseIsGood: stageController.lossPulseIsGood,
                    manaTurbulence: stageController.manaTurbulence
                )
                ScatterPlotView(points: viewModel.dataset.points)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )

            if viewModel.revealMathematicalForm {
                mathMiniCard
                    .padding(10)
            }
        }
    }

    private var runeField: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color.black.opacity(0.24), Color.white.opacity(0.04)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

            NeuralRunesView(
                layerSizes: layerSizes,
                runes: viewModel.runeSnapshots,
                weightMatrices: viewModel.weightHeatmaps,
                showNumbers: viewModel.showRuneNumbers,
                energyPulseToken: viewModel.energyPulseToken,
                backwardPulseToken: viewModel.backwardPulseToken,
                flowDirection: stageController.flowDirection,
                pinnedRuneID: viewModel.pinnedRune?.id,
                inspectRuneID: stageController.inspectRuneID,
                inspectMode: stageController.inspectMode,
                emphasizedLayers: stageController.emphasizedLayers,
                manaTurbulence: stageController.manaTurbulence,
                reducedMotion: reducedMotion
            ) { rune in
                viewModel.requestRuneInspection(rune)
            } onTapThread: { thread in
                viewModel.requestThreadInspection(layerIndex: thread.layerIndex, weight: thread.weight)
            }
            .padding(12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    private var spellHUD: some View {
        VStack(alignment: .leading, spacing: 8) {
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        hudMetric("Instability", String(format: "%.3f", lossValue))
                        hudMetric("Accuracy", String(format: "%.2f", viewModel.trainAccuracy))
                        hudMetric("Epoch", "\(viewModel.currentStep)")
                    }

                    ProgressView(value: Double(viewModel.instabilityLevel))
                        .tint(stageController.lossPulseIsGood ? Theme.mint : Theme.danger)
                        .frame(maxWidth: 180)
                }
            }
            .frame(maxWidth: 290, alignment: .leading)

            HStack(spacing: 6) {
                chip(
                    text: viewModel.isPlaying ? "Auto" : "Step",
                    color: viewModel.isPlaying ? Theme.starlight : Theme.warning
                )
                if stageController.inspectMode {
                    chip(text: "Inspect", color: Theme.gold)
                }
                switch stageController.manaState {
                case .balanced:
                    chip(text: "Mana Stable", color: Theme.mint)
                case .chaos:
                    chip(text: "Mana Chaos", color: Theme.danger)
                case .stagnant:
                    chip(text: "Mana Stagnant", color: Theme.warning)
                }
            }
        }
    }

    private var mathMiniCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 4) {
                Text("Math Form")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.gold)
                Text("z = W·x + b")
                Text("a = \u{03C3}(z)")
                Text("L = BCE(y, \u{005E}y)")
            }
            .font(Typography.mono)
            .foregroundStyle(.white)
        }
        .frame(width: 150)
    }

    private var hintChip: some View {
        chip(text: "Tap rune/thread to inspect", color: Theme.starlight)
    }

    private func outputSigilBadge(_ sigil: String) -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("Output Sigil")
                .font(Typography.caption)
                .foregroundStyle(.white.opacity(0.72))
            Text(sigil)
                .font(Typography.section)
                .foregroundStyle(Theme.gold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.42), in: Capsule(style: .continuous))
        .overlay(
            Capsule(style: .continuous)
                .stroke(Theme.gold.opacity(0.6), lineWidth: 1)
        )
    }

    private func hudMetric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(Typography.caption)
                .foregroundStyle(.white.opacity(0.72))
            Text(value)
                .font(Typography.mono)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func chip(text: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(text)
                .font(Typography.caption)
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.38), in: Capsule(style: .continuous))
        .overlay(
            Capsule(style: .continuous)
                .stroke(color.opacity(0.75), lineWidth: 1)
        )
    }
}

private struct StageSigilFrame: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path(roundedRect: rect, cornerRadius: 18)

        let inset = rect.insetBy(dx: 16, dy: 16)
        path.addEllipse(in: inset)

        path.move(to: CGPoint(x: rect.minX + 16, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - 16, y: rect.midY))

        path.move(to: CGPoint(x: rect.midX, y: rect.minY + 16))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - 16))

        return path
    }
}

private struct ManaTurbulenceOverlay: View {
    let state: ManaFeedbackState
    let intensity: Float
    let reducedMotion: Bool

    var body: some View {
        if state == .balanced || intensity < 0.08 {
            EmptyView()
        } else {
            GeometryReader { proxy in
                TimelineView(.animation(minimumInterval: reducedMotion ? 1.0 / 8.0 : 1.0 / 20.0)) { timeline in
                    Canvas { context, _ in
                        let t = timeline.date.timeIntervalSinceReferenceDate
                        let strength = CGFloat(MathHelpers.clamp(intensity, min: 0, max: 1))
                        let color = state == .chaos ? Theme.danger : Theme.warning
                        let waveCount = state == .chaos ? 11 : 7

                        for idx in 0..<waveCount {
                            let phase = Double(idx) * 0.77 + t * (state == .chaos ? 2.2 : 0.8)
                            let x = (sin(phase) * 0.5 + 0.5) * proxy.size.width
                            let y = (cos(phase * 1.2) * 0.5 + 0.5) * proxy.size.height
                            let radius = CGFloat(18 + idx * 2) * (0.6 + strength)
                            let rect = CGRect(x: x - radius * 0.5, y: y - radius * 0.5, width: radius, height: radius)
                            context.stroke(
                                Path(ellipseIn: rect),
                                with: .color(color.opacity(0.04 + 0.15 * strength)),
                                lineWidth: 1
                            )
                        }
                    }
                }
            }
            .transition(.opacity)
        }
    }
}
