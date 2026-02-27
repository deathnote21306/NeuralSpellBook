import Foundation
import SwiftUI

@MainActor
public final class SandboxViewModel: ObservableObject {
    @Published public var datasetType: DatasetType = .linearlySeparable
    @Published public var pointCount: Float = 220
    @Published public var noise: Float = 0.14
    @Published public var seed: Float = 7
    @Published public var normalizeData: Bool = true
    @Published public var trainSplit: Float = 0.8

    @Published public var hiddenLayerCount: Int = 2
    @Published public var hiddenWidth1: Float = 12
    @Published public var hiddenWidth2: Float = 10
    @Published public var hiddenWidth3: Float = 8
    @Published public var activation: ActivationKind = .relu
    @Published public var outputMode: OutputMode = .sigmoid
    @Published public var dropout: Float = 0.08
    @Published public var l2: Float = 0.0008
    @Published public var optimizer: OptimizerKind = .adam
    @Published public var gradientClip: Float = 0

    @Published public var learningRate: Float = 0.02 {
        didSet {
            spellStage.updateManaFlow(learningRate: learningRate)
        }
    }
    @Published public var batchSize: Float = 20
    @Published public var speed: Float = 0.55
    @Published public var earlyStoppingEnabled: Bool = false

    @Published public private(set) var dataset: Dataset
    @Published public private(set) var decisionBoundary: [Float] = []
    @Published public var boundaryResolution: Int = 96

    @Published public private(set) var lossHistory: [TrainingHistoryPoint] = []
    @Published public private(set) var trainAccuracy: Float = 0
    @Published public private(set) var validationAccuracy: Float = 0
    @Published public private(set) var gradientMagnitudes: [Float] = []
    @Published public private(set) var activationHeatmaps: [Tensor] = []
    @Published public private(set) var weightHeatmaps: [Tensor] = []
    @Published public private(set) var tensorSummaries: [TensorSummary] = []
    @Published public private(set) var phaseMessages: [String] = []

    @Published public private(set) var runeSnapshots: [RuneSnapshot] = []
    @Published public var selectedRune: RuneSnapshot?
    @Published public var pinnedRune: RuneSnapshot?
    @Published public var selectedTensor: TensorSummary?
    @Published public var showRuneInspector: Bool = false
    @Published public var showTensorInspector: Bool = false

    @Published public var showRuneNumbers: Bool = false
    @Published public var revealMathematicalForm: Bool = false
    @Published public var soundEnabled: Bool = true

    @Published public private(set) var currentStep: Int = 0
    @Published public private(set) var isPlaying: Bool = false
    @Published public private(set) var energyPulseToken: Int = 0
    @Published public private(set) var backwardPulseToken: Int = 0
    @Published public private(set) var boundaryPulseToken: Int = 0
    @Published public private(set) var instabilityLevel: Float = 0
    @Published public private(set) var feedbackCards: [String] = []
    @Published public var uiToastMessage: String?

    public let spellStage = SpellStageController()

    private var engine: TrainingEngine
    private var playerTask: Task<Void, Never>?
    private var lossStats = RollingStats(maxCount: 45)

    public init() {
        var config = DatasetConfig()
        config.type = .linearlySeparable
        config.pointCount = 220
        config.noise = 0.14
        config.seed = 7
        config.normalize = true
        config.trainSplit = 0.8

        let initialDataset = Dataset.make(config: config)
        self.dataset = initialDataset
        self.engine = TrainingEngine(configuration: MLPConfiguration(hiddenSizes: [12, 10], activation: .relu, outputMode: .sigmoid, dropout: 0.08, l2: 0.0008, seed: 7))
        refreshBoundaryAndRunes()
        spellStage.updateManaFlow(learningRate: learningRate)
    }

    deinit {
        playerTask?.cancel()
    }

    public var hiddenSizes: [Int] {
        var sizes: [Int] = [Int(hiddenWidth1)]
        if hiddenLayerCount >= 2 { sizes.append(Int(hiddenWidth2)) }
        if hiddenLayerCount >= 3 { sizes.append(Int(hiddenWidth3)) }
        return sizes.map { max(2, $0) }
    }

    public var trainLossValues: [Float] {
        lossHistory.map(\.loss)
    }

    public func regenerateDataset() {
        spellStage.setSpellIntent("Glyph field remapped")
        var config = DatasetConfig()
        config.type = datasetType
        config.pointCount = Int(pointCount)
        config.noise = noise
        config.seed = UInt64(seed.rounded())
        config.normalize = normalizeData
        config.trainSplit = trainSplit
        dataset = Dataset.make(config: config)

        resetTrainingState()
        refreshBoundaryAndRunes()
        spellStage.triggerBoundaryMorph(intensity: 0.24)
        uiToastMessage = "Dataset regenerated."
    }

    public func normalizeDatasetNow() {
        dataset.normalizeInPlace()
        normalizeData = true
        resetTrainingState()
        refreshBoundaryAndRunes()
        spellStage.triggerBoundaryMorph(intensity: 0.2)
        spellStage.setSpellIntent("Glyphs normalized")
        uiToastMessage = "Applied normalization."
    }

    public func rebuildModel() {
        spellStage.setSpellIntent("Runes reconfigured")
        engine.rebuild(configuration: currentModelConfiguration)
        resetTrainingState()
        refreshBoundaryAndRunes()
        spellStage.triggerWeightUpdateEmphasis(changedWeights: gradientMagnitudes)
        uiToastMessage = "Model rebuilt with current settings."
    }

    public func applyRecipe(_ recipe: SpellRecipe) {
        datasetType = recipe.datasetType
        hiddenLayerCount = max(1, min(3, recipe.hiddenLayers.count))
        hiddenWidth1 = Float(recipe.hiddenLayers[safe: 0] ?? 10)
        hiddenWidth2 = Float(recipe.hiddenLayers[safe: 1] ?? 8)
        hiddenWidth3 = Float(recipe.hiddenLayers[safe: 2] ?? 6)
        learningRate = recipe.learningRate
        batchSize = Float(recipe.batchSize)
        dropout = recipe.dropout
        l2 = recipe.l2
        regenerateDataset()
        rebuildModel()
    }

    public func applyGuidedPreset(_ chapter: LessonChapter) {
        spellStage.resetTransientState()
        switch chapter {
        case .awakening:
            spellStage.setSpellIntent("Open the spellbook")
            resetEverything()
        case .firstSpell:
            spellStage.setSpellIntent("Cast forward energy")
            datasetType = .linearlySeparable
            pointCount = 180
            noise = 0.08
            normalizeData = true
            hiddenLayerCount = 2
            hiddenWidth1 = 8
            hiddenWidth2 = 6
            activation = .relu
            learningRate = 0.02
            dropout = 0
            l2 = 0
            batchSize = 18
            regenerateDataset()
            rebuildModel()
        case .instability:
            spellStage.setSpellIntent("Reveal instability")
            datasetType = .xor
            pointCount = 200
            noise = 0.16
            normalizeData = true
            hiddenLayerCount = 1
            hiddenWidth1 = 4
            activation = .tanh
            learningRate = 0.22
            batchSize = 12
            dropout = 0
            l2 = 0
            regenerateDataset()
            rebuildModel()
        case .backprop:
            spellStage.setSpellIntent("Perform backprop ritual")
            datasetType = .xor
            pointCount = 210
            noise = 0.11
            normalizeData = true
            hiddenLayerCount = 2
            hiddenWidth1 = 12
            hiddenWidth2 = 10
            activation = .tanh
            learningRate = 0.02
            batchSize = 20
            dropout = 0.05
            regenerateDataset()
            rebuildModel()
        case .manaControls:
            spellStage.setSpellIntent("Tune mana flow")
            datasetType = .circles
            pointCount = 240
            noise = 0.1
            normalizeData = true
            hiddenLayerCount = 2
            hiddenWidth1 = 14
            hiddenWidth2 = 10
            activation = .relu
            learningRate = 0.02
            batchSize = 20
            dropout = 0.1
            l2 = 0.0005
            regenerateDataset()
            rebuildModel()
        case .inspect:
            spellStage.setSpellIntent("Inspect runes")
            datasetType = .circles
            hiddenLayerCount = 2
            hiddenWidth1 = 14
            hiddenWidth2 = 10
            learningRate = 0.014
            dropout = 0.1
            l2 = 0.0008
            regenerateDataset()
            rebuildModel()
            for _ in 0..<6 { stepTraining() }
        case .evolution:
            spellStage.setSpellIntent("Seal the journey")
            learningRate = 0.015
            dropout = max(dropout, 0.12)
            l2 = max(l2, 0.001)
            rebuildModel()
            for _ in 0..<18 { stepTraining() }
        }
        spellStage.updateManaFlow(learningRate: learningRate)
    }

    public func castPrediction() {
        spellStage.triggerForwardCast()
        energyPulseToken += 1
        refreshBoundaryAndRunes()
        spellStage.revealOutputSigil(outputSigilFromCurrentRunes())
        spellStage.triggerBoundaryMorph(intensity: 0.16)
    }

    public func triggerBackwardPulse() {
        spellStage.triggerBackpropRitual()
        backwardPulseToken += 1
    }

    public func triggerBoundaryShiftPulse() {
        spellStage.triggerBoundaryMorph(intensity: 0.55)
        boundaryPulseToken += 1
        refreshBoundaryAndRunes()
    }

    public func togglePlayPause() {
        isPlaying ? pauseTraining() : playTraining()
    }

    public func playTraining() {
        guard !isPlaying else { return }
        isPlaying = true
        playerTask?.cancel()
        spellStage.setSpellIntent("Auto ritual active")
        uiToastMessage = "Training started."

        playerTask = Task {
            while !Task.isCancelled && isPlaying {
                await MainActor.run {
                    stepTraining()
                }

                let interval = UInt64(max(55, Int((1 - speed) * 260 + 40)))
                try? await Task.sleep(nanoseconds: interval * 1_000_000)
            }
        }
    }

    public func pauseTraining() {
        isPlaying = false
        playerTask?.cancel()
        playerTask = nil
        spellStage.setSpellIntent("Ritual paused")
        uiToastMessage = "Training paused."
    }

    public func stepTraining() {
        let previousLoss = lossHistory.last?.loss
        spellStage.triggerForwardCast()

        let result = engine.step(
            dataset: dataset,
            learningRate: learningRate,
            batchSize: Int(batchSize),
            optimizer: optimizer,
            gradientClip: gradientClip
        )

        currentStep += 1
        trainAccuracy = result.trainAccuracy
        validationAccuracy = result.validationAccuracy
        phaseMessages = result.phaseMessages
        gradientMagnitudes = result.gradientMagnitudes
        activationHeatmaps = result.activationMaps
        weightHeatmaps = engine.layerWeightHeatmaps()
        tensorSummaries = result.tensorSummaries
        instabilityLevel = min(1, result.loss)

        lossStats.push(result.loss)
        lossHistory.append(
            TrainingHistoryPoint(
                step: currentStep,
                loss: result.loss,
                trainAccuracy: trainAccuracy,
                validationAccuracy: validationAccuracy
            )
        )

        if lossHistory.count > 260 {
            lossHistory.removeFirst(lossHistory.count - 260)
        }

        if currentStep.isMultiple(of: 2) {
            refreshBoundaryAndRunes()
        } else {
            runeSnapshots = engine.runeSnapshots(for: dataset.trainingPoints.first)
        }

        energyPulseToken += 1
        updateFeedbackCards()
        spellStage.triggerWeightUpdateEmphasis(changedWeights: result.gradientMagnitudes)
        spellStage.updateManaFlow(learningRate: learningRate)

        let improved = previousLoss.map { result.loss <= $0 } ?? true
        spellStage.triggerLossPulse(isGood: improved)
        let delta = abs((previousLoss ?? result.loss) - result.loss)
        let intensity = min(1, delta * 6 + learningRate * 1.2 + (improved ? 0.12 : 0.32))
        spellStage.triggerBoundaryMorph(intensity: intensity)
        spellStage.revealOutputSigil(outputSigilFromCurrentRunes())

        if earlyStoppingEnabled,
           lossHistory.count > 30,
           let recent = lossHistory.last?.validationAccuracy,
           let old = lossHistory.dropLast(12).last?.validationAccuracy,
           recent + 0.03 < old {
            pauseTraining()
        }
    }

    public func resetTrainingState() {
        pauseTraining()
        currentStep = 0
        trainAccuracy = 0
        validationAccuracy = 0
        instabilityLevel = 0
        lossHistory = []
        phaseMessages = []
        gradientMagnitudes = []
        activationHeatmaps = []
        weightHeatmaps = []
        tensorSummaries = []
        selectedTensor = nil
        selectedRune = nil
        showTensorInspector = false
        showRuneInspector = false
        lossStats = RollingStats(maxCount: 45)
        feedbackCards = []
        spellStage.resetTransientState()
        spellStage.updateManaFlow(learningRate: learningRate)
    }

    public func resetEverything() {
        datasetType = .linearlySeparable
        pointCount = 220
        noise = 0.14
        seed = 7
        normalizeData = true
        trainSplit = 0.8

        hiddenLayerCount = 2
        hiddenWidth1 = 12
        hiddenWidth2 = 10
        hiddenWidth3 = 8
        activation = .relu
        outputMode = .sigmoid
        dropout = 0.08
        l2 = 0.0008
        optimizer = .adam
        gradientClip = 0

        learningRate = 0.02
        batchSize = 20
        speed = 0.55
        earlyStoppingEnabled = false

        regenerateDataset()
        rebuildModel()
        spellStage.setSpellIntent("Ready to cast")
        uiToastMessage = "Reset to beginner-safe defaults."
    }

    public func pinSelectedRune() {
        guard let selectedRune else { return }
        pinnedRune = selectedRune
        spellStage.enterInspectMode(target: selectedRune.id)
        uiToastMessage = "\(selectedRune.name) pinned for comparison."
    }

    public func clearPinnedRune() {
        pinnedRune = nil
        spellStage.exitInspectMode()
        uiToastMessage = "Pinned rune cleared."
    }

    public func applyOutputModeFixForBinaryTask() {
        outputMode = .sigmoid
        rebuildModel()
        uiToastMessage = "Switched to sigmoid for binary output."
    }

    public func refreshVisuals() {
        refreshBoundaryAndRunes()
    }

    public func requestRuneInspection(_ rune: RuneSnapshot) {
        if isPlaying {
            spellStage.setSpellIntent("Pause to inspect runes")
            uiToastMessage = "Pause training to inspect this rune clearly."
            return
        }
        selectedRune = rune
        showRuneInspector = true
        spellStage.enterInspectMode(target: rune.id)
    }

    public func requestThreadInspection(layerIndex: Int, weight: Float) {
        let signText = weight >= 0 ? "+" : "-"
        let direction = weight >= 0 ? "Sigil A" : "Sigil B"
        uiToastMessage = "Thread L\(layerIndex) \(signText)\(String(format: "%.3f", abs(weight))) pushes toward \(direction)."
    }

    public var currentModelConfiguration: MLPConfiguration {
        MLPConfiguration(
            hiddenSizes: hiddenSizes,
            activation: activation,
            outputMode: outputMode,
            dropout: dropout,
            l2: l2,
            seed: UInt64(seed.rounded())
        )
    }

    public var lossVariance: Float {
        lossStats.variance
    }

    public var lossSlope: Float {
        lossStats.slope
    }

    private func refreshBoundaryAndRunes() {
        decisionBoundary = engine.decisionBoundary(resolution: boundaryResolution)
        runeSnapshots = engine.runeSnapshots(for: dataset.trainingPoints.first)
        weightHeatmaps = engine.layerWeightHeatmaps()
    }

    private func outputSigilFromCurrentRunes() -> String? {
        guard let outputLayer = runeSnapshots.map(\.layerIndex).max() else { return nil }
        let outputRunes = runeSnapshots.filter { $0.layerIndex == outputLayer }
        guard let winner = outputRunes.max(by: { $0.activation < $1.activation }) else { return nil }
        if outputRunes.count > 1 {
            return winner.nodeIndex == 0 ? "Sigil A" : "Sigil B"
        }
        return winner.activation >= 0.5 ? "Sigil A" : "Sigil B"
    }

    private func updateFeedbackCards() {
        var cards: [String] = []

        if learningRate > 0.16 {
            cards.append("Too much power causes chaos.")
        } else if learningRate < 0.004 {
            cards.append("Too little power prevents growth.")
        }

        if batchSize < 8 {
            cards.append("Tiny batches make gradients noisy.")
        }

        if !normalizeData {
            cards.append("Normalization can stabilize training.")
        }

        feedbackCards = Array(cards.prefix(3))
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
