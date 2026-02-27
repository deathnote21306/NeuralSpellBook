import SwiftUI

struct DecisionBoundaryCanvas: View {
    let values: [Float]
    let resolution: Int
    var chaosLevel: Float = 0
    var morphIntensity: Float = 0
    var lossPulseToken: Int = 0
    var lossPulseIsGood: Bool = true
    var manaTurbulence: Float = 0

    @State private var pulseAmount: CGFloat = 0

    var body: some View {
        Canvas { context, size in
            let n = max(resolution, 2)
            guard values.count >= n * n else { return }

            let cellW = size.width / CGFloat(n)
            let cellH = size.height / CGFloat(n)
            let morph = CGFloat(MathHelpers.clamp(morphIntensity, min: 0, max: 1))
            let turbulence = CGFloat(MathHelpers.clamp(manaTurbulence, min: 0, max: 1))
            let chaos = CGFloat(MathHelpers.clamp(chaosLevel, min: 0, max: 1))

            for row in 0..<n {
                for col in 0..<n {
                    let index = row * n + col
                    let probability = MathHelpers.clamp(values[index], min: 0, max: 1)

                    let signed = probability * 2 - 1
                    let baseColor = signed >= 0 ? Theme.boundaryPositive : Theme.boundaryNegative
                    let alpha = 0.15 + CGFloat(abs(signed)) * 0.45
                    let wave = sin(Double(row) * 0.32 + Double(col) * 0.26) * 0.5 + 0.5
                    let jitter = (chaos * 0.07 + turbulence * 0.05 + morph * 0.09) * CGFloat(wave)
                    let pulseTint = lossPulseIsGood ? Theme.mint : Theme.danger

                    let rect = CGRect(
                        x: CGFloat(col) * cellW,
                        y: CGFloat(row) * cellH,
                        width: cellW + jitter,
                        height: cellH + jitter
                    )

                    context.fill(Path(rect), with: .color(baseColor.opacity(alpha + pulseAmount * 0.08)))
                    if pulseAmount > 0.01 {
                        context.stroke(
                            Path(rect),
                            with: .color(pulseTint.opacity(0.12 * pulseAmount)),
                            lineWidth: 0.25 + pulseAmount * 0.55
                        )
                    }
                }
            }
        }
        .onChange(of: lossPulseToken) { _, _ in
            withAnimation(.easeOut(duration: 0.14)) {
                pulseAmount = 1
            }
            Task {
                try? await Task.sleep(nanoseconds: 280_000_000)
                withAnimation(.easeOut(duration: 0.28)) {
                    pulseAmount = 0
                }
            }
        }
    }
}
