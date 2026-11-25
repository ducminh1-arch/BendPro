import SwiftUI

extension Color {
    // A7 Design Tokens
    public static let bgVoid = Color(hex: 0x090D16)
    public static let bgPanel = Color(hex: 0x121A2C)
    public static let bgPanelRaised = Color(hex: 0x1A2438)
    public static let bgInset = Color(hex: 0x0C1220)

    public static let line = Color(hex: 0x263251)
    public static let lineSoft = Color(hex: 0x1A2338)

    public static let metal200 = Color(hex: 0xCDD4DA)
    public static let metal400 = Color(hex: 0x8A939B)
    public static let metal600 = Color(hex: 0x5B646B)

    public static let textPrimary = Color(hex: 0xEEF1F6)
    public static let textSecondary = Color(hex: 0x94A1BD)
    public static let textTertiary = Color(hex: 0x5C6884)

    public static let accent = Color(hex: 0x3D82F6)
    public static let accentDim = Color(hex: 0x2563EB)
    public static let accentWash = Color(hex: 0x3D82F6).opacity(0.14)

    public static let colorOk = Color(hex: 0x35C97E)
    public static let colorWarn = Color(hex: 0xF0A93B)
    public static let colorDanger = Color(hex: 0xFF4D4F)

    public static let okWash = Color(hex: 0x35C97E).opacity(0.14)
    public static let warnWash = Color(hex: 0xF0A93B).opacity(0.14)
    public static let dangerWash = Color(hex: 0xFF4D4F).opacity(0.14)

    public init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xff) / 255.0
        let g = Double((hex >> 8) & 0xff) / 255.0
        let b = Double(hex & 0xff) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
