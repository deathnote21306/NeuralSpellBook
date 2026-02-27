import SwiftUI

struct IntroForwardSceneView: View {
    let onBegin: () -> Void

    var body: some View {
        IntroBeatSceneTemplate(
            canvas: { IntroBeat0Canvas() },
            tag: "Chapter I · Coming Up",
            headline: "A chain of\nsimple decisions.",
            bodyText: "Each node receives a number, multiplies it by a learned weight, and passes the result forward. Hundreds of these tiny steps, chained together, produce one final prediction.",
            analogy: "✦ Like passing a whisper through a crowd — each person transforms it",
            buttonTitle: "Begin Chapter I →",
            onBegin: onBegin
        )
    }
}
