import Foundation

public func summarize(result: BendResult) -> String {
    switch result {
    case let r as OffsetResult:
        return "Marks \(String(format: "%.2f", r.distanceBetweenBendsIn))\" apart · shrink \(String(format: "%.3f", r.shrinkIn))\""

    case let r as NinetyResult:
        let deductStr = (r.deductIn.truncatingRemainder(dividingBy: 1.0) == 0.0) ? "\(Int(r.deductIn))" : String(format: "%.1f", r.deductIn)
        return "Mark at \(String(format: "%.2f", r.markIn))\" · deduct \(deductStr)\""

    case let r as KickResult:
        return "Mark at \(String(format: "%.2f", r.distanceToMarkIn))\" · gain \(String(format: "%.3f", r.gainIn))\""

    case let r as Saddle3Result:
        return "Side bends \(String(format: "%.2f", r.centerToSideIn))\" from center · gain \(String(format: "%.3f", r.totalGainIn))\""

    case let r as Kick90Result:
        return "Kick mark \(String(format: "%.2f", r.kickMarkIn))\" from start · stub mark \(String(format: "%.2f", r.stubMarkIn))\" from end"

    case let r as SegmentedResult:
        return "\(r.shots) shots at \(String(format: "%.1f", r.anglePerShotDeg))° · \(String(format: "%.2f", r.distanceBetweenShotsIn))\" apart"

    case let r as Saddle4Result:
        return "Inner \(String(format: "%.2f", r.innerSpacingIn))\" apart · outer \(String(format: "%.2f", r.outerFromInnerIn))\" beyond each"

    case let r as RollingOffsetResult:
        return "True offset \(String(format: "%.2f", r.trueOffsetIn))\" · roll \(String(format: "%.1f", r.rollAngleDeg))° · marks \(String(format: "%.2f", r.distanceBetweenBendsIn))\" apart"

    case let r as WireFillResult:
        let sizeStr = (r.sizeIn.truncatingRemainder(dividingBy: 1.0) == 0.0) ? "\(Int(r.sizeIn))" : "\(r.sizeIn)"
        return "\(r.count) × \(r.awg) AWG in \(sizeStr)\" EMT · \(String(format: "%.1f", r.fillPct))% fill"

    default:
        return ""
    }
}
