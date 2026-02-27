import Foundation

public enum OptimizerKind: String, CaseIterable, Identifiable {
    case sgd = "SGD"
    case adam = "Adam"

    public var id: String { rawValue }
}

public struct SGDOptimizer {
    public init() {}

    public mutating func update(
        layer: DenseLayer,
        gradW: Tensor,
        gradB: [Float],
        learningRate: Float,
        clip: Float?
    ) {
        let clippedW = gradW.clipped(limit: clip)

        for i in layer.weights.data.indices {
            layer.weights.data[i] -= learningRate * clippedW.data[i]
        }

        for i in layer.bias.indices {
            let g = clip.map { MathHelpers.clamp(gradB[i], min: -$0, max: $0) } ?? gradB[i]
            layer.bias[i] -= learningRate * g
        }
    }
}

public struct AdamOptimizer {
    private var t: Int = 0
    private var mW: [Int: Tensor] = [:]
    private var vW: [Int: Tensor] = [:]
    private var mB: [Int: [Float]] = [:]
    private var vB: [Int: [Float]] = [:]

    private let beta1: Float = 0.9
    private let beta2: Float = 0.999
    private let epsilon: Float = 1e-8

    public init() {}

    public mutating func reset() {
        t = 0
        mW = [:]
        vW = [:]
        mB = [:]
        vB = [:]
    }

    public mutating func update(
        layerIndex: Int,
        layer: DenseLayer,
        gradW: Tensor,
        gradB: [Float],
        learningRate: Float,
        clip: Float?
    ) {
        t += 1

        let clippedGradW = gradW.clipped(limit: clip)
        let clippedGradB: [Float] = gradB.enumerated().map { index, value in
            guard let clip else { return value }
            return MathHelpers.clamp(value, min: -clip, max: clip)
        }

        let currentMW = mW[layerIndex] ?? Tensor(rows: gradW.rows, cols: gradW.cols)
        let currentVW = vW[layerIndex] ?? Tensor(rows: gradW.rows, cols: gradW.cols)
        let currentMB = mB[layerIndex] ?? Array(repeating: 0, count: gradB.count)
        let currentVB = vB[layerIndex] ?? Array(repeating: 0, count: gradB.count)

        var nextMW = currentMW
        var nextVW = currentVW
        var nextMB = currentMB
        var nextVB = currentVB

        let biasCorrection1 = 1 - Foundation.pow(beta1, Float(t))
        let biasCorrection2 = 1 - Foundation.pow(beta2, Float(t))

        for i in layer.weights.data.indices {
            nextMW.data[i] = beta1 * currentMW.data[i] + (1 - beta1) * clippedGradW.data[i]
            nextVW.data[i] = beta2 * currentVW.data[i] + (1 - beta2) * clippedGradW.data[i] * clippedGradW.data[i]

            let mHat = nextMW.data[i] / max(biasCorrection1, epsilon)
            let vHat = nextVW.data[i] / max(biasCorrection2, epsilon)
            layer.weights.data[i] -= learningRate * mHat / (Foundation.sqrt(vHat) + epsilon)
        }

        for i in layer.bias.indices {
            nextMB[i] = beta1 * currentMB[i] + (1 - beta1) * clippedGradB[i]
            nextVB[i] = beta2 * currentVB[i] + (1 - beta2) * clippedGradB[i] * clippedGradB[i]

            let mHat = nextMB[i] / max(biasCorrection1, epsilon)
            let vHat = nextVB[i] / max(biasCorrection2, epsilon)
            layer.bias[i] -= learningRate * mHat / (Foundation.sqrt(vHat) + epsilon)
        }

        mW[layerIndex] = nextMW
        vW[layerIndex] = nextVW
        mB[layerIndex] = nextMB
        vB[layerIndex] = nextVB
    }
}
