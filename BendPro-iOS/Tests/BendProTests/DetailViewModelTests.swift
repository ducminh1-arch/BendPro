import XCTest
@testable import BendPro
import BendProCore

final class DetailViewModelTests: XCTestCase {

    func testSaveLabels() {
        XCTAssertEqual(buildLabel(kind: .offset, angleDeg: 30.0), "30° Offset")
        XCTAssertEqual(buildLabel(kind: .offset, angleDeg: 22.5), "22.5° Offset")
        XCTAssertEqual(buildLabel(kind: .ninety, angleDeg: 30.0), "90° Bend")
        XCTAssertEqual(buildLabel(kind: .kick, angleDeg: 45.0), "45° Kick")
        XCTAssertEqual(buildLabel(kind: .saddle3, angleDeg: 30.0), "3-Point Saddle")
        XCTAssertEqual(buildLabel(kind: .kick90, angleDeg: 30.0), "30° Kick + 90°")
        XCTAssertEqual(buildLabel(kind: .segmented, angleDeg: 90.0), "Multi-Shot 90°")
        XCTAssertEqual(buildLabel(kind: .segmented, angleDeg: 45.0), "Multi-Shot 90°")
        XCTAssertEqual(buildLabel(kind: .saddle4, angleDeg: 22.5), "4-Point Saddle")
        XCTAssertEqual(buildLabel(kind: .rolling, angleDeg: 30.0), "30° Rolling Offset")
        XCTAssertEqual(buildLabel(kind: .wirefill, angleDeg: 30.0), "Wire Fill")
    }

    func testInputSummaries() {
        let offsetSum = buildInputSummary(
            kind: .offset,
            unit: .inch,
            tradeSizeIn: 0.75,
            offsetIn: 4.0,
            stubHeightIn: 12.0,
            riseIn: 6.0,
            depthIn: 3.0,
            kickOffsetIn: 4.0,
            kick90StubIn: 18.0,
            totalAngleDeg: 90.0,
            radiusIn: 24.0,
            shots: 6,
            obstructionWidthIn: 8.0,
            rollingVerticalIn: 6.0,
            rollingHorizontalIn: 4.0,
            wireConduitSizeIn: 0.75,
            wireAwg: "12",
            wireCount: 3
        )
        XCTAssertEqual(offsetSum, "Offset 4\" · 3/4\"")

        let ninetySum = buildInputSummary(
            kind: .ninety,
            unit: .inch,
            tradeSizeIn: 0.75,
            offsetIn: 4.0,
            stubHeightIn: 12.0,
            riseIn: 6.0,
            depthIn: 3.0,
            kickOffsetIn: 4.0,
            kick90StubIn: 18.0,
            totalAngleDeg: 90.0,
            radiusIn: 24.0,
            shots: 6,
            obstructionWidthIn: 8.0,
            rollingVerticalIn: 6.0,
            rollingHorizontalIn: 4.0,
            wireConduitSizeIn: 0.75,
            wireAwg: "12",
            wireCount: 3
        )
        XCTAssertEqual(ninetySum, "Stub 12\" · 3/4\"")

        let kickSum = buildInputSummary(
            kind: .kick,
            unit: .inch,
            tradeSizeIn: 0.75,
            offsetIn: 4.0,
            stubHeightIn: 12.0,
            riseIn: 6.0,
            depthIn: 3.0,
            kickOffsetIn: 4.0,
            kick90StubIn: 18.0,
            totalAngleDeg: 90.0,
            radiusIn: 24.0,
            shots: 6,
            obstructionWidthIn: 8.0,
            rollingVerticalIn: 6.0,
            rollingHorizontalIn: 4.0,
            wireConduitSizeIn: 0.75,
            wireAwg: "12",
            wireCount: 3
        )
        XCTAssertEqual(kickSum, "Rise 6\" · 3/4\"")

        let saddle3Sum = buildInputSummary(
            kind: .saddle3,
            unit: .inch,
            tradeSizeIn: 0.75,
            offsetIn: 4.0,
            stubHeightIn: 12.0,
            riseIn: 6.0,
            depthIn: 3.0,
            kickOffsetIn: 4.0,
            kick90StubIn: 18.0,
            totalAngleDeg: 90.0,
            radiusIn: 24.0,
            shots: 6,
            obstructionWidthIn: 8.0,
            rollingVerticalIn: 6.0,
            rollingHorizontalIn: 4.0,
            wireConduitSizeIn: 0.75,
            wireAwg: "12",
            wireCount: 3
        )
        XCTAssertEqual(saddle3Sum, "Depth 3\" · 3/4\"")

        let kick90Sum = buildInputSummary(
            kind: .kick90,
            unit: .inch,
            tradeSizeIn: 0.75,
            offsetIn: 4.0,
            stubHeightIn: 12.0,
            riseIn: 6.0,
            depthIn: 3.0,
            kickOffsetIn: 4.0,
            kick90StubIn: 18.0,
            totalAngleDeg: 90.0,
            radiusIn: 24.0,
            shots: 6,
            obstructionWidthIn: 8.0,
            rollingVerticalIn: 6.0,
            rollingHorizontalIn: 4.0,
            wireConduitSizeIn: 0.75,
            wireAwg: "12",
            wireCount: 3
        )
        XCTAssertEqual(kick90Sum, "Kick offset 4\" · Stub 18\" · 3/4\"")

        let segmentedSum = buildInputSummary(
            kind: .segmented,
            unit: .inch,
            tradeSizeIn: 0.75,
            offsetIn: 4.0,
            stubHeightIn: 12.0,
            riseIn: 6.0,
            depthIn: 3.0,
            kickOffsetIn: 4.0,
            kick90StubIn: 18.0,
            totalAngleDeg: 90.0,
            radiusIn: 24.0,
            shots: 6,
            obstructionWidthIn: 8.0,
            rollingVerticalIn: 6.0,
            rollingHorizontalIn: 4.0,
            wireConduitSizeIn: 0.75,
            wireAwg: "12",
            wireCount: 3
        )
        XCTAssertEqual(segmentedSum, "Sweep 90° · Radius 24\" · 6 shots")

        let saddle4Sum = buildInputSummary(
            kind: .saddle4,
            unit: .inch,
            tradeSizeIn: 0.75,
            offsetIn: 4.0,
            stubHeightIn: 12.0,
            riseIn: 6.0,
            depthIn: 3.0,
            kickOffsetIn: 4.0,
            kick90StubIn: 18.0,
            totalAngleDeg: 90.0,
            radiusIn: 24.0,
            shots: 6,
            obstructionWidthIn: 8.0,
            rollingVerticalIn: 6.0,
            rollingHorizontalIn: 4.0,
            wireConduitSizeIn: 0.75,
            wireAwg: "12",
            wireCount: 3
        )
        XCTAssertEqual(saddle4Sum, "Depth 3\" · Width 8\" · 3/4\"")

        let rollingSum = buildInputSummary(
            kind: .rolling,
            unit: .inch,
            tradeSizeIn: 0.75,
            offsetIn: 4.0,
            stubHeightIn: 12.0,
            riseIn: 6.0,
            depthIn: 3.0,
            kickOffsetIn: 4.0,
            kick90StubIn: 18.0,
            totalAngleDeg: 90.0,
            radiusIn: 24.0,
            shots: 6,
            obstructionWidthIn: 8.0,
            rollingVerticalIn: 6.0,
            rollingHorizontalIn: 4.0,
            wireConduitSizeIn: 0.75,
            wireAwg: "12",
            wireCount: 3
        )
        XCTAssertEqual(rollingSum, "Vertical 6\" · Horizontal 4\" · 3/4\"")

        let wireSum = buildInputSummary(
            kind: .wirefill,
            unit: .inch,
            tradeSizeIn: 0.75,
            offsetIn: 4.0,
            stubHeightIn: 12.0,
            riseIn: 6.0,
            depthIn: 3.0,
            kickOffsetIn: 4.0,
            kick90StubIn: 18.0,
            totalAngleDeg: 90.0,
            radiusIn: 24.0,
            shots: 6,
            obstructionWidthIn: 8.0,
            rollingVerticalIn: 6.0,
            rollingHorizontalIn: 4.0,
            wireConduitSizeIn: 0.75,
            wireAwg: "12",
            wireCount: 3
        )
        XCTAssertEqual(wireSum, "3 × 12 AWG in 3/4\" EMT")
    }

    func testInitialDefaultsAll9Kinds() {
        let vm = DetailViewModel()

        let offsetState = vm.getState(for: .offset)
        XCTAssertEqual(offsetState.offsetIn, 4.0)
        XCTAssertEqual(offsetState.angleDeg, 30.0)
        XCTAssertEqual(offsetState.tradeSizeIn, 0.75)
        XCTAssertFalse(offsetState.saved)

        let ninetyState = vm.getState(for: .ninety)
        XCTAssertEqual(ninetyState.stubHeightIn, 12.0)
        XCTAssertEqual(ninetyState.tradeSizeIn, 0.75)

        let kickState = vm.getState(for: .kick)
        XCTAssertEqual(kickState.riseIn, 6.0)
        XCTAssertEqual(kickState.angleDeg, 30.0)
        XCTAssertEqual(kickState.tradeSizeIn, 0.75)

        let saddle3State = vm.getState(for: .saddle3)
        XCTAssertEqual(saddle3State.depthIn, 3.0)
        XCTAssertEqual(saddle3State.tradeSizeIn, 0.75)

        let kick90State = vm.getState(for: .kick90)
        XCTAssertEqual(kick90State.kickOffsetIn, 4.0)
        XCTAssertEqual(kick90State.kick90StubIn, 18.0)
        XCTAssertEqual(kick90State.angleDeg, 30.0)

        let segmentedState = vm.getState(for: .segmented)
        XCTAssertEqual(segmentedState.totalAngleDeg, 90.0)
        XCTAssertEqual(segmentedState.radiusIn, 24.0)
        XCTAssertEqual(segmentedState.shots, 6)

        let saddle4State = vm.getState(for: .saddle4)
        XCTAssertEqual(saddle4State.depthIn, 3.0)
        XCTAssertEqual(saddle4State.obstructionWidthIn, 8.0)

        let rollingState = vm.getState(for: .rolling)
        XCTAssertEqual(rollingState.rollingVerticalIn, 6.0)
        XCTAssertEqual(rollingState.rollingHorizontalIn, 4.0)
        XCTAssertEqual(rollingState.angleDeg, 30.0)

        let wirefillState = vm.getState(for: .wirefill)
        XCTAssertEqual(wirefillState.wireConduitSizeIn, 0.75)
        XCTAssertEqual(wirefillState.wireAwg, "12")
        XCTAssertEqual(wirefillState.wireCount, 3)
    }

    func testResetToDefaultsAll9Kinds() {
        let vm = DetailViewModel()

        // Kick90
        vm.setKickOffset(kind: .kick90, kickOffsetIn: 8.0)
        vm.setKick90Stub(kind: .kick90, kick90StubIn: 30.0)
        XCTAssertEqual(vm.getState(for: .kick90).kickOffsetIn, 8.0)
        vm.resetToDefaults(.kick90)
        XCTAssertEqual(vm.getState(for: .kick90).kickOffsetIn, 4.0)
        XCTAssertEqual(vm.getState(for: .kick90).kick90StubIn, 18.0)

        // Segmented
        vm.setTotalAngle(kind: .segmented, totalAngleDeg: 45.0)
        vm.setRadius(kind: .segmented, radiusIn: 36.0)
        vm.setShots(kind: .segmented, shots: 10)
        XCTAssertEqual(vm.getState(for: .segmented).shots, 10)
        vm.resetToDefaults(.segmented)
        XCTAssertEqual(vm.getState(for: .segmented).totalAngleDeg, 90.0)
        XCTAssertEqual(vm.getState(for: .segmented).radiusIn, 24.0)
        XCTAssertEqual(vm.getState(for: .segmented).shots, 6)

        // Saddle4
        vm.setDepth(kind: .saddle4, depthIn: 5.0)
        vm.setObstructionWidth(kind: .saddle4, widthIn: 16.0)
        XCTAssertEqual(vm.getState(for: .saddle4).obstructionWidthIn, 16.0)
        vm.resetToDefaults(.saddle4)
        XCTAssertEqual(vm.getState(for: .saddle4).depthIn, 3.0)
        XCTAssertEqual(vm.getState(for: .saddle4).obstructionWidthIn, 8.0)

        // Rolling
        vm.setRollingVertical(kind: .rolling, verticalIn: 12.0)
        vm.setRollingHorizontal(kind: .rolling, horizontalIn: 10.0)
        XCTAssertEqual(vm.getState(for: .rolling).rollingVerticalIn, 12.0)
        vm.resetToDefaults(.rolling)
        XCTAssertEqual(vm.getState(for: .rolling).rollingVerticalIn, 6.0)
        XCTAssertEqual(vm.getState(for: .rolling).rollingHorizontalIn, 4.0)

        // Wirefill
        vm.setWireConduitSize(kind: .wirefill, sizeIn: 1.0)
        vm.setWireAwg(kind: .wirefill, awg: "10")
        vm.setWireCount(kind: .wirefill, count: 8)
        XCTAssertEqual(vm.getState(for: .wirefill).wireCount, 8)
        vm.resetToDefaults(.wirefill)
        XCTAssertEqual(vm.getState(for: .wirefill).wireConduitSizeIn, 0.75)
        XCTAssertEqual(vm.getState(for: .wirefill).wireAwg, "12")
        XCTAssertEqual(vm.getState(for: .wirefill).wireCount, 3)
    }

    func testBenderPickerRoundTripPreservesInputs() {
        let vm = DetailViewModel()

        // Modify inputs for offset
        vm.setOffset(kind: .offset, offsetIn: 8.5)
        vm.setAngle(kind: .offset, angleDeg: 22.5)
        XCTAssertEqual(vm.getState(for: .offset).offsetIn, 8.5)
        XCTAssertEqual(vm.getState(for: .offset).angleDeg, 22.5)

        // Bender picker round-trip does NOT call resetToDefaults
        let bender = BENDERS[0]
        vm.clampTradeSize(bender: bender, kind: .offset)

        // Inputs are preserved!
        XCTAssertEqual(vm.getState(for: .offset).offsetIn, 8.5)
        XCTAssertEqual(vm.getState(for: .offset).angleDeg, 22.5)

        // Leaving the detail screen calls resetToDefaults
        vm.resetToDefaults(.offset)
        XCTAssertEqual(vm.getState(for: .offset).offsetIn, 4.0)
        XCTAssertEqual(vm.getState(for: .offset).angleDeg, 30.0)

        // Same check for rolling
        vm.setRollingVertical(kind: .rolling, verticalIn: 10.0)
        vm.setRollingHorizontal(kind: .rolling, horizontalIn: 8.0)
        vm.clampTradeSize(bender: bender, kind: .rolling)
        XCTAssertEqual(vm.getState(for: .rolling).rollingVerticalIn, 10.0)
        XCTAssertEqual(vm.getState(for: .rolling).rollingHorizontalIn, 8.0)
        vm.resetToDefaults(.rolling)
        XCTAssertEqual(vm.getState(for: .rolling).rollingVerticalIn, 6.0)
        XCTAssertEqual(vm.getState(for: .rolling).rollingHorizontalIn, 4.0)
    }

    func testClampTradeSize() {
        let vm = DetailViewModel()

        // iToolco Mega Bender supports [1.0, 1.25, 1.5]
        guard let itoolco = BENDERS.first(where: { $0.id == "itoolco-mega-1-1.5" }) else {
            XCTFail("iToolco bender not found")
            return
        }

        // Default size is 0.75, which is not supported by iToolco Mega
        XCTAssertEqual(vm.getState(for: .offset).tradeSizeIn, 0.75)
        XCTAssertFalse(itoolco.conduitSizesIn.contains(0.75))

        // Clamp to iToolco
        vm.clampTradeSize(bender: itoolco, kind: .offset)
        XCTAssertEqual(vm.getState(for: .offset).tradeSizeIn, 1.0)

        // Klein supports [0.5, 0.75, 1.0, 1.25]
        let klein = BENDERS[0]
        vm.clampTradeSize(bender: klein, kind: .offset)
        XCTAssertEqual(vm.getState(for: .offset).tradeSizeIn, 1.0)
    }

    func testSaveHistoryEntryMarksSaved() {
        let vm = DetailViewModel()
        let bender = BENDERS[0]

        XCTAssertFalse(vm.getState(for: .offset).saved)

        let entry = vm.saveHistoryEntry(kind: .offset, unit: .inch, bender: bender)
        XCTAssertEqual(entry.kind, .offset)
        XCTAssertEqual(entry.label, "30° Offset")
        XCTAssertEqual(entry.inputSummary, "Offset 4\" · 3/4\"")
        XCTAssertTrue(vm.getState(for: .offset).saved)

        // Modifying any value resets saved to false
        vm.setOffset(kind: .offset, offsetIn: 5.0)
        XCTAssertFalse(vm.getState(for: .offset).saved)
    }

    func testGoldenCalculationsOutputViaViewModel() {
        let vm = DetailViewModel()
        let klein = BENDERS[0]
        guard let greenlee = BENDERS.first(where: { $0.id == "greenlee-840ah" }) else {
            XCTFail("Greenlee bender not found")
            return
        }

        // kick90(30, 4, 0.75, 18, K) -> kickMark 8, deduct 6, stubMark 12, ok
        let k90Res = calculateResult(kind: .kick90, state: vm.getState(for: .kick90), bender: klein) as! Kick90Result
        XCTAssertEqual(k90Res.kickMarkIn, 8.0, accuracy: 1e-9)
        XCTAssertEqual(k90Res.deductIn, 6.0, accuracy: 1e-9)
        XCTAssertEqual(k90Res.stubMarkIn, 12.0, accuracy: 1e-9)
        XCTAssertEqual(k90Res.feasibility.level, .ok)

        // segmented(90, 24, 6) -> anglePerShot 18, distance 7.508854321931082, warn
        let segRes = calculateResult(kind: .segmented, state: vm.getState(for: .segmented), bender: klein) as! SegmentedResult
        XCTAssertEqual(segRes.anglePerShotDeg, 18.0, accuracy: 1e-9)
        XCTAssertEqual(segRes.distanceBetweenShotsIn, 7.508854321931082, accuracy: 1e-9)
        XCTAssertEqual(segRes.feasibility.level, .warn)

        // saddle4(3, 8, G, 1) -> inner 8, outerFromInner 7.5, totalGain 0.75, ok
        var s4State = vm.getState(for: .saddle4)
        s4State.tradeSizeIn = 1.0
        let s4Res = calculateResult(kind: .saddle4, state: s4State, bender: greenlee) as! Saddle4Result
        XCTAssertEqual(s4Res.innerSpacingIn, 8.0, accuracy: 1e-9)
        XCTAssertEqual(s4Res.outerFromInnerIn, 7.5, accuracy: 1e-9)
        XCTAssertEqual(s4Res.totalGainIn, 0.75, accuracy: 1e-9)
        XCTAssertEqual(s4Res.feasibility.level, .ok)

        // rolling(30, 6, 4, K, 0.75) -> trueOffset 7.211102550927978, rollAngle 33.690067525979785, distance 14.422205101855956, shrink 2.7041634565979917, ok
        let rollRes = calculateResult(kind: .rolling, state: vm.getState(for: .rolling), bender: klein) as! RollingOffsetResult
        XCTAssertEqual(rollRes.trueOffsetIn, 7.211102550927978, accuracy: 1e-9)
        XCTAssertEqual(rollRes.rollAngleDeg, 33.690067525979785, accuracy: 1e-9)
        XCTAssertEqual(rollRes.distanceBetweenBendsIn, 14.422205101855956, accuracy: 1e-9)
        XCTAssertEqual(rollRes.shrinkIn, 2.7041634565979917, accuracy: 1e-9)
        XCTAssertEqual(rollRes.feasibility.level, .ok)

        // wirefill(0.75, "12", 3) -> conduitArea 0.533, total 0.0399, max 40, fill 7.4859287054409, ok
        let wireRes = calculateResult(kind: .wirefill, state: vm.getState(for: .wirefill), bender: klein) as! WireFillResult
        XCTAssertEqual(wireRes.conduitAreaSqIn, 0.533, accuracy: 1e-9)
        XCTAssertEqual(wireRes.totalConductorAreaSqIn, 0.0399, accuracy: 1e-9)
        XCTAssertEqual(wireRes.maxFillPct, 40)
        XCTAssertEqual(wireRes.fillPct, 7.4859287054409, accuracy: 1e-9)
        XCTAssertEqual(wireRes.feasibility.level, .ok)
    }
}
