import SwiftUI

// UX Friction Audit Checklist (before this layout refactor)
// [x] No consistent "do this now" anchor at the top of panels.
// [x] Guided and Free Play used different spatial rules and felt inconsistent.
// [x] Right stage could become too small due to nested scrolling.
// [x] Left panel hierarchy was unclear when many cards were visible.
// [x] iPad landscape left unused whitespace in several states.
// [x] Controls and explanation appeared at the same visual priority.
// [x] Users lacked persistent context (where am I, what is next, why it matters).
// [x] Narrow layouts did not clearly separate panel flow from visualization flow.
struct SplitLabLayout<TopBar: View, LeftPanel: View, RightStage: View, BottomBar: View>: View {
    var wideBreakpoint: CGFloat = 980
    var leftRatio: CGFloat = 0.33
    var spacing: CGFloat = 12

    @ViewBuilder var topBar: () -> TopBar
    @ViewBuilder var leftPanel: () -> LeftPanel
    @ViewBuilder var rightStage: () -> RightStage

    private let bottomBarBuilder: (() -> BottomBar)?

    init(
        wideBreakpoint: CGFloat = 980,
        leftRatio: CGFloat = 0.33,
        spacing: CGFloat = 12,
        @ViewBuilder topBar: @escaping () -> TopBar,
        @ViewBuilder leftPanel: @escaping () -> LeftPanel,
        @ViewBuilder rightStage: @escaping () -> RightStage,
        @ViewBuilder bottomBar: @escaping () -> BottomBar
    ) {
        self.wideBreakpoint = wideBreakpoint
        self.leftRatio = leftRatio
        self.spacing = spacing
        self.topBar = topBar
        self.leftPanel = leftPanel
        self.rightStage = rightStage
        self.bottomBarBuilder = bottomBar
    }

    init(
        wideBreakpoint: CGFloat = 980,
        leftRatio: CGFloat = 0.33,
        spacing: CGFloat = 12,
        @ViewBuilder topBar: @escaping () -> TopBar,
        @ViewBuilder leftPanel: @escaping () -> LeftPanel,
        @ViewBuilder rightStage: @escaping () -> RightStage
    ) where BottomBar == EmptyView {
        self.wideBreakpoint = wideBreakpoint
        self.leftRatio = leftRatio
        self.spacing = spacing
        self.topBar = topBar
        self.leftPanel = leftPanel
        self.rightStage = rightStage
        self.bottomBarBuilder = nil
    }

    var body: some View {
        GeometryReader { proxy in
            let isWide = proxy.size.width >= wideBreakpoint
            let leftWidth = min(520, max(320, proxy.size.width * leftRatio))

            VStack(spacing: spacing) {
                topBar()
                    .frame(maxWidth: .infinity)

                if isWide {
                    HStack(alignment: .top, spacing: spacing) {
                        ScrollView {
                            leftPanel()
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .padding(.bottom, 4)
                        }
                        .scrollIndicators(.hidden)
                        .frame(width: leftWidth)

                        rightStage()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                } else {
                    ScrollView {
                        VStack(spacing: spacing) {
                            leftPanel()
                            Divider().overlay(Color.white.opacity(0.2))
                            rightStage()
                                .frame(minHeight: min(560, max(360, proxy.size.height * 0.44)))
                        }
                    }
                    .scrollIndicators(.hidden)
                    .frame(maxHeight: .infinity)
                }

                if let bottomBarBuilder {
                    bottomBarBuilder()
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}
