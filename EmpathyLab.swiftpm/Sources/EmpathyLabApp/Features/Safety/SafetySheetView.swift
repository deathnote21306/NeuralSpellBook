import SwiftUI

public struct SafetySheetView: View {
    public let onStart: () -> Void
    public let onCancel: () -> Void

    public init(
        onStart: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.onStart = onStart
        self.onCancel = onCancel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Safety Notice")
                .font(.title2)
                .fontWeight(.semibold)

            Text("This simulation may feel visually or physically demanding. You can stop at any time.")
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button("Cancel", action: onCancel)
                    .buttonStyle(.bordered)

                Button("Start", action: onStart)
                    .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(24)
    }
}
