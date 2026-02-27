import SwiftUI

public struct SliderRow: View {
    public let title: String
    @Binding public var value: Float
    public let range: ClosedRange<Float>
    public let step: Float
    public var format: String = "%.3f"

    public init(
        title: String,
        value: Binding<Float>,
        range: ClosedRange<Float>,
        step: Float = 0.001,
        format: String = "%.3f"
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.format = format
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(Typography.body)
                Spacer()
                Text(String(format: format, value))
                    .font(Typography.mono)
                    .foregroundStyle(.secondary)
            }
            Slider(value: $value, in: range, step: step)
                .tint(Theme.starlight)
        }
    }
}
