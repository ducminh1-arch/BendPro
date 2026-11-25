import XCTest
@testable import BendPro
import BendProCore

final class HomeScreenTests: XCTestCase {

    func testCoreBendsItems() {
        XCTAssertEqual(CORE_BENDS.count, 4)
        XCTAssertEqual(CORE_BENDS.map { $0.kind }, [.offset, .ninety, .saddle3, .kick])
        XCTAssertEqual(CORE_BENDS[0].title, "Offset")
        XCTAssertEqual(CORE_BENDS[0].sub, "Two bends to clear an obstacle vertically")
        XCTAssertEqual(CORE_BENDS[1].title, "90° Bend")
        XCTAssertEqual(CORE_BENDS[1].sub, "Stub-up from floor or wall")
        XCTAssertEqual(CORE_BENDS[2].title, "3-Point Saddle")
        XCTAssertEqual(CORE_BENDS[2].sub, "Over a round or square obstruction")
        XCTAssertEqual(CORE_BENDS[3].title, "Kick")
        XCTAssertEqual(CORE_BENDS[3].sub, "Single angled bend")
    }

    func testAdvancedBendsItems() {
        XCTAssertEqual(ADVANCED_BENDS.count, 4)
        XCTAssertEqual(ADVANCED_BENDS.map { $0.kind }, [.kick90, .segmented, .saddle4, .rolling])
        XCTAssertEqual(ADVANCED_BENDS[0].title, "Kick + 90°")
        XCTAssertEqual(ADVANCED_BENDS[0].sub, "Kick with a stub-up at the end")
        XCTAssertEqual(ADVANCED_BENDS[1].title, "Multi-Shot")
        XCTAssertEqual(ADVANCED_BENDS[1].sub, "Segmented bend for large radius")
        XCTAssertEqual(ADVANCED_BENDS[2].title, "4-Point Saddle")
        XCTAssertEqual(ADVANCED_BENDS[2].sub, "Flat-topped, wide obstruction")
        XCTAssertEqual(ADVANCED_BENDS[3].title, "Rolling Offset")
        XCTAssertEqual(ADVANCED_BENDS[3].sub, "Offset across two planes")
    }

    func testToolsBendsItems() {
        XCTAssertEqual(TOOLS_BENDS.count, 1)
        XCTAssertEqual(TOOLS_BENDS[0].kind, .wirefill)
        XCTAssertEqual(TOOLS_BENDS[0].title, "Wire Fill")
        XCTAssertEqual(TOOLS_BENDS[0].sub, "Conduit fill % vs NEC limit")
    }

    func testTotalCardsCount() {
        let total = CORE_BENDS.count + ADVANCED_BENDS.count + TOOLS_BENDS.count
        XCTAssertEqual(total, 9)
    }
}
