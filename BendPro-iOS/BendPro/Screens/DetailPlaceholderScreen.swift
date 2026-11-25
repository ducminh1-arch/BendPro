import SwiftUI
import BendProCore

public struct DetailPlaceholderScreen: View {
    public let kind: BendKind
    public let bender: Bender
    public var onOpenBenderPicker: () -> Void

    public init(kind: BendKind, bender: Bender, onOpenBenderPicker: @escaping () -> Void) {
        self.kind = kind
        self.bender = bender
        self.onOpenBenderPicker = onOpenBenderPicker
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if kind != .wirefill {
                    BenderSelectRow(
                        bender: bender,
                        selectedSize: 0.75,
                        onClick: onOpenBenderPicker
                    )
                }

                VStack(spacing: 8) {
                    Text(kind.title)
                        .font(.poppins(.semibold, size: 18))
                        .foregroundColor(.textPrimary)

                    Text(kind.subtitle)
                        .font(.poppins(.regular, size: 13))
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
            .padding(16)
        }
        .background(Color.bgVoid)
    }
}
