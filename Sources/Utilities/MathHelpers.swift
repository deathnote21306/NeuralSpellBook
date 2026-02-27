import Foundation

public enum MathHelpers {
    public static func clamp<T: Comparable>(_ value: T, min lower: T, max upper: T) -> T {
        Swift.min(upper, Swift.max(lower, value))
    }

    public static func mean(_ values: [Float]) -> Float {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Float(values.count)
    }

    public static func std(_ values: [Float]) -> Float {
        guard values.count > 1 else { return 1 }
        let m = mean(values)
        let variance = values.map { ($0 - m) * ($0 - m) }.reduce(0, +) / Float(values.count)
        return max(Foundation.sqrt(variance), 1e-5)
    }

    public static func sigmoid(_ x: Float) -> Float {
        1 / (1 + Foundation.exp(-x))
    }

    public static func tanhDerivative(_ activated: Float) -> Float {
        1 - activated * activated
    }

    public static func reluDerivative(_ activated: Float) -> Float {
        activated > 0 ? 1 : 0
    }

    public static func lerp(from: Float, to: Float, t: Float) -> Float {
        from + (to - from) * t
    }

    public static func movingAverage(_ values: [Float], window: Int) -> [Float] {
        guard window > 1, values.count >= window else { return values }
        var result: [Float] = []
        result.reserveCapacity(values.count - window + 1)
        var sum: Float = 0
        for i in values.indices {
            sum += values[i]
            if i >= window { sum -= values[i - window] }
            if i >= window - 1 { result.append(sum / Float(window)) }
        }
        return result
    }
}
