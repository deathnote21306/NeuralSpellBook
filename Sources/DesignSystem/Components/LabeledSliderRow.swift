import SwiftUI

public struct LabeledSliderRow: View {
    public let title: String
    public let helper: String
    @Binding public var value: Float
    public let range: ClosedRange<Float>
    public let step: Float
    public var format: String = "%.3f"

    public init(
        title: String,
        helper: String,
        value: Binding<Float>,
        range: ClosedRange<Float>,
        step: Float = 0.001,
        format: String = "%.3f"
    ) {
        self.title = title
        self.helper = helper
        self._value = value
        self.range = range
        self.step = step
        self.format = format
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(Typography.body)
                        .foregroundStyle(.white)
                    Text(helper)
                        .font(Typography.caption)
                        .foregroundStyle(.white.opacity(0.66))
                }

                Spacer(minLength: 8)

                Text(String(format: format, value))
                    .font(Typography.mono)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.16), in: Capsule(style: .continuous))
            }

            Slider(value: $value, in: range, step: step)
                .tint(Theme.starlight)
                .frame(minHeight: 44)
        }
        .padding(10)
        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}
