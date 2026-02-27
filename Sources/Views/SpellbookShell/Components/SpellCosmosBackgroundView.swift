import SwiftUI

struct SpellCosmosBackgroundView: View {
    var particleCount: Int = 130

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate

                for i in 0..<particleCount {
                    let seed = Double(i) * 1.618
                    let x = (sin(seed * 1.27 + t * 0.09) * 0.5 + 0.5) * size.width
                    let y = (cos(seed * 0.93 + t * 0.07) * 0.5 + 0.5) * size.height
                    let radius = CGFloat(0.6 + Double(i % 4) * 0.45)
                    let gold = i.isMultiple(of: 3)
                    let color = gold
                        ? Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.35)
                        : Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.32)

                    let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                    context.fill(Path(ellipseIn: rect), with: .color(color))
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
