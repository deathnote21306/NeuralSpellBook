import SwiftUI

public struct AboutView: View {
    public let onBack: () -> Void

    public init(onBack: @escaping () -> Void) {
        self.onBack = onBack
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("About & Ethics")
                .font(.largeTitle)
                .fontWeight(.semibold)

            ScrollView {
                Text("Empathy Lab is an offline learning prototype. Simulations are approximations and do not replace testing with real users. No data leaves this device.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button("Back", action: onBack)
                .buttonStyle(.bordered)
        }
        .padding(24)
    }
}
