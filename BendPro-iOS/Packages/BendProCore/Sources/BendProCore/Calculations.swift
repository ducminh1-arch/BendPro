import Foundation

public func arc(radius: Double, angleDeg: Double) -> Double {
    radius * angleDeg * Double.pi / 180.0
}

public func feasibilityFromRatio(spacing: Double, minSpacing: Double, comfySpacing: Double) -> Feasibility {
    if spacing <= 0.0 || spacing < minSpacing {
        return Feasibility(level: .danger, message: "Impossible — bends will overlap with this bender/shoe.")
    } else if spacing < comfySpacing {
        return Feasibility(level: .warn, message: "Tight — double-check clearance before bending.")
    } else {
        return Feasibility(level: .ok, message: "Feasible with the selected bender.")
    }
}

public func calculateOffset(angle: Double, offset: Double, bender: Bender, size: Double) -> OffsetResult {
    let entry = ANGLE_TABLE[angle] ?? ANGLE_TABLE[45.0]!
    let distanceBetweenBends = offset * entry.multiplier
    let travel = distanceBetweenBends
    let shrink = entry.shrinkPerInch * offset
    let r = shoeRadius(bender: bender, size: size)
    let a = arc(radius: r, angleDeg: angle)
    let feasibility = feasibilityFromRatio(spacing: distanceBetweenBends, minSpacing: 2.0 * a, comfySpacing: 3.0 * a)
    return OffsetResult(
        distanceBetweenBendsIn: distanceBetweenBends,
        travelIn: travel,
        shrinkIn: shrink,
        feasibility: feasibility
    )
}

public func calculateNinety(size: Double, stub: Double) -> NinetyResult {
    let deduct = DEDUCT_TABLE[size] ?? 8.0
    let mark = stub - deduct
    let feasibility: Feasibility
    if mark <= 0.0 {
        feasibility = Feasibility(level: .danger, message: "Stub is shorter than the deduct — raise the stub height.")
    } else if mark < 2.0 {
        feasibility = Feasibility(level: .warn, message: "Very short mark — leaves little margin for error.")
    } else {
        feasibility = Feasibility(level: .ok, message: "Feasible with the selected bender.")
    }
    return NinetyResult(deductIn: deduct, markIn: mark, feasibility: feasibility)
}

public func calculateKick(angle: Double, rise: Double, bender: Bender, size: Double) -> KickResult {
    let entry = ANGLE_TABLE[angle] ?? ANGLE_TABLE[45.0]!
    let distanceToMark = rise * entry.multiplier
    let gain = entry.shrinkPerInch * rise
    let r = shoeRadius(bender: bender, size: size)
    let a = arc(radius: r, angleDeg: angle)
    let feasibility = feasibilityFromRatio(spacing: distanceToMark, minSpacing: a, comfySpacing: 1.5 * a)
    return KickResult(distanceToMarkIn: distanceToMark, gainIn: gain, feasibility: feasibility)
}

public func calculateSaddle3(depth: Double, bender: Bender, size: Double) -> Saddle3Result {
    let centerToSide = depth * 2.5
    let totalGain = depth * 0.25
    let r = shoeRadius(bender: bender, size: size)
    let centerArc = arc(radius: r, angleDeg: 45.0)
    let sideArc = arc(radius: r, angleDeg: 22.5)
    let minSpacing = centerArc / 2.0 + sideArc
    let feasibility = feasibilityFromRatio(spacing: centerToSide, minSpacing: minSpacing, comfySpacing: minSpacing * 1.6)
    return Saddle3Result(centerToSideIn: centerToSide, totalGainIn: totalGain, feasibility: feasibility)
}

public func calculateKick90(angle: Double, kickOffset: Double, size: Double, stub: Double, bender: Bender) -> Kick90Result {
    let entry = ANGLE_TABLE[angle] ?? ANGLE_TABLE[45.0]!
    let kickMark = kickOffset * entry.multiplier
    let deduct = DEDUCT_TABLE[size] ?? 8.0
    let stubMark = stub - deduct
    let r = shoeRadius(bender: bender, size: size)
    let kickArc = arc(radius: r, angleDeg: angle)
    let feasibility: Feasibility
    if kickOffset <= 0.0 || kickMark < kickArc || stubMark <= 0.0 {
        feasibility = Feasibility(level: .danger, message: "Not possible — increase kick offset or stub length.")
    } else if kickMark < kickArc * 1.5 || stubMark < 2.0 {
        feasibility = Feasibility(level: .warn, message: "Tight on one end — double-check clearance before bending.")
    } else {
        feasibility = Feasibility(level: .ok, message: "Feasible with the selected bender.")
    }
    return Kick90Result(kickMarkIn: kickMark, deductIn: deduct, stubMarkIn: stubMark, feasibility: feasibility)
}

public func calculateSegmented(totalAngle: Double, radius: Double, shots: Int) -> SegmentedResult {
    let anglePerShot = shots > 1 ? totalAngle / Double(shots - 1) : totalAngle
    let anglePerShotRad = anglePerShot * Double.pi / 180.0
    let distanceBetweenShots = 2.0 * radius * sin(anglePerShotRad / 2.0)
    let feasibility: Feasibility
    if totalAngle <= 0.0 || radius <= 0.0 || shots < 2 {
        feasibility = Feasibility(level: .danger, message: "Not possible — check angle, radius, and shot count.")
    } else if anglePerShot > 15.0 {
        feasibility = Feasibility(level: .warn, message: "More than ~15° per shot — the sweep will look faceted, add more shots.")
    } else {
        feasibility = Feasibility(level: .ok, message: "Feasible — smooth sweep with this shot count.")
    }
    return SegmentedResult(
        anglePerShotDeg: anglePerShot,
        distanceBetweenShotsIn: distanceBetweenShots,
        shots: shots,
        feasibility: feasibility
    )
}

public func calculateSaddle4(depth: Double, obstructionWidth: Double, bender: Bender, size: Double) -> Saddle4Result {
    let innerSpacing = obstructionWidth
    let outerFromInner = depth * 2.5
    let totalGain = depth * 0.25
    let r = shoeRadius(bender: bender, size: size)
    let sideArc = arc(radius: r, angleDeg: 22.5)
    let feasibility = feasibilityFromRatio(spacing: outerFromInner, minSpacing: sideArc, comfySpacing: sideArc * 1.6)
    return Saddle4Result(
        innerSpacingIn: innerSpacing,
        outerFromInnerIn: outerFromInner,
        totalGainIn: totalGain,
        sideAngleDeg: 22.5,
        feasibility: feasibility
    )
}

public func calculateRolling(angle: Double, vertical: Double, horizontal: Double, bender: Bender, size: Double) -> RollingOffsetResult {
    let trueOffset = sqrt(vertical * vertical + horizontal * horizontal)
    let rollAngle = atan2(horizontal, vertical) * 180.0 / Double.pi
    let entry = ANGLE_TABLE[angle] ?? ANGLE_TABLE[45.0]!
    let distanceBetweenBends = trueOffset * entry.multiplier
    let shrink = entry.shrinkPerInch * trueOffset
    let r = shoeRadius(bender: bender, size: size)
    let a = arc(radius: r, angleDeg: angle)
    let feasibility: Feasibility
    if vertical <= 0.0 && horizontal <= 0.0 {
        feasibility = Feasibility(level: .danger, message: "Enter at least one of vertical or horizontal offset.")
    } else {
        feasibility = feasibilityFromRatio(spacing: distanceBetweenBends, minSpacing: 2.0 * a, comfySpacing: 3.0 * a)
    }
    return RollingOffsetResult(
        trueOffsetIn: trueOffset,
        rollAngleDeg: rollAngle,
        distanceBetweenBendsIn: distanceBetweenBends,
        shrinkIn: shrink,
        feasibility: feasibility
    )
}

public func calculateWireFill(size: Double, awg: String, count: Int) -> WireFillResult {
    let conduitArea = EMT_INTERNAL_AREA[size] ?? 0.533
    let wireArea = THHN_AREA[awg] ?? 0.0133
    let totalArea = wireArea * Double(count)
    let maxFillPct: Double
    if count == 1 {
        maxFillPct = 53.0
    } else if count == 2 {
        maxFillPct = 31.0
    } else {
        maxFillPct = 40.0
    }
    let fillPct = totalArea / conduitArea * 100.0
    let feasibility: Feasibility
    if count <= 0 || fillPct > maxFillPct {
        feasibility = Feasibility(
            level: .danger,
            message: "Exceeds the \(Int(maxFillPct))% NEC fill limit for \(count) conductor(s) — step up conduit size."
        )
    } else if fillPct > maxFillPct - 5.0 {
        feasibility = Feasibility(
            level: .warn,
            message: "Close to the fill limit — little room for a mixed-size pull."
        )
    } else {
        feasibility = Feasibility(level: .ok, message: "Within the NEC fill limit.")
    }
    return WireFillResult(
        conduitAreaSqIn: conduitArea,
        conductorAreaSqIn: wireArea,
        totalConductorAreaSqIn: totalArea,
        maxFillPct: maxFillPct,
        fillPct: fillPct,
        count: count,
        awg: awg,
        sizeIn: size,
        feasibility: feasibility
    )
}
