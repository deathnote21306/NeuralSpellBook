import SwiftUI

struct IntroLossSceneView: View {
    let onBegin: () -> Void

    var body: some View {
        IntroBeatSceneTemplate(
            canvas: { IntroBeat1Canvas() },
            tag: "Chapter II · Coming Up",
            headline: "Try. Fail. Measure.\nThe error has a number.",
            bodyText: "The network just made its first guess — and it was wrong. But how wrong, exactly? Loss is a single number that captures the distance between prediction and reality. Without it, there is nothing to correct.",
            analogy: "✦ You can't improve what you can't measure",
            buttonTitle: "Begin Chapter II →",
            onBegin: onBegin
        )
    }
}
