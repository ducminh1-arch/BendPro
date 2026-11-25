import SwiftUI
import BendProCore

public struct BenderSelectRow: View {
    public let bender: Bender
    public let selectedSize: Double
    public var onClick: () -> Void

    public init(bender: Bender, selectedSize: Double, onClick: @escaping () -> Void) {
        self.bender = bender
        self.selectedSize = selectedSize
        self.onClick = onClick
    }

    public var body: some View {
        Button(action: onClick) {
            HStack(spacing: 10) {
                BendsNavIconView(tint: .accent)
                    .frame(width: 18, height: 18)

                Text("\(bender.brand) · \(tradeSizeLabel(selectedSize))")
                    .font(.poppins(.medium, size: 13))
                    .foregroundColor(.textPrimary)

                Spacer()

                ChevronRightShape()
                    .stroke(Color.textTertiary, style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
                    .frame(width: 14, height: 14)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .frame(minHeight: AppTapTarget.min)
            .background(Color.bgPanel)
            .cornerRadius(AppRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(Color.lineSoft, lineWidth: 1)
            )
        }
        .accessibilityLabel("Bender: \(bender.brand), size \(tradeSizeLabel(selectedSize)). Tap to change.")
    }
}
