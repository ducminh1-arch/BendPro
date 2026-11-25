package com.bendpro.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bendpro.core.BENDERS
import com.bendpro.core.Bender
import com.bendpro.core.tradeSizeLabel
import com.bendpro.ui.theme.Accent
import com.bendpro.ui.theme.AccentWash
import com.bendpro.ui.theme.BgPanel
import com.bendpro.ui.theme.Line
import com.bendpro.ui.theme.LineSoft
import com.bendpro.ui.theme.Metal400
import com.bendpro.ui.theme.PoppinsFontFamily
import com.bendpro.ui.theme.TextPrimary
import com.bendpro.ui.theme.TextSecondary

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun BenderPickerScreen(
    selectedId: String,
    onSelectBender: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text(
            text = "Select the bender you're working with. Centerline radius per shoe drives every calculation and QuickCheck result.",
            fontFamily = PoppinsFontFamily,
            fontSize = 13.sp,
            lineHeight = 19.5.sp,
            color = TextSecondary
        )

        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
            BENDERS.forEach { bender ->
                val isSelected = bender.id == selectedId
                BenderCard(
                    bender = bender,
                    isSelected = isSelected,
                    onClick = { onSelectBender(bender.id) }
                )
            }
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun BenderCard(
    bender: Bender,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    val borderColor = if (isSelected) Accent else LineSoft
    val bgColor = if (isSelected) AccentWash else BgPanel

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(bgColor)
            .border(1.dp, borderColor, RoundedCornerShape(16.dp))
            .clickable(
                role = Role.RadioButton,
                onClickLabel = "Select ${bender.brand} ${bender.model}",
                onClick = onClick
            )
            .padding(14.dp)
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = bender.brand,
                    fontFamily = PoppinsFontFamily,
                    fontSize = 15.sp,
                    letterSpacing = 0.3.sp,
                    color = TextPrimary
                )
                if (isSelected) {
                    Text(
                        text = "SELECTED",
                        fontFamily = PoppinsFontFamily,
                        fontWeight = FontWeight.Bold,
                        fontSize = 9.5.sp,
                        letterSpacing = 0.6.sp,
                        color = Accent
                    )
                }
            }

            Text(
                text = bender.model,
                fontFamily = PoppinsFontFamily,
                fontSize = 12.5.sp,
                color = TextSecondary
            )

            FlowRow(
                horizontalArrangement = Arrangement.spacedBy(6.dp),
                verticalArrangement = Arrangement.spacedBy(6.dp),
                modifier = Modifier.padding(top = 4.dp)
            ) {
                bender.conduitSizesIn.forEach { size ->
                    Box(
                        modifier = Modifier
                            .border(1.dp, Line, RoundedCornerShape(999.dp))
                            .padding(horizontal = 8.dp, vertical = 2.dp)
                    ) {
                        Text(
                            text = tradeSizeLabel(size),
                            fontFamily = FontFamily.Monospace,
                            fontSize = 10.5.sp,
                            color = Metal400
                        )
                    }
                }
            }
        }
    }
}
