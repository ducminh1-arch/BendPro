package com.bendpro.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bendpro.ui.theme.BgPanel
import com.bendpro.ui.theme.LineSoft
import com.bendpro.ui.theme.PoppinsFontFamily
import com.bendpro.ui.theme.TextPrimary
import com.bendpro.ui.theme.TextTertiary

@Composable
fun PlainField(
    label: String,
    suffix: String,
    value: Number,
    onChange: (Double) -> Unit,
    min: Double? = null,
    max: Double? = null,
    isInteger: Boolean = false,
    modifier: Modifier = Modifier
) {
    var text by remember(value) {
        mutableStateOf(
            if (isInteger) {
                value.toInt().toString()
            } else if (value.toDouble() % 1.0 == 0.0) {
                value.toInt().toString()
            } else {
                value.toString()
            }
        )
    }

    Box(
        modifier = modifier
            .fillMaxWidth()
            .heightIn(min = 48.dp)
            .clip(RoundedCornerShape(10.dp))
            .background(BgPanel)
            .border(1.dp, LineSoft, RoundedCornerShape(10.dp))
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
                color = TextTertiary,
                modifier = Modifier.weight(1f)
            )

            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                BasicTextField(
                    value = text,
                    onValueChange = { newText ->
                        text = newText
                        val parsed = newText.toDoubleOrNull() ?: 0.0
                        val clamped = if (min != null && max != null) {
                            parsed.coerceIn(min, max)
                        } else if (min != null) {
                            parsed.coerceAtLeast(min)
                        } else if (max != null) {
                            parsed.coerceAtMost(max)
                        } else {
                            parsed
                        }
                        onChange(if (isInteger) Math.round(clamped).toDouble() else clamped)
                    },
                    textStyle = TextStyle(
                        color = TextPrimary,
                        fontSize = 15.sp,
                        fontFamily = FontFamily.Monospace,
                        fontWeight = FontWeight.SemiBold,
                        textAlign = TextAlign.End
                    ),
                    keyboardOptions = KeyboardOptions(
                        keyboardType = if (isInteger) KeyboardType.Number else KeyboardType.Decimal
                    ),
                    singleLine = true,
                    cursorBrush = SolidColor(TextPrimary),
                    modifier = Modifier.width(64.dp)
                )

                Text(
                    text = suffix,
                    fontFamily = FontFamily.Monospace,
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Normal,
                    color = TextPrimary
                )
            }
        }
    }
}
