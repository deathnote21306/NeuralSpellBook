import Foundation

public enum DiagnosticsSeverity: Int, Comparable {
    case high = 0
    case medium = 1
    case low = 2

    public static func < (lhs: DiagnosticsSeverity, rhs: DiagnosticsSeverity) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public enum DiagnosticsFixAction: Hashable {
    case reduceLearningRate
    case increaseLearningRate
    case increaseBatchSize
    case normalizeDataset
    case matchOutputForBinary
    case enableDropoutAndEarlyStop
    case enableGradientClipping
}

public struct DiagnosticsIssue: Identifiable, Hashable {
    public let id = UUID()
    public let icon: String
    public let title: String
    public let explanation: String
    public let fixTitle: String
    public let severity: DiagnosticsSeverity
    public let fixAction: DiagnosticsFixAction

    public init(
        icon: String,
        title: String,
        explanation: String,
        fixTitle: String,
        severity: DiagnosticsSeverity,
        fixAction: DiagnosticsFixAction
    ) {
        self.icon = icon
        self.title = title
        self.explanation = explanation
        self.fixTitle = fixTitle
        self.severity = severity
        self.fixAction = fixAction
    }
}
