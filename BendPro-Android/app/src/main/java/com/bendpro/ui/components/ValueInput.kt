package com.bendpro.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.sizeIn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bendpro.core.AppUnit
import com.bendpro.core.formatLength
import com.bendpro.ui.theme.Accent
import com.bendpro.ui.theme.AccentWash
import com.bendpro.ui.theme.BgInset
import com.bendpro.ui.theme.BgPanel
import com.bendpro.ui.theme.Line
import com.bendpro.ui.theme.LineSoft
import com.bendpro.ui.theme.PoppinsFontFamily
import com.bendpro.ui.theme.TextPrimary
import com.bendpro.ui.theme.TextTertiary
import java.util.Locale
import kotlin.math.roundToInt

private enum class InputStyle {
    PAD, SLIDER
}

private val PAD_KEYS = listOf(
    "1", "2", "3",
    "4", "5", "6",
    "7", "8", "9",
    ".", "0", "⌫"
)

@Composable
fun ValueInput(
    label: String,
    valueIn: Double,
    onChangeIn: (Double) -> Unit,
    unit: AppUnit,
    minIn: Double = 0.0,
    maxIn: Double = 96.0,
    stepIn: Double = 0.125,
    modifier: Modifier = Modifier
) {
    var expanded by remember { mutableStateOf(false) }
    var style by remember { mutableStateOf(InputStyle.PAD) }

    // Raw input string for the keypad / readout
    var raw by remember(unit) {
        mutableStateOf(
            if (unit == AppUnit.MM) {
                (valueIn * 25.4).roundToInt().toString()
            } else {
                if (valueIn % 1.0 == 0.0) valueIn.toInt().toString() else valueIn.toString()
            }
        )
    }

    // Keep raw string in sync when external valueIn changes and not actively typing
    LaunchedEffect(valueIn, unit) {
        val currentParsed = if (unit == AppUnit.MM) {
            (raw.toDoubleOrNull() ?: 0.0) / 25.4
        } else {
            raw.toDoubleOrNull() ?: 0.0
        }
        if (Math.abs(currentParsed - valueIn) > 1e-4) {
            raw = if (unit == AppUnit.MM) {
                (valueIn * 25.4).roundToInt().toString()
            } else {
                if (valueIn % 1.0 == 0.0) valueIn.toInt().toString() else String.format(Locale.US, "%.3f", valueIn)
            }
        }
    }

    if (!expanded) {
        // Collapsed state
        Box(
            modifier = modifier
                .fillMaxWidth()
                .heightIn(min = 48.dp)
                .clip(RoundedCornerShape(10.dp))
                .background(BgPanel)
                .border(1.dp, LineSoft, RoundedCornerShape(10.dp))
                .clickable(
                    onClickLabel = "Edit value",
                    role = Role.Button
                ) { expanded = true }
                .semantics {
                    contentDescription = "$label, ${formatLength(valueIn, unit)}. Tap to edit."
                }
                .padding(horizontal = 14.dp, vertical = 12.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = label.uppercase(),
                    fontFamily = PoppinsFontFamily,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Medium,
                    letterSpacing = 0.08.sp,
                    color = TextTertiary
                )
                Text(
                    text = formatLength(valueIn, unit),
                    fontFamily = FontFamily.Monospace,
                    fontSize = 15.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = TextPrimary
                )
            }
        }
    } else {
        // Expanded state
        Box(
            modifier = modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(16.dp))
                .background(BgPanel)
                .border(1.dp, LineSoft, RoundedCornerShape(16.dp))
                .padding(14.dp)
        ) {
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                // Header: label + style toggle buttons
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = label.uppercase(),
                        fontFamily = PoppinsFontFamily,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Medium,
                        letterSpacing = 0.08.sp,
                        color = TextTertiary
                    )

                    // Toggle: KEYPAD | SLIDE | DONE
                    Row(
                        modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(BgInset)
                            .border(1.dp, Line, RoundedCornerShape(6.dp)),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Box(
                            modifier = Modifier
                                .sizeIn(minWidth = 48.dp, minHeight = 36.dp)
                                .clip(RoundedCornerShape(6.dp))
                                .background(if (style == InputStyle.PAD) AccentWash else BgInset)
                                .clickable(
                                    role = Role.RadioButton,
                                    onClick = { style = InputStyle.PAD }
                                )
                                .padding(horizontal = 8.dp, vertical = 6.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "KEYPAD",
                                fontFamily = PoppinsFontFamily,
                                fontSize = 10.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = if (style == InputStyle.PAD) Accent else TextTertiary
                            )
                        }

                        Box(
                            modifier = Modifier
                                .sizeIn(minWidth = 48.dp, minHeight = 36.dp)
                                .clip(RoundedCornerShape(6.dp))
                                .background(if (style == InputStyle.SLIDER) AccentWash else BgInset)
                                .clickable(
                                    role = Role.RadioButton,
                                    onClick = { style = InputStyle.SLIDER }
                                )
                                .padding(horizontal = 8.dp, vertical = 6.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "SLIDE",
                                fontFamily = PoppinsFontFamily,
                                fontSize = 10.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = if (style == InputStyle.SLIDER) Accent else TextTertiary
                            )
                        }

                        Box(
                            modifier = Modifier
                                .sizeIn(minWidth = 48.dp, minHeight = 36.dp)
                                .clickable(
                                    role = Role.Button,
                                    onClick = { expanded = false }
                                )
                                .padding(horizontal = 8.dp, vertical = 6.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "DONE",
                                fontFamily = PoppinsFontFamily,
                                fontSize = 10.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = TextTertiary
                            )
                        }
                    }
                }

                // Numeric readout
                Row(
                    verticalAlignment = Alignment.Bottom,
                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    val displayValue = if (unit == AppUnit.MM) {
                        (valueIn * 25.4).roundToInt().toString()
                    } else {
                        String.format(Locale.US, "%.3f", valueIn)
                    }

                    Text(
                        text = displayValue,
                        fontFamily = FontFamily.Monospace,
                        fontSize = 28.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = TextPrimary
                    )

                    Text(
                        text = if (unit == AppUnit.MM) "mm" else "in",
                        fontFamily = PoppinsFontFamily,
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Medium,
                        color = TextTertiary,
                        modifier = Modifier.padding(bottom = 4.dp)
                    )
                }

                if (style == InputStyle.PAD) {
                    // 3x4 Keypad grid
                    Column(
                        modifier = Modifier.fillMaxWidth(),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        for (row in 0 until 4) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                for (col in 0 until 3) {
                                    val key = PAD_KEYS[row * 3 + col]
                                    val keyDesc = when (key) {
                                        "⌫" -> "Backspace"
                                        "." -> "Decimal point"
                                        else -> key
                                    }
                                    Box(
                                        modifier = Modifier
                                            .weight(1f)
                                            .height(48.dp)
                                            .clip(RoundedCornerShape(6.dp))
                                            .background(BgInset)
                                            .border(1.dp, Line, RoundedCornerShape(6.dp))
                                            .semantics { contentDescription = keyDesc }
                                            .clickable(
                                                role = Role.Button,
                                                onClickLabel = keyDesc
                                            ) {
                                                if (key == "⌫") {
                                                    val next = raw.dropLast(1).ifEmpty { "0" }
                                                    raw = next
                                                    val n = next.toDoubleOrNull() ?: 0.0
                                                    onChangeIn(if (unit == AppUnit.MM) n / 25.4 else n)
                                                } else if (key == "." && raw.contains(".")) {
                                                    // Ignore duplicate dot
                                                } else {
                                                    val next = if (raw == "0" && key != ".") key else raw + key
                                                    raw = next
                                                    val n = next.toDoubleOrNull() ?: 0.0
                                                    onChangeIn(if (unit == AppUnit.MM) n / 25.4 else n)
                                                }
                                            },
                                        contentAlignment = Alignment.Center
                                    ) {
                                        Text(
                                            text = key,
                                            fontFamily = FontFamily.Monospace,
                                            fontSize = 17.sp,
                                            fontWeight = FontWeight.Medium,
                                            color = TextPrimary,
                                            textAlign = TextAlign.Center
                                        )
                                    }
                                }
                            }
                        }
                    }
                } else {
                    // Slider
                    var trackWidthPx by remember { mutableFloatStateOf(1f) }

                    fun handlePointer(xPx: Float) {
                        val pct = (xPx / trackWidthPx).coerceIn(0f, 1f)
                        if (unit == AppUnit.MM) {
                            val minMm = minIn * 25.4
                            val maxMm = maxIn * 25.4
                            val valueMm = minMm + pct * (maxMm - minMm)
                            val snappedMm = Math.round(valueMm).toDouble()
                            raw = snappedMm.toLong().toString()
                            onChangeIn(snappedMm / 25.4)
                        } else {
                            val value = minIn + pct * (maxIn - minIn)
                            val snapped = (Math.round(value / stepIn) * stepIn)
                            raw = String.format(Locale.US, "%.3f", snapped)
                            onChangeIn(snapped)
                        }
                    }

                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(48.dp)
                            .clip(RoundedCornerShape(999.dp))
                            .background(BgInset)
                            .border(1.dp, Line, RoundedCornerShape(999.dp))
                            .onSizeChanged { trackWidthPx = it.width.toFloat().coerceAtLeast(1f) }
                            .pointerInput(unit, minIn, maxIn, stepIn) {
                                detectTapGestures { offset ->
                                    handlePointer(offset.x)
                                }
                            }
                            .pointerInput(unit, minIn, maxIn, stepIn) {
                                detectDragGestures { change, _ ->
                                    change.consume()
                                    handlePointer(change.position.x)
                                }
                            }
                    ) {
                        val pct = if (unit == AppUnit.MM) {
                            val minMm = minIn * 25.4
                            val maxMm = maxIn * 25.4
                            val curMm = valueIn * 25.4
                            ((curMm - minMm) / (maxMm - minMm)).coerceIn(0.0, 1.0).toFloat()
                        } else {
                            ((valueIn - minIn) / (maxIn - minIn)).coerceIn(0.0, 1.0).toFloat()
                        }

                        // Slider fill
                        Box(
                            modifier = Modifier
                                .fillMaxHeight()
                                .fillMaxWidth(pct)
                                .clip(RoundedCornerShape(999.dp))
                                .background(AccentWash)
                        )

                        // Slider thumb (28dp circle, Accent, shadow)
                        Box(
                            modifier = Modifier
                                .align(Alignment.CenterStart)
                                .offset {
                                    val thumbOffset = (pct * trackWidthPx - 14.dp.toPx()).toInt()
                                        .coerceIn(0, (trackWidthPx - 28.dp.toPx()).toInt())
                                    IntOffset(thumbOffset, 0)
                                }
                                .size(28.dp)
                                .shadow(elevation = 8.dp, shape = CircleShape)
                                .background(Accent, CircleShape)
                        )
                    }
                }
            }
        }
    }
}
