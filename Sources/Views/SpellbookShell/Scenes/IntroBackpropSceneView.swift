import SwiftUI

struct IntroBackpropSceneView: View {
    let onBegin: () -> Void

    var body: some View {
        IntroBeatSceneTemplate(
            canvas: { IntroBeat2Canvas() },
            tag: "Chapter III · Coming Up",
            headline: "The error flows\nbackwards.",
            bodyText: "We know the loss — now we must fix it. Backpropagation traces the error back through every layer, assigning each weight its share of blame, then nudging them all in the right direction. This is how the network actually learns.",
            analogy: "✦ Every AI weight ever trained was adjusted this way",
            buttonTitle: "Begin Chapter III →",
            onBegin: onBegin
        )
    }
}
