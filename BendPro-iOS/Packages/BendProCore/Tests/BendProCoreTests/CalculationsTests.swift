import XCTest
@testable import BendProCore

final class CalculationsTests: XCTestCase {

    private let klein = BENDERS[0]    // klein-emt-standard
    private let greenlee = BENDERS[1] // greenlee-855

    func testOffsetGolden() {
        // offset(30, 4, K, 0.75) -> distanceBetweenBends 8, travel 8, shrink 1.5, ok
        let r1 = calculateOffset(angle: 30, offset: 4, bender: klein, size: 0.75)
        XCTAssertEqual(r1.distanceBetweenBendsIn, 8.0, accuracy: 1e-9)
        XCTAssertEqual(r1.travelIn, 8.0, accuracy: 1e-9)
        XCTAssertEqual(r1.shrinkIn, 1.5, accuracy: 1e-9)
        XCTAssertEqual(r1.feasibility.level, .ok)
        XCTAssertEqual(summarize(result: r1), "Marks 8.00\" apart · shrink 1.500\"")

        // offset(10, 1, K, 1) -> distance 6, shrink 0.0625, ok
        let r2 = calculateOffset(angle: 10, offset: 1, bender: klein, size: 1.0)
        XCTAssertEqual(r2.distanceBetweenBendsIn, 6.0, accuracy: 1e-9)
        XCTAssertEqual(r2.shrinkIn, 0.0625, accuracy: 1e-9)
        XCTAssertEqual(r2.feasibility.level, .ok)

        // offset(45, 1, K, 0.75) -> distance 1.4, shrink 0.375, danger
        let r3 = calculateOffset(angle: 45, offset: 1, bender: klein, size: 0.75)
        XCTAssertEqual(r3.distanceBetweenBendsIn, 1.4, accuracy: 1e-9)
        XCTAssertEqual(r3.shrinkIn, 0.375, accuracy: 1e-9)
        XCTAssertEqual(r3.feasibility.level, .danger)

        // offset(22.5, 2, K, 0.75) -> distance 5.2, shrink 0.5, warn
        let r4 = calculateOffset(angle: 22.5, offset: 2, bender: klein, size: 0.75)
        XCTAssertEqual(r4.distanceBetweenBendsIn, 5.2, accuracy: 1e-9)
        XCTAssertEqual(r4.shrinkIn, 0.5, accuracy: 1e-9)
        XCTAssertEqual(r4.feasibility.level, .warn)

        // offset(30, 2, K, 0.75) -> distance 4, shrink 0.75, danger
        let r5 = calculateOffset(angle: 30, offset: 2, bender: klein, size: 0.75)
        XCTAssertEqual(r5.distanceBetweenBendsIn, 4.0, accuracy: 1e-9)
        XCTAssertEqual(r5.shrinkIn, 0.75, accuracy: 1e-9)
        XCTAssertEqual(r5.feasibility.level, .danger)

        // offset(30, 3, K, 0.75) -> distance 6, shrink 1.125, warn
        let r6 = calculateOffset(angle: 30, offset: 3, bender: klein, size: 0.75)
        XCTAssertEqual(r6.distanceBetweenBendsIn, 6.0, accuracy: 1e-9)
        XCTAssertEqual(r6.shrinkIn, 1.125, accuracy: 1e-9)
        XCTAssertEqual(r6.feasibility.level, .warn)
    }

    func testNinetyGolden() {
        // ninety(0.75, 12) -> deduct 6, mark 6, ok
        let r1 = calculateNinety(size: 0.75, stub: 12)
        XCTAssertEqual(r1.deductIn, 6.0, accuracy: 1e-9)
        XCTAssertEqual(r1.markIn, 6.0, accuracy: 1e-9)
        XCTAssertEqual(r1.feasibility.level, .ok)
        XCTAssertEqual(summarize(result: r1), "Mark at 6.00\" · deduct 6\"")

        // ninety(1, 9) -> deduct 8, mark 1, warn
        let r2 = calculateNinety(size: 1.0, stub: 9)
        XCTAssertEqual(r2.deductIn, 8.0, accuracy: 1e-9)
        XCTAssertEqual(r2.markIn, 1.0, accuracy: 1e-9)
        XCTAssertEqual(r2.feasibility.level, .warn)

        // ninety(0.5, 4) -> deduct 5, mark -1, danger
        let r3 = calculateNinety(size: 0.5, stub: 4)
        XCTAssertEqual(r3.deductIn, 5.0, accuracy: 1e-9)
        XCTAssertEqual(r3.markIn, -1.0, accuracy: 1e-9)
        XCTAssertEqual(r3.feasibility.level, .danger)
    }

    func testKickGolden() {
        // kick(45, 6, K, 0.75) -> distanceToMark 8.4, gain 2.25, ok
        let r1 = calculateKick(angle: 45, rise: 6, bender: klein, size: 0.75)
        XCTAssertEqual(r1.distanceToMarkIn, 8.4, accuracy: 1e-9)
        XCTAssertEqual(r1.gainIn, 2.25, accuracy: 1e-9)
        XCTAssertEqual(r1.feasibility.level, .ok)
        XCTAssertEqual(summarize(result: r1), "Mark at 8.40\" · gain 2.250\"")

        // kick(45, 3, K, 0.75) -> distanceToMark 4.2, gain 1.125, warn
        let r2 = calculateKick(angle: 45, rise: 3, bender: klein, size: 0.75)
        XCTAssertEqual(r2.distanceToMarkIn, 4.2, accuracy: 1e-9)
        XCTAssertEqual(r2.gainIn, 1.125, accuracy: 1e-9)
        XCTAssertEqual(r2.feasibility.level, .warn)

        // kick(60, 2, K, 0.75) -> distanceToMark 2.4, gain 0.5, danger
        let r3 = calculateKick(angle: 60, rise: 2, bender: klein, size: 0.75)
        XCTAssertEqual(r3.distanceToMarkIn, 2.4, accuracy: 1e-9)
        XCTAssertEqual(r3.gainIn, 0.5, accuracy: 1e-9)
        XCTAssertEqual(r3.feasibility.level, .danger)
    }

    func testSaddle3Golden() {
        // saddle3(3, K, 0.75) -> centerToSide 7.5, totalGain 0.75, ok
        let r1 = calculateSaddle3(depth: 3, bender: klein, size: 0.75)
        XCTAssertEqual(r1.centerToSideIn, 7.5, accuracy: 1e-9)
        XCTAssertEqual(r1.totalGainIn, 0.75, accuracy: 1e-9)
        XCTAssertEqual(r1.feasibility.level, .ok)
        XCTAssertEqual(summarize(result: r1), "Side bends 7.50\" from center · gain 0.750\"")

        // saddle3(1, K, 0.75) -> centerToSide 2.5, totalGain 0.25, danger
        let r2 = calculateSaddle3(depth: 1, bender: klein, size: 0.75)
        XCTAssertEqual(r2.centerToSideIn, 2.5, accuracy: 1e-9)
        XCTAssertEqual(r2.totalGainIn, 0.25, accuracy: 1e-9)
        XCTAssertEqual(r2.feasibility.level, .danger)
    }

    func testKick90Golden() {
        // kick90(30, 4, 0.75, 18, K) -> kickMark 8, deduct 6, stubMark 12, ok
        let r1 = calculateKick90(angle: 30, kickOffset: 4, size: 0.75, stub: 18, bender: klein)
        XCTAssertEqual(r1.kickMarkIn, 8.0, accuracy: 1e-9)
        XCTAssertEqual(r1.deductIn, 6.0, accuracy: 1e-9)
        XCTAssertEqual(r1.stubMarkIn, 12.0, accuracy: 1e-9)
        XCTAssertEqual(r1.feasibility.level, .ok)
        XCTAssertEqual(summarize(result: r1), "Kick mark 8.00\" from start · stub mark 12.00\" from end")

        // kick90(45, 1, 0.75, 18, K) -> kickMark 1.4, stubMark 12, danger
        let r2 = calculateKick90(angle: 45, kickOffset: 1, size: 0.75, stub: 18, bender: klein)
        XCTAssertEqual(r2.kickMarkIn, 1.4, accuracy: 1e-9)
        XCTAssertEqual(r2.stubMarkIn, 12.0, accuracy: 1e-9)
        XCTAssertEqual(r2.feasibility.level, .danger)
    }

    func testSegmentedGolden() {
        // segmented(90, 24, 6) -> anglePerShot 18, distanceBetweenShots 7.508854321931082, warn
        let r1 = calculateSegmented(totalAngle: 90, radius: 24, shots: 6)
        XCTAssertEqual(r1.anglePerShotDeg, 18.0, accuracy: 1e-9)
        XCTAssertEqual(r1.distanceBetweenShotsIn, 7.508854321931082, accuracy: 1e-9)
        XCTAssertEqual(r1.feasibility.level, .warn)
        XCTAssertEqual(summarize(result: r1), "6 shots at 18.0° · 7.51\" apart")

        // segmented(90, 24, 8) -> anglePerShot 12.857142857142858, distance 5.374294852958777, ok
        let r2 = calculateSegmented(totalAngle: 90, radius: 24, shots: 8)
        XCTAssertEqual(r2.anglePerShotDeg, 12.857142857142858, accuracy: 1e-9)
        XCTAssertEqual(r2.distanceBetweenShotsIn, 5.374294852958777, accuracy: 1e-9)
        XCTAssertEqual(r2.feasibility.level, .ok)

        // segmented(90, 24, 1) -> anglePerShot 90, danger
        let r3 = calculateSegmented(totalAngle: 90, radius: 24, shots: 1)
        XCTAssertEqual(r3.anglePerShotDeg, 90.0, accuracy: 1e-9)
        XCTAssertEqual(r3.feasibility.level, .danger)
    }

    func testSaddle4Golden() {
        // saddle4(3, 8, G, 1) -> inner 8, outerFromInner 7.5, totalGain 0.75, ok
        let r1 = calculateSaddle4(depth: 3, obstructionWidth: 8, bender: greenlee, size: 1.0)
        XCTAssertEqual(r1.innerSpacingIn, 8.0, accuracy: 1e-9)
        XCTAssertEqual(r1.outerFromInnerIn, 7.5, accuracy: 1e-9)
        XCTAssertEqual(r1.totalGainIn, 0.75, accuracy: 1e-9)
        XCTAssertEqual(r1.feasibility.level, .ok)
        XCTAssertEqual(summarize(result: r1), "Inner 8.00\" apart · outer 7.50\" beyond each")

        // saddle4(1, 8, K, 0.75) -> outerFromInner 2.5, totalGain 0.25, warn
        let r2 = calculateSaddle4(depth: 1, obstructionWidth: 8, bender: klein, size: 0.75)
        XCTAssertEqual(r2.outerFromInnerIn, 2.5, accuracy: 1e-9)
        XCTAssertEqual(r2.totalGainIn, 0.25, accuracy: 1e-9)
        XCTAssertEqual(r2.feasibility.level, .warn)
    }

    func testRollingGolden() {
        // rolling(30, 6, 4, K, 0.75) -> trueOffset 7.211102550927978, rollAngle 33.690067525979785, distance 14.422205101855956, shrink 2.7041634565979917, ok
        let r1 = calculateRolling(angle: 30, vertical: 6, horizontal: 4, bender: klein, size: 0.75)
        XCTAssertEqual(r1.trueOffsetIn, 7.211102550927978, accuracy: 1e-9)
        XCTAssertEqual(r1.rollAngleDeg, 33.690067525979785, accuracy: 1e-9)
        XCTAssertEqual(r1.distanceBetweenBendsIn, 14.422205101855956, accuracy: 1e-9)
        XCTAssertEqual(r1.shrinkIn, 2.7041634565979917, accuracy: 1e-9)
        XCTAssertEqual(r1.feasibility.level, .ok)
        XCTAssertEqual(summarize(result: r1), "True offset 7.21\" · roll 33.7° · marks 14.42\" apart")

        // rolling(30, 0, 0, K, 0.75) -> all 0, danger
        let r2 = calculateRolling(angle: 30, vertical: 0, horizontal: 0, bender: klein, size: 0.75)
        XCTAssertEqual(r2.trueOffsetIn, 0.0, accuracy: 1e-9)
        XCTAssertEqual(r2.distanceBetweenBendsIn, 0.0, accuracy: 1e-9)
        XCTAssertEqual(r2.shrinkIn, 0.0, accuracy: 1e-9)
        XCTAssertEqual(r2.feasibility.level, .danger)
    }

    func testWireFillGolden() {
        // wirefill(0.75, "12", 3) -> conduitArea 0.533, total 0.0399, max 40, fill 7.4859287054409, ok
        let r1 = calculateWireFill(size: 0.75, awg: "12", count: 3)
        XCTAssertEqual(r1.conduitAreaSqIn, 0.533, accuracy: 1e-9)
        XCTAssertEqual(r1.totalConductorAreaSqIn, 0.0399, accuracy: 1e-9)
        XCTAssertEqual(r1.maxFillPct, 40.0, accuracy: 1e-9)
        XCTAssertEqual(r1.fillPct, 7.4859287054409, accuracy: 1e-9)
        XCTAssertEqual(r1.feasibility.level, .ok)
        XCTAssertEqual(summarize(result: r1), "3 × 12 AWG in 0.75\" EMT · 7.5% fill")

        // wirefill(0.5, "12", 9) -> total 0.1197, fill 39.375, warn
        let r2 = calculateWireFill(size: 0.5, awg: "12", count: 9)
        XCTAssertEqual(r2.totalConductorAreaSqIn, 0.1197, accuracy: 1e-9)
        XCTAssertEqual(r2.fillPct, 39.375, accuracy: 1e-9)
        XCTAssertEqual(r2.feasibility.level, .warn)

        // wirefill(0.5, "12", 10) -> total 0.133, fill 43.75, danger
        let r3 = calculateWireFill(size: 0.5, awg: "12", count: 10)
        XCTAssertEqual(r3.totalConductorAreaSqIn, 0.133, accuracy: 1e-9)
        XCTAssertEqual(r3.fillPct, 43.75, accuracy: 1e-9)
        XCTAssertEqual(r3.feasibility.level, .danger)

        // wirefill(0.5, "8", 2) -> max 31, fill 24.07894736842105, ok
        let r4 = calculateWireFill(size: 0.5, awg: "8", count: 2)
        XCTAssertEqual(r4.maxFillPct, 31.0, accuracy: 1e-9)
        XCTAssertEqual(r4.fillPct, 24.07894736842105, accuracy: 1e-9)
        XCTAssertEqual(r4.feasibility.level, .ok)

        // wirefill(1, "1", 5) -> fill 90.39351851851852, danger
        let r5 = calculateWireFill(size: 1.0, awg: "1", count: 5)
        XCTAssertEqual(r5.fillPct, 90.39351851851852, accuracy: 1e-9)
        XCTAssertEqual(r5.feasibility.level, .danger)
    }
}
