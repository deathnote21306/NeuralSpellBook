import Foundation
import SwiftUI

@MainActor
public final class DiagnosticsViewModel: ObservableObject {
    @Published public var issues: [DiagnosticsIssue] = []
    @Published public var toastText: String?

    public init() {}

    public func refresh(using vm: SandboxViewModel) {
        var found: [DiagnosticsIssue] = []

        let losses = vm.trainLossValues
        let lossVariance = vm.lossVariance
        let lossSlope = vm.lossSlope
        let trainAcc = vm.trainAccuracy
        let valAcc = vm.validationAccuracy

        if vm.learningRate > 0.12,
           losses.count > 8,
           (lossSlope > 0.004 || lossVariance > 0.04) {
            found.append(
                DiagnosticsIssue(
                    icon: "bolt.trianglebadge.exclamationmark",
                    title: "Learning rate is too high",
                    explanation: "The instability meter is oscillating because updates overshoot good weights.",
                    fixTitle: "Reduce LR + clip",
                    severity: .high,
                    fixAction: .reduceLearningRate
                )
            )
        }

        if vm.learningRate < 0.004,
           losses.count > 10,
           abs(lossSlope) < 0.0015,
           trainAcc < 0.8 {
            found.append(
                DiagnosticsIssue(
                    icon: "tortoise",
                    title: "Learning rate is too low",
                    explanation: "Updates are tiny, so the model barely changes.",
                    fixTitle: "Increase LR",
                    severity: .medium,
                    fixAction: .increaseLearningRate
                )
            )
        }

        if vm.batchSize < 8,
           losses.count > 6,
           lossVariance > 0.015 {
            found.append(
                DiagnosticsIssue(
                    icon: "waveform.path.ecg",
                    title: "Batch size is too small",
                    explanation: "Noisy mini-batches produce jumpy gradients.",
                    fixTitle: "Increase batch",
                    severity: .medium,
                    fixAction: .increaseBatchSize
                )
            )
        }

        if !vm.dataset.normalized || vm.dataset.meanDistanceFromZero > 0.25 || vm.dataset.featureSpread > 4.2 {
            found.append(
                DiagnosticsIssue(
                    icon: "arrow.up.and.down.and.sparkles",
                    title: "Missing normalization",
                    explanation: "Feature scales are uneven, which slows and destabilizes learning.",
                    fixTitle: "Normalize data",
                    severity: .high,
                    fixAction: .normalizeDataset
                )
            )
        }

        if vm.outputMode == .softmax && vm.dataset.hasBinaryLabels {
            found.append(
                DiagnosticsIssue(
                    icon: "arrow.triangle.swap",
                    title: "Output mismatch",
                    explanation: "This task is binary; sigmoid is the clearest match.",
                    fixTitle: "Switch to sigmoid",
                    severity: .low,
                    fixAction: .matchOutputForBinary
                )
            )
        }

        if vm.lossHistory.count > 24,
           trainAcc - valAcc > 0.12,
           valAcc < 0.8 {
            found.append(
                DiagnosticsIssue(
                    icon: "eye.trianglebadge.exclamationmark",
                    title: "Possible overfitting",
                    explanation: "Train accuracy rises while validation falls behind.",
                    fixTitle: "Add protection runes",
                    severity: .medium,
                    fixAction: .enableDropoutAndEarlyStop
                )
            )
        }

        issues = Array(found.sorted(by: { $0.severity < $1.severity }).prefix(3))
    }

    public func applyFix(_ issue: DiagnosticsIssue, to vm: SandboxViewModel) {
        switch issue.fixAction {
        case .reduceLearningRate:
            vm.learningRate = max(0.001, vm.learningRate * 0.45)
            vm.gradientClip = max(1.0, vm.gradientClip)
            vm.rebuildModel()
            toastText = "Smaller steps + clipping reduce overshoot."

        case .increaseLearningRate:
            vm.learningRate = min(0.2, vm.learningRate * 1.9)
            vm.rebuildModel()
            toastText = "Larger steps help the model move out of plateaus."

        case .increaseBatchSize:
            vm.batchSize = min(64, max(10, vm.batchSize * 2))
            toastText = "Bigger batches smooth noisy gradients."

        case .normalizeDataset:
            vm.normalizeDatasetNow()
            vm.rebuildModel()
            toastText = "Normalization aligns feature scales for steadier updates."

        case .matchOutputForBinary:
            vm.applyOutputModeFixForBinaryTask()
            toastText = "Sigmoid gives clearer binary probabilities."

        case .enableDropoutAndEarlyStop:
            vm.dropout = max(0.2, vm.dropout)
            vm.earlyStoppingEnabled = true
            vm.l2 = max(vm.l2, 0.001)
            vm.rebuildModel()
            toastText = "Regularization helps generalization on unseen data."

        case .enableGradientClipping:
            vm.gradientClip = max(vm.gradientClip, 1.2)
            vm.rebuildModel()
            toastText = "Gradient clipping tames unstable updates."
        }

        refresh(using: vm)
    }
}
