package com.bendpro.core

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
enum class BendKind(val id: String) {
    @SerialName("offset") OFFSET("offset"),
    @SerialName("ninety") NINETY("ninety"),
    @SerialName("kick") KICK("kick"),
    @SerialName("saddle3") SADDLE3("saddle3"),
    @SerialName("kick90") KICK90("kick90"),
    @SerialName("segmented") SEGMENTED("segmented"),
    @SerialName("saddle4") SADDLE4("saddle4"),
    @SerialName("rolling") ROLLING("rolling"),
    @SerialName("wirefill") WIREFILL("wirefill");

    companion object {
        fun fromId(id: String): BendKind? = entries.firstOrNull { it.id == id }
    }
}

enum class AppUnit(val id: String, val label: String) {
    INCHES("in", "IN"),
    FEET_INCHES("ft-in", "FT+IN"),
    MM("mm", "MM");

    companion object {
        fun fromId(id: String): AppUnit = entries.firstOrNull { it.id == id } ?: INCHES
    }
}

enum class FeasibilityLevel(val id: String) {
    OK("ok"),
    WARN("warn"),
    DANGER("danger");

    companion object {
        fun fromId(id: String): FeasibilityLevel = entries.firstOrNull { it.id == id } ?: OK
    }
}

data class Feasibility(
    val level: FeasibilityLevel,
    val message: String
)

data class Bender(
    val id: String,
    val brand: String,
    val model: String,
    val conduitSizesIn: List<Double>,
    val minShoeRadiusIn: Map<Double, Double>
)

sealed interface BendResult {
    val kind: BendKind
    val feasibility: Feasibility
}

data class OffsetResult(
    val angleDeg: Double,
    val offsetIn: Double,
    val distanceBetweenBendsIn: Double,
    val travelIn: Double,
    val shrinkIn: Double,
    override val feasibility: Feasibility
) : BendResult {
    override val kind: BendKind get() = BendKind.OFFSET
}

data class NinetyResult(
    val tradeSizeIn: Double,
    val stubHeightIn: Double,
    val deductIn: Double,
    val markIn: Double,
    override val feasibility: Feasibility
) : BendResult {
    override val kind: BendKind get() = BendKind.NINETY
}

data class KickResult(
    val angleDeg: Double,
    val riseIn: Double,
    val distanceToMarkIn: Double,
    val gainIn: Double,
    override val feasibility: Feasibility
) : BendResult {
    override val kind: BendKind get() = BendKind.KICK
}

data class Saddle3Result(
    val depthIn: Double,
    val centerAngleDeg: Double,
    val sideAngleDeg: Double,
    val centerToSideIn: Double,
    val totalGainIn: Double,
    override val feasibility: Feasibility
) : BendResult {
    override val kind: BendKind get() = BendKind.SADDLE3
}

data class Kick90Result(
    val angleDeg: Double,
    val kickOffsetIn: Double,
    val kickMarkIn: Double,
    val tradeSizeIn: Double,
    val stubHeightIn: Double,
    val deductIn: Double,
    val stubMarkIn: Double,
    override val feasibility: Feasibility
) : BendResult {
    override val kind: BendKind get() = BendKind.KICK90
}

data class SegmentedResult(
    val totalAngleDeg: Double,
    val radiusIn: Double,
    val shots: Int,
    val anglePerShotDeg: Double,
    val distanceBetweenShotsIn: Double,
    override val feasibility: Feasibility
) : BendResult {
    override val kind: BendKind get() = BendKind.SEGMENTED
}

data class Saddle4Result(
    val depthIn: Double,
    val obstructionWidthIn: Double,
    val sideAngleDeg: Double,
    val innerSpacingIn: Double,
    val outerFromInnerIn: Double,
    val totalGainIn: Double,
    override val feasibility: Feasibility
) : BendResult {
    override val kind: BendKind get() = BendKind.SADDLE4
}

data class RollingOffsetResult(
    val angleDeg: Double,
    val verticalIn: Double,
    val horizontalIn: Double,
    val trueOffsetIn: Double,
    val rollAngleDeg: Double,
    val distanceBetweenBendsIn: Double,
    val shrinkIn: Double,
    override val feasibility: Feasibility
) : BendResult {
    override val kind: BendKind get() = BendKind.ROLLING
}

data class WireFillResult(
    val conduitMaterial: String = "EMT",
    val conduitSizeIn: Double,
    val conduitAreaSqIn: Double,
    val wireAwg: String,
    val wireAreaSqIn: Double,
    val conductorCount: Int,
    val totalConductorAreaSqIn: Double,
    val maxFillPct: Double,
    val fillPct: Double,
    override val feasibility: Feasibility
) : BendResult {
    override val kind: BendKind get() = BendKind.WIREFILL
}

@Serializable
data class HistoryEntry(
    val id: String,
    val kind: BendKind,
    val label: String,
    val createdAt: Long,
    val inputSummary: String,
    val resultSummary: String
)
