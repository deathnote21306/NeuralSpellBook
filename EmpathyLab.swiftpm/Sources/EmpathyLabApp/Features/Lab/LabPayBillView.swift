import SwiftUI

public struct LabPayBillView: View {
    public let onFinishLab: () -> Void

    @State private var amount = ""
    @State private var dueDate = Date()

    public init(onFinishLab: @escaping () -> Void) {
        self.onFinishLab = onFinishLab
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text("Lab: Pay a Bill (Before)")
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

            Button("Finish Lab", action: onFinishLab)
                .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding(24)
    }
}
