import Foundation
import SwiftUI

/*
 What is interactive now:
 - Forward cast, loss pulse, backprop ritual, weight emphasis, boundary morph, inspect mode, and mana turbulence are all transient UI states.
 - These states are triggered immediately by existing user actions so the stage reacts before/while ML updates complete.

 Action -> visual mapping:
 - Cast Prediction -> forward energy flow + output sigil reveal.
 - Loss changes -> instability pulse tint (good/bad) on boundary.
 - Backprop -> reverse thread flow.
 - Weight update -> strongest layers highlighted.
 - Learning-rate change -> mana turbulence state (chaos/stagnant/stable).
 - Rune tap -> inspect focus with highlighted rune and dimmed context.
*/
public enum SpellFlowDirection {
    case idle
    case forward
    case backward
}

public enum ManaFeedbackState: String {
    case balanced
    case chaos
    case stagnant
}

@MainActor
public final class SpellStageController: ObservableObject {
    @Published public private(set) var flowDirection: SpellFlowDirection = .idle
    @Published public private(set) var forwardCastToken: Int = 0
    @Published public private(set) var backpropToken: Int = 0
    @Published public private(set) var lossPulseToken: Int = 0
    @Published public private(set) var lossPulseIsGood: Bool = true
    @Published public private(set) var weightUpdateToken: Int = 0
    @Published public private(set) var emphasizedLayers: Set<Int> = []
    @Published public private(set) var boundaryMorphIntensity: Float = 0
    @Published public private(set) var inspectRuneID: UUID?
    @Published public private(set) var inspectMode: Bool = false
    @Published public private(set) var manaState: ManaFeedbackState = .balanced
    @Published public private(set) var manaTurbulence: Float = 0
    @Published public private(set) var spellIntentLine: String = "Cast prediction"
    @Published public private(set) var outputSigil: String?
    @Published public private(set) var outputSigilToken: Int = 0

    private var flowResetTask: Task<Void, Never>?
    private var emphasisResetTask: Task<Void, Never>?
    private var boundaryResetTask: Task<Void, Never>?

    public init() {}

    public func triggerForwardCast(outputSigil: String? = nil) {
        forwardCastToken += 1
        flowDirection = .forward
        spellIntentLine = "Spell intent: cast prediction"
        if let outputSigil {
            self.outputSigil = outputSigil
            outputSigilToken += 1
        }
        scheduleFlowReset()
    }

    public func revealOutputSigil(_ sigil: String?) {
        guard let sigil else { return }
        outputSigil = sigil
        outputSigilToken += 1
    }

    public func triggerLossPulse(isGood: Bool) {
        lossPulseIsGood = isGood
        lossPulseToken += 1
        spellIntentLine = isGood ? "Instability is falling" : "Instability spiked"
    }

    public func triggerBackpropRitual() {
        backpropToken += 1
        flowDirection = .backward
        spellIntentLine = "Spell intent: perform backprop ritual"
        scheduleFlowReset()
    }

    public func triggerWeightUpdateEmphasis(changedWeights: [Float]) {
        guard !changedWeights.isEmpty else {
            emphasizedLayers = []
            return
        }

        let topLayers = changedWeights
            .enumerated()
            .sorted { abs($0.element) > abs($1.element) }
            .prefix(2)
            .map { $0.offset + 1 }

        emphasizedLayers = Set(topLayers)
        weightUpdateToken += 1
        spellIntentLine = "Threads updated by gradient guidance"

        emphasisResetTask?.cancel()
        emphasisResetTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            self?.emphasizedLayers = []
        }
    }

    public func triggerBoundaryMorph(intensity: Float) {
        let capped = MathHelpers.clamp(intensity, min: 0, max: 1)
        withAnimation(.easeOut(duration: 0.3)) {
            boundaryMorphIntensity = max(boundaryMorphIntensity, capped)
        }

        boundaryResetTask?.cancel()
        boundaryResetTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 650_000_000)
            withAnimation(.easeOut(duration: 0.55)) {
                self?.boundaryMorphIntensity = 0
            }
        }
    }

    public func enterInspectMode(target: UUID?) {
        inspectMode = true
        inspectRuneID = target
        spellIntentLine = "Spell intent: inspect rune internals"
    }

    public func exitInspectMode() {
        inspectMode = false
        inspectRuneID = nil
    }

    public func updateManaFlow(learningRate: Float) {
        if learningRate > 0.16 {
            manaState = .chaos
            manaTurbulence = min(1, (learningRate - 0.16) * 6.2)
            spellIntentLine = "Mana turbulence: chaotic"
        } else if learningRate < 0.004 {
            manaState = .stagnant
            manaTurbulence = min(0.42, (0.004 - learningRate) * 55)
            spellIntentLine = "Mana turbulence: stagnant"
        } else {
            manaState = .balanced
            manaTurbulence = 0.08
        }
    }

    public func setSpellIntent(_ text: String) {
        spellIntentLine = text
    }

    public func resetTransientState() {
        flowResetTask?.cancel()
        emphasisResetTask?.cancel()
        boundaryResetTask?.cancel()
        flowDirection = .idle
        emphasizedLayers = []
        boundaryMorphIntensity = 0
        inspectMode = false
        inspectRuneID = nil
        outputSigil = nil
        manaState = .balanced
        manaTurbulence = 0
        spellIntentLine = "Cast prediction"
    }

    private func scheduleFlowReset() {
        flowResetTask?.cancel()
        flowResetTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 920_000_000)
            self?.flowDirection = .idle
        }
    }
}
