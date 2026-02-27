import Foundation

public struct Tensor: Equatable {
    public var rows: Int
    public var cols: Int
    public var data: [Float]

    public init(rows: Int, cols: Int, repeating value: Float = 0) {
        self.rows = rows
        self.cols = cols
        self.data = Array(repeating: value, count: rows * cols)
    }

    public init(rows: Int, cols: Int, data: [Float]) {
        self.rows = rows
        self.cols = cols
        self.data = data
    }

    public var shape: [Int] { [rows, cols] }

    public subscript(_ row: Int, _ col: Int) -> Float {
        get { data[row * cols + col] }
        set { data[row * cols + col] = newValue }
    }

    public static func random(
        rows: Int,
        cols: Int,
        in range: ClosedRange<Float>,
        generator: inout SeededRandom
    ) -> Tensor {
        var values: [Float] = []
        values.reserveCapacity(rows * cols)
        for _ in 0..<(rows * cols) {
            values.append(generator.nextFloat(in: range))
        }
        return Tensor(rows: rows, cols: cols, data: values)
    }

    public func transposed() -> Tensor {
        var result = Tensor(rows: cols, cols: rows)
        for r in 0..<rows {
            for c in 0..<cols {
                result[c, r] = self[r, c]
            }
        }
        return result
    }

    public func map(_ transform: (Float) -> Float) -> Tensor {
        Tensor(rows: rows, cols: cols, data: data.map(transform))
    }

    public func hadamard(_ other: Tensor) -> Tensor {
        var output = self
        for index in output.data.indices {
            output.data[index] *= other.data[index]
        }
        return output
    }

    public func addRowVector(_ vector: [Float]) -> Tensor {
        var result = self
        guard vector.count == cols else { return self }
        for r in 0..<rows {
            for c in 0..<cols {
                result[r, c] += vector[c]
            }
        }
        return result
    }

    public func meanAbs() -> Float {
        guard !data.isEmpty else { return 0 }
        return data.map { abs($0) }.reduce(0, +) / Float(data.count)
    }

    public func clipped(limit: Float?) -> Tensor {
        guard let limit, limit > 0 else { return self }
        return map { MathHelpers.clamp($0, min: -limit, max: limit) }
    }

    public func sampleValues(_ count: Int = 8) -> [Float] {
        Array(data.prefix(max(1, count)))
    }

    public var minValue: Float { data.min() ?? 0 }
    public var maxValue: Float { data.max() ?? 0 }
    public var meanValue: Float { MathHelpers.mean(data) }

    public static func +(lhs: Tensor, rhs: Tensor) -> Tensor {
        var result = lhs
        for index in result.data.indices {
            result.data[index] += rhs.data[index]
        }
        return result
    }

    public static func -(lhs: Tensor, rhs: Tensor) -> Tensor {
        var result = lhs
        for index in result.data.indices {
            result.data[index] -= rhs.data[index]
        }
        return result
    }

    public static func *(lhs: Tensor, rhs: Float) -> Tensor {
        lhs.map { $0 * rhs }
    }

    public static func /(lhs: Tensor, rhs: Float) -> Tensor {
        lhs.map { $0 / rhs }
    }
}
