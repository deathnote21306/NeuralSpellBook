import SwiftUI

public struct ParticlesBackground: View {
    public var density: Int = 90
    public var speed: Double = 0.35

    public init(density: Int = 90, speed: Double = 0.35) {
        self.density = density
        self.speed = speed
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate * speed
                for i in 0..<density {
                    let point = particlePoint(index: i, time: t, size: size)
                    let radius = particleRadius(index: i)
                    let alpha = particleAlpha(index: i, time: t)
                    let rect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
                    context.fill(Path(ellipseIn: rect), with: .color(Color.white.opacity(alpha)))
                }
            }
            .ignoresSafeArea()
        }
        .allowsHitTesting(false)
    }

    private func particlePoint(index: Int, time: Double, size: CGSize) -> CGPoint {
        let seed = Double(index) * 1.618
        let xNorm = sin(seed * 2.1 + time * 0.6) * 0.45 + 0.5
        let yWave = cos(seed * 1.3 + time * 0.4) * 0.5 + 0.5
        let yNorm = (yWave + Double(index % 9) * 0.08).truncatingRemainder(dividingBy: 1.2)
        return CGPoint(x: xNorm * size.width, y: yNorm * size.height)
    }

    private func particleRadius(index: Int) -> CGFloat {
        CGFloat(1.2 + Double(index % 4))
    }

    private func particleAlpha(index: Int, time: Double) -> Double {
        let seed = Double(index) * 1.618
        return 0.08 + 0.17 * (sin(seed + time) * 0.5 + 0.5)
    }
}
