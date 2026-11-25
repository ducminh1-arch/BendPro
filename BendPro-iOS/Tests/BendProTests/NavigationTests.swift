import XCTest
@testable import BendPro
import BendProCore

final class NavigationTests: XCTestCase {

    func testInitialState() {
        let vm = ShellViewModel()
        XCTAssertEqual(vm.activeTab, .bends)
        XCTAssertEqual(vm.bendsRoute, .home)
    }

    func testOpenDetail() {
        let vm = ShellViewModel()
        vm.openDetail(.offset)
        XCTAssertEqual(vm.bendsRoute, .detail(.offset))
        XCTAssertEqual(vm.activeTab, .bends)
    }

    func testOpenBenderPicker() {
        let vm = ShellViewModel()
        vm.openDetail(.ninety)
        vm.openBenderPicker(returnTo: .ninety)
        XCTAssertEqual(vm.bendsRoute, .benderPicker(returnTo: .ninety))
    }

    func testNavigateBackFromBenderPicker() {
        let vm = ShellViewModel()
        vm.openDetail(.saddle3)
        vm.openBenderPicker(returnTo: .saddle3)
        vm.navigateBack()
        XCTAssertEqual(vm.bendsRoute, .detail(.saddle3))
    }

    func testNavigateBackFromDetail() {
        let vm = ShellViewModel()
        vm.openDetail(.kick)
        vm.navigateBack()
        XCTAssertEqual(vm.bendsRoute, .home)
    }

    func testNavigateBackFromHomeDoesNothing() {
        let vm = ShellViewModel()
        XCTAssertEqual(vm.bendsRoute, .home)
        vm.navigateBack()
        XCTAssertEqual(vm.bendsRoute, .home)
    }

    func testSwitchingTabResetsBendsRouteToHome() {
        let vm = ShellViewModel()
        vm.openDetail(.rolling)
        XCTAssertEqual(vm.bendsRoute, .detail(.rolling))

        // Switch to history
        vm.selectTab(.history)
        XCTAssertEqual(vm.activeTab, .history)
        XCTAssertEqual(vm.bendsRoute, .home)

        // Go back to bends
        vm.selectTab(.bends)
        XCTAssertEqual(vm.activeTab, .bends)
        XCTAssertEqual(vm.bendsRoute, .home)

        // Open detail and switch to settings
        vm.openDetail(.wirefill)
        XCTAssertEqual(vm.bendsRoute, .detail(.wirefill))
        vm.selectTab(.settings)
        XCTAssertEqual(vm.activeTab, .settings)
        XCTAssertEqual(vm.bendsRoute, .home)
    }

    func testEdgeSwipeBack() {
        let vm = ShellViewModel()
        vm.openDetail(.segmented)

        // Valid edge swipe (start < 30, width > 50)
        let handled = vm.handleEdgeSwipe(startLocationX: 20, translationWidth: 60)
        XCTAssertTrue(handled)
        XCTAssertEqual(vm.bendsRoute, .home)

        // Invalid swipe: start not near edge
        vm.openDetail(.segmented)
        let notEdge = vm.handleEdgeSwipe(startLocationX: 50, translationWidth: 80)
        XCTAssertFalse(notEdge)
        XCTAssertEqual(vm.bendsRoute, .detail(.segmented))

        // Invalid swipe: width too short
        let tooShort = vm.handleEdgeSwipe(startLocationX: 10, translationWidth: 30)
        XCTAssertFalse(tooShort)
        XCTAssertEqual(vm.bendsRoute, .detail(.segmented))
    }
}
