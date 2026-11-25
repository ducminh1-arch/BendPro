package com.bendpro.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bendpro.core.AppUnit
import com.bendpro.ui.theme.Accent
import com.bendpro.ui.theme.AccentWash
import com.bendpro.ui.theme.BgPanel
import com.bendpro.ui.theme.Line
import com.bendpro.ui.theme.LineSoft
import com.bendpro.ui.theme.PoppinsFontFamily
import com.bendpro.ui.theme.TextPrimary
import com.bendpro.ui.theme.TextSecondary
import com.bendpro.ui.theme.TextTertiary

@Composable
fun SettingsScreen(
    unit: AppUnit,
    onUnitChange: (AppUnit) -> Unit,
    darkOptimized: Boolean,
    onToggleDark: (Boolean) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(20.dp)
    ) {
        // Units Section
        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Text(
                text = "UNITS",
                fontFamily = PoppinsFontFamily,
                fontWeight = FontWeight.SemiBold,
                fontSize = 11.sp,
                letterSpacing = 0.9.sp,
                color = TextTertiary
            )

            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                AppUnit.entries.forEach { appUnit ->
                    val isActive = appUnit == unit
                    UnitPill(
                        label = appUnit.label,
                        isActive = isActive,
                        onClick = { onUnitChange(appUnit) }
                    )
                }
            }
        }

        HorizontalDivider(thickness = 1.dp, color = LineSoft)

        // Display Section
        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Text(
                text = "DISPLAY",
                fontFamily = PoppinsFontFamily,
                fontWeight = FontWeight.SemiBold,
                fontSize = 11.sp,
                letterSpacing = 0.9.sp,
                color = TextTertiary
            )

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable(
                        role = Role.Switch,
                        onClickLabel = "Toggle high-contrast dark mode",
                        onClick = { onToggleDark(!darkOptimized) }
                    ),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(2.dp)
                ) {
                    Text(
                        text = "High-contrast dark mode",
                        fontFamily = PoppinsFontFamily,
                        fontSize = 13.5.sp,
                        color = TextPrimary
                    )
                    Text(
                        text = "Optimized for bright job-site light and headlamps.",
                        fontFamily = PoppinsFontFamily,
                        fontSize = 11.5.sp,
                        color = TextTertiary
                    )
                }

                Switch(
                    checked = darkOptimized,
                    onCheckedChange = onToggleDark,
                    colors = SwitchDefaults.colors(
                        checkedThumbColor = TextPrimary,
                        checkedTrackColor = Accent,
                        uncheckedThumbColor = TextTertiary,
                        uncheckedTrackColor = BgPanel,
                        uncheckedBorderColor = Line
                    )
                )
            }
        }

        HorizontalDivider(thickness = 1.dp, color = LineSoft)

        // About Section
        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Text(
                text = "ABOUT",
                fontFamily = PoppinsFontFamily,
                fontWeight = FontWeight.SemiBold,
                fontSize = 11.sp,
                letterSpacing = 0.9.sp,
                color = TextTertiary
            )

            Text(
                text = "BendPro runs the same centerline-radius engine for every calculation and diagram — offline, with no account and no data collection.",
                fontFamily = PoppinsFontFamily,
                fontSize = 12.5.sp,
                lineHeight = 20.sp,
                color = TextSecondary
            )
        }
    }
}

@Composable
private fun UnitPill(
    label: String,
    isActive: Boolean,
    onClick: () -> Unit
) {
    val bgColor = if (isActive) AccentWash else BgPanel
    val borderColor = if (isActive) Accent else Line
    val textColor = if (isActive) Accent else TextSecondary

    Box(
        modifier = Modifier
            .heightIn(min = 48.dp)
            .clip(RoundedCornerShape(999.dp))
            .background(bgColor)
            .border(1.dp, borderColor, RoundedCornerShape(999.dp))
            .clickable(
                role = Role.RadioButton,
                onClickLabel = "Select unit $label",
                onClick = onClick
            )
            .padding(horizontal = 14.dp, vertical = 8.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = label,
            fontFamily = PoppinsFontFamily,
            fontWeight = FontWeight.SemiBold,
            fontSize = 12.5.sp,
            color = textColor
        )
    }
}
