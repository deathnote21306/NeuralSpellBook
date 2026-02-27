import SwiftUI

struct SpellSceneColumns<Left: View, Right: View>: View {
    let left: Left
    let right: Right

    init(@ViewBuilder left: () -> Left, @ViewBuilder right: () -> Right) {
        self.left = left()
        self.right = right()
    }

    var body: some View {
        GeometryReader { proxy in
            let wide = proxy.size.width > 880
            if wide {
                HStack(alignment: .top, spacing: 22) {
                    left.frame(maxWidth: .infinity, alignment: .top)
                    right.frame(maxWidth: .infinity, alignment: .top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } else {
                VStack(spacing: 18) {
                    left
                    right
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.bottom, 10)
            }
        }
    }
}
