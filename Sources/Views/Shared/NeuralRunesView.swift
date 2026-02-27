import SwiftUI

private struct RuneKey: Hashable {
    let layer: Int
    let node: Int
}

struct RuneThreadSnapshot: Identifiable {
    let id: String
    let layerIndex: Int
    let fromIndex: Int
    let toIndex: Int
    let weight: Float
    let midPoint: CGPoint
}

struct NeuralRunesView: View {
    let layerSizes: [Int]
    let runes: [RuneSnapshot]
    let weightMatrices: [Tensor]
    let showNumbers: Bool
    let energyPulseToken: Int
    let backwardPulseToken: Int
    let flowDirection: SpellFlowDirection
    let pinnedRuneID: UUID?
    let inspectRuneID: UUID?
    let inspectMode: Bool
    let emphasizedLayers: Set<Int>
    let manaTurbulence: Float
    let reducedMotion: Bool
    let onTapRune: (RuneSnapshot) -> Void
    let onTapThread: (RuneThreadSnapshot) -> Void

    init(
        layerSizes: [Int],
        runes: [RuneSnapshot],
        weightMatrices: [Tensor],
        showNumbers: Bool,
        energyPulseToken: Int,
        backwardPulseToken: Int,
        flowDirection: SpellFlowDirection = .idle,
        pinnedRuneID: UUID?,
        inspectRuneID: UUID? = nil,
        inspectMode: Bool = false,
        emphasizedLayers: Set<Int> = [],
        manaTurbulence: Float = 0,
        reducedMotion: Bool,
        onTapRune: @escaping (RuneSnapshot) -> Void,
        onTapThread: @escaping (RuneThreadSnapshot) -> Void = { _ in }
    ) {
        self.layerSizes = layerSizes
        self.runes = runes
        self.weightMatrices = weightMatrices
        self.showNumbers = showNumbers
        self.energyPulseToken = energyPulseToken
        self.backwardPulseToken = backwardPulseToken
        self.flowDirection = flowDirection
        self.pinnedRuneID = pinnedRuneID
        self.inspectRuneID = inspectRuneID
        self.inspectMode = inspectMode
        self.emphasizedLayers = emphasizedLayers
        self.manaTurbulence = manaTurbulence
        self.reducedMotion = reducedMotion
        self.onTapRune = onTapRune
        self.onTapThread = onTapThread
    }

    var body: some View {
        GeometryReader { proxy in
            let positions = nodePositions(size: proxy.size)
            let runeLookup = Dictionary(uniqueKeysWithValues: runes.map { (RuneKey(layer: $0.layerIndex, node: $0.nodeIndex), $0) })
            let selectedKey = runes
                .first(where: { $0.id == inspectRuneID })
                .map { RuneKey(layer: $0.layerIndex, node: $0.nodeIndex) }
            let threads = makeThreads(positions: positions)

            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                Canvas { context, _ in
                    drawConnections(
                        context: &context,
                        positions: positions,
                        selectedKey: selectedKey,
                        time: timeline.date.timeIntervalSinceReferenceDate
                    )
                    drawNodes(
                        context: &context,
                        positions: positions,
                        runeLookup: runeLookup,
                        selectedKey: selectedKey
                    )
                }
            }

            ForEach(threads) { thread in
                Button {
                    onTapThread(thread)
                } label: {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.clear)
                        .frame(width: 44, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .position(thread.midPoint)
                .accessibilityLabel("Thread layer \(thread.layerIndex)")
            }

            ForEach(0..<layerSizes.count, id: \.self) { layer in
                ForEach(0..<layerSizes[layer], id: \.self) { node in
                    if let rune = runeLookup[RuneKey(layer: layer, node: node)], let point = positions[RuneKey(layer: layer, node: node)] {
                        Button {
                            onTapRune(rune)
                        } label: {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 44, height: 44)
                                .contentShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(
                                            rune.id == inspectRuneID || pinnedRuneID == rune.id
                                                ? Theme.gold.opacity(0.84)
                                                : Color.clear,
                                            lineWidth: 2.2
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                        .position(point)
                        .accessibilityLabel("Inspect \(rune.name)")
                    }
                }
            }
        }
        .frame(minHeight: 220)
    }

    private func nodePositions(size: CGSize) -> [RuneKey: CGPoint] {
        var map: [RuneKey: CGPoint] = [:]
        let layerCount = max(layerSizes.count, 2)

        for layer in 0..<layerCount {
            let x = CGFloat(layer) / CGFloat(layerCount - 1)
            let xPos = x * size.width
            let nodes = max(layerSizes[safe: layer] ?? 2, 1)

            for node in 0..<nodes {
                let y = CGFloat(node + 1) / CGFloat(nodes + 1)
                map[RuneKey(layer: layer, node: node)] = CGPoint(x: xPos, y: y * size.height)
            }
        }

        return map
    }

    private func makeThreads(positions: [RuneKey: CGPoint]) -> [RuneThreadSnapshot] {
        var snapshots: [RuneThreadSnapshot] = []
        for layer in 1..<layerSizes.count {
            guard let weights = weightMatrices[safe: layer - 1] else { continue }
            let prevCount = layerSizes[layer - 1]
            let currentCount = layerSizes[layer]

            for prev in 0..<prevCount {
                for current in 0..<currentCount {
                    guard prev < weights.rows, current < weights.cols,
                          let from = positions[RuneKey(layer: layer - 1, node: prev)],
                          let to = positions[RuneKey(layer: layer, node: current)] else { continue }
                    let mid = CGPoint(x: (from.x + to.x) * 0.5, y: (from.y + to.y) * 0.5)
                    snapshots.append(
                        RuneThreadSnapshot(
                            id: "\(layer)-\(prev)-\(current)",
                            layerIndex: layer,
                            fromIndex: prev,
                            toIndex: current,
                            weight: weights[prev, current],
                            midPoint: mid
                        )
                    )
                }
            }
        }
        return snapshots
    }

    private func drawConnections(
        context: inout GraphicsContext,
        positions: [RuneKey: CGPoint],
        selectedKey: RuneKey?,
        time: TimeInterval
    ) {
        let turbulence = CGFloat(MathHelpers.clamp(manaTurbulence, min: 0, max: 1))
        let flowToken = flowDirection == .backward ? backwardPulseToken : energyPulseToken

        for layer in 1..<layerSizes.count {
            guard let weights = weightMatrices[safe: layer - 1] else { continue }
            let prevCount = layerSizes[layer - 1]
            let currentCount = layerSizes[layer]

            for prev in 0..<prevCount {
                for current in 0..<currentCount {
                    guard prev < weights.rows, current < weights.cols,
                          let from = positions[RuneKey(layer: layer - 1, node: prev)],
                          let to = positions[RuneKey(layer: layer, node: current)] else { continue }

                    let weight = weights[prev, current]
                    let strength = CGFloat(min(1, abs(weight) * 1.5))
                    let emphasized = emphasizedLayers.contains(layer)
                    let baseColor = weight >= 0 ? Theme.starlight : Theme.ember
                    let selectedEdge = isSelectedEdge(layer: layer, prev: prev, current: current, selectedKey: selectedKey)
                    let dimmedForInspect = inspectMode && !selectedEdge
                    let alpha: CGFloat = dimmedForInspect ? 0.13 : (0.24 + strength * 0.44)
                    let widthBoost = emphasized ? 1.6 : 0

                    var path = Path()
                    path.move(to: from)
                    path.addLine(to: to)
                    context.stroke(path, with: .color(baseColor.opacity(alpha)), lineWidth: 0.9 + strength * 1.45 + widthBoost)

                    if emphasized {
                        context.stroke(path, with: .color(Theme.gold.opacity(0.32)), lineWidth: 2.9)
                    }

                    guard !reducedMotion else { continue }

                    let phase = CGFloat(sin(time * 2.4 + Double(layer * 4 + current)) * 0.5 + 0.5)
                    let pulse = CGFloat(flowToken) * 0.04
                    let rawStart = (phase + pulse + turbulence * 0.3).truncatingRemainder(dividingBy: 1)
                    let travelLength: CGFloat = 0.16 + turbulence * 0.06
                    let isBackward = flowDirection == .backward
                    let start = isBackward ? max(0, 1 - rawStart - travelLength) : rawStart
                    let end = min(1, start + travelLength)
                    let pulsePath = path.trimmedPath(from: start, to: end)
                    let pulseColor = flowDirection == .backward
                        ? Theme.gold.opacity(dimmedForInspect ? 0.35 : 0.9)
                        : Theme.mint.opacity(dimmedForInspect ? 0.35 : 0.95)

                    context.stroke(
                        pulsePath,
                        with: .color(pulseColor),
                        style: StrokeStyle(lineWidth: (emphasized ? 2.8 : 2.2), lineCap: .round)
                    )
                }
            }
        }
    }

    private func drawNodes(
        context: inout GraphicsContext,
        positions: [RuneKey: CGPoint],
        runeLookup: [RuneKey: RuneSnapshot],
        selectedKey: RuneKey?
    ) {
        for layer in 0..<layerSizes.count {
            for node in 0..<layerSizes[layer] {
                guard let point = positions[RuneKey(layer: layer, node: node)],
                      let rune = runeLookup[RuneKey(layer: layer, node: node)] else { continue }

                let activation = CGFloat(abs(rune.activation))
                let baseColor = rune.layerIndex == layerSizes.count - 1 ? Theme.gold : Theme.starlight
                let isSelected = rune.id == inspectRuneID || rune.id == pinnedRuneID
                let dimmed = inspectMode && rune.id != inspectRuneID
                let glow = min(0.98, 0.28 + activation * 0.75)
                let nodeScale: CGFloat = isSelected ? 1.34 : 1

                let haloSize: CGFloat = (isSelected ? 42 : 32) * nodeScale
                let haloRect = CGRect(x: point.x - haloSize * 0.5, y: point.y - haloSize * 0.5, width: haloSize, height: haloSize)
                context.fill(Path(ellipseIn: haloRect), with: .color(baseColor.opacity((dimmed ? 0.1 : 0.28) * glow)))

                let coreSize: CGFloat = (isSelected ? 24 : 17) * nodeScale
                let rect = CGRect(x: point.x - coreSize * 0.5, y: point.y - coreSize * 0.5, width: coreSize, height: coreSize)
                context.fill(Path(ellipseIn: rect), with: .color(baseColor.opacity(dimmed ? 0.34 : 0.84)))
                context.stroke(Path(ellipseIn: rect), with: .color(Color.white.opacity(dimmed ? 0.25 : 0.95)), lineWidth: isSelected ? 1.7 : 1)

                if showNumbers || isSelected || (selectedKey != nil && selectedKey == RuneKey(layer: layer, node: node)) {
                    let text = Text(String(format: "%.2f", rune.activation))
                        .font(Typography.mono)
                        .foregroundStyle(.white)
                    context.draw(text, at: CGPoint(x: point.x, y: point.y - (isSelected ? 22 : 17)))
                }
            }
        }
    }

    private func isSelectedEdge(layer: Int, prev: Int, current: Int, selectedKey: RuneKey?) -> Bool {
        guard let selectedKey else { return true }
        let touchesSource = selectedKey.layer == layer - 1 && selectedKey.node == prev
        let touchesTarget = selectedKey.layer == layer && selectedKey.node == current
        return touchesSource || touchesTarget
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
