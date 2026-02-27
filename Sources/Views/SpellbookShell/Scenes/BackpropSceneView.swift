import SwiftUI

private struct BackpropWeightChange: Identifiable {
    let id = UUID()
    let name: String
    let oldValue: String
    let delta: String
    let newValue: String
    let layerIndex: Int
}

// MARK: - Scene

struct BackpropSceneView: View {
    let onNext: () -> Void
    let onOpenModal: (SpellModalKey) -> Void
    @Binding var mathReveal: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var ritualProgress: Double = 0
    @State private var ritualDone = false
    @State private var isAnimating = false
    @State private var selectedLayerIndex: Int? = nil   // tapped layer for blame detail

    private let layers = [3, 4, 4, 2]

    private let layerBlame: [CGFloat] = [0.30, 0.46, 0.62, 0.86]

    private let weightChanges: [BackpropWeightChange] = [
        .init(name: "W input→hidden", oldValue: "0.500", delta: "+0.031", newValue: "0.531", layerIndex: 0),
        .init(name: "W hidden I bias", oldValue: "−0.300", delta: "+0.019", newValue: "−0.281", layerIndex: 1),
        .init(name: "W hidden II→out", oldValue: "0.800", delta: "−0.045", newValue: "0.755", layerIndex: 2)
    ]

    private var ritualMessage: String {
        switch ritualProgress {
        case ..<0.18: return "The spell remembers the mistake at the output layer first."
        case ..<0.48: return "Gradients pull blame backward through the hidden runes."
        case ..<0.82: return "Each thread receives its share of responsibility for the error."
        default:      return ritualDone ? "The ritual is done. Weights corrected — loss falls." : "Correction reaches the earliest layers."
        }
    }

    private var selectedLayerName: String {
        switch selectedLayerIndex {
        case 0: return "Input Layer"
        case 1: return "Hidden I"
        case 2: return "Hidden II"
        case 3: return "Output Layer"
        default: return ""
        }
    }

    private var selectedBlameInfo: (blame: String, gradient: String, correction: String, explanation: String) {
        switch selectedLayerIndex {
        case 3: return ("86%", "0.045", "−0.045", "Output nodes receive the direct error signal. They know exactly how far the prediction was from truth.")
        case 2: return ("62%", "0.031", "+0.031", "Second hidden layer: receives partial blame passed back from the output. The chain rule distributes responsibility.")
        case 1: return ("46%", "0.019", "+0.019", "First hidden layer: further from the mistake, so blame is diluted further. Gradients vanish as they travel deeper.")
        case 0: return ("30%", "0.007", "+0.007", "Input nodes absorb the least blame. They are first in the chain but last to receive correction signal.")
        default: return ("—", "—", "—", "Tap a layer to see how blame is distributed during the backpropagation ritual.")
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {

            // Crimson ambient background for backprop
            BackpropAmbientView(progress: ritualProgress, isAnimating: isAnimating)

            // Full-screen canvas
            BackpropCanvasView(
                progress: ritualProgress,
                ritualDone: ritualDone,
                isAnimating: isAnimating,
                selectedLayerIndex: selectedLayerIndex,
                onTapLayer: { layerIndex in
                    guard ritualDone else { return }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                        selectedLayerIndex = (selectedLayerIndex == layerIndex) ? nil : layerIndex
                    }
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bottom gradient
            LinearGradient(
                colors: [.clear, Color(red: 0.03, green: 0.01, blue: 0.07).opacity(0.98)],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 340)
            .allowsHitTesting(false)

            // Bottom panel
            VStack(spacing: 12) {

                // Status chips
                HStack(spacing: 8) {
                    BackpropStatusChip(
                        title: isAnimating ? "Ritual active" : (ritualDone ? "Correction complete" : "Awaiting ritual"),
                        tint: isAnimating ? Color(red: 0.85, green: 0.19, blue: 0.38) : (ritualDone ? Color(red: 0.24, green: 0.84, blue: 0.75) : Color(red: 0.86, green: 0.85, blue: 1.0))
                    )
                    if ritualDone {
                        BackpropStatusChip(title: "↓ 41% improvement", tint: Color(red: 0.24, green: 0.84, blue: 0.75))
                        BackpropStatusChip(title: "New Loss: 0.31", tint: Color(red: 0.49, green: 0.38, blue: 1.0))
                    }
                }

                // Dynamic content area
                Group {
                    if isAnimating {
                        Text(ritualMessage)
                            .font(.system(size: 16, weight: .regular, design: .serif))
                            .foregroundStyle(.white.opacity(0.84))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .transition(.opacity)

                    } else if ritualDone, let _ = selectedLayerIndex {
                        // Layer blame detail card
                        BackpropBlameCard(
                            layerName: selectedLayerName,
                            info: selectedBlameInfo,
                            mathReveal: mathReveal
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))

                    } else if ritualDone {
                        VStack(spacing: 4) {
                            Text("✦  TAP A LAYER TO SEE BLAME DISTRIBUTION  ✦")
                                .font(.custom("AvenirNext-DemiBold", size: 12))
                                .tracking(2.5)
                                .foregroundStyle(Color(red: 0.85, green: 0.19, blue: 0.38).opacity(0.85))
                            Text("Error flows right to left — each layer absorbs a fraction of the total loss")
                                .font(.custom("AvenirNext-Regular", size: 13))
                                .foregroundStyle(.white.opacity(0.45))
                                .multilineTextAlignment(.center)
                        }
                        .transition(.opacity)

                    } else {
                        Text("Backpropagation traces backwards through every connection to assign blame and correct each weight. Perform the ritual to see error flow.")
                            .font(.system(size: 16, weight: .regular, design: .serif))
                            .foregroundStyle(.white.opacity(0.70))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .lineSpacing(4)
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.35), value: isAnimating)
                .animation(.spring(response: 0.4, dampingFraction: 0.82), value: selectedLayerIndex)
                .animation(.easeInOut(duration: 0.35), value: ritualDone)

                // Buttons
                HStack(spacing: 10) {
                    SpellButton(title: "✦ Why This Works", tone: .gold) { onOpenModal(.backprop) }
                    SpellButton(
                        title: isAnimating ? "🩸 Ritual in progress..." : (ritualDone ? "↺ Replay" : "🩸 Perform Ritual"),
                        tone: .danger
                    ) { performRitual() }
                }

                if ritualDone {
                    SpellButton(title: "Chapter IV →", tone: .spirit, isPulsing: true) { onNext() }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 90)
            .animation(.easeInOut(duration: 0.35), value: ritualDone)

            // Chapter label
            VStack {
                HStack {
                    Text("CHAPTER III · BACKPROPAGATION")
                        .font(.custom("AvenirNext-DemiBold", size: 9.5))
                        .tracking(3.5)
                        .foregroundStyle(Color(red: 0.85, green: 0.19, blue: 0.38).opacity(0.45))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)
                Spacer()
            }
            .allowsHitTesting(false)
        }
    }

    private func performRitual() {
        guard !isAnimating else { return }
        ritualDone = false
        selectedLayerIndex = nil
        ritualProgress = 0
        isAnimating = true

        if reduceMotion {
            ritualProgress = 1
        } else {
            withAnimation(.easeInOut(duration: 1.65)) { ritualProgress = 1 }
        }

        Task {
            try? await Task.sleep(nanoseconds: reduceMotion ? 300_000_000 : 1_700_000_000)
            await MainActor.run {
                isAnimating = false
                ritualDone = true
            }
        }
    }
}

// MARK: - Blame card

private struct BackpropBlameCard: View {
    let layerName: String
    let info: (blame: String, gradient: String, correction: String, explanation: String)
    let mathReveal: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(layerName.uppercased())
                    .font(.custom("AvenirNext-DemiBold", size: 10))
                    .tracking(2.5)
                    .foregroundStyle(Color(red: 0.85, green: 0.19, blue: 0.38).opacity(0.85))
                Text(info.explanation)
                    .font(.custom("AvenirNext-Regular", size: 14))
                    .foregroundStyle(.white.opacity(0.68))
                    .lineSpacing(3)
                    .lineLimit(3)
                if mathReveal {
                    Text("W_new = W_old − α × gradient\n= W_old − 0.01 × \(info.gradient)")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color(red: 0.24, green: 0.84, blue: 0.75))
                        .lineSpacing(2)
                }
            }
            VStack(alignment: .trailing, spacing: 10) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(info.blame)
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(red: 0.85, green: 0.19, blue: 0.38))
                    Text("blame")
                        .font(.custom("AvenirNext-DemiBold", size: 9))
                        .tracking(1.5)
                        .foregroundStyle(.white.opacity(0.32))
                }
                VStack(alignment: .trailing, spacing: 2) {
                    Text(info.correction)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(red: 0.24, green: 0.84, blue: 0.75))
                    Text("Δweight")
                        .font(.custom("AvenirNext-DemiBold", size: 9))
                        .tracking(1.5)
                        .foregroundStyle(.white.opacity(0.32))
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.04, green: 0.02, blue: 0.10).opacity(0.97),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(Color(red: 0.85, green: 0.19, blue: 0.38).opacity(0.35), lineWidth: 1))
    }
}

// MARK: - Ambient background

private struct BackpropAmbientView: View {
    let progress: Double
    let isAnimating: Bool

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                let pulse = CGFloat(0.75 + 0.25 * sin(t * 0.7))
                let intensity = CGFloat(0.06 + progress * 0.08) * pulse

                ctx.fill(
                    Path(ellipseIn: CGRect(x: size.width * 0.55, y: -size.height * 0.05,
                                           width: size.width * 0.70, height: size.height * 0.60)),
                    with: .radialGradient(
                        Gradient(colors: [Color(red: 0.85, green: 0.19, blue: 0.38).opacity(intensity), .clear]),
                        center: CGPoint(x: size.width * 0.90, y: 0),
                        startRadius: 0, endRadius: size.width * 0.45
                    )
                )
                ctx.fill(
                    Path(ellipseIn: CGRect(x: -size.width * 0.10, y: size.height * 0.35,
                                           width: size.width * 0.55, height: size.height * 0.55)),
                    with: .radialGradient(
                        Gradient(colors: [Color(red: 1.0, green: 0.42, blue: 0.21).opacity(intensity * 0.7), .clear]),
                        center: CGPoint(x: 0, y: size.height * 0.65),
                        startRadius: 0, endRadius: size.width * 0.38
                    )
                )
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

// MARK: - Full-screen canvas

private struct BackpropCanvasView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let progress: Double
    let ritualDone: Bool
    let isAnimating: Bool
    let selectedLayerIndex: Int?
    let onTapLayer: (Int) -> Void

    private let layers = [3, 4, 4, 2]

    var body: some View {
        GeometryReader { proxy in
            let layout = BackpropNetworkLayout(size: proxy.size, layers: layers)

            ZStack {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                    Canvas { context, _ in
                        drawEdges(context: &context, layout: layout,
                                  timeline: timeline.date.timeIntervalSinceReferenceDate)
                        drawNodes(context: &context, layout: layout,
                                  timeline: timeline.date.timeIntervalSinceReferenceDate)
                        drawLabels(context: &context, layout: layout)
                    }
                }

                // Invisible tap targets per layer column
                if ritualDone {
                    ForEach(0..<4) { layerIndex in
                        let anchor = layout.anchorPoints[layerIndex]
                        Button {
                            onTapLayer(layerIndex)
                        } label: {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: proxy.size.width * 0.22, height: proxy.size.height * 0.75)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .position(x: anchor.x, y: proxy.size.height * 0.46)
                    }
                }
            }
        }
    }

    private func drawEdges(context: inout GraphicsContext, layout: BackpropNetworkLayout, timeline: TimeInterval) {
        let hasSelection = selectedLayerIndex != nil

        for edge in layout.edges {
            let path = curvedPath(from: edge.from, to: edge.to)
            let selected = (selectedLayerIndex == edge.segment || selectedLayerIndex == edge.segment + 1)
            let wave = edgeWave(for: edge)

            // Base dim stroke
            let baseOp: Double = hasSelection ? (selected ? 0.22 : 0.04) : 0.10
            context.stroke(path, with: .color(Color(red: 0.49, green: 0.38, blue: 1.0).opacity(baseOp)),
                           style: StrokeStyle(lineWidth: 1.0, lineCap: .round))

            guard wave > 0.01 else { continue }

            // ── LAYER 1: Error glow (outer, wide) ─────────────────────────
            let glowOp: Double = hasSelection ? (selected ? 0.22 : 0.0) : 0.08 + wave * 0.14
            if glowOp > 0.01 {
                context.stroke(path, with: .color(Color(red: 0.85, green: 0.19, blue: 0.38).opacity(glowOp)),
                               style: StrokeStyle(lineWidth: 9, lineCap: .round))
            }

            // ── LAYER 2: Error gradient mid stroke ─────────────────────────
            let midOp: Double = hasSelection ? (selected ? 0.75 : 0.03) : 0.28 + wave * 0.55
            context.stroke(path, with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.85, green: 0.19, blue: 0.38).opacity(midOp),
                    Color(red: 1.0, green: 0.42, blue: 0.21).opacity(midOp * 0.70),
                    Color(red: 0.91, green: 0.72, blue: 0.29).opacity(midOp * 0.45)
                ]),
                startPoint: edge.to,   // error flows right→left
                endPoint: edge.from
            ), style: StrokeStyle(lineWidth: 2.0 + wave * 1.8, lineCap: .round))

            // ── LAYER 3: Bright core ────────────────────────────────────────
            let coreOp: Double = hasSelection ? (selected ? 0.85 : 0.01) : 0.22 + wave * 0.50
            if coreOp > 0.01 {
                context.stroke(path, with: .color(Color(red: 0.85, green: 0.19, blue: 0.38).opacity(coreOp * 0.70)),
                               style: StrokeStyle(lineWidth: 0.8, lineCap: .round))
            }

            // Shimmer ripple (no particles)
            if wave > 0.5 && !hasSelection {
                let shimmer = 0.12 + 0.12 * sin(timeline * 2.2 + Double(edge.segment) * 1.5)
                context.stroke(path, with: .color(Color(red: 0.85, green: 0.19, blue: 0.38).opacity(shimmer)),
                               style: StrokeStyle(lineWidth: 2.0, lineCap: .round))
            }
        }
    }

    private func drawNodes(context: inout GraphicsContext, layout: BackpropNetworkLayout, timeline: TimeInterval) {
        let hasSelection = selectedLayerIndex != nil

        for node in layout.nodes {
            let blame = nodeBlame(for: node)
            let isSelectedLayer = selectedLayerIndex == node.layerIndex
            let radius: CGFloat = 9.5 + blame * 5 + (isSelectedLayer ? 3 : 0)
            let tint = blame > 0.2 ? Color(red: 0.85, green: 0.19, blue: 0.38) : Color(red: 0.49, green: 0.38, blue: 1.0)
            let dimmed = hasSelection && !isSelectedLayer

            // Halo
            let hR = radius * 3.0
            let haloOp: Double = dimmed ? 0.04 : (0.10 + Double(blame) * 0.20)
            context.fill(
                Path(ellipseIn: CGRect(x: node.point.x - hR, y: node.point.y - hR, width: hR * 2, height: hR * 2)),
                with: .radialGradient(
                    Gradient(colors: [tint.opacity(haloOp), .clear]),
                    center: node.point, startRadius: 0, endRadius: hR
                )
            )

            // Node fill
            let rect = CGRect(x: node.point.x - radius, y: node.point.y - radius, width: radius * 2, height: radius * 2)
            context.fill(
                Path(ellipseIn: rect),
                with: .radialGradient(
                    Gradient(colors: [
                        blame > 0.25 ? Color(red: 0.55, green: 0.10, blue: 0.24) : Color(red: 0.12, green: 0.06, blue: 0.26),
                        Color(red: 0.04, green: 0.02, blue: 0.10)
                    ]),
                    center: CGPoint(x: node.point.x - 2, y: node.point.y - 2),
                    startRadius: 1, endRadius: radius
                )
            )

            // Node border
            let borderOp: Double = dimmed ? 0.22 : (isSelectedLayer ? 0.95 : 0.72)
            context.stroke(Path(ellipseIn: rect), with: .color(tint.opacity(borderOp)),
                           lineWidth: isSelectedLayer ? 2.0 : 1.1)

            // Selected layer invite pulse
            if ritualDone && !hasSelection {
                let invitePulse = 0.25 + 0.20 * CGFloat(sin(timeline * 1.8 + Double(node.layerIndex) * 1.4 + Double(node.index) * 0.5))
                let inviteR = radius + 7 + 3 * CGFloat(sin(timeline * 1.8 + Double(node.index) * 0.5))
                context.stroke(
                    Path(ellipseIn: CGRect(x: node.point.x - inviteR, y: node.point.y - inviteR, width: inviteR * 2, height: inviteR * 2)),
                    with: .color(tint.opacity(invitePulse)),
                    style: StrokeStyle(lineWidth: 1.3, dash: [3, 4])
                )
            }

            // Blame value label post-ritual
            if ritualDone {
                let blameVal = [0.30, 0.46, 0.62, 0.86][node.layerIndex]
                let pulsing = 0.65 + 0.35 * sin(timeline * 2.0 + Double(node.index))
                let labelOp: Double = dimmed ? 0.20 : pulsing
                context.draw(
                    Text(String(format: "%.0f%%", blameVal * 100))
                        .font(.custom("AvenirNext-DemiBold", size: 10))
                        .foregroundStyle(Color(red: 0.85, green: 0.19, blue: 0.38).opacity(labelOp)),
                    at: CGPoint(x: node.point.x, y: node.point.y + radius + 12)
                )
            }
        }
    }

    private func drawLabels(context: inout GraphicsContext, layout: BackpropNetworkLayout) {
        let labels = ["INPUT", "HIDDEN I", "HIDDEN II", "OUTPUT"]
        let hasSelection = selectedLayerIndex != nil
        for (index, label) in labels.enumerated() {
            let point = layout.anchorPoints[index]
            let highlighted = selectedLayerIndex == index
            let op: Double = hasSelection ? (highlighted ? 0.80 : 0.18) : 0.36
            context.draw(
                Text(label)
                    .font(.custom("AvenirNext-DemiBold", size: 11))
                    .foregroundStyle(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(op)),
                at: point
            )
        }

        // ── Δweight column labels (shown post-ritual above each layer) ─────
        if ritualDone {
            let deltas = ["+0.007", "+0.019", "+0.031", "−0.045"]
            let spiritC  = Color(red: 0.24, green: 0.84, blue: 0.75)
            let crimsonC = Color(red: 0.85, green: 0.19, blue: 0.38)
            let deltaColors: [Color] = [spiritC, spiritC, spiritC, crimsonC]

            for (index, delta) in deltas.enumerated() {
                let point = layout.anchorPoints[index]
                let highlighted = !hasSelection || selectedLayerIndex == index
                let op: Double = highlighted ? 0.88 : 0.20

                context.draw(
                    Text(delta)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(deltaColors[index].opacity(op)),
                    at: CGPoint(x: point.x, y: point.y + 18)
                )
                context.draw(
                    Text("Δw")
                        .font(.custom("AvenirNext-DemiBold", size: 8))
                        .foregroundStyle(Color.white.opacity(op * 0.40)),
                    at: CGPoint(x: point.x, y: point.y + 32)
                )
            }
        }

        // Error direction label
        context.draw(
            Text("← ERROR PROPAGATES BACKWARD")
                .font(.custom("AvenirNext-DemiBold", size: 10))
                .tracking(1.8)
                .foregroundStyle(Color(red: 0.85, green: 0.19, blue: 0.38).opacity((ritualDone || isAnimating) ? 0.65 : 0.22)),
            at: CGPoint(x: layout.centerX, y: layout.bottomY)
        )
    }

    private func curvedPath(from start: CGPoint, to end: CGPoint) -> Path {
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        return path
    }

    private func edgeWave(for edge: BackpropEdge) -> Double {
        if ritualDone && !isAnimating { return 1 }
        let windows: [(Double, Double)] = [(0.70, 0.20), (0.44, 0.24), (0.18, 0.24)]
        guard edge.segment < windows.count else { return 0 }
        let window = windows[edge.segment]
        return max(0, min(1, (progress - window.0) / window.1))
    }

    private func nodeBlame(for node: BackpropNode) -> CGFloat {
        if ritualDone && !isAnimating {
            return [0.30, 0.46, 0.62, 0.86][node.layerIndex]
        }
        let windows: [(Double, Double)] = [(0.10, 0.18), (0.34, 0.20), (0.58, 0.18), (0.78, 0.16)]
        let window = windows[node.layerIndex]
        return CGFloat(max(0, min(1, (progress - window.0) / window.1)))
    }
}

// MARK: - Status chip

private struct BackpropStatusChip: View {
    let title: String
    let tint: Color

    var body: some View {
        Text(title)
            .font(.custom("AvenirNext-DemiBold", size: 11))
            .foregroundStyle(.white.opacity(0.84))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint.opacity(0.14), in: Capsule(style: .continuous))
            .overlay(Capsule(style: .continuous).stroke(tint.opacity(0.28), lineWidth: 1))
    }
}

// MARK: - Layout

private struct BackpropNetworkLayout {
    let nodes: [BackpropNode]
    let edges: [BackpropEdge]
    let anchorPoints: [CGPoint]
    let centerX: CGFloat
    let bottomY: CGFloat

    init(size: CGSize, layers: [Int]) {
        let xPositions: [CGFloat] = [0.13, 0.39, 0.68, 0.90].map { size.width * $0 }
        let steps: [CGFloat] = [58, 50, 50, 64]

        var builtNodes: [BackpropNode] = []
        var anchors: [CGPoint] = []

        for (layerIndex, count) in layers.enumerated() {
            let x = xPositions[layerIndex]
            anchors.append(CGPoint(x: x, y: 22))
            for nodeIndex in 0..<count {
                let y = size.height * 0.45 + (CGFloat(nodeIndex) - CGFloat(count - 1) / 2) * steps[layerIndex]
                builtNodes.append(BackpropNode(layerIndex: layerIndex, index: nodeIndex, point: CGPoint(x: x, y: y)))
            }
        }

        nodes = builtNodes
        anchorPoints = anchors
        centerX = size.width / 2
        bottomY = size.height - 30

        var builtEdges: [BackpropEdge] = []
        for layerIndex in 0..<(layers.count - 1) {
            let from = builtNodes.filter { $0.layerIndex == layerIndex }
            let to = builtNodes.filter { $0.layerIndex == layerIndex + 1 }
            for source in from {
                for target in to {
                    builtEdges.append(BackpropEdge(from: source.point, to: target.point, segment: layerIndex))
                }
            }
        }
        edges = builtEdges
    }
}

private struct BackpropNode: Identifiable {
    let id = UUID()
    let layerIndex: Int
    let index: Int
    let point: CGPoint
}

private struct BackpropEdge: Identifiable {
    let id = UUID()
    let from: CGPoint
    let to: CGPoint
    let segment: Int
}
