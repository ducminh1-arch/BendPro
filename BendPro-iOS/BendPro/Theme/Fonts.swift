import SwiftUI

extension Font {
    public static func poppins(_ weight: Font.Weight = .regular, size: CGFloat) -> Font {
        let fontName: String
        switch weight {
        case .bold:
            fontName = "Poppins-Bold"
        case .semibold:
            fontName = "Poppins-SemiBold"
        case .medium:
            fontName = "Poppins-Medium"
        default:
            fontName = "Poppins-Regular"
        }
        return .custom(fontName, size: size)
    }

    public static func appMono(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}
