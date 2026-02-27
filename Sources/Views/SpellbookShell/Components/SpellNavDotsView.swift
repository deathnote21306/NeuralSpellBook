import SwiftUI

struct SpellNavDotsView: View {
    let scenes: [SpellSceneID]
    let activeScene: SpellSceneID
    let onTapScene: (SpellSceneID) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(scenes) { scene in
                    let isActive = scene == activeScene
                    Button {
                        onTapScene(scene)
                    } label: {
                        Capsule(style: .continuous)
                            .fill(isActive ? Color(red: 0.49, green: 0.38, blue: 1.0) : Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.25))
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.45), lineWidth: 1)
                            )
                            .frame(width: isActive ? 22 : 6, height: 6)
                            .shadow(color: isActive ? Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.55) : .clear, radius: 6)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Jump to \(scene.displayTitle)")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.28), in: Capsule(style: .continuous))
        }
        .frame(maxWidth: 440)
    }
}
