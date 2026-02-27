import Foundation

public struct SpellRecipe: Identifiable {
    public let id = UUID()
    public let name: String
    public let summary: String
    public let datasetType: DatasetType
    public let hiddenLayers: [Int]
    public let learningRate: Float
    public let batchSize: Int
    public let dropout: Float
    public let l2: Float

    public init(
        name: String,
        summary: String,
        datasetType: DatasetType,
        hiddenLayers: [Int],
        learningRate: Float,
        batchSize: Int,
        dropout: Float,
        l2: Float
    ) {
        self.name = name
        self.summary = summary
        self.datasetType = datasetType
        self.hiddenLayers = hiddenLayers
        self.learningRate = learningRate
        self.batchSize = batchSize
        self.dropout = dropout
        self.l2 = l2
    }
}

public enum RecipeLibrary {
    public static let starter = SpellRecipe(
        name: "Starter Sigil",
        summary: "Fast stable defaults for beginners.",
        datasetType: .linearlySeparable,
        hiddenLayers: [10, 8],
        learningRate: 0.02,
        batchSize: 20,
        dropout: 0.1,
        l2: 0.0008
    )

    public static let xorFocus = SpellRecipe(
        name: "XOR Weaver",
        summary: "Emphasizes non-linear structure.",
        datasetType: .xor,
        hiddenLayers: [12, 10],
        learningRate: 0.018,
        batchSize: 24,
        dropout: 0.08,
        l2: 0.001
    )
}
