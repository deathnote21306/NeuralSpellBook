import Foundation

public struct MLPConfiguration {
    public var hiddenSizes: [Int]
    public var activation: ActivationKind
    public var outputMode: OutputMode
    public var dropout: Float
    public var l2: Float
    public var seed: UInt64

    public init(
        hiddenSizes: [Int] = [12, 8],
        activation: ActivationKind = .relu,
        outputMode: OutputMode = .sigmoid,
        dropout: Float = 0,
        l2: Float = 0,
        seed: UInt64 = 7
    ) {
        self.hiddenSizes = hiddenSizes
        self.activation = activation
        self.outputMode = outputMode
        self.dropout = dropout
        self.l2 = l2
        self.seed = seed
    }
}

public struct LayerDiagnostics {
    public let name: String
    public let weights: Tensor
    public let activations: Tensor
    public let gradient: Tensor?
    public let gradientMagnitude: Float
}

public struct MLPStepReport {
    public let loss: Float
    public let probabilities: Tensor
    public let trainAccuracy: Float
    public let layerDiagnostics: [LayerDiagnostics]
    public let activations: [Tensor]
    public let phaseMessages: [String]
}

public final class MLP {
    public private(set) var configuration: MLPConfiguration
    public private(set) var layers: [DenseLayer] = []

    private var rng: SeededRandom
    private var dropoutLayer: DropoutLayer
    private var sgd = SGDOptimizer()
    private var adam = AdamOptimizer()

    public init(configuration: MLPConfiguration) {
        self.configuration = configuration
        self.rng = SeededRandom(seed: configuration.seed)
        self.dropoutLayer = DropoutLayer(rate: configuration.dropout)
        rebuild(configuration: configuration)
    }

    public func rebuild(configuration: MLPConfiguration) {
        self.configuration = configuration
        self.rng = SeededRandom(seed: configuration.seed)
        self.dropoutLayer = DropoutLayer(rate: configuration.dropout)
        self.adam.reset()

        var sizes: [Int] = [2]
        sizes.append(contentsOf: configuration.hiddenSizes.map { max(2, $0) })
        sizes.append(configuration.outputMode == .sigmoid ? 1 : 2)

        layers.removeAll(keepingCapacity: true)
        for i in 0..<(sizes.count - 1) {
            layers.append(DenseLayer(inputSize: sizes[i], outputSize: sizes[i + 1], generator: &rng))
        }
    }

    public var layerWeights: [Tensor] {
        layers.map(\.weights)
    }

    public func predictProbability(x: Float, y: Float) -> Float {
        let input = Tensor(rows: 1, cols: 2, data: [x, y])
        let forward = forward(input: input, training: false)
        if configuration.outputMode == .sigmoid {
            return forward.output[0, 0]
        }
        return forward.output[0, 1]
    }

    public func forwardActivations(for input: Tensor) -> [Tensor] {
        forward(input: input, training: false).activations
    }

    public func accuracy(on points: [DataPoint]) -> Float {
        guard !points.isEmpty else { return 0 }

        let input = Tensor(rows: points.count, cols: 2, data: points.flatMap { [$0.x, $0.y] })
        let output = forward(input: input, training: false).output

        var correct = 0
        if configuration.outputMode == .sigmoid {
            for row in 0..<output.rows {
                let prediction = output[row, 0] > 0.5 ? 1 : 0
                if prediction == points[row].label { correct += 1 }
            }
        } else {
            for row in 0..<output.rows {
                let prediction = Ops.argmax(output, row: row)
                if prediction == points[row].label { correct += 1 }
            }
        }

        return Float(correct) / Float(points.count)
    }

    public func trainStep(
        batchInput: Tensor,
        labels: [Int],
        learningRate: Float,
        optimizer: OptimizerKind,
        gradientClip: Float?
    ) -> MLPStepReport {
        let forwardState = forward(input: batchInput, training: true)
        let lossResult: LossResult

        if configuration.outputMode == .sigmoid {
            lossResult = Losses.binaryCrossEntropy(probabilities: forwardState.output, labels: labels)
        } else {
            lossResult = Losses.softmaxCrossEntropy(logits: forwardState.logits, labels: labels)
        }

        var delta = lossResult.gradient
        var gradients = Array(repeating: Tensor(rows: 1, cols: 1), count: layers.count)

        for layerIndex in layers.indices.reversed() {
            let previousActivation = forwardState.activations[layerIndex]
            let batchCount = Float(max(previousActivation.rows, 1))

            var gradW = Ops.matmul(previousActivation.transposed(), delta) / batchCount
            if configuration.l2 > 0 {
                gradW = gradW + (layers[layerIndex].weights * configuration.l2)
            }

            let gradB = Ops.sumRows(delta).map { $0 / batchCount }
            gradients[layerIndex] = gradW

            let oldWeights = layers[layerIndex].weights
            switch optimizer {
            case .sgd:
                sgd.update(
                    layer: layers[layerIndex],
                    gradW: gradW,
                    gradB: gradB,
                    learningRate: learningRate,
                    clip: gradientClip
                )
            case .adam:
                adam.update(
                    layerIndex: layerIndex,
                    layer: layers[layerIndex],
                    gradW: gradW,
                    gradB: gradB,
                    learningRate: learningRate,
                    clip: gradientClip
                )
            }

            guard layerIndex > 0 else { continue }
            delta = Ops.matmul(delta, oldWeights.transposed())

            let hiddenActivated = forwardState.activations[layerIndex]
            let derivative = configuration.activation.derivative(forActivated: hiddenActivated)
            delta = delta.hadamard(derivative)

            if configuration.dropout > 0 {
                let maskIndex = layerIndex - 1
                if maskIndex < forwardState.dropoutMasks.count {
                    let keep = max(1 - configuration.dropout, 1e-5)
                    delta = delta.hadamard(forwardState.dropoutMasks[maskIndex]) / keep
                }
            }
        }

        var layerDiagnostics: [LayerDiagnostics] = []
        layerDiagnostics.reserveCapacity(layers.count)

        for index in layers.indices {
            layerDiagnostics.append(
                LayerDiagnostics(
                    name: index == layers.count - 1 ? "Output Rune Layer" : "Rune Layer \(index + 1)",
                    weights: layers[index].weights,
                    activations: forwardState.activations[index + 1],
                    gradient: gradients[index],
                    gradientMagnitude: gradients[index].meanAbs()
                )
            )
        }

        let trainAccuracy: Float
        if configuration.outputMode == .sigmoid {
            var correct = 0
            for row in 0..<lossResult.probabilities.rows {
                if (lossResult.probabilities[row, 0] > 0.5 ? 1 : 0) == labels[row] {
                    correct += 1
                }
            }
            trainAccuracy = Float(correct) / Float(max(labels.count, 1))
        } else {
            var correct = 0
            for row in 0..<lossResult.probabilities.rows {
                if Ops.argmax(lossResult.probabilities, row: row) == labels[row] {
                    correct += 1
                }
            }
            trainAccuracy = Float(correct) / Float(max(labels.count, 1))
        }

        return MLPStepReport(
            loss: lossResult.loss,
            probabilities: lossResult.probabilities,
            trainAccuracy: trainAccuracy,
            layerDiagnostics: layerDiagnostics,
            activations: forwardState.activations,
            phaseMessages: [
                "Forward pass: runes combine incoming energy.",
                "Loss: the instability meter measures prediction error.",
                "Backpropagation: gradients flow backward to each weight.",
                "Update: weights shift to reduce future instability."
            ]
        )
    }

    private struct ForwardState {
        var output: Tensor
        var logits: Tensor
        var activations: [Tensor]
        var dropoutMasks: [Tensor]
    }

    private func forward(input: Tensor, training: Bool) -> ForwardState {
        var current = input
        var activations: [Tensor] = [input]
        var dropoutMasks: [Tensor] = []
        var finalLogits = input

        for index in layers.indices {
            let logits = layers[index].forward(current)
            finalLogits = logits

            if index == layers.count - 1 {
                if configuration.outputMode == .sigmoid {
                    current = logits.map(MathHelpers.sigmoid)
                } else {
                    current = Ops.softmax(logits)
                }
            } else {
                current = configuration.activation.apply(to: logits)

                if training, configuration.dropout > 0 {
                    var mutableDropout = dropoutLayer
                    let dropped = mutableDropout.apply(current, rng: &rng)
                    current = dropped.output
                    dropoutMasks.append(dropped.mask)
                } else {
                    dropoutMasks.append(Tensor(rows: current.rows, cols: current.cols, repeating: 1))
                }
            }

            activations.append(current)
        }

        return ForwardState(output: current, logits: finalLogits, activations: activations, dropoutMasks: dropoutMasks)
    }
}
