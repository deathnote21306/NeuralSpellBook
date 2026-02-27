import Foundation

public enum DataSplit: String, Codable {
    case train
    case validation
}

public struct DataPoint: Identifiable, Hashable, Codable {
    public var id = UUID()
    public var x: Float
    public var y: Float
    public var label: Int
    public var split: DataSplit

    public init(x: Float, y: Float, label: Int, split: DataSplit = .train) {
        self.x = x
        self.y = y
        self.label = label
        self.split = split
    }
}
