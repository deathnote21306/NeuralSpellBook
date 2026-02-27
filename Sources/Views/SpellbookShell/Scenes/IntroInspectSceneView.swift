import SwiftUI

struct IntroInspectSceneView: View {
    let onBegin: () -> Void

    var body: some View {
        IntroBeatSceneTemplate(
            canvas: { IntroBeat4Canvas() },
            tag: "Chapter V · Coming Up",
            headline: "Pause. Look inside.\nWhat did it learn?",
            bodyText: "Training is done. Now we open the network and inspect each neuron — its activation value, what it detected, and how much blame it carried. This is the moment where the math becomes meaning.",
            analogy: "✦ Not a black box anymore — every node tells a story",
            buttonTitle: "Begin Chapter V →",
            onBegin: onBegin
        )
    }
}
