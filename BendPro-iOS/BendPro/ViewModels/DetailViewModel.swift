import Foundation
import Combine
import BendProCore

public struct BendDetailState: Equatable {
    public var tradeSizeIn: Double = 0.75
    public var angleDeg: Double = 30.0
    public var offsetIn: Double = 4.0
    public var stubHeightIn: Double = 12.0
    public var riseIn: Double = 6.0
    public var depthIn: Double = 3.0
    public var kickOffsetIn: Double = 4.0
    public var kick90StubIn: Double = 18.0
    public var totalAngleDeg: Double = 90.0
    public var radiusIn: Double = 24.0
    public var shots: Int = 6
    public var obstructionWidthIn: Double = 8.0
    public var rollingVerticalIn: Double = 6.0
    public var rollingHorizontalIn: Double = 4.0
    public var wireConduitSizeIn: Double = 0.75
    public var wireAwg: String = "12"
    public var wireCount: Int = 3
    public var saved: Bool = false

    public init(
        tradeSizeIn: Double = 0.75,
        angleDeg: Double = 30.0,
        offsetIn: Double = 4.0,
        stubHeightIn: Double = 12.0,
        riseIn: Double = 6.0,
        depthIn: Double = 3.0,
        kickOffsetIn: Double = 4.0,
        kick90StubIn: Double = 18.0,
        totalAngleDeg: Double = 90.0,
        radiusIn: Double = 24.0,
        shots: Int = 6,
        obstructionWidthIn: Double = 8.0,
        rollingVerticalIn: Double = 6.0,
        rollingHorizontalIn: Double = 4.0,
        wireConduitSizeIn: Double = 0.75,
        wireAwg: String = "12",
        wireCount: Int = 3,
        saved: Bool = false
    ) {
        self.tradeSizeIn = tradeSizeIn
        self.angleDeg = angleDeg
        self.offsetIn = offsetIn
        self.stubHeightIn = stubHeightIn
        self.riseIn = riseIn
        self.depthIn = depthIn
        self.kickOffsetIn = kickOffsetIn
        self.kick90StubIn = kick90StubIn
        self.totalAngleDeg = totalAngleDeg
        self.radiusIn = radiusIn
        self.shots = shots
        self.obstructionWidthIn = obstructionWidthIn
        self.rollingVerticalIn = rollingVerticalIn
        self.rollingHorizontalIn = rollingHorizontalIn
        self.wireConduitSizeIn = wireConduitSizeIn
        self.wireAwg = wireAwg
        self.wireCount = wireCount
        self.saved = saved
    }
}

public func formatAngle(_ angle: Double) -> String {
    if angle.truncatingRemainder(dividingBy: 1.0) == 0 {
        return "\(Int(angle))"
    } else {
        return "\(angle)"
    }
}

public func buildLabel(kind: BendKind, angleDeg: Double) -> String {
    switch kind {
    case .offset:
        return "\(formatAngle(angleDeg))° Offset"
    case .ninety:
        return "90° Bend"
    case .kick:
        return "\(formatAngle(angleDeg))° Kick"
    case .saddle3:
        return "3-Point Saddle"
    case .kick90:
        return "\(formatAngle(angleDeg))° Kick + 90°"
    case .segmented:
        return "Multi-Shot 90°"
    case .saddle4:
        return "4-Point Saddle"
    case .rolling:
        return "\(formatAngle(angleDeg))° Rolling Offset"
    case .wirefill:
        return "Wire Fill"
    }
}

public func buildInputSummary(
    kind: BendKind,
    unit: LengthUnit,
    tradeSizeIn: Double,
    offsetIn: Double,
    stubHeightIn: Double,
    riseIn: Double,
    depthIn: Double,
    kickOffsetIn: Double,
    kick90StubIn: Double,
    totalAngleDeg: Double,
    radiusIn: Double,
    shots: Int,
    obstructionWidthIn: Double,
    rollingVerticalIn: Double,
    rollingHorizontalIn: Double,
    wireConduitSizeIn: Double,
    wireAwg: String,
    wireCount: Int
) -> String {
    switch kind {
    case .offset:
        return "Offset \(formatLength(offsetIn, unit: unit)) · \(tradeSizeLabel(tradeSizeIn))"
    case .ninety:
        return "Stub \(formatLength(stubHeightIn, unit: unit)) · \(tradeSizeLabel(tradeSizeIn))"
    case .kick:
        return "Rise \(formatLength(riseIn, unit: unit)) · \(tradeSizeLabel(tradeSizeIn))"
    case .saddle3:
        return "Depth \(formatLength(depthIn, unit: unit)) · \(tradeSizeLabel(tradeSizeIn))"
    case .kick90:
        return "Kick offset \(formatLength(kickOffsetIn, unit: unit)) · Stub \(formatLength(kick90StubIn, unit: unit)) · \(tradeSizeLabel(tradeSizeIn))"
    case .segmented:
        return "Sweep \(formatAngle(totalAngleDeg))° · Radius \(formatLength(radiusIn, unit: unit)) · \(shots) shots"
    case .saddle4:
        return "Depth \(formatLength(depthIn, unit: unit)) · Width \(formatLength(obstructionWidthIn, unit: unit)) · \(tradeSizeLabel(tradeSizeIn))"
    case .rolling:
        return "Vertical \(formatLength(rollingVerticalIn, unit: unit)) · Horizontal \(formatLength(rollingHorizontalIn, unit: unit)) · \(tradeSizeLabel(tradeSizeIn))"
    case .wirefill:
        return "\(wireCount) × \(wireAwg) AWG in \(tradeSizeLabel(wireConduitSizeIn)) EMT"
    }
}

public func calculateResult(kind: BendKind, state: BendDetailState, bender: Bender) -> BendResult {
    switch kind {
    case .offset:
        return calcOffset(angleDeg: state.angleDeg, offsetIn: state.offsetIn, bender: bender, tradeSizeIn: state.tradeSizeIn)
    case .ninety:
        return calcNinety(tradeSizeIn: state.tradeSizeIn, stubHeightIn: state.stubHeightIn)
    case .kick:
        return calcKick(angleDeg: state.angleDeg, riseIn: state.riseIn, bender: bender, tradeSizeIn: state.tradeSizeIn)
    case .saddle3:
        return calcSaddle3(depthIn: state.depthIn, bender: bender, tradeSizeIn: state.tradeSizeIn)
    case .kick90:
        return calcKick90(angleDeg: state.angleDeg, kickOffsetIn: state.kickOffsetIn, tradeSizeIn: state.tradeSizeIn, kick90StubIn: state.kick90StubIn, bender: bender)
    case .segmented:
        return calcSegmented(totalAngleDeg: state.totalAngleDeg, radiusIn: state.radiusIn, shots: state.shots)
    case .saddle4:
        return calcSaddle4(depthIn: state.depthIn, obstructionWidthIn: state.obstructionWidthIn, bender: bender, tradeSizeIn: state.tradeSizeIn)
    case .rolling:
        return calcRollingOffset(angleDeg: state.angleDeg, rollingVerticalIn: state.rollingVerticalIn, rollingHorizontalIn: state.rollingHorizontalIn, bender: bender, tradeSizeIn: state.tradeSizeIn)
    case .wirefill:
        return calcWireFill(conduitSizeIn: state.wireConduitSizeIn, wireAwg: state.wireAwg, count: state.wireCount)
    }
}

public class DetailViewModel: ObservableObject {
    @Published private var states: [BendKind: BendDetailState]

    public init() {
        var initial: [BendKind: BendDetailState] = [:]
        for kind in BendKind.allCases {
            initial[kind] = BendDetailState()
        }
        self.states = initial
    }

    public func getState(for kind: BendKind) -> BendDetailState {
        states[kind] ?? BendDetailState()
    }

    public func updateState(for kind: BendKind, transform: (inout BendDetailState) -> Void) {
        var current = getState(for: kind)
        transform(&current)
        states[kind] = current
    }

    /// Deviation A9.2: Clamp the trade size to the selected bender's supported sizes.
    public func clampTradeSize(bender: Bender, kind: BendKind) {
        let current = getState(for: kind)
        if !bender.conduitSizesIn.contains(current.tradeSizeIn) {
            let clamped = bender.conduitSizesIn.first ?? 0.75
            updateState(for: kind) { state in
                state.tradeSizeIn = clamped
            }
        }
    }

    public func setTradeSize(kind: BendKind, sizeIn: Double) {
        updateState(for: kind) { state in
            state.tradeSizeIn = sizeIn
            state.saved = false
        }
    }

    public func setAngle(kind: BendKind, angleDeg: Double) {
        updateState(for: kind) { state in
            state.angleDeg = angleDeg
            state.saved = false
        }
    }

    public func setOffset(kind: BendKind, offsetIn: Double) {
        updateState(for: kind) { state in
            state.offsetIn = offsetIn
            state.saved = false
        }
    }

    public func setStubHeight(kind: BendKind, stubHeightIn: Double) {
        updateState(for: kind) { state in
            state.stubHeightIn = stubHeightIn
            state.saved = false
        }
    }

    public func setRise(kind: BendKind, riseIn: Double) {
        updateState(for: kind) { state in
            state.riseIn = riseIn
            state.saved = false
        }
    }

    public func setDepth(kind: BendKind, depthIn: Double) {
        updateState(for: kind) { state in
            state.depthIn = depthIn
            state.saved = false
        }
    }

    public func setKickOffset(kind: BendKind, kickOffsetIn: Double) {
        updateState(for: kind) { state in
            state.kickOffsetIn = kickOffsetIn
            state.saved = false
        }
    }

    public func setKick90Stub(kind: BendKind, kick90StubIn: Double) {
        updateState(for: kind) { state in
            state.kick90StubIn = kick90StubIn
            state.saved = false
        }
    }

    public func setTotalAngle(kind: BendKind, totalAngleDeg: Double) {
        updateState(for: kind) { state in
            state.totalAngleDeg = totalAngleDeg
            state.saved = false
        }
    }

    public func setRadius(kind: BendKind, radiusIn: Double) {
        updateState(for: kind) { state in
            state.radiusIn = radiusIn
            state.saved = false
        }
    }

    public func setShots(kind: BendKind, shots: Int) {
        updateState(for: kind) { state in
            state.shots = shots
            state.saved = false
        }
    }

    public func setObstructionWidth(kind: BendKind, widthIn: Double) {
        updateState(for: kind) { state in
            state.obstructionWidthIn = widthIn
            state.saved = false
        }
    }

    public func setRollingVertical(kind: BendKind, verticalIn: Double) {
        updateState(for: kind) { state in
            state.rollingVerticalIn = verticalIn
            state.saved = false
        }
    }

    public func setRollingHorizontal(kind: BendKind, horizontalIn: Double) {
        updateState(for: kind) { state in
            state.rollingHorizontalIn = horizontalIn
            state.saved = false
        }
    }

    public func setWireConduitSize(kind: BendKind, sizeIn: Double) {
        updateState(for: kind) { state in
            state.wireConduitSizeIn = sizeIn
            state.saved = false
        }
    }

    public func setWireAwg(kind: BendKind, awg: String) {
        updateState(for: kind) { state in
            state.wireAwg = awg
            state.saved = false
        }
    }

    public func setWireCount(kind: BendKind, count: Int) {
        updateState(for: kind) { state in
            state.wireCount = count
            state.saved = false
        }
    }

    /// Resets inputs for this kind to its defaults in A5.
    public func resetToDefaults(_ kind: BendKind) {
        states[kind] = BendDetailState()
    }

    public func saveHistoryEntry(kind: BendKind, unit: LengthUnit, bender: Bender) -> HistoryEntry {
        let state = getState(for: kind)
        let result = calculateResult(kind: kind, state: state, bender: bender)
        let label = buildLabel(kind: kind, angleDeg: state.angleDeg)
        let inputSummary = buildInputSummary(
            kind: kind,
            unit: unit,
            tradeSizeIn: state.tradeSizeIn,
            offsetIn: state.offsetIn,
            stubHeightIn: state.stubHeightIn,
            riseIn: state.riseIn,
            depthIn: state.depthIn,
            kickOffsetIn: state.kickOffsetIn,
            kick90StubIn: state.kick90StubIn,
            totalAngleDeg: state.totalAngleDeg,
            radiusIn: state.radiusIn,
            shots: state.shots,
            obstructionWidthIn: state.obstructionWidthIn,
            rollingVerticalIn: state.rollingVerticalIn,
            rollingHorizontalIn: state.rollingHorizontalIn,
            wireConduitSizeIn: state.wireConduitSizeIn,
            wireAwg: state.wireAwg,
            wireCount: state.wireCount
        )
        let resultSummary = summarize(result)

        updateState(for: kind) { s in
            s.saved = true
        }

        let nowMillis = Int64(Date().timeIntervalSince1970 * 1000)
        return HistoryEntry(
            id: "\(nowMillis)",
            kind: kind,
            label: label,
            createdAt: nowMillis,
            inputSummary: inputSummary,
            resultSummary: resultSummary
        )
    }
}
