import Foundation

public final class DenseLayer {
    public let inputSize: Int
    public let outputSize: Int
    public var weights: Tensor
    public var bias: [Float]

    public init(inputSize: Int, outputSize: Int, generator: inout SeededRandom) {
        self.inputSize = inputSize
        self.outputSize = outputSize

        // Xavier-ish range keeps activations readable in early steps.
        let scale = Float(Foundation.sqrt(6.0 / Float(inputSize + outputSize)))
        self.weights = Tensor.random(rows: inputSize, cols: outputSize, in: -scale...scale, generator: &generator)
        self.bias = Array(repeating: 0, count: outputSize)
    }

    public func forward(_ input: Tensor) -> Tensor {
        Ops.matmul(input, weights).addRowVector(bias)
    }
}

public struct DropoutLayer {
    public var rate: Float

    public init(rate: Float) {
        self.rate = MathHelpers.clamp(rate, min: 0, max: 0.9)
    }

    public mutating func apply(_ tensor: Tensor, rng: inout SeededRandom) -> (output: Tensor, mask: Tensor) {
        let keep = max(1 - rate, 1e-5)
        var mask = Tensor(rows: tensor.rows, cols: tensor.cols, repeating: 1)

        for index in mask.data.indices {
            mask.data[index] = rng.nextFloat() < keep ? 1 : 0
        }

        let dropped = tensor.hadamard(mask) / keep
        return (dropped, mask)
    }
}
