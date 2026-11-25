import XCTest
@testable import BendProCore

final class UnitsTests: XCTestCase {

    func testToFraction() {
        XCTAssertEqual(toFraction(7.375), "7 3/8")
        XCTAssertEqual(toFraction(0.3125), "5/16")
        XCTAssertEqual(toFraction(0.03), "0")
        XCTAssertEqual(toFraction(3.5), "3 1/2")
        XCTAssertEqual(toFraction(0.0), "0")
        XCTAssertEqual(toFraction(1.0), "1")
    }

    func testFormatLengthInches() {
        XCTAssertEqual(formatLength(7.375, unit: .inch), "7 3/8\"")
        XCTAssertEqual(formatLength(0.3125, unit: .inch), "5/16\"")
        XCTAssertEqual(formatLength(-2.5, unit: .inch), "-2 1/2\"")
        XCTAssertEqual(formatLength(0.0, unit: .inch), "0\"")
    }

    func testFormatLengthFeetInches() {
        XCTAssertEqual(formatLength(30.5, unit: .ftIn), "2' 6 1/2\"")
        XCTAssertEqual(formatLength(12.0, unit: .ftIn), "1' 0\"")
        XCTAssertEqual(formatLength(6.0, unit: .ftIn), "6\"")
        // Deviation A9.3: 11.99 rounds up to 12" -> carries over to 1' 0"
        XCTAssertEqual(formatLength(11.99, unit: .ftIn), "1' 0\"")
        XCTAssertEqual(formatLength(23.99, unit: .ftIn), "2' 0\"")
    }

    func testFormatLengthMillimeters() {
        XCTAssertEqual(formatLength(7.375, unit: .mm), "187 mm")
        XCTAssertEqual(formatLength(4.1875, unit: .mm, precision: 3), "106.362 mm")
        XCTAssertEqual(formatLength(1.0, unit: .mm), "25 mm")
        XCTAssertEqual(formatLength(1.0, unit: .mm, precision: 1), "25.4 mm")
    }

    func testFormatLengthNonFinite() {
        XCTAssertEqual(formatLength(Double.nan, unit: .inch), "—")
        XCTAssertEqual(formatLength(Double.infinity, unit: .ftIn), "—")
        XCTAssertEqual(formatLength(-Double.infinity, unit: .mm), "—")
    }

    func testParseToInches() {
        XCTAssertEqual(parseToInches("12.5", unit: .inch) ?? 0, 12.5, accuracy: 1e-9)
        XCTAssertEqual(parseToInches("25.4", unit: .mm) ?? 0, 1.0, accuracy: 1e-9)
        XCTAssertNil(parseToInches("abc", unit: .inch))
    }
}
