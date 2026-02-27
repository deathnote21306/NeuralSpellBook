import Foundation
import SwiftUI

@MainActor
public final class GuidedJourneyViewModel: ObservableObject {
    @Published public private(set) var chapter: LessonChapter = .awakening
    @Published public private(set) var storyLine: String = "Intelligence is not born. It is trained."
    @Published public var spellbookOpened: Bool = false
    @Published public var showLossExplanationOverlay: Bool = false
    @Published public var stepModeEnabled: Bool = true
    @Published public var backpropStep: Int = 0
    @Published public var manaExperimentPhase: Int = 0
    @Published public var showFinalButtons: Bool = false
    @Published public var toastMessage: String?

    public var sandbox: SandboxViewModel

    public init(sandbox: SandboxViewModel) {
        self.sandbox = sandbox
    }

    public var chapterProgressText: String {
        if chapter == .awakening {
            return "Prologue"
        }
        return "Chapter \(chapter.rawValue) / 6"
    }

    public var chapterProgressValue: Float {
        chapter.progress
    }

    public var currentActionTitle: String {
        switch chapter {
        case .manaControls:
            switch manaExperimentPhase {
            case 0: return "Run Chaos Trial"
            case 1: return "Run Stagnation Trial"
            default: return "Stabilize and Continue"
            }
        case .backprop:
            if stepModeEnabled {
                return "Perform Step \(min(backpropStep + 1, 3))"
            }
            return chapter.actionTitle
        default:
            return chapter.actionTitle
        }
    }

    public var chapterGoalLine: String {
        switch chapter {
        case .awakening:
            return "Networks are trained, not born."
        case .firstSpell:
            return "Forward pass turns data into prediction."
        case .instability:
            return "Loss tells you how wrong the model is."
        case .backprop:
            return "Gradients point toward better weights."
        case .manaControls:
            return "Hyperparameters control learning behavior."
        case .inspect:
            return "Inspect internals to understand behavior."
        case .evolution:
            return "Repetition + correction drives improvement."
        }
    }

    public var nextActionInstruction: String {
        switch chapter {
        case .awakening:
            return "Open the spellbook, then awaken the runes."
        case .firstSpell:
            return "Cast prediction and watch energy flow forward."
        case .instability:
            return "Trigger a wrong cast and watch instability rise."
        case .backprop:
            return "Run omen, thread update, then boundary shift."
        case .manaControls:
            return "Test chaotic mana, then stagnant mana, then stabilize."
        case .inspect:
            return "Tap a rune to inspect charge and incoming threads."
        case .evolution:
            return "Seal the ritual, then replay or enter Free Play."
        }
    }

    public var nextActionWhy: String {
        switch chapter {
        case .awakening:
            return "This introduces the core idea: intelligence comes from training loops, not instant magic."
        case .firstSpell:
            return "Forward pass is the model’s first job: convert input features into an output probability."
        case .instability:
            return "Loss is your compass. If loss is high, the model is wrong and needs correction."
        case .backprop:
            return "Backprop sends error signals backward so each weight can change in the most useful direction."
        case .manaControls:
            return "Learning rate and batch size decide whether training is chaotic, stagnant, or stable."
        case .inspect:
            return "Inspection turns the model into a glass box: you can see values, not just final predictions."
        case .evolution:
            return "The final chapter connects all steps into one loop: predict, measure, correct, improve."
        }
    }

    public var nextActionSystemImage: String {
        switch chapter {
        case .awakening: return "sparkles"
        case .firstSpell: return "wand.and.stars"
        case .instability: return "questionmark.circle"
        case .backprop: return "arrowshape.turn.up.backward.2"
        case .manaControls: return "dial.medium"
        case .inspect: return "magnifyingglass"
        case .evolution: return "book.closed.fill"
        }
    }

    public var nextActionDisabledReason: String? {
        if chapter == .inspect, sandbox.isPlaying {
            return "Pause training first so rune values stop changing while you inspect."
        }
        return nil
    }

    public var whatToDoNowHint: String {
        switch chapter {
        case .awakening:
            return "Open the spellbook to begin."
        case .firstSpell:
            return "Cast a prediction."
        case .instability:
            return "Observe why the prediction fails."
        case .backprop:
            return "Run the correction ritual."
        case .manaControls:
            return "Compare high and low learning rate."
        case .inspect:
            return "Inspect a rune in detail."
        case .evolution:
            return "Close the loop and reflect."
        }
    }

    public func resetJourney() {
        chapter = .awakening
        storyLine = "Intelligence is not born. It is trained."
        spellbookOpened = false
        showLossExplanationOverlay = false
        stepModeEnabled = true
        backpropStep = 0
        manaExperimentPhase = 0
        showFinalButtons = false
        toastMessage = nil
        sandbox.resetEverything()
        sandbox.applyGuidedPreset(.awakening)
        sandbox.spellStage.resetTransientState()
        sandbox.spellStage.setSpellIntent("Open the spellbook")
    }

    public func openSpellbook() {
        withAnimation(.easeInOut(duration: 0.45)) {
            spellbookOpened = true
            storyLine = "Touch the sigil to awaken a tiny network."
        }
        sandbox.spellStage.setSpellIntent("Tap awaken to ignite the first runes")
    }

    public func performPrimaryAction() {
        switch chapter {
        case .awakening:
            sandbox.applyGuidedPreset(.firstSpell)
            sandbox.castPrediction()
            advance(to: .firstSpell, line: "Energy can move through the runes and become a prediction.")

        case .firstSpell:
            sandbox.spellStage.setSpellIntent("Cast forward energy")
            sandbox.castPrediction()
            toastMessage = "Forward pass complete."
            advance(to: .instability, line: "Now watch what happens when predictions are wrong.")

        case .instability:
            sandbox.spellStage.setSpellIntent("Reveal instability")
            sandbox.applyGuidedPreset(.instability)
            sandbox.castPrediction()
            sandbox.stepTraining()
            sandbox.spellStage.triggerLossPulse(isGood: false)
            sandbox.spellStage.triggerBoundaryMorph(intensity: 0.62)
            showLossExplanationOverlay = true
            toastMessage = "Loss = how wrong the spell is."
            advance(to: .backprop, line: "Let gradients guide correction.")

        case .backprop:
            if backpropStep == 0 {
                sandbox.applyGuidedPreset(.backprop)
            }
            if stepModeEnabled {
                runBackpropStepMode()
            } else {
                sandbox.triggerBackwardPulse()
                sandbox.stepTraining()
                sandbox.triggerBoundaryShiftPulse()
                toastMessage = "Backprop ritual performed."
                advance(to: .manaControls, line: "Now tune the mana controls.")
            }

        case .manaControls:
            if manaExperimentPhase == 0 {
                sandbox.applyGuidedPreset(.manaControls)
            }
            runManaExperiment()

        case .inspect:
            sandbox.applyGuidedPreset(.inspect)
            if let rune = sandbox.runeSnapshots.first(where: { $0.layerIndex == 1 }) {
                sandbox.selectedRune = rune
                sandbox.showRuneInspector = true
                sandbox.spellStage.enterInspectMode(target: rune.id)
            }
            toastMessage = "Inspect runes to understand the network internals."
            advance(to: .evolution, line: "Final ritual: improvement through repetition.")

        case .evolution:
            sandbox.applyGuidedPreset(.evolution)
            sandbox.spellStage.triggerBoundaryMorph(intensity: 0.32)
            sandbox.spellStage.setSpellIntent("Ritual complete")
            toastMessage = "Intelligence is repetition guided by correction."
            showFinalButtons = true
        }
    }

    public func continueAfterOverlay() {
        showLossExplanationOverlay = false
    }

    private func runBackpropStepMode() {
        switch backpropStep {
        case 0:
            sandbox.triggerBackwardPulse()
            toastMessage = "Step 1: Gradients are flowing backward."
        case 1:
            sandbox.spellStage.setSpellIntent("Update threads")
            sandbox.stepTraining()
            toastMessage = "Step 2: Weights update."
        default:
            sandbox.triggerBoundaryShiftPulse()
            toastMessage = "Step 3: Decision boundary shifts."
            advance(to: .manaControls, line: "You can now tune learning behavior.")
        }

        backpropStep += 1
    }

    private func runManaExperiment() {
        switch manaExperimentPhase {
        case 0:
            sandbox.learningRate = 0.28
            for _ in 0..<4 { sandbox.stepTraining() }
            sandbox.spellStage.updateManaFlow(learningRate: sandbox.learningRate)
            sandbox.spellStage.triggerBoundaryMorph(intensity: 0.8)
            toastMessage = "Too much power causes chaos."
            manaExperimentPhase = 1

        case 1:
            sandbox.learningRate = 0.0014
            for _ in 0..<4 { sandbox.stepTraining() }
            sandbox.spellStage.updateManaFlow(learningRate: sandbox.learningRate)
            sandbox.spellStage.triggerBoundaryMorph(intensity: 0.18)
            toastMessage = "Too little power prevents growth."
            manaExperimentPhase = 2

        default:
            sandbox.learningRate = 0.018
            sandbox.batchSize = 20
            sandbox.dropout = 0.12
            sandbox.rebuildModel()
            for _ in 0..<6 { sandbox.stepTraining() }
            sandbox.spellStage.updateManaFlow(learningRate: sandbox.learningRate)
            sandbox.spellStage.triggerBoundaryMorph(intensity: 0.26)
            toastMessage = "Balanced mana produces steady improvement."
            advance(to: .inspect, line: "Pause and inspect the runes.")
        }
    }

    private func advance(to next: LessonChapter, line: String) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            chapter = next
            storyLine = line
        }
    }
}
