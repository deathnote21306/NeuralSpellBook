import SwiftUI

struct IntroHyperSceneView: View {
    let onBegin: () -> Void

    var body: some View {
        IntroBeatSceneTemplate(
            canvas: { IntroBeat3Canvas() },
            chapterNumber: 4,
            chapterTitle: "Training\nthe Trainer",
            missionText: "Adjust 3 real settings — speed, batch size, rounds — and see how each one changes the entire learning outcome.",
            whyText: "These choices are made by humans, not the AI. Get them wrong and training fails. Get them right and magic happens.",
            buttonTitle: "PLAY CHAPTER IV",
            onBegin: onBegin
        )
    }
}
