import SwiftUI

public struct WhySheet: View {
    @Environment(\.dismiss) private var dismiss

    public let title: String
    public let explanation: String

    public init(title: String, explanation: String) {
        self.title = title
        self.explanation = explanation
    }

    public var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(Typography.title)
                    .foregroundStyle(.white)

                Text(explanation)
                    .font(Typography.body)
                    .foregroundStyle(.white.opacity(0.9))

                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Why This Matters")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
