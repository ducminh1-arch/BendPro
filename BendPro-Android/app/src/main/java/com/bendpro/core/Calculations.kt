package com.bendpro.core

import java.util.Locale

fun arc(radiusIn: Double, angleDeg: Double): Double =
    radiusIn * angleDeg * Math.PI / 180.0

fun angleConstants(angleDeg: Double): AngleConstants =
    ANGLE_TABLE[angleDeg] ?: ANGLE_TABLE[45.0]!!

fun feasibilityFromRatio(spacing: Double, minSpacing: Double, comfySpacing: Double): Feasibility =
    if (spacing <= 0.0 || spacing < minSpacing) {
        Feasibility(FeasibilityLevel.DANGER, "Impossible — bends will overlap with this bender/shoe.")
    } else if (spacing < comfySpacing) {
        Feasibility(FeasibilityLevel.WARN, "Tight — double-check clearance before bending.")
    } else {
        Feasibility(FeasibilityLevel.OK, "Feasible with the selected bender.")
    }

fun calcOffset(
    angleDeg: Double,
    offsetIn: Double,
    bender: Bender,
    tradeSizeIn: Double
): OffsetResult {
    val (multiplier, shrinkPerInch) = angleConstants(angleDeg)
    val distanceBetweenBendsIn = offsetIn * multiplier
    val travelIn = distanceBetweenBendsIn
    val shrinkIn = shrinkPerInch * offsetIn

    val radius = shoeRadius(bender, tradeSizeIn)
    val a = arc(radius, angleDeg)
    val feasibility = feasibilityFromRatio(distanceBetweenBendsIn, a * 2.0, a * 3.0)

    return OffsetResult(
        angleDeg = angleDeg,
        offsetIn = offsetIn,
        distanceBetweenBendsIn = distanceBetweenBendsIn,
        travelIn = travelIn,
        shrinkIn = shrinkIn,
        feasibility = feasibility
    )
}

fun calcNinety(
    tradeSizeIn: Double,
    stubHeightIn: Double
): NinetyResult {
    val deductIn = DEDUCT_TABLE[tradeSizeIn] ?: 8.0
    val markIn = stubHeightIn - deductIn

    val feasibility = if (markIn <= 0.0) {
        Feasibility(FeasibilityLevel.DANGER, "Stub is shorter than the deduct — raise the stub height.")
    } else if (markIn < 2.0) {
        Feasibility(FeasibilityLevel.WARN, "Very short mark — leaves little margin for error.")
    } else {
        Feasibility(FeasibilityLevel.OK, "Feasible with the selected bender.")
    }

    return NinetyResult(
        tradeSizeIn = tradeSizeIn,
        stubHeightIn = stubHeightIn,
        deductIn = deductIn,
        markIn = markIn,
        feasibility = feasibility
    )
}

fun calcKick(
    angleDeg: Double,
    riseIn: Double,
    bender: Bender,
    tradeSizeIn: Double
): KickResult {
    val (multiplier, shrinkPerInch) = angleConstants(angleDeg)
    val distanceToMarkIn = riseIn * multiplier
    val gainIn = shrinkPerInch * riseIn

    val radius = shoeRadius(bender, tradeSizeIn)
    val a = arc(radius, angleDeg)
    val feasibility = feasibilityFromRatio(distanceToMarkIn, a, a * 1.5)

    return KickResult(
        angleDeg = angleDeg,
        riseIn = riseIn,
        distanceToMarkIn = distanceToMarkIn,
        gainIn = gainIn,
        feasibility = feasibility
    )
}

fun calcSaddle3(
    depthIn: Double,
    bender: Bender,
    tradeSizeIn: Double
): Saddle3Result {
    val centerAngleDeg = 45.0
    val sideAngleDeg = 22.5
    val centerToSideIn = depthIn * 2.5
    val totalGainIn = depthIn * 0.25

    val radius = shoeRadius(bender, tradeSizeIn)
    val centerArc = arc(radius, centerAngleDeg)
    val sideArc = arc(radius, sideAngleDeg)
    val minSpacing = centerArc / 2.0 + sideArc
    val feasibility = feasibilityFromRatio(centerToSideIn, minSpacing, minSpacing * 1.6)

    return Saddle3Result(
        depthIn = depthIn,
        centerAngleDeg = centerAngleDeg,
        sideAngleDeg = sideAngleDeg,
        centerToSideIn = centerToSideIn,
        totalGainIn = totalGainIn,
        feasibility = feasibility
    )
}

fun calcKick90(
    angleDeg: Double,
    kickOffsetIn: Double,
    tradeSizeIn: Double,
    stubHeightIn: Double,
    bender: Bender
): Kick90Result {
    val (multiplier) = angleConstants(angleDeg)
    val kickMarkIn = kickOffsetIn * multiplier
    val deductIn = DEDUCT_TABLE[tradeSizeIn] ?: 8.0
    val stubMarkIn = stubHeightIn - deductIn

    val radius = shoeRadius(bender, tradeSizeIn)
    val kickArc = arc(radius, angleDeg)

    val feasibility = if (kickOffsetIn <= 0.0 || kickMarkIn < kickArc || stubMarkIn <= 0.0) {
        Feasibility(FeasibilityLevel.DANGER, "Not possible — increase kick offset or stub length.")
    } else if (kickMarkIn < kickArc * 1.5 || stubMarkIn < 2.0) {
        Feasibility(FeasibilityLevel.WARN, "Tight on one end — double-check clearance before bending.")
    } else {
        Feasibility(FeasibilityLevel.OK, "Feasible with the selected bender.")
    }

    return Kick90Result(
        angleDeg = angleDeg,
        kickOffsetIn = kickOffsetIn,
        kickMarkIn = kickMarkIn,
        tradeSizeIn = tradeSizeIn,
        stubHeightIn = stubHeightIn,
        deductIn = deductIn,
        stubMarkIn = stubMarkIn,
        feasibility = feasibility
    )
}

fun calcSegmented(
    totalAngleDeg: Double,
    radiusIn: Double,
    shots: Int
): SegmentedResult {
    val anglePerShotDeg = if (shots > 1) totalAngleDeg / (shots - 1) else totalAngleDeg
    val rad = (anglePerShotDeg * Math.PI) / 180.0
    val distanceBetweenShotsIn = 2.0 * radiusIn * Math.sin(rad / 2.0)

    val feasibility = if (totalAngleDeg <= 0.0 || radiusIn <= 0.0 || shots < 2) {
        Feasibility(FeasibilityLevel.DANGER, "Not possible — check angle, radius, and shot count.")
    } else if (anglePerShotDeg > 15.0) {
        Feasibility(FeasibilityLevel.WARN, "More than ~15° per shot — the sweep will look faceted, add more shots.")
    } else {
        Feasibility(FeasibilityLevel.OK, "Feasible — smooth sweep with this shot count.")
    }

    return SegmentedResult(
        totalAngleDeg = totalAngleDeg,
        radiusIn = radiusIn,
        shots = shots,
        anglePerShotDeg = anglePerShotDeg,
        distanceBetweenShotsIn = distanceBetweenShotsIn,
        feasibility = feasibility
    )
}

fun calcSaddle4(
    depthIn: Double,
    obstructionWidthIn: Double,
    bender: Bender,
    tradeSizeIn: Double
): Saddle4Result {
    val sideAngleDeg = 22.5
    val innerSpacingIn = obstructionWidthIn
    val outerFromInnerIn = depthIn * 2.5
    val totalGainIn = depthIn * 0.25

    val radius = shoeRadius(bender, tradeSizeIn)
    val sideArc = arc(radius, sideAngleDeg)
    val feasibility = feasibilityFromRatio(outerFromInnerIn, sideArc, sideArc * 1.6)

    return Saddle4Result(
        depthIn = depthIn,
        obstructionWidthIn = obstructionWidthIn,
        sideAngleDeg = sideAngleDeg,
        innerSpacingIn = innerSpacingIn,
        outerFromInnerIn = outerFromInnerIn,
        totalGainIn = totalGainIn,
        feasibility = feasibility
    )
}

fun calcRollingOffset(
    angleDeg: Double,
    verticalIn: Double,
    horizontalIn: Double,
    bender: Bender,
    tradeSizeIn: Double
): RollingOffsetResult {
    val (multiplier, shrinkPerInch) = angleConstants(angleDeg)
    val trueOffsetIn = Math.sqrt(verticalIn * verticalIn + horizontalIn * horizontalIn)
    val rollAngleDeg = (Math.atan2(horizontalIn, verticalIn) * 180.0) / Math.PI
    val distanceBetweenBendsIn = trueOffsetIn * multiplier
    val shrinkIn = shrinkPerInch * trueOffsetIn

    val radius = shoeRadius(bender, tradeSizeIn)
    val a = arc(radius, angleDeg)
    val feasibility = if (verticalIn <= 0.0 && horizontalIn <= 0.0) {
        Feasibility(FeasibilityLevel.DANGER, "Enter at least one of vertical or horizontal offset.")
    } else {
        feasibilityFromRatio(distanceBetweenBendsIn, a * 2.0, a * 3.0)
    }

    return RollingOffsetResult(
        angleDeg = angleDeg,
        verticalIn = verticalIn,
        horizontalIn = horizontalIn,
        trueOffsetIn = trueOffsetIn,
        rollAngleDeg = rollAngleDeg,
        distanceBetweenBendsIn = distanceBetweenBendsIn,
        shrinkIn = shrinkIn,
        feasibility = feasibility
    )
}

fun calcWireFill(
    conduitSizeIn: Double,
    wireAwg: String,
    conductorCount: Int
): WireFillResult {
    val conduitAreaSqIn = EMT_INTERNAL_AREA_SQIN[conduitSizeIn] ?: EMT_INTERNAL_AREA_SQIN[0.75]!!
    val wireAreaSqIn = THHN_AREA_SQIN[wireAwg] ?: THHN_AREA_SQIN["12"]!!
    val totalConductorAreaSqIn = wireAreaSqIn * conductorCount
    val maxFillPct = if (conductorCount == 1) 53.0 else if (conductorCount == 2) 31.0 else 40.0
    val fillPct = (totalConductorAreaSqIn / conduitAreaSqIn) * 100.0

    val maxFillInt = maxFillPct.toInt()
    val feasibility = if (conductorCount <= 0 || fillPct > maxFillPct) {
        Feasibility(
            FeasibilityLevel.DANGER,
            "Exceeds the ${maxFillInt}% NEC fill limit for $conductorCount conductor(s) — step up conduit size."
        )
    } else if (fillPct > maxFillPct - 5.0) {
        Feasibility(FeasibilityLevel.WARN, "Close to the fill limit — little room for a mixed-size pull.")
    } else {
        Feasibility(FeasibilityLevel.OK, "Within the NEC fill limit.")
    }

    return WireFillResult(
        conduitMaterial = "EMT",
        conduitSizeIn = conduitSizeIn,
        conduitAreaSqIn = conduitAreaSqIn,
        wireAwg = wireAwg,
        wireAreaSqIn = wireAreaSqIn,
        conductorCount = conductorCount,
        totalConductorAreaSqIn = totalConductorAreaSqIn,
        maxFillPct = maxFillPct,
        fillPct = fillPct,
        feasibility = feasibility
    )
}

private fun formatPlainNumber(value: Double): String =
    if (value == value.toLong().toDouble()) {
        value.toLong().toString()
    } else {
        value.toString()
    }

fun summarize(result: BendResult): String = when (result) {
    is OffsetResult ->
        String.format(
            Locale.US,
            "Marks %.2f\" apart · shrink %.3f\"",
            result.distanceBetweenBendsIn,
            result.shrinkIn
        )
    is NinetyResult ->
        String.format(
            Locale.US,
            "Mark at %.2f\" · deduct %s\"",
            result.markIn,
            formatPlainNumber(result.deductIn)
        )
    is KickResult ->
        String.format(
            Locale.US,
            "Mark at %.2f\" · gain %.3f\"",
            result.distanceToMarkIn,
            result.gainIn
        )
    is Saddle3Result ->
        String.format(
            Locale.US,
            "Side bends %.2f\" from center · gain %.3f\"",
            result.centerToSideIn,
            result.totalGainIn
        )
    is Kick90Result ->
        String.format(
            Locale.US,
            "Kick mark %.2f\" from start · stub mark %.2f\" from end",
            result.kickMarkIn,
            result.stubMarkIn
        )
    is SegmentedResult ->
        String.format(
            Locale.US,
            "%d shots at %.1f° · %.2f\" apart",
            result.shots,
            result.anglePerShotDeg,
            result.distanceBetweenShotsIn
        )
    is Saddle4Result ->
        String.format(
            Locale.US,
            "Inner %.2f\" apart · outer %.2f\" beyond each",
            result.innerSpacingIn,
            result.outerFromInnerIn
        )
    is RollingOffsetResult ->
        String.format(
            Locale.US,
            "True offset %.2f\" · roll %.1f° · marks %.2f\" apart",
            result.trueOffsetIn,
            result.rollAngleDeg,
            result.distanceBetweenBendsIn
        )
    is WireFillResult ->
        String.format(
            Locale.US,
            "%d × %s AWG in %s\" EMT · %.1f%% fill",
            result.conductorCount,
            result.wireAwg,
            formatPlainNumber(result.conduitSizeIn),
            result.fillPct
        )
}
