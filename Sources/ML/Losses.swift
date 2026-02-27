import Foundation

public enum OutputMode: String, CaseIterable, Identifiable {
    case sigmoid = "Sigmoid"
    case softmax = "Softmax"

    public var id: String { rawValue }
}

public struct LossResult {
    public var loss: Float
    public var probabilities: Tensor
    public var gradient: Tensor
}

public enum Losses {
    public static func binaryCrossEntropy(probabilities: Tensor, labels: [Int]) -> LossResult {
        precondition(probabilities.cols == 1, "Binary cross entropy expects one output column")
        precondition(probabilities.rows == labels.count, "Row/label mismatch")

        var loss: Float = 0
        var gradient = Tensor(rows: probabilities.rows, cols: 1)

        for row in 0..<probabilities.rows {
            let y = Float(labels[row])
            let p = MathHelpers.clamp(probabilities[row, 0], min: 1e-6, max: 1 - 1e-6)
            loss += -(y * Foundation.log(p) + (1 - y) * Foundation.log(1 - p))
            gradient[row, 0] = p - y
        }

        loss /= Float(max(labels.count, 1))
        return LossResult(loss: loss, probabilities: probabilities, gradient: gradient)
    }

    public static func softmaxCrossEntropy(logits: Tensor, labels: [Int]) -> LossResult {
        precondition(logits.rows == labels.count, "Row/label mismatch")

        let probabilities = Ops.softmax(logits)
        var loss: Float = 0
        var gradient = probabilities

        for row in 0..<logits.rows {
            let label = MathHelpers.clamp(labels[row], min: 0, max: logits.cols - 1)
            let p = MathHelpers.clamp(probabilities[row, label], min: 1e-6, max: 1)
            loss += -Foundation.log(p)
            gradient[row, label] -= 1
        }

        loss /= Float(max(labels.count, 1))
        return LossResult(loss: loss, probabilities: probabilities, gradient: gradient)
    }
}
