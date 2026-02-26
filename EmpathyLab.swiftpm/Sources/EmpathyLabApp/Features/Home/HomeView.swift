import SwiftUI

public struct HomeView: View {
    public let onStartExperience: () -> Void
    public let onOpenAbout: () -> Void

    public init(
        onStartExperience: @escaping () -> Void,
        onOpenAbout: @escaping () -> Void
    ) {
        self.onStartExperience = onStartExperience
        self.onOpenAbout = onOpenAbout
    }

    public var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Empathy Lab")
                .font(.largeTitle)
                .fontWeight(.semibold)

            Button("Experience (3 min)", action: onStartExperience)
                .buttonStyle(.borderedProminent)

            Button("About & Ethics", action: onOpenAbout)
                .buttonStyle(.bordered)

            Spacer()
        }
        .padding(24)
    }
}
