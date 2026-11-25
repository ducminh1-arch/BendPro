package com.bendpro.ui.viewmodel

import androidx.lifecycle.ViewModel
import com.bendpro.core.AppUnit
import com.bendpro.core.Bender
import com.bendpro.core.BendKind
import com.bendpro.core.BendResult
import com.bendpro.core.HistoryEntry
import com.bendpro.core.calcKick
import com.bendpro.core.calcKick90
import com.bendpro.core.calcNinety
import com.bendpro.core.calcOffset
import com.bendpro.core.calcRollingOffset
import com.bendpro.core.calcSaddle3
import com.bendpro.core.calcSaddle4
import com.bendpro.core.calcSegmented
import com.bendpro.core.calcWireFill
import com.bendpro.core.formatLength
import com.bendpro.core.summarize
import com.bendpro.core.tradeSizeLabel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

data class BendDetailState(
    val tradeSizeIn: Double = 0.75,
    val angleDeg: Double = 30.0,
    val offsetIn: Double = 4.0,
    val stubHeightIn: Double = 12.0,
    val riseIn: Double = 6.0,
    val depthIn: Double = 3.0,
    val kickOffsetIn: Double = 4.0,
    val kick90StubIn: Double = 18.0,
    val totalAngleDeg: Double = 90.0,
    val radiusIn: Double = 24.0,
    val shots: Int = 6,
    val obstructionWidthIn: Double = 8.0,
    val rollingVerticalIn: Double = 6.0,
    val rollingHorizontalIn: Double = 4.0,
    val wireConduitSizeIn: Double = 0.75,
    val wireAwg: String = "12",
    val wireCount: Int = 3,
    val saved: Boolean = false
)

fun formatAngle(angle: Double): String =
    if (angle % 1.0 == 0.0) angle.toInt().toString() else angle.toString()

fun buildLabel(kind: BendKind, angleDeg: Double): String = when (kind) {
    BendKind.OFFSET -> "${formatAngle(angleDeg)}° Offset"
    BendKind.NINETY -> "90° Bend"
    BendKind.KICK -> "${formatAngle(angleDeg)}° Kick"
    BendKind.SADDLE3 -> "3-Point Saddle"
    BendKind.KICK90 -> "${formatAngle(angleDeg)}° Kick + 90°"
    BendKind.SEGMENTED -> "Multi-Shot 90°"
    BendKind.SADDLE4 -> "4-Point Saddle"
    BendKind.ROLLING -> "${formatAngle(angleDeg)}° Rolling Offset"
    BendKind.WIREFILL -> "Wire Fill"
}

fun buildInputSummary(
    kind: BendKind,
    unit: AppUnit,
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
): String = when (kind) {
    BendKind.OFFSET -> "Offset ${formatLength(offsetIn, unit)} · ${tradeSizeLabel(tradeSizeIn)}"
    BendKind.NINETY -> "Stub ${formatLength(stubHeightIn, unit)} · ${tradeSizeLabel(tradeSizeIn)}"
    BendKind.KICK -> "Rise ${formatLength(riseIn, unit)} · ${tradeSizeLabel(tradeSizeIn)}"
    BendKind.SADDLE3 -> "Depth ${formatLength(depthIn, unit)} · ${tradeSizeLabel(tradeSizeIn)}"
    BendKind.KICK90 -> "Kick offset ${formatLength(kickOffsetIn, unit)} · Stub ${formatLength(kick90StubIn, unit)} · ${tradeSizeLabel(tradeSizeIn)}"
    BendKind.SEGMENTED -> "Sweep ${formatAngle(totalAngleDeg)}° · Radius ${formatLength(radiusIn, unit)} · $shots shots"
    BendKind.SADDLE4 -> "Depth ${formatLength(depthIn, unit)} · Width ${formatLength(obstructionWidthIn, unit)} · ${tradeSizeLabel(tradeSizeIn)}"
    BendKind.ROLLING -> "Vertical ${formatLength(rollingVerticalIn, unit)} · Horizontal ${formatLength(rollingHorizontalIn, unit)} · ${tradeSizeLabel(tradeSizeIn)}"
    BendKind.WIREFILL -> "$wireCount × $wireAwg AWG in ${tradeSizeLabel(wireConduitSizeIn)} EMT"
}

fun calculateResult(kind: BendKind, state: BendDetailState, bender: Bender): BendResult = when (kind) {
    BendKind.OFFSET -> calcOffset(state.angleDeg, state.offsetIn, bender, state.tradeSizeIn)
    BendKind.NINETY -> calcNinety(state.tradeSizeIn, state.stubHeightIn)
    BendKind.KICK -> calcKick(state.angleDeg, state.riseIn, bender, state.tradeSizeIn)
    BendKind.SADDLE3 -> calcSaddle3(state.depthIn, bender, state.tradeSizeIn)
    BendKind.KICK90 -> calcKick90(state.angleDeg, state.kickOffsetIn, state.tradeSizeIn, state.kick90StubIn, bender)
    BendKind.SEGMENTED -> calcSegmented(state.totalAngleDeg, state.radiusIn, state.shots)
    BendKind.SADDLE4 -> calcSaddle4(state.depthIn, state.obstructionWidthIn, bender, state.tradeSizeIn)
    BendKind.ROLLING -> calcRollingOffset(state.angleDeg, state.rollingVerticalIn, state.rollingHorizontalIn, bender, state.tradeSizeIn)
    BendKind.WIREFILL -> calcWireFill(state.wireConduitSizeIn, state.wireAwg, state.wireCount)
}

class DetailViewModel : ViewModel() {

    private val _states = MutableStateFlow<Map<BendKind, BendDetailState>>(
        BendKind.entries.associateWith { BendDetailState() }
    )
    val states: StateFlow<Map<BendKind, BendDetailState>> = _states.asStateFlow()

    fun getState(kind: BendKind): BendDetailState =
        _states.value[kind] ?: BendDetailState()

    fun updateState(kind: BendKind, update: (BendDetailState) -> BendDetailState) {
        _states.update { current ->
            val existing = current[kind] ?: BendDetailState()
            current + (kind to update(existing))
        }
    }

    /**
     * Deviation A9.2: Clamp the trade size to the selected bender's supported sizes.
     */
    fun clampTradeSize(bender: Bender, kind: BendKind) {
        val current = getState(kind)
        if (!bender.conduitSizesIn.contains(current.tradeSizeIn)) {
            val clampedSize = bender.conduitSizesIn.firstOrNull() ?: 0.75
            updateState(kind) { it.copy(tradeSizeIn = clampedSize) }
        }
    }

    fun setTradeSize(kind: BendKind, sizeIn: Double) {
        updateState(kind) { it.copy(tradeSizeIn = sizeIn, saved = false) }
    }

    fun setAngle(kind: BendKind, angleDeg: Double) {
        updateState(kind) { it.copy(angleDeg = angleDeg, saved = false) }
    }

    fun setOffset(kind: BendKind, offsetIn: Double) {
        updateState(kind) { it.copy(offsetIn = offsetIn, saved = false) }
    }

    fun setStubHeight(kind: BendKind, stubHeightIn: Double) {
        updateState(kind) { it.copy(stubHeightIn = stubHeightIn, saved = false) }
    }

    fun setRise(kind: BendKind, riseIn: Double) {
        updateState(kind) { it.copy(riseIn = riseIn, saved = false) }
    }

    fun setDepth(kind: BendKind, depthIn: Double) {
        updateState(kind) { it.copy(depthIn = depthIn, saved = false) }
    }

    fun setKickOffset(kind: BendKind, kickOffsetIn: Double) {
        updateState(kind) { it.copy(kickOffsetIn = kickOffsetIn, saved = false) }
    }

    fun setKick90Stub(kind: BendKind, kick90StubIn: Double) {
        updateState(kind) { it.copy(kick90StubIn = kick90StubIn, saved = false) }
    }

    fun setTotalAngle(kind: BendKind, totalAngleDeg: Double) {
        updateState(kind) { it.copy(totalAngleDeg = totalAngleDeg, saved = false) }
    }

    fun setRadius(kind: BendKind, radiusIn: Double) {
        updateState(kind) { it.copy(radiusIn = radiusIn, saved = false) }
    }

    fun setShots(kind: BendKind, shots: Int) {
        updateState(kind) { it.copy(shots = shots, saved = false) }
    }

    fun setObstructionWidth(kind: BendKind, widthIn: Double) {
        updateState(kind) { it.copy(obstructionWidthIn = widthIn, saved = false) }
    }

    fun setRollingVertical(kind: BendKind, verticalIn: Double) {
        updateState(kind) { it.copy(rollingVerticalIn = verticalIn, saved = false) }
    }

    fun setRollingHorizontal(kind: BendKind, horizontalIn: Double) {
        updateState(kind) { it.copy(rollingHorizontalIn = horizontalIn, saved = false) }
    }

    fun setWireConduitSize(kind: BendKind, sizeIn: Double) {
        updateState(kind) { it.copy(wireConduitSizeIn = sizeIn, saved = false) }
    }

    fun setWireAwg(kind: BendKind, awg: String) {
        updateState(kind) { it.copy(wireAwg = awg, saved = false) }
    }

    fun setWireCount(kind: BendKind, count: Int) {
        updateState(kind) { it.copy(wireCount = count, saved = false) }
    }

    fun resetSaved(kind: BendKind) {
        updateState(kind) { it.copy(saved = false) }
    }

    /**
     * Resets inputs for this bend kind to its default values in A5.
     * Called when opened from Home or when exiting the Detail screen.
     */
    fun resetToDefaults(kind: BendKind) {
        _states.update { current ->
            current + (kind to BendDetailState())
        }
    }

    fun saveHistoryEntry(kind: BendKind, unit: AppUnit, bender: Bender): HistoryEntry {
        val state = getState(kind)
        val result = calculateResult(kind, state, bender)
        val label = buildLabel(kind, state.angleDeg)
        val inputSummary = buildInputSummary(
            kind = kind,
            unit = unit,
            tradeSizeIn = state.tradeSizeIn,
            offsetIn = state.offsetIn,
            stubHeightIn = state.stubHeightIn,
            riseIn = state.riseIn,
            depthIn = state.depthIn,
            kickOffsetIn = state.kickOffsetIn,
            kick90StubIn = state.kick90StubIn,
            totalAngleDeg = state.totalAngleDeg,
            radiusIn = state.radiusIn,
            shots = state.shots,
            obstructionWidthIn = state.obstructionWidthIn,
            rollingVerticalIn = state.rollingVerticalIn,
            rollingHorizontalIn = state.rollingHorizontalIn,
            wireConduitSizeIn = state.wireConduitSizeIn,
            wireAwg = state.wireAwg,
            wireCount = state.wireCount
        )
        val resultSummary = summarize(result)

        updateState(kind) { it.copy(saved = true) }

        return HistoryEntry(
            id = System.currentTimeMillis().toString(),
            kind = kind,
            label = label,
            createdAt = System.currentTimeMillis(),
            inputSummary = inputSummary,
            resultSummary = resultSummary
        )
    }
}
