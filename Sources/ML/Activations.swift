import Foundation

public enum ActivationKind: String, CaseIterable, Identifiable {
    case relu = "ReLU"
    case tanh = "tanh"

    public var id: String { rawValue }

    public func apply(to tensor: Tensor) -> Tensor {
        switch self {
        case .relu:
            return tensor.map { max($0, 0) }
        case .tanh:
            return tensor.map { Foundation.tanh($0) }
        }
    }

    public func derivative(forActivated activated: Tensor) -> Tensor {
        switch self {
        case .relu:
            return activated.map { MathHelpers.reluDerivative($0) }
        case .tanh:
            return activated.map { MathHelpers.tanhDerivative($0) }
        }
    }
}
