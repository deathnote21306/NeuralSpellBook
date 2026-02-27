import Foundation

public struct SeededRandom: RandomNumberGenerator {
    private var state: UInt64

    public init(seed: UInt64) {
        self.state = seed == 0 ? 0xA5A5_5A5A_D3C3_B2A1 : seed
    }

    public mutating func next() -> UInt64 {
        state ^= state >> 12
        state ^= state << 25
        state ^= state >> 27
        return state &* 2685821657736338717
    }

    public mutating func nextFloat() -> Float {
        Float(next() & 0x00FF_FFFF) / Float(0x00FF_FFFF)
    }

    public mutating func nextFloat(in range: ClosedRange<Float>) -> Float {
        range.lowerBound + (range.upperBound - range.lowerBound) * nextFloat()
    }

    public mutating func nextInt(in range: ClosedRange<Int>) -> Int {
        let width = max(1, range.upperBound - range.lowerBound + 1)
        return range.lowerBound + Int(next() % UInt64(width))
    }
}
