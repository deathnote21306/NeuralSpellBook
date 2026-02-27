import SwiftUI

public enum Theme {
    // Core palette matching the HTML design
    public static let void   = Color(red: 0.012, green: 0.004, blue: 0.051)   // #03010d
    public static let deep   = Color(red: 0.027, green: 0.016, blue: 0.102)   // #07041a
    public static let mana   = Color(red: 0.361, green: 0.188, blue: 1.000)   // #5c2fff
    public static let manaB  = Color(red: 0.486, green: 0.373, blue: 1.000)   // #7c5fff
    public static let manaB2 = Color(red: 0.627, green: 0.502, blue: 1.000)   // #a080ff
    public static let gold   = Color(red: 0.910, green: 0.722, blue: 0.294)   // #e8b84b
    public static let goldD  = Color(red: 0.549, green: 0.431, blue: 0.157)   // #8c6e28
    public static let ember  = Color(red: 1.000, green: 0.420, blue: 0.208)   // #ff6b35
    public static let spirit = Color(red: 0.239, green: 0.839, blue: 0.753)   // #3dd6c0
    public static let crimson = Color(red: 0.851, green: 0.188, blue: 0.376)  // #d93060
    public static let star   = Color(red: 0.867, green: 0.831, blue: 1.000)   // #ddd4ff

    // Legacy aliases for existing code
    public static let midnight = void
    public static let nebula   = deep
    public static let starlight = spirit
    public static let mint     = spirit

    public static let background = LinearGradient(
        colors: [void, deep, Color(red: 0.035, green: 0.020, blue: 0.080)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let glassFill   = Color.white.opacity(0.05)
    public static let glassBorder = Color.white.opacity(0.10)
    public static let panelShadow = Color.black.opacity(0.40)

    public static let success = spirit
    public static let warning = gold
    public static let danger  = crimson

    public static let boundaryPositive = spirit
    public static let boundaryNegative = ember
}
