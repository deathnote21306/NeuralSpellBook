import SwiftUI

struct IntroHyperSceneView: View {
    let onBegin: () -> Void

    var body: some View {
        IntroBeatSceneTemplate(
            canvas: { IntroBeat3Canvas() },
            tag: "Chapter IV · Coming Up",
            headline: "Three dials.\nInfinite consequences.",
            bodyText: "The correction loop works — but how fast should it learn? How many examples at once? How many rounds? These are hyperparameters: the human choices that govern the entire training process. Get them wrong, and the network never converges.",
            analogy: "✦ The most human part of machine learning",
            buttonTitle: "Begin Chapter IV →",
            onBegin: onBegin
        )
    }
}
