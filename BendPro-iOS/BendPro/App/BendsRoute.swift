import Foundation
import BendProCore

public enum BendsRoute: Equatable, Hashable {
    case home
    case detail(BendKind)
    case benderPicker(returnTo: BendKind)
}

public class ShellViewModel: ObservableObject {
    @Published public var activeTab: AppTab
    @Published public var bendsRoute: BendsRoute

    public init(activeTab: AppTab = .bends, bendsRoute: BendsRoute = .home) {
        self.activeTab = activeTab
        self.bendsRoute = bendsRoute
    }

    public func selectTab(_ tab: AppTab) {
        activeTab = tab
        // Leaving the Bends tab resets it to Home (spec C1)
        if tab != .bends {
            bendsRoute = .home
        }
    }

    public func openDetail(_ kind: BendKind) {
        activeTab = .bends
        bendsRoute = .detail(kind)
    }

    public func openBenderPicker(returnTo: BendKind) {
        activeTab = .bends
        bendsRoute = .benderPicker(returnTo: returnTo)
    }

    public func navigateBack() {
        guard activeTab == .bends else { return }
        switch bendsRoute {
        case .home:
            break
        case .detail:
            bendsRoute = .home
        case .benderPicker(let returnTo):
            bendsRoute = .detail(returnTo)
        }
    }

    @discardableResult
    public func handleEdgeSwipe(startLocationX: CGFloat, translationWidth: CGFloat) -> Bool {
        if startLocationX < 30 && translationWidth > 50 {
            navigateBack()
            return true
        }
        return false
    }
}
