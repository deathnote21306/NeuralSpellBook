import SwiftUI

public struct DesignFixPayBillView: View {
    public let onFinishFix: () -> Void

    @State private var amount = ""
    @State private var dueDate = Date()

    public init(onFinishFix: @escaping () -> Void) {
        self.onFinishFix = onFinishFix
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text("Design Fix: Pay a Bill (After)")
                .font(.largeTitle)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                TextField("Amount", text: $amount)
                    .textFieldStyle(.roundedBorder)
                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button("Finish Fix", action: onFinishFix)
                .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding(24)
    }
}
