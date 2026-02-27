import SwiftUI

struct ScatterPlotView: View {
    let points: [DataPoint]

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            Canvas { context, _ in
                for point in points {
                    let x = normalized(point.x, in: -1.6...1.6) * width
                    let y = (1 - normalized(point.y, in: -1.6...1.6)) * height
                    let radius: CGFloat = point.split == .train ? 3.4 : 2.6
                    let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)

                    let fill: Color
                    if point.label == 1 {
                        fill = point.split == .train ? Theme.starlight : Theme.starlight.opacity(0.55)
                    } else {
                        fill = point.split == .train ? Theme.ember : Theme.ember.opacity(0.55)
                    }

                    context.fill(Path(ellipseIn: rect), with: .color(fill))
                }
            }
        }
    }

    private func normalized(_ value: Float, in range: ClosedRange<Float>) -> CGFloat {
        let t = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return CGFloat(MathHelpers.clamp(t, min: 0, max: 1))
    }
}
