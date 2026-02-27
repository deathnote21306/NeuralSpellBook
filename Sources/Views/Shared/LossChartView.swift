import SwiftUI

struct LossChartView: View {
    let points: [TrainingHistoryPoint]

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            Canvas { context, _ in
                guard points.count > 1 else { return }

                let losses = points.map(\.loss)
                let minLoss = losses.min() ?? 0
                let maxLoss = max((losses.max() ?? 1), minLoss + 0.001)

                var lossPath = Path()
                for (index, point) in points.enumerated() {
                    let x = CGFloat(index) / CGFloat(points.count - 1) * width
                    let t = (point.loss - minLoss) / (maxLoss - minLoss)
                    let y = height - CGFloat(t) * height
                    if index == 0 { lossPath.move(to: CGPoint(x: x, y: y)) }
                    else { lossPath.addLine(to: CGPoint(x: x, y: y)) }
                }

                context.stroke(lossPath, with: .color(Theme.ember), style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))

                var valPath = Path()
                for (index, point) in points.enumerated() {
                    let x = CGFloat(index) / CGFloat(points.count - 1) * width
                    let y = height - CGFloat(point.validationAccuracy) * height
                    if index == 0 { valPath.move(to: CGPoint(x: x, y: y)) }
                    else { valPath.addLine(to: CGPoint(x: x, y: y)) }
                }

                context.stroke(valPath, with: .color(Theme.mint), style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round, dash: [5, 4]))
            }
        }
        .frame(height: 150)
    }
}
