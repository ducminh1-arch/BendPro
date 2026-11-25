import SwiftUI
import BendProCore

public struct MainShellView: View {
    @ObservedObject public var appStore: AppStore
    @StateObject public var nav: ShellViewModel
    @StateObject public var detailVM: DetailViewModel

    public init(
        appStore: AppStore,
        nav: ShellViewModel = ShellViewModel(),
        detailVM: DetailViewModel = DetailViewModel()
    ) {
        self.appStore = appStore
        self._nav = StateObject(wrappedValue: nav)
        self._detailVM = StateObject(wrappedValue: detailVM)
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Main Content Area (constrained and centered on iPad)
            HStack {
                Spacer(minLength: 0)

                ZStack {
                    switch nav.activeTab {
                    case .bends:
                        bendsTabContent
                    case .history:
                        HistoryScreen(
                            entries: appStore.history,
                            onClear: { appStore.clearHistory() }
                        )
                    case .settings:
                        SettingsScreen(
                            unit: appStore.unit,
                            onUnitChange: { appStore.setUnit($0) },
                            darkOptimized: appStore.darkOptimized,
                            onToggleDark: { appStore.setDarkOptimized($0) }
                        )
                    }
                }
                .frame(maxWidth: 640)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bottom Nav Bar
            BottomBar(activeTab: Binding(
                get: { nav.activeTab },
                set: { newTab in
                    if newTab != nav.activeTab {
                        if case .detail(let kind) = nav.bendsRoute {
                            detailVM.resetToDefaults(kind)
                        }
                        nav.selectTab(newTab)
                    }
                }
            ))
        }
        .background(Color.bgVoid.ignoresSafeArea())
        .gesture(edgeSwipeGesture)
    }

    @ViewBuilder
    private var bendsTabContent: some View {
        VStack(spacing: 0) {
            switch nav.bendsRoute {
            case .home:
                HomeHeader(onInfoClick: {
                    nav.selectTab(.settings)
                })
                HomeScreen(onSelectKind: { kind in
                    detailVM.resetToDefaults(kind)
                    if kind != .wirefill {
                        detailVM.clampTradeSize(bender: appStore.selectedBender, kind: kind)
                    }
                    nav.openDetail(kind)
                })

            case .detail(let kind):
                DetailHeader(title: kind.title, onBack: {
                    detailVM.resetToDefaults(kind)
                    nav.navigateBack()
                })
                BendDetailScreen(
                    kind: kind,
                    unit: appStore.unit,
                    bender: appStore.selectedBender,
                    detailVM: detailVM,
                    onOpenBenderPicker: {
                        nav.openBenderPicker(returnTo: kind)
                    },
                    onSaveHistory: { entry in
                        appStore.addHistory(entry)
                    }
                )

            case .benderPicker(let returnTo):
                DetailHeader(title: "Select Bender", onBack: {
                    nav.navigateBack()
                })
                BendersScreen(
                    selectedId: appStore.benderId,
                    onSelect: { id in
                        appStore.setBenderId(id)
                        if returnTo != .wirefill {
                            detailVM.clampTradeSize(bender: appStore.selectedBender, kind: returnTo)
                        }
                        nav.navigateBack()
                    }
                )
            }
        }
    }

    private var edgeSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 20, coordinateSpace: .local)
            .onEnded { gesture in
                if gesture.startLocation.x < 30 && gesture.translation.width > 50 {
                    if case .detail(let kind) = nav.bendsRoute {
                        detailVM.resetToDefaults(kind)
                    }
                    nav.navigateBack()
                }
            }
    }
}
