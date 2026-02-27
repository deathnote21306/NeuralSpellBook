import SwiftUI

public enum Typography {
    public static let hero = Font.custom("AvenirNext-Bold", size: 42)
    public static let chapterTitle = Font.custom("AvenirNext-DemiBold", size: 30)
    public static let title = Font.custom("AvenirNext-DemiBold", size: 24)
    public static let section = Font.custom("AvenirNext-DemiBold", size: 19)
    public static let body = Font.custom("AvenirNext-Regular", size: 17)
    public static let caption = Font.custom("AvenirNext-Regular", size: 14)
    public static let mono = Font.system(size: 13, weight: .medium, design: .monospaced)
}
