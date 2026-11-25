import Foundation

public enum BendKind: String, CaseIterable, Codable, Identifiable, Hashable {
    case offset
    case ninety
    case saddle3
    case kick
    case kick90
    case segmented
    case saddle4
    case rolling
    case wirefill

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .offset: return "Offset"
        case .ninety: return "90° Bend"
        case .saddle3: return "3-Point Saddle"
        case .kick: return "Kick"
        case .kick90: return "Kick + 90°"
        case .segmented: return "Multi-Shot"
        case .saddle4: return "4-Point Saddle"
        case .rolling: return "Rolling Offset"
        case .wirefill: return "Wire Fill"
        }
    }

    public var subtitle: String {
        switch self {
        case .offset: return "Two bends to clear an obstacle vertically"
        case .ninety: return "Stub-up from floor or wall"
        case .saddle3: return "Over a round or square obstruction"
        case .kick: return "Single angled bend"
        case .kick90: return "Kick with a stub-up at the end"
        case .segmented: return "Segmented bend for large radius"
        case .saddle4: return "Flat-topped, wide obstruction"
        case .rolling: return "Offset across two planes"
        case .wirefill: return "Conduit fill % vs NEC limit"
        }
    }
}

public enum LengthUnit: String, CaseIterable, Codable, Identifiable, Hashable {
    case inch = "in"
    case ftIn = "ft-in"
    case mm = "mm"

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .inch: return "IN"
        case .ftIn: return "FT+IN"
        case .mm: return "MM"
        }
    }
}

public enum FeasibilityLevel: String, Codable, Hashable {
    case ok
    case warn
    case danger
}

public struct Feasibility: Codable, Hashable, Equatable {
    public let level: FeasibilityLevel
    public let message: String

    public init(level: FeasibilityLevel, message: String) {
        self.level = level
        self.message = message
    }
}

public struct Bender: Identifiable, Hashable, Equatable {
    public let id: String
    public let brand: String
    public let model: String
    public let radii: [Double: Double]

    public init(id: String, brand: String, model: String, radii: [Double: Double]) {
        self.id = id
        self.brand = brand
        self.model = model
        self.radii = radii
    }

    public var conduitSizesIn: [Double] {
        radii.keys.sorted()
    }
}

public protocol BendResult {
    var feasibility: Feasibility { get }
}

public struct OffsetResult: BendResult, Hashable, Equatable {
    public let distanceBetweenBendsIn: Double
    public let travelIn: Double
    public let shrinkIn: Double
    public let feasibility: Feasibility

    public init(distanceBetweenBendsIn: Double, travelIn: Double, shrinkIn: Double, feasibility: Feasibility) {
        self.distanceBetweenBendsIn = distanceBetweenBendsIn
        self.travelIn = travelIn
        self.shrinkIn = shrinkIn
        self.feasibility = feasibility
    }
}

public struct NinetyResult: BendResult, Hashable, Equatable {
    public let deductIn: Double
    public let markIn: Double
    public let feasibility: Feasibility

    public init(deductIn: Double, markIn: Double, feasibility: Feasibility) {
        self.deductIn = deductIn
        self.markIn = markIn
        self.feasibility = feasibility
    }
}

public struct KickResult: BendResult, Hashable, Equatable {
    public let distanceToMarkIn: Double
    public let gainIn: Double
    public let feasibility: Feasibility

    public init(distanceToMarkIn: Double, gainIn: Double, feasibility: Feasibility) {
        self.distanceToMarkIn = distanceToMarkIn
        self.gainIn = gainIn
        self.feasibility = feasibility
    }
}

public struct Saddle3Result: BendResult, Hashable, Equatable {
    public let centerToSideIn: Double
    public let totalGainIn: Double
    public let feasibility: Feasibility

    public init(centerToSideIn: Double, totalGainIn: Double, feasibility: Feasibility) {
        self.centerToSideIn = centerToSideIn
        self.totalGainIn = totalGainIn
        self.feasibility = feasibility
    }
}

public struct Kick90Result: BendResult, Hashable, Equatable {
    public let kickMarkIn: Double
    public let deductIn: Double
    public let stubMarkIn: Double
    public let feasibility: Feasibility

    public init(kickMarkIn: Double, deductIn: Double, stubMarkIn: Double, feasibility: Feasibility) {
        self.kickMarkIn = kickMarkIn
        self.deductIn = deductIn
        self.stubMarkIn = stubMarkIn
        self.feasibility = feasibility
    }
}

public struct SegmentedResult: BendResult, Hashable, Equatable {
    public let anglePerShotDeg: Double
    public let distanceBetweenShotsIn: Double
    public let shots: Int
    public let feasibility: Feasibility

    public init(anglePerShotDeg: Double, distanceBetweenShotsIn: Double, shots: Int, feasibility: Feasibility) {
        self.anglePerShotDeg = anglePerShotDeg
        self.distanceBetweenShotsIn = distanceBetweenShotsIn
        self.shots = shots
        self.feasibility = feasibility
    }
}

public struct Saddle4Result: BendResult, Hashable, Equatable {
    public let innerSpacingIn: Double
    public let outerFromInnerIn: Double
    public let totalGainIn: Double
    public let sideAngleDeg: Double
    public let feasibility: Feasibility

    public init(innerSpacingIn: Double, outerFromInnerIn: Double, totalGainIn: Double, sideAngleDeg: Double = 22.5, feasibility: Feasibility) {
        self.innerSpacingIn = innerSpacingIn
        self.outerFromInnerIn = outerFromInnerIn
        self.totalGainIn = totalGainIn
        self.sideAngleDeg = sideAngleDeg
        self.feasibility = feasibility
    }
}

public struct RollingOffsetResult: BendResult, Hashable, Equatable {
    public let trueOffsetIn: Double
    public let rollAngleDeg: Double
    public let distanceBetweenBendsIn: Double
    public let shrinkIn: Double
    public let feasibility: Feasibility

    public init(trueOffsetIn: Double, rollAngleDeg: Double, distanceBetweenBendsIn: Double, shrinkIn: Double, feasibility: Feasibility) {
        self.trueOffsetIn = trueOffsetIn
        self.rollAngleDeg = rollAngleDeg
        self.distanceBetweenBendsIn = distanceBetweenBendsIn
        self.shrinkIn = shrinkIn
        self.feasibility = feasibility
    }
}

public struct WireFillResult: BendResult, Hashable, Equatable {
    public let conduitAreaSqIn: Double
    public let conductorAreaSqIn: Double
    public let totalConductorAreaSqIn: Double
    public let maxFillPct: Double
    public let fillPct: Double
    public let count: Int
    public let awg: String
    public let sizeIn: Double
    public let feasibility: Feasibility

    public init(conduitAreaSqIn: Double, conductorAreaSqIn: Double, totalConductorAreaSqIn: Double, maxFillPct: Double, fillPct: Double, count: Int, awg: String, sizeIn: Double, feasibility: Feasibility) {
        self.conduitAreaSqIn = conduitAreaSqIn
        self.conductorAreaSqIn = conductorAreaSqIn
        self.totalConductorAreaSqIn = totalConductorAreaSqIn
        self.maxFillPct = maxFillPct
        self.fillPct = fillPct
        self.count = count
        self.awg = awg
        self.sizeIn = sizeIn
        self.feasibility = feasibility
    }
}

public struct HistoryEntry: Codable, Identifiable, Hashable, Equatable {
    public let id: String
    public let kind: BendKind
    public let label: String
    public let createdAt: Int64
    public let inputSummary: String
    public let resultSummary: String

    public init(id: String, kind: BendKind, label: String, createdAt: Int64, inputSummary: String, resultSummary: String) {
        self.id = id
        self.kind = kind
        self.label = label
        self.createdAt = createdAt
        self.inputSummary = inputSummary
        self.resultSummary = resultSummary
    }
}

public struct PersistedState: Codable, Equatable {
    public var unit: LengthUnit
    public var benderId: String
    public var history: [HistoryEntry]
    public var darkOptimized: Bool

    public init(unit: LengthUnit = .inch, benderId: String = "klein-emt-standard", history: [HistoryEntry] = [], darkOptimized: Bool = true) {
        self.unit = unit
        self.benderId = benderId
        self.history = history
        self.darkOptimized = darkOptimized
    }
}
