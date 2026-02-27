import Foundation

public enum DatasetType: String, CaseIterable, Identifiable {
    case linearlySeparable = "Linearly separable"
    case circles = "Circles"
    case xor = "XOR"

    public var id: String { rawValue }
}

public struct DatasetConfig {
    public var type: DatasetType = .linearlySeparable
    public var pointCount: Int = 220
    public var noise: Float = 0.14
    public var seed: UInt64 = 7
    public var normalize: Bool = true
    public var trainSplit: Float = 0.8

    public init() {}
}

public struct Dataset {
    public var points: [DataPoint]
    public var normalized: Bool

    public init(points: [DataPoint], normalized: Bool) {
        self.points = points
        self.normalized = normalized
    }

    public var trainingPoints: [DataPoint] {
        points.filter { $0.split == .train }
    }

    public var validationPoints: [DataPoint] {
        points.filter { $0.split == .validation }
    }

    public var hasBinaryLabels: Bool {
        Set(points.map(\.label)).isSubset(of: [0, 1])
    }

    public var featureSpread: Float {
        guard !points.isEmpty else { return 0 }
        let xs = points.map(\.x)
        let ys = points.map(\.y)
        let xRange = (xs.max() ?? 0) - (xs.min() ?? 0)
        let yRange = (ys.max() ?? 0) - (ys.min() ?? 0)
        return max(xRange, yRange)
    }

    public var meanDistanceFromZero: Float {
        guard !points.isEmpty else { return 0 }
        let mx = abs(MathHelpers.mean(points.map(\.x)))
        let my = abs(MathHelpers.mean(points.map(\.y)))
        return (mx + my) * 0.5
    }

    public static func make(config: DatasetConfig) -> Dataset {
        var rng = SeededRandom(seed: config.seed)
        var raw: [DataPoint] = []
        raw.reserveCapacity(config.pointCount)

        for i in 0..<config.pointCount {
            let sampled = samplePoint(type: config.type, index: i, rng: &rng)
            var x = sampled.x + gaussian(scale: config.noise, rng: &rng)
            var y = sampled.y + gaussian(scale: config.noise, rng: &rng)
            x = MathHelpers.clamp(x, min: -1.5, max: 1.5)
            y = MathHelpers.clamp(y, min: -1.5, max: 1.5)
            raw.append(DataPoint(x: x, y: y, label: sampled.label))
        }

        if config.normalize {
            normalize(points: &raw)
        }

        assignSplits(points: &raw, trainSplit: config.trainSplit, seed: config.seed &+ 77)
        return Dataset(points: raw, normalized: config.normalize)
    }

    public mutating func normalizeInPlace() {
        var mutable = points
        Self.normalize(points: &mutable)
        points = mutable
        normalized = true
    }

    private static func samplePoint(type: DatasetType, index: Int, rng: inout SeededRandom) -> (x: Float, y: Float, label: Int) {
        switch type {
        case .linearlySeparable:
            let x = rng.nextFloat(in: -1...1)
            let y = rng.nextFloat(in: -1...1)
            let boundary = 0.4 * x + 0.06
            return (x, y, y > boundary ? 1 : 0)

        case .circles:
            let theta = rng.nextFloat(in: 0...(2 * .pi))
            let outer = index.isMultiple(of: 2)
            let radius: Float = outer ? rng.nextFloat(in: 0.65...1.05) : rng.nextFloat(in: 0.1...0.45)
            let x = Foundation.cos(theta) * radius
            let y = Foundation.sin(theta) * radius
            return (x, y, outer ? 1 : 0)

        case .xor:
            let x = rng.nextFloat(in: -1...1)
            let y = rng.nextFloat(in: -1...1)
            let label = ((x > 0 && y > 0) || (x < 0 && y < 0)) ? 0 : 1
            return (x, y, label)
        }
    }

    private static func gaussian(scale: Float, rng: inout SeededRandom) -> Float {
        guard scale > 0 else { return 0 }
        let u1 = max(rng.nextFloat(), 1e-5)
        let u2 = max(rng.nextFloat(), 1e-5)
        let z = Foundation.sqrt(-2 * Foundation.log(u1)) * Foundation.cos(2 * .pi * u2)
        return z * scale
    }

    private static func normalize(points: inout [DataPoint]) {
        guard !points.isEmpty else { return }
        let mx = MathHelpers.mean(points.map(\.x))
        let my = MathHelpers.mean(points.map(\.y))
        let sx = MathHelpers.std(points.map(\.x))
        let sy = MathHelpers.std(points.map(\.y))

        for index in points.indices {
            points[index].x = (points[index].x - mx) / sx
            points[index].y = (points[index].y - my) / sy
        }
    }

    private static func assignSplits(points: inout [DataPoint], trainSplit: Float, seed: UInt64) {
        var order = Array(points.indices)
        var rng = SeededRandom(seed: seed)

        for i in order.indices.reversed() {
            let j = Int(rng.next() % UInt64(i + 1))
            order.swapAt(i, j)
        }

        let clampedSplit = MathHelpers.clamp(trainSplit, min: 0.5, max: 0.95)
        let trainCount = Int(Float(points.count) * clampedSplit)
        let trainSet = Set(order.prefix(trainCount))

        for index in points.indices {
            points[index].split = trainSet.contains(index) ? .train : .validation
        }
    }
}
