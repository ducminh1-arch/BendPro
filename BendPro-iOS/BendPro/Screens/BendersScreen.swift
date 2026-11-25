import SwiftUI
import BendProCore

public struct BendersScreen: View {
    public let selectedId: String
    public var onSelect: (String) -> Void

    public init(selectedId: String, onSelect: @escaping (String) -> Void) {
        self.selectedId = selectedId
        self.onSelect = onSelect
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Select the bender you're working with. Centerline radius per shoe drives every calculation and QuickCheck result.")
                    .font(.poppins(.regular, size: 13))
                    .foregroundColor(.textSecondary)
                    .lineSpacing(4)

                VStack(spacing: 10) {
                    ForEach(BENDERS) { bender in
                        let isSelected = (bender.id == selectedId)
                        BenderCard(
                            bender: bender,
                            isSelected: isSelected
                        ) {
                            onSelect(bender.id)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Color.bgVoid)
    }
}

public struct BenderCard: View {
    public let bender: Bender
    public let isSelected: Bool
    public var onClick: () -> Void

    public var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(bender.brand)
                        .font(.poppins(.medium, size: 15))
                        .tracking(0.3)
                        .foregroundColor(.textPrimary)

                    Spacer()

                    if isSelected {
                        Text("SELECTED")
                            .font(.poppins(.bold, size: 9.5))
                            .tracking(0.6)
                            .foregroundColor(.accent)
                    }
                }

                Text(bender.model)
                    .font(.poppins(.regular, size: 12.5))
                    .foregroundColor(.textSecondary)

                // Supported size pills
                HStack(spacing: 6) {
                    ForEach(bender.conduitSizesIn, id: \.self) { size in
                        Text(tradeSizeLabel(size))
                            .font(.appMono(size: 10.5))
                            .foregroundColor(.metal400)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 999)
                                    .stroke(Color.line, lineWidth: 1)
                            )
                    }
                }
                .padding(.top, 4)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.accentWash : Color.bgPanel)
            .cornerRadius(AppRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .stroke(isSelected ? Color.accent : Color.lineSoft, lineWidth: 1)
            )
        }
        .accessibilityLabel("\(bender.brand) \(bender.model)\(isSelected ? ", Selected" : "")")
    }
}
