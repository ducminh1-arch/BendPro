import SwiftUI

public enum AppTab: String, CaseIterable, Identifiable {
    case bends
    case history
    case settings

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .bends: return "Bends"
        case .history: return "History"
        case .settings: return "Settings"
        }
    }
}

public struct BottomBar: View {
    @Binding public var activeTab: AppTab

    public init(activeTab: Binding<AppTab>) {
        self._activeTab = activeTab
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top hairline border
            Rectangle()
                .fill(Color.lineSoft)
                .frame(height: 1)

            HStack {
                Spacer(minLength: 0)

                HStack(spacing: 0) {
                    ForEach(AppTab.allCases) { tab in
                        let isActive = (tab == activeTab)
                        let tint: Color = isActive ? .accent : .textTertiary

                        Button(action: {
                            activeTab = tab
                        }) {
                            VStack(spacing: 4) {
                                tabIcon(for: tab, tint: tint)
                                Text(tab.label)
                                    .font(.poppins(.medium, size: 10.5))
                                    .tracking(0.2)
                                    .foregroundColor(tint)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .contentShape(Rectangle())
                        }
                        .accessibilityLabel("Switch to \(tab.label) tab")
                    }
                }
                .frame(maxWidth: 640)

                Spacer(minLength: 0)
            }
            .background(Color.bgPanel)
        }
    }

    @ViewBuilder
    private func tabIcon(for tab: AppTab, tint: Color) -> some View {
        switch tab {
        case .bends:
            BendsNavIconView(tint: tint)
        case .history:
            HistoryNavIconView(tint: tint)
        case .settings:
            SettingsNavIconView(tint: tint)
        }
    }
}
