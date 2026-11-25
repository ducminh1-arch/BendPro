package com.bendpro.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bendpro.core.AppUnit
import com.bendpro.core.Bender
import com.bendpro.core.BendKind
import com.bendpro.core.HistoryEntry
import com.bendpro.core.Kick90Result
import com.bendpro.core.KickResult
import com.bendpro.core.NinetyResult
import com.bendpro.core.OFFSET_ANGLES
import com.bendpro.core.OffsetResult
import com.bendpro.core.RollingOffsetResult
import com.bendpro.core.Saddle3Result
import com.bendpro.core.Saddle4Result
import com.bendpro.core.SegmentedResult
import com.bendpro.core.TRADE_SIZES
import com.bendpro.core.WIRE_AWG_OPTIONS
import com.bendpro.core.WireFillResult
import com.bendpro.core.formatLength
import com.bendpro.core.tradeSizeLabel
import com.bendpro.ui.components.PlainField
import com.bendpro.ui.components.StatusPill
import com.bendpro.ui.components.ValueInput
import com.bendpro.ui.diagrams.BendDiagram
import com.bendpro.ui.theme.Accent
import com.bendpro.ui.theme.AccentWash
import com.bendpro.ui.theme.BgInset
import com.bendpro.ui.theme.BgPanel
import com.bendpro.ui.theme.Line
import com.bendpro.ui.theme.LineSoft
import com.bendpro.ui.theme.PoppinsFontFamily
import com.bendpro.ui.theme.TextPrimary
import com.bendpro.ui.theme.TextSecondary
import com.bendpro.ui.theme.TextTertiary
import com.bendpro.ui.viewmodel.DetailViewModel
import com.bendpro.ui.viewmodel.calculateResult
import com.bendpro.ui.viewmodel.formatAngle
import java.util.Locale
import kotlin.math.max

private const val LEAD_IN = 3.0

@Composable
fun DetailScreen(
    kind: BendKind,
    unit: AppUnit,
    bender: Bender,
    viewModel: DetailViewModel,
    onOpenBenderPicker: () -> Unit,
    onSaveHistory: (HistoryEntry) -> Unit,
    modifier: Modifier = Modifier
) {
    val states by viewModel.states.collectAsState()
    val state = states[kind] ?: com.bendpro.ui.viewmodel.BendDetailState()

    // Ensure trade size is supported by the chosen bender (Deviation A9.2) - skipped for wirefill
    LaunchedEffect(bender, kind) {
        if (kind != BendKind.WIREFILL) {
            viewModel.clampTradeSize(bender, kind)
        }
    }

    val result = calculateResult(kind, state, bender)

    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Bender row (shown for all except wirefill)
        if (kind != BendKind.WIREFILL) {
            BenderSelectRow(
                bender = bender,
                selectedSize = state.tradeSizeIn,
                onClick = onOpenBenderPicker
            )

            // CONDUIT chips (filtered by the bender's supported sizes)
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Text(
                    text = "CONDUIT",
                    fontFamily = PoppinsFontFamily,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.SemiBold,
                    letterSpacing = 0.08.sp,
                    color = TextTertiary
                )

                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .horizontalScroll(rememberScrollState()),
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    TRADE_SIZES.filter { bender.conduitSizesIn.contains(it) }.forEach { size ->
                        val isSelected = size == state.tradeSizeIn
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(6.dp))
                                .background(if (isSelected) AccentWash else BgInset)
                                .border(1.dp, if (isSelected) Accent else Line, RoundedCornerShape(6.dp))
                                .clickable { viewModel.setTradeSize(kind, size) }
                                .padding(horizontal = 12.dp, vertical = 8.dp)
                        ) {
                            Text(
                                text = tradeSizeLabel(size),
                                fontFamily = FontFamily.Monospace,
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Medium,
                                color = if (isSelected) Accent else TextSecondary
                            )
                        }
                    }
                }
            }
        }

        // Inputs Section
        Column(
            modifier = Modifier.fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                text = "INPUTS",
                fontFamily = PoppinsFontFamily,
                fontSize = 11.sp,
                fontWeight = FontWeight.SemiBold,
                letterSpacing = 0.09.sp,
                color = TextTertiary
            )

            when (kind) {
                BendKind.OFFSET -> {
                    ValueInput(
                        label = "RISE",
                        valueIn = state.offsetIn,
                        onChangeIn = { viewModel.setOffset(kind, it) },
                        unit = unit,
                        maxIn = 24.0
                    )

                    AngleChipsRow(
                        selectedAngle = state.angleDeg,
                        onSelectAngle = { viewModel.setAngle(kind, it) }
                    )
                }

                BendKind.NINETY -> {
                    ValueInput(
                        label = "STUB LENGTH",
                        valueIn = state.stubHeightIn,
                        onChangeIn = { viewModel.setStubHeight(kind, it) },
                        unit = unit,
                        maxIn = 60.0
                    )
                }

                BendKind.KICK -> {
                    ValueInput(
                        label = "RISE",
                        valueIn = state.riseIn,
                        onChangeIn = { viewModel.setRise(kind, it) },
                        unit = unit,
                        maxIn = 24.0
                    )

                    AngleChipsRow(
                        selectedAngle = state.angleDeg,
                        onSelectAngle = { viewModel.setAngle(kind, it) }
                    )
                }

                BendKind.SADDLE3 -> {
                    ValueInput(
                        label = "OBSTRUCTION DEPTH",
                        valueIn = state.depthIn,
                        onChangeIn = { viewModel.setDepth(kind, it) },
                        unit = unit,
                        maxIn = 12.0
                    )
                }

                BendKind.KICK90 -> {
                    ValueInput(
                        label = "KICK OFFSET",
                        valueIn = state.kickOffsetIn,
                        onChangeIn = { viewModel.setKickOffset(kind, it) },
                        unit = unit,
                        maxIn = 12.0
                    )

                    ValueInput(
                        label = "STUB LENGTH (FROM FINISHED END)",
                        valueIn = state.kick90StubIn,
                        onChangeIn = { viewModel.setKick90Stub(kind, it) },
                        unit = unit,
                        maxIn = 60.0
                    )

                    AngleChipsRow(
                        selectedAngle = state.angleDeg,
                        onSelectAngle = { viewModel.setAngle(kind, it) }
                    )
                }

                BendKind.SEGMENTED -> {
                    PlainField(
                        label = "TOTAL SWEEP ANGLE",
                        suffix = "°",
                        value = state.totalAngleDeg,
                        onChange = { viewModel.setTotalAngle(kind, it) },
                        min = 1.0,
                        max = 180.0
                    )

                    ValueInput(
                        label = "BEND RADIUS",
                        valueIn = state.radiusIn,
                        onChangeIn = { viewModel.setRadius(kind, it) },
                        unit = unit,
                        maxIn = 60.0
                    )

                    PlainField(
                        label = "NUMBER OF SHOTS",
                        suffix = "shots",
                        value = state.shots,
                        onChange = { viewModel.setShots(kind, it.toInt()) },
                        min = 2.0,
                        max = 20.0,
                        isInteger = true
                    )
                }

                BendKind.SADDLE4 -> {
                    ValueInput(
                        label = "OBSTRUCTION DEPTH",
                        valueIn = state.depthIn,
                        onChangeIn = { viewModel.setDepth(kind, it) },
                        unit = unit,
                        maxIn = 12.0
                    )

                    ValueInput(
                        label = "OBSTRUCTION WIDTH (FLAT TOP)",
                        valueIn = state.obstructionWidthIn,
                        onChangeIn = { viewModel.setObstructionWidth(kind, it) },
                        unit = unit,
                        maxIn = 36.0
                    )
                }

                BendKind.ROLLING -> {
                    ValueInput(
                        label = "VERTICAL OFFSET",
                        valueIn = state.rollingVerticalIn,
                        onChangeIn = { viewModel.setRollingVertical(kind, it) },
                        unit = unit,
                        maxIn = 24.0
                    )

                    ValueInput(
                        label = "HORIZONTAL OFFSET",
                        valueIn = state.rollingHorizontalIn,
                        onChangeIn = { viewModel.setRollingHorizontal(kind, it) },
                        unit = unit,
                        maxIn = 24.0
                    )

                    AngleChipsRow(
                        selectedAngle = state.angleDeg,
                        onSelectAngle = { viewModel.setAngle(kind, it) }
                    )
                }

                BendKind.WIREFILL -> {
                    // CONDUIT SIZE (EMT)
                    Column(
                        modifier = Modifier.fillMaxWidth(),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text(
                            text = "CONDUIT SIZE (EMT)",
                            fontFamily = PoppinsFontFamily,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.SemiBold,
                            letterSpacing = 0.08.sp,
                            color = TextTertiary
                        )

                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .horizontalScroll(rememberScrollState()),
                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            TRADE_SIZES.forEach { size ->
                                val isSelected = size == state.wireConduitSizeIn
                                Box(
                                    modifier = Modifier
                                        .clip(RoundedCornerShape(6.dp))
                                        .background(if (isSelected) AccentWash else BgInset)
                                        .border(1.dp, if (isSelected) Accent else Line, RoundedCornerShape(6.dp))
                                        .clickable { viewModel.setWireConduitSize(kind, size) }
                                        .padding(horizontal = 12.dp, vertical = 8.dp)
                                ) {
                                    Text(
                                        text = tradeSizeLabel(size),
                                        fontFamily = FontFamily.Monospace,
                                        fontSize = 13.sp,
                                        fontWeight = FontWeight.Medium,
                                        color = if (isSelected) Accent else TextSecondary
                                    )
                                }
                            }
                        }
                    }

                    // WIRE SIZE (AWG, THHN/THWN)
                    Column(
                        modifier = Modifier.fillMaxWidth(),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text(
                            text = "WIRE SIZE (AWG, THHN/THWN)",
                            fontFamily = PoppinsFontFamily,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.SemiBold,
                            letterSpacing = 0.08.sp,
                            color = TextTertiary
                        )

                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .horizontalScroll(rememberScrollState()),
                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            WIRE_AWG_OPTIONS.forEach { awg ->
                                val isSelected = awg == state.wireAwg
                                Box(
                                    modifier = Modifier
                                        .clip(RoundedCornerShape(6.dp))
                                        .background(if (isSelected) AccentWash else BgInset)
                                        .border(1.dp, if (isSelected) Accent else Line, RoundedCornerShape(6.dp))
                                        .clickable { viewModel.setWireAwg(kind, awg) }
                                        .padding(horizontal = 12.dp, vertical = 8.dp)
                                ) {
                                    Text(
                                        text = awg,
                                        fontFamily = FontFamily.Monospace,
                                        fontSize = 13.sp,
                                        fontWeight = FontWeight.Medium,
                                        color = if (isSelected) Accent else TextSecondary
                                    )
                                }
                            }
                        }
                    }

                    // Number of conductors
                    PlainField(
                        label = "NUMBER OF CONDUCTORS",
                        suffix = "ct",
                        value = state.wireCount,
                        onChange = { viewModel.setWireCount(kind, it.toInt()) },
                        min = 1.0,
                        max = 40.0,
                        isInteger = true
                    )
                }
            }
        }

        // Marks on Conduit Section (only for kinds that have marks)
        val hasMarks = kind !in listOf(BendKind.SEGMENTED, BendKind.WIREFILL)
        if (hasMarks) {
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Text(
                    text = "MARKS ON CONDUIT",
                    fontFamily = PoppinsFontFamily,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.SemiBold,
                    letterSpacing = 0.09.sp,
                    color = TextTertiary
                )

                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(10.dp))
                        .background(BgPanel)
                        .border(1.dp, LineSoft, RoundedCornerShape(10.dp))
                ) {
                    Column(modifier = Modifier.fillMaxWidth()) {
                        when (result) {
                            is OffsetResult -> {
                                MarkRow(label = "Mark 1", value = formatLength(LEAD_IN, unit))
                                RowDivider()
                                MarkRow(label = "Mark 2", value = formatLength(LEAD_IN + result.distanceBetweenBendsIn, unit))
                            }
                            is NinetyResult -> {
                                MarkRow(label = "Mark 1", value = formatLength(result.markIn, unit))
                            }
                            is KickResult -> {
                                MarkRow(label = "Mark", value = formatLength(result.distanceToMarkIn, unit))
                            }
                            is Saddle3Result -> {
                                MarkRow(label = "Center → Side", value = formatLength(result.centerToSideIn, unit))
                            }
                            is Kick90Result -> {
                                MarkRow(label = "Mark 1 · from start", value = formatLength(result.kickMarkIn, unit))
                                RowDivider()
                                MarkRow(label = "Mark 2 · from end", value = formatLength(result.stubMarkIn, unit))
                            }
                            is Saddle4Result -> {
                                MarkRow(label = "Inner pair · spacing", value = formatLength(result.innerSpacingIn, unit))
                                RowDivider()
                                MarkRow(label = "Outer · beyond each inner", value = formatLength(result.outerFromInnerIn, unit))
                            }
                            is RollingOffsetResult -> {
                                MarkRow(label = "Mark 1", value = formatLength(LEAD_IN, unit))
                                RowDivider()
                                MarkRow(label = "Mark 2", value = formatLength(LEAD_IN + result.distanceBetweenBendsIn, unit))
                            }
                            else -> {}
                        }
                    }
                }
            }
        }

        // Calculations Section
        Column(
            modifier = Modifier.fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                text = "CALCULATIONS",
                fontFamily = PoppinsFontFamily,
                fontSize = 11.sp,
                fontWeight = FontWeight.SemiBold,
                letterSpacing = 0.09.sp,
                color = TextTertiary
            )

            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(10.dp))
                    .background(BgPanel)
                    .border(1.dp, LineSoft, RoundedCornerShape(10.dp))
            ) {
                Column(modifier = Modifier.fillMaxWidth()) {
                    when (result) {
                        is OffsetResult -> {
                            CalculationRow(label = "Spacing", value = formatLength(result.distanceBetweenBendsIn, unit))
                            RowDivider()
                            CalculationRow(label = "Shrink", value = formatLength(result.shrinkIn, unit, precision = 3))
                        }
                        is NinetyResult -> {
                            CalculationRow(label = "Deduct", value = formatLength(result.deductIn, unit))
                            RowDivider()
                            CalculationRow(
                                label = "Gain",
                                value = formatLength(max(result.deductIn * 0.36, 0.1), unit, precision = 2)
                            )
                            RowDivider()
                            CalculationRow(label = "Mark", value = formatLength(result.markIn, unit))
                        }
                        is KickResult -> {
                            CalculationRow(label = "Gain", value = formatLength(result.gainIn, unit, precision = 3))
                        }
                        is Saddle3Result -> {
                            CalculationRow(label = "Total gain", value = formatLength(result.totalGainIn, unit, precision = 3))
                        }
                        is Kick90Result -> {
                            CalculationRow(label = "90° deduct", value = formatLength(result.deductIn, unit))
                        }
                        is SegmentedResult -> {
                            CalculationRow(
                                label = "Angle per shot",
                                value = String.format(Locale.US, "%.1f°", result.anglePerShotDeg)
                            )
                            RowDivider()
                            CalculationRow(
                                label = "Distance between shots",
                                value = formatLength(result.distanceBetweenShotsIn, unit)
                            )
                        }
                        is Saddle4Result -> {
                            CalculationRow(
                                label = "All 4 bends",
                                value = "${formatAngle(result.sideAngleDeg)}°"
                            )
                            RowDivider()
                            CalculationRow(
                                label = "Total gain",
                                value = formatLength(result.totalGainIn, unit, precision = 3)
                            )
                        }
                        is RollingOffsetResult -> {
                            CalculationRow(label = "True offset", value = formatLength(result.trueOffsetIn, unit))
                            RowDivider()
                            CalculationRow(
                                label = "Roll angle",
                                value = String.format(Locale.US, "%.1f°", result.rollAngleDeg)
                            )
                            RowDivider()
                            CalculationRow(label = "Shrink", value = formatLength(result.shrinkIn, unit, precision = 3))
                        }
                        is WireFillResult -> {
                            CalculationRow(
                                label = "Conduit area",
                                value = String.format(Locale.US, "%.3f sq in", result.conduitAreaSqIn)
                            )
                            RowDivider()
                            CalculationRow(
                                label = "Conductor area",
                                value = String.format(Locale.US, "%.4f sq in", result.totalConductorAreaSqIn)
                            )
                            RowDivider()
                            CalculationRow(
                                label = "Fill (max ${result.maxFillPct.toInt()}%)",
                                value = String.format(Locale.US, "%.1f%%", result.fillPct)
                            )
                        }
                    }
                }
            }

            if (kind == BendKind.WIREFILL) {
                Text(
                    text = "EMT and THHN/THWN only, approximate NEC Chapter 9 subset — not verified against a specific code edition. Verify against the current NEC tables for other conduit or wire types.",
                    fontFamily = PoppinsFontFamily,
                    fontSize = 11.sp,
                    lineHeight = 16.sp,
                    color = TextTertiary,
                    modifier = Modifier.padding(top = 2.dp, start = 2.dp, end = 2.dp)
                )
            }
        }

        // Diagram Card
        BendDiagram(result = result)

        // Status Pill
        StatusPill(feasibility = result.feasibility)

        // Save Button
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(48.dp)
                .clip(RoundedCornerShape(10.dp))
                .background(Accent)
                .clickable(
                    role = Role.Button,
                    onClickLabel = if (state.saved) "Calculation already saved" else "Save to history",
                    onClick = {
                        if (!state.saved) {
                            val entry = viewModel.saveHistoryEntry(kind, unit, bender)
                            onSaveHistory(entry)
                        }
                    }
                ),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = if (state.saved) "Saved ✓" else "Save to history",
                fontFamily = PoppinsFontFamily,
                fontWeight = FontWeight.SemiBold,
                fontSize = 15.sp,
                letterSpacing = 0.03.sp,
                color = Color.White
            )
        }
    }
}

@Composable
private fun AngleChipsRow(
    selectedAngle: Double,
    onSelectAngle: (Double) -> Unit
) {
    Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text(
            text = "ANGLE",
            fontFamily = PoppinsFontFamily,
            fontSize = 11.sp,
            fontWeight = FontWeight.Medium,
            letterSpacing = 0.08.sp,
            color = TextTertiary
        )

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            OFFSET_ANGLES.forEach { angle ->
                val isSelected = angle == selectedAngle
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(6.dp))
                        .background(if (isSelected) AccentWash else BgInset)
                        .border(1.dp, if (isSelected) Accent else Line, RoundedCornerShape(6.dp))
                        .clickable { onSelectAngle(angle) }
                        .padding(horizontal = 12.dp, vertical = 8.dp)
                ) {
                    Text(
                        text = "${formatAngle(angle)}°",
                        fontFamily = FontFamily.Monospace,
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Medium,
                        color = if (isSelected) Accent else TextSecondary
                    )
                }
            }
        }
    }
}

@Composable
private fun MarkRow(label: String, value: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 14.dp, vertical = 11.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(7.dp)
                    .clip(CircleShape)
                    .background(Accent)
            )
            Text(
                text = label,
                fontFamily = PoppinsFontFamily,
                fontSize = 13.sp,
                color = TextSecondary
            )
        }

        Text(
            text = value,
            fontFamily = FontFamily.Monospace,
            fontSize = 14.sp,
            fontWeight = FontWeight.SemiBold,
            color = Accent
        )
    }
}

@Composable
private fun CalculationRow(label: String, value: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 14.dp, vertical = 11.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = label,
            fontFamily = PoppinsFontFamily,
            fontSize = 13.sp,
            color = TextSecondary
        )

        Text(
            text = value,
            fontFamily = FontFamily.Monospace,
            fontSize = 14.sp,
            fontWeight = FontWeight.SemiBold,
            color = TextPrimary
        )
    }
}

@Composable
private fun RowDivider() {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(1.dp)
            .background(LineSoft)
    )
}
