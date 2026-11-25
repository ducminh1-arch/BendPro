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
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bendpro.app.R
import com.bendpro.core.Bender
import com.bendpro.core.BendKind
import com.bendpro.core.tradeSizeLabel
import com.bendpro.ui.theme.Accent
import com.bendpro.ui.theme.AccentWash
import com.bendpro.ui.theme.BgPanel
import com.bendpro.ui.theme.LineSoft
import com.bendpro.ui.theme.PoppinsFontFamily
import com.bendpro.ui.theme.TextPrimary
import com.bendpro.ui.theme.TextSecondary
import com.bendpro.ui.theme.TextTertiary

val TITLE_MAP = mapOf(
    BendKind.OFFSET to "Offset",
    BendKind.NINETY to "90° Bend",
    BendKind.SADDLE3 to "3-Point Saddle",
    BendKind.KICK to "Kick",
    BendKind.KICK90 to "Kick + 90°",
    BendKind.SEGMENTED to "Multi-Shot",
    BendKind.SADDLE4 to "4-Point Saddle",
    BendKind.ROLLING to "Rolling Offset",
    BendKind.WIREFILL to "Wire Fill"
)

@Composable
fun DetailPlaceholderScreen(
    kind: BendKind,
    bender: Bender,
    selectedSize: Double = 0.75,
    onOpenBenderPicker: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Bender row (only if not wirefill)
        if (kind != BendKind.WIREFILL) {
            BenderSelectRow(
                bender = bender,
                selectedSize = selectedSize,
                onClick = onOpenBenderPicker
            )
        }

        // Placeholder body (styled like .soon-screen)
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 48.dp),
            contentAlignment = Alignment.Center
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(48.dp)
                        .clip(RoundedCornerShape(14.dp))
                        .background(AccentWash),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        painter = painterResource(id = getIconForKind(kind)),
                        contentDescription = null,
                        tint = Accent,
                        modifier = Modifier.size(24.dp)
                    )
                }

                Text(
                    text = TITLE_MAP[kind] ?: "Bend Detail",
                    fontFamily = PoppinsFontFamily,
                    fontWeight = FontWeight.Medium,
                    fontSize = 16.sp,
                    color = TextSecondary
                )

                Text(
                    text = "Calculators and interactive diagrams for this bend type will be implemented in the next phase.",
                    fontFamily = PoppinsFontFamily,
                    fontSize = 13.sp,
                    color = TextTertiary,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.padding(horizontal = 24.dp)
                )
            }
        }
    }
}

@Composable
fun BenderSelectRow(
    bender: Bender,
    selectedSize: Double,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .heightIn(min = 48.dp)
            .clip(RoundedCornerShape(10.dp))
            .background(BgPanel)
            .border(1.dp, LineSoft, RoundedCornerShape(10.dp))
            .clickable(
                onClickLabel = "Change bender",
                onClick = onClick
            )
            .semantics {
                contentDescription = "Bender: ${bender.brand}, size ${tradeSizeLabel(selectedSize)}. Tap to change."
            }
            .padding(horizontal = 12.dp, vertical = 11.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Icon(
                painter = painterResource(id = R.drawable.ic_nav_bends),
                contentDescription = null,
                tint = Accent,
                modifier = Modifier.size(18.dp)
            )

            Text(
                text = "${bender.brand} · ${tradeSizeLabel(selectedSize)}",
                fontFamily = PoppinsFontFamily,
                fontWeight = FontWeight.Medium,
                fontSize = 13.sp,
                color = TextPrimary,
                modifier = Modifier.weight(1f)
            )

            Icon(
                painter = painterResource(id = R.drawable.ic_chevron_right),
                contentDescription = "Select bender",
                tint = TextTertiary,
                modifier = Modifier.size(16.dp)
            )
        }
    }
}

fun getIconForKind(kind: BendKind): Int = when (kind) {
    BendKind.OFFSET -> R.drawable.ic_bend_offset
    BendKind.NINETY -> R.drawable.ic_bend_ninety
    BendKind.SADDLE3 -> R.drawable.ic_bend_saddle3
    BendKind.KICK -> R.drawable.ic_bend_kick
    BendKind.KICK90 -> R.drawable.ic_bend_kick90
    BendKind.SEGMENTED -> R.drawable.ic_bend_segmented
    BendKind.SADDLE4 -> R.drawable.ic_bend_saddle4
    BendKind.ROLLING -> R.drawable.ic_bend_rolling
    BendKind.WIREFILL -> R.drawable.ic_bend_wirefill
}
