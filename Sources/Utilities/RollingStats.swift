import Foundation

public struct RollingStats {
    private(set) var values: [Float] = []
    public let maxCount: Int

    public init(maxCount: Int = 40) {
        self.maxCount = max(2, maxCount)
    }

    public mutating func push(_ value: Float) {
        values.append(value)
        if values.count > maxCount {
            values.removeFirst(values.count - maxCount)
        }
    }

    public var mean: Float {
        MathHelpers.mean(values)
    }

    public var variance: Float {
        guard values.count > 1 else { return 0 }
        let m = mean
        return values.map { ($0 - m) * ($0 - m) }.reduce(0, +) / Float(values.count)
    }

    public var slope: Float {
        guard values.count > 3 else { return 0 }
        let n = Float(values.count)
        let xMean = (n - 1) / 2
        let yMean = mean
        var numerator: Float = 0
        var denominator: Float = 0

        for (index, value) in values.enumerated() {
            let x = Float(index)
            numerator += (x - xMean) * (value - yMean)
            denominator += (x - xMean) * (x - xMean)
        }

        guard denominator > 1e-6 else { return 0 }
        return numerator / denominator
    }
}
