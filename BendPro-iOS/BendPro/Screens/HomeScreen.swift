import SwiftUI
import BendProCore

public struct HomeCardItem: Identifiable {
    public let kind: BendKind
    public var id: String { kind.id }
    public var title: String { kind.title }
    public var sub: String { kind.subtitle }

    public init(kind: BendKind) {
        self.kind = kind
    }
}

public let CORE_BENDS: [HomeCardItem] = [
    HomeCardItem(kind: .offset),
    HomeCardItem(kind: .ninety),
    HomeCardItem(kind: .saddle3),
    HomeCardItem(kind: .kick)
]

public let ADVANCED_BENDS: [HomeCardItem] = [
    HomeCardItem(kind: .kick90),
    HomeCardItem(kind: .segmented),
    HomeCardItem(kind: .saddle4),
    HomeCardItem(kind: .rolling)
]

public let TOOLS_BENDS: [HomeCardItem] = [
    HomeCardItem(kind: .wirefill)
]

public struct HomeScreen: View {
    public var onSelectKind: (BendKind) -> Void

    public init(onSelectKind: @escaping (BendKind) -> Void) {
        self.onSelectKind = onSelectKind
    }

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Core Bends Section
                sectionView(title: "Core Bends", items: CORE_BENDS)

                // Advanced Bends Section
                sectionView(title: "Advanced Bends", items: ADVANCED_BENDS)

                // Tools Section
                sectionView(title: "Tools", items: TOOLS_BENDS)
            }
            .padding(16)
        }
        .background(Color.bgVoid)
    }

    @ViewBuilder
    private func sectionView(title: String, items: [HomeCardItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.poppins(.semibold, size: 11))
                .tracking(1.1)
                .foregroundColor(.textTertiary)
                .padding(.leading, 2)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(items) { item in
                    BendCard(item: item) {
                        onSelectKind(item.kind)
                    }
                }
            }
        }
    }
}

public struct BendCard: View {
    public let item: HomeCardItem
    public var onClick: () -> Void

    public var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading, spacing: 16) {
                // Icon Box (34x34)
                ZStack {
                    RoundedRectangle(cornerRadius: 9)
                        .fill(Color.accentWash)
                        .frame(width: 34, height: 34)

                    BendKindIconView(kind: item.kind, tint: .accent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.poppins(.medium, size: 14.5))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)

                    Text(item.sub)
                        .font(.poppins(.regular, size: 11))
                        .foregroundColor(.textTertiary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 108, alignment: .topLeading)
            .background(Color.bgPanel)
            .cornerRadius(AppRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .stroke(Color.lineSoft, lineWidth: 1)
            )
        }
        .accessibilityLabel("\(item.title), \(item.sub)")
    }
}
