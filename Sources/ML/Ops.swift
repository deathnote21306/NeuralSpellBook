import Foundation

public enum Ops {
    public static func matmul(_ a: Tensor, _ b: Tensor) -> Tensor {
        precondition(a.cols == b.rows, "Incompatible tensor shapes for matmul")

        var output = Tensor(rows: a.rows, cols: b.cols)
        for r in 0..<a.rows {
            for c in 0..<b.cols {
                var sum: Float = 0
                for k in 0..<a.cols {
                    sum += a[r, k] * b[k, c]
                }
                output[r, c] = sum
            }
        }
        return output
    }

    public static func sumRows(_ tensor: Tensor) -> [Float] {
        var sums = Array(repeating: Float(0), count: tensor.cols)
        for c in 0..<tensor.cols {
            var value: Float = 0
            for r in 0..<tensor.rows {
                value += tensor[r, c]
            }
            sums[c] = value
        }
        return sums
    }

    public static func argmax(_ tensor: Tensor, row: Int) -> Int {
        guard tensor.cols > 0 else { return 0 }
        var bestIndex = 0
        var bestValue = tensor[row, 0]
        for c in 1..<tensor.cols {
            if tensor[row, c] > bestValue {
                bestValue = tensor[row, c]
                bestIndex = c
            }
        }
        return bestIndex
    }

    public static func softmax(_ logits: Tensor) -> Tensor {
        var probabilities = Tensor(rows: logits.rows, cols: logits.cols)
        for r in 0..<logits.rows {
            var maxLogit = logits[r, 0]
            for c in 1..<logits.cols {
                maxLogit = max(maxLogit, logits[r, c])
            }

            var sumExp: Float = 0
            for c in 0..<logits.cols {
                let expValue = Foundation.exp(logits[r, c] - maxLogit)
                probabilities[r, c] = expValue
                sumExp += expValue
            }

            let safe = max(sumExp, 1e-8)
            for c in 0..<logits.cols {
                probabilities[r, c] /= safe
            }
        }
        return probabilities
    }
}
