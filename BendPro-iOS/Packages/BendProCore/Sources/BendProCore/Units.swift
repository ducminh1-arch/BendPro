import Foundation

public func toFraction(_ v: Double) -> String {
    let whole = Int(floor(v))
    let frac = v - Double(whole)
    let sixteenths = Int((frac * 16.0).rounded())

    if sixteenths == 0 {
        return "\(whole)"
    }
    if sixteenths == 16 {
        return "\(whole + 1)"
    }

    var num = sixteenths
    var den = 16
    while num % 2 == 0 && den % 2 == 0 {
        num /= 2
        den /= 2
    }

    if whole == 0 {
        return "\(num)/\(den)"
    } else {
        return "\(whole) \(num)/\(den)"
    }
}

public func formatLength(_ valueIn: Double, unit: LengthUnit, precision: Int = 2) -> String {
    guard valueIn.isFinite else {
        return "—"
    }

    let isNegative = valueIn < 0.0
    let absVal = abs(valueIn)

    switch unit {
    case .mm:
        let mm = absVal * 25.4
        let decimals = (precision == 2) ? 0 : precision
        let formattedNumber = String(format: "%.\(decimals)f", mm)
        let isZero = (Double(formattedNumber) ?? 0.0) == 0.0
        let sign = (isNegative && !isZero) ? "-" : ""
        return "\(sign)\(formattedNumber) mm"

    case .ftIn:
        let feet = Int(floor(absVal / 12.0))
        let inches = absVal - Double(feet) * 12.0
        let sixteenths = Int((inches * 16.0).rounded())

        // Deviation A9.3: if inches round up to 12", carry over into feet
        if sixteenths == 192 {
            let nextFeet = feet + 1
            let isZero = nextFeet == 0
            let sign = (isNegative && !isZero) ? "-" : ""
            return "\(sign)\(nextFeet)' 0\""
        }

        let inchStr = toFraction(inches)
        let isZero = (feet == 0 && inchStr == "0")
        let sign = (isNegative && !isZero) ? "-" : ""

        if feet > 0 {
            return "\(sign)\(feet)' \(inchStr)\""
        } else {
            return "\(sign)\(inchStr)\""
        }

    case .inch:
        let inchStr = toFraction(absVal)
        let isZero = (inchStr == "0")
        let sign = (isNegative && !isZero) ? "-" : ""
        return "\(sign)\(inchStr)\""
    }
}

public func parseToInches(_ text: String, unit: LengthUnit) -> Double? {
    let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let value = Double(cleaned) else { return nil }
    if unit == .mm {
        return value / 25.4
    }
    return value
}
