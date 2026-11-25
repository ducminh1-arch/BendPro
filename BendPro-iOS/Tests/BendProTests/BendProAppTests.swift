import XCTest
@testable import BendPro
import BendProCore

final class BendProAppTests: XCTestCase {
    func testAppTargetLoads() {
        XCTAssertEqual(BendKind.allCases.count, 9)
    }
}
