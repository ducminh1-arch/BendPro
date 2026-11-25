import XCTest
@testable import BendPro
import BendProCore

final class AppStoreTests: XCTestCase {

    private var testDefaults: UserDefaults!
    private let suiteName = "com.bendpro.tests.appstore"

    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: suiteName)!
        testDefaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: suiteName)
        testDefaults = nil
        super.tearDown()
    }

    func testInitialDefaults() {
        let store = AppStore(userDefaults: testDefaults)
        XCTAssertEqual(store.unit, .inch)
        XCTAssertEqual(store.benderId, "klein-emt-standard")
        XCTAssertEqual(store.selectedBender.id, "klein-emt-standard")
        XCTAssertEqual(store.history.count, 0)
        XCTAssertTrue(store.darkOptimized)
    }

    func testSetUnitPersists() {
        let store1 = AppStore(userDefaults: testDefaults)
        store1.setUnit(.mm)
        XCTAssertEqual(store1.unit, .mm)

        // Reload from same UserDefaults
        let store2 = AppStore(userDefaults: testDefaults)
        XCTAssertEqual(store2.unit, .mm)
    }

    func testSetBenderIdPersists() {
        let store1 = AppStore(userDefaults: testDefaults)
        store1.setBenderId("itoolco-mega-1-1.5")
        XCTAssertEqual(store1.benderId, "itoolco-mega-1-1.5")
        XCTAssertEqual(store1.selectedBender.model, "Mega Bender (1–1-1/2\")")

        let store2 = AppStore(userDefaults: testDefaults)
        XCTAssertEqual(store2.benderId, "itoolco-mega-1-1.5")
    }

    func testHistoryAppendAndClear() {
        let store1 = AppStore(userDefaults: testDefaults)
        let entry1 = HistoryEntry(
            id: "1001",
            kind: .offset,
            label: "30° Offset",
            createdAt: 1700000000000,
            inputSummary: "Offset 4\" · 3/4\"",
            resultSummary: "Marks 8.00\" apart · shrink 1.500\""
        )
        store1.addHistory(entry1)
        XCTAssertEqual(store1.history.count, 1)

        let store2 = AppStore(userDefaults: testDefaults)
        XCTAssertEqual(store2.history.count, 1)
        XCTAssertEqual(store2.history.first?.label, "30° Offset")

        store2.clearHistory()
        XCTAssertEqual(store2.history.count, 0)

        let store3 = AppStore(userDefaults: testDefaults)
        XCTAssertEqual(store3.history.count, 0)
    }

    func testCorruptDataFallback() {
        // Put corrupt data in UserDefaults
        testDefaults.set(Data("corrupt json bytes".utf8), forKey: AppStore.storageKey)

        let store = AppStore(userDefaults: testDefaults)
        XCTAssertEqual(store.unit, .inch)
        XCTAssertEqual(store.benderId, "klein-emt-standard")
        XCTAssertEqual(store.history.count, 0)
        XCTAssertTrue(store.darkOptimized)
    }
}
