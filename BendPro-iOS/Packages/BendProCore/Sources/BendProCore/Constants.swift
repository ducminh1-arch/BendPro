import Foundation

public struct AngleEntry: Equatable {
    public let multiplier: Double
    public let shrinkPerInch: Double

    public init(multiplier: Double, shrinkPerInch: Double) {
        self.multiplier = multiplier
        self.shrinkPerInch = shrinkPerInch
    }
}

public let ANGLE_TABLE: [Double: AngleEntry] = [
    10.0: AngleEntry(multiplier: 6.0, shrinkPerInch: 1.0 / 16.0),
    22.5: AngleEntry(multiplier: 2.6, shrinkPerInch: 1.0 / 4.0),
    30.0: AngleEntry(multiplier: 2.0, shrinkPerInch: 3.0 / 8.0),
    45.0: AngleEntry(multiplier: 1.4, shrinkPerInch: 3.0 / 8.0),
    60.0: AngleEntry(multiplier: 1.2, shrinkPerInch: 1.0 / 4.0)
]

public let OFFSET_ANGLES: [Double] = [10.0, 22.5, 30.0, 45.0, 60.0]

public let DEDUCT_TABLE: [Double: Double] = [
    0.5: 5.0,
    0.75: 6.0,
    1.0: 8.0,
    1.25: 11.0,
    1.5: 13.0,
    2.0: 17.0
]

public let TRADE_SIZES: [Double] = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]

public func tradeSizeLabel(_ size: Double) -> String {
    switch size {
    case 0.5: return "1/2\""
    case 0.75: return "3/4\""
    case 1.0: return "1\""
    case 1.25: return "1-1/4\""
    case 1.5: return "1-1/2\""
    case 2.0: return "2\""
    default: return "\(size)\""
    }
}

public let EMT_INTERNAL_AREA: [Double: Double] = [
    0.5: 0.304,
    0.75: 0.533,
    1.0: 0.864,
    1.25: 1.496,
    1.5: 2.036,
    2.0: 3.356
]

public let WIRE_AWG_OPTIONS: [String] = ["14", "12", "10", "8", "6", "4", "3", "2", "1"]

public let THHN_AREA: [String: Double] = [
    "14": 0.0097,
    "12": 0.0133,
    "10": 0.0211,
    "8": 0.0366,
    "6": 0.0507,
    "4": 0.0824,
    "3": 0.0973,
    "2": 0.1158,
    "1": 0.1562
]

public let BENDERS: [Bender] = [
    Bender(
        id: "klein-emt-standard",
        brand: "Klein Tools",
        model: "EMT Bender (1/2–1\")",
        radii: [0.5: 4.0, 0.75: 4.5, 1.0: 5.75]
    ),
    Bender(
        id: "greenlee-855",
        brand: "Greenlee",
        model: "855 Series (1/2–1-1/4\")",
        radii: [0.5: 4.0, 0.75: 4.5, 1.0: 5.75, 1.25: 7.0]
    ),
    Bender(
        id: "milwaukee-emt",
        brand: "Milwaukee",
        model: "EMT Bender (1/2–1\")",
        radii: [0.5: 4.0, 0.75: 4.5, 1.0: 5.75]
    ),
    Bender(
        id: "ideal-imc-rigid",
        brand: "Ideal Industries",
        model: "IMC/Rigid Bender (1/2–1\")",
        radii: [0.5: 4.5, 0.75: 5.25, 1.0: 6.5]
    ),
    Bender(
        id: "ridgid-emt",
        brand: "Ridgid",
        model: "EMT Bender (1/2–1\")",
        radii: [0.5: 4.0, 0.75: 4.5, 1.0: 5.75]
    ),
    Bender(
        id: "itoolco-mega-1-1.5",
        brand: "iToolco",
        model: "Mega Bender (1–1-1/2\")",
        radii: [1.0: 5.75, 1.25: 7.0, 1.5: 8.25]
    ),
    Bender(
        id: "current-tools-1000",
        brand: "Current Tools",
        model: "1000 Series (1/2–1\")",
        radii: [0.5: 4.0, 0.75: 4.5, 1.0: 5.75]
    ),
    Bender(
        id: "custom",
        brand: "Custom",
        model: "Add your own",
        radii: [0.5: 4.0, 0.75: 4.5, 1.0: 5.75, 1.25: 7.0, 1.5: 8.25, 2.0: 9.5]
    )
]

public func shoeRadius(bender: Bender, size: Double) -> Double {
    bender.radii[size] ?? 4.0
}
