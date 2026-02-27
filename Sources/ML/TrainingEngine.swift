import Foundation

public struct TrainingHistoryPoint: Identifiable {
    public let id = UUID()
    public let step: Int
    public let loss: Float
    public let trainAccuracy: Float
    public let validationAccuracy: Float
}

public struct TensorSummary: Identifiable {
    public let id = UUID()
    public let name: String
    public let shape: [Int]
    public let minValue: Float
    public let maxValue: Float
    public let meanValue: Float
    public let samples: [Float]
    public let meaning: String

    public init(name: String, tensor: Tensor, meaning: String) {
        self.name = name
        self.shape = tensor.shape
        self.minValue = tensor.minValue
        self.maxValue = tensor.maxValue
        self.meanValue = tensor.meanValue
        self.samples = tensor.sampleValues(10)
        self.meaning = meaning
    }
}

public struct RuneSnapshot: Identifiable {
    public let id = UUID()
    public let layerIndex: Int
    public let nodeIndex: Int
    public let name: String
    public let activation: Float
    public let incomingWeights: [Float]
    public let tensorShapeDescription: String
    public let meaning: String
}

public struct TrainingStepOutcome {
    public let loss: Float
    public let trainAccuracy: Float
    public let validationAccuracy: Float
    public let tensorSummaries: [TensorSummary]
    public let gradientMagnitudes: [Float]
    public let activationMaps: [Tensor]
    public let phaseMessages: [String]
}

@MainActor
public final class TrainingEngine {
    private(set) var model: MLP
    private var batchRng: SeededRandom

    public init(configuration: MLPConfiguration, seed: UInt64 = 1337) {
        self.model = MLP(configuration: configuration)
        self.batchRng = SeededRandom(seed: seed)
    }

    public func rebuild(configuration: MLPConfiguration) {
        model.rebuild(configuration: configuration)
    }

    public func step(
        dataset: Dataset,
        learningRate: Float,
        batchSize: Int,
        optimizer: OptimizerKind,
        gradientClip: Float
    ) -> TrainingStepOutcome {
        guard !dataset.trainingPoints.isEmpty else {
            return TrainingStepOutcome(
                loss: 0,
                trainAccuracy: 0,
                validationAccuracy: 0,
                tensorSummaries: [],
                gradientMagnitudes: [],
                activationMaps: [],
                phaseMessages: ["No data points available for training."]
            )
        }

        let batch = makeBatch(from: dataset.trainingPoints, size: batchSize)
        let report = model.trainStep(
            batchInput: batch.input,
            labels: batch.labels,
            learningRate: learningRate,
            optimizer: optimizer,
            gradientClip: gradientClip > 0 ? gradientClip : nil
        )

        let validationAccuracy = model.accuracy(on: dataset.validationPoints)

        let tensorSummaries: [TensorSummary] = [
            TensorSummary(name: "Batch Input", tensor: batch.input, meaning: "Current mini-batch in [batch, features]."),
            TensorSummary(name: "Predictions", tensor: report.probabilities, meaning: "Model confidence for each sample."),
            TensorSummary(name: "Last Layer Activations", tensor: report.activations.last ?? Tensor(rows: 1, cols: 1), meaning: "Output rune intensity.")
        ]

        return TrainingStepOutcome(
            loss: report.loss,
            trainAccuracy: report.trainAccuracy,
            validationAccuracy: validationAccuracy,
            tensorSummaries: tensorSummaries,
            gradientMagnitudes: report.layerDiagnostics.map(\.gradientMagnitude),
            activationMaps: report.layerDiagnostics.map(\.activations),
            phaseMessages: report.phaseMessages
        )
    }

    public func decisionBoundary(resolution: Int, range: ClosedRange<Float> = -1.6...1.6) -> [Float] {
        let n = max(20, resolution)
        let axis = linspace(from: range.lowerBound, to: range.upperBound, count: n)
        var values: [Float] = []
        values.reserveCapacity(n * n)

        for y in axis.reversed() {
            for x in axis {
                values.append(model.predictProbability(x: x, y: y))
            }
        }

        return values
    }

    public func runeSnapshots(for point: DataPoint?) -> [RuneSnapshot] {
        let sample = point ?? DataPoint(x: 0.15, y: -0.15, label: 1)
        let inputTensor = Tensor(rows: 1, cols: 2, data: [sample.x, sample.y])
        let activations = model.forwardActivations(for: inputTensor)

        var snapshots: [RuneSnapshot] = []

        for layerIndex in activations.indices {
            let activationTensor = activations[layerIndex]
            for nodeIndex in 0..<activationTensor.cols {
                let value = activationTensor[0, nodeIndex]
                let incomingWeights: [Float]
                if layerIndex == 0 {
                    incomingWeights = []
                } else {
                    let weightTensor = model.layerWeights[layerIndex - 1]
                    incomingWeights = (0..<weightTensor.rows).map { weightTensor[$0, nodeIndex] }
                }

                snapshots.append(
                    RuneSnapshot(
                        layerIndex: layerIndex,
                        nodeIndex: nodeIndex,
                        name: runeName(layerIndex: layerIndex, nodeIndex: nodeIndex),
                        activation: value,
                        incomingWeights: incomingWeights,
                        tensorShapeDescription: layerIndex == 0 ? "[batch, features]" : "[batch, units]",
                        meaning: meaningForRune(layerIndex: layerIndex, weights: incomingWeights)
                    )
                )
            }
        }

        return snapshots
    }

    public func layerWeightHeatmaps() -> [Tensor] {
        model.layerWeights
    }

    private func makeBatch(from points: [DataPoint], size: Int) -> (input: Tensor, labels: [Int]) {
        let effectiveSize = max(2, min(size, points.count))
        var sampled: [DataPoint] = []
        sampled.reserveCapacity(effectiveSize)

        for _ in 0..<effectiveSize {
            let idx = Int(batchRng.next() % UInt64(points.count))
            sampled.append(points[idx])
        }

        return (
            Tensor(rows: sampled.count, cols: 2, data: sampled.flatMap { [$0.x, $0.y] }),
            sampled.map(\.label)
        )
    }

    private func linspace(from: Float, to: Float, count: Int) -> [Float] {
        guard count > 1 else { return [from] }
        let step = (to - from) / Float(count - 1)
        return (0..<count).map { from + Float($0) * step }
    }

    private func runeName(layerIndex: Int, nodeIndex: Int) -> String {
        if layerIndex == 0 {
            return nodeIndex == 0 ? "Input Rune X" : "Input Rune Y"
        }
        if layerIndex == model.layerWeights.count {
            return "Output Rune \(nodeIndex + 1)"
        }
        return "Rune H\(layerIndex)-\(nodeIndex + 1)"
    }

    private func meaningForRune(layerIndex: Int, weights: [Float]) -> String {
        if layerIndex == 0 {
            return "Represents one raw feature before transformation."
        }

        if layerIndex == 1, weights.count >= 2 {
            let wx = weights[0]
            let wy = weights[1]
            let orientation: String
            if abs(wx) > abs(wy) * 1.25 {
                orientation = "responds more to horizontal shifts"
            } else if abs(wy) > abs(wx) * 1.25 {
                orientation = "responds more to vertical shifts"
            } else {
                orientation = "responds to diagonal combinations"
            }
            return "This rune \(orientation). This is a helpful intuition, not a guarantee."
        }

        return "This rune combines simpler runes into richer patterns. This is a helpful intuition, not a guarantee."
    }
}
