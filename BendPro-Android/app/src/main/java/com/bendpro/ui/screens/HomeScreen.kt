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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bendpro.app.R
import com.bendpro.core.BendKind
import com.bendpro.ui.theme.Accent
import com.bendpro.ui.theme.AccentWash
import com.bendpro.ui.theme.BgPanel
import com.bendpro.ui.theme.LineSoft
import com.bendpro.ui.theme.PoppinsFontFamily
import com.bendpro.ui.theme.TextPrimary
import com.bendpro.ui.theme.TextTertiary

data class HomeCardItem(
    val kind: BendKind,
    val title: String,
    val sub: String,
    val iconRes: Int
)

val CORE_BENDS = listOf(
    HomeCardItem(
        kind = BendKind.OFFSET,
        title = "Offset",
        sub = "Two bends to clear an obstacle vertically",
        iconRes = R.drawable.ic_bend_offset
    ),
    HomeCardItem(
        kind = BendKind.NINETY,
        title = "90° Bend",
        sub = "Stub-up from floor or wall",
        iconRes = R.drawable.ic_bend_ninety
    ),
    HomeCardItem(
        kind = BendKind.SADDLE3,
        title = "3-Point Saddle",
        sub = "Over a round or square obstruction",
        iconRes = R.drawable.ic_bend_saddle3
    ),
    HomeCardItem(
        kind = BendKind.KICK,
        title = "Kick",
        sub = "Single angled bend",
        iconRes = R.drawable.ic_bend_kick
    )
)

val ADVANCED_BENDS = listOf(
    HomeCardItem(
        kind = BendKind.KICK90,
        title = "Kick + 90°",
        sub = "Kick with a stub-up at the end",
        iconRes = R.drawable.ic_bend_kick90
    ),
    HomeCardItem(
        kind = BendKind.SEGMENTED,
        title = "Multi-Shot",
        sub = "Segmented bend for large radius",
        iconRes = R.drawable.ic_bend_segmented
    ),
    HomeCardItem(
        kind = BendKind.SADDLE4,
        title = "4-Point Saddle",
        sub = "Flat-topped, wide obstruction",
        iconRes = R.drawable.ic_bend_saddle4
    ),
    HomeCardItem(
        kind = BendKind.ROLLING,
        title = "Rolling Offset",
        sub = "Offset across two planes",
        iconRes = R.drawable.ic_bend_rolling
    )
)

val TOOL_BENDS = listOf(
    HomeCardItem(
        kind = BendKind.WIREFILL,
        title = "Wire Fill",
        sub = "Conduit fill % vs NEC limit",
        iconRes = R.drawable.ic_bend_wirefill
    )
)

@Composable
fun HomeScreen(
    onSelectKind: (BendKind) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        HomeSection(title = "Core Bends", items = CORE_BENDS, onSelectKind = onSelectKind)
        HomeSection(title = "Advanced Bends", items = ADVANCED_BENDS, onSelectKind = onSelectKind)
        HomeSection(title = "Tools", items = TOOL_BENDS, onSelectKind = onSelectKind)
    }
}

@Composable
private fun HomeSection(
    title: String,
    items: List<HomeCardItem>,
    onSelectKind: (BendKind) -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Text(
            text = title,
            fontFamily = PoppinsFontFamily,
            fontWeight = FontWeight.SemiBold,
            fontSize = 11.sp,
            letterSpacing = 1.1.sp,
            color = TextTertiary,
            modifier = Modifier.padding(start = 2.dp)
        )

        // 2-column grid chunked
        items.chunked(2).forEach { rowItems ->
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                rowItems.forEach { item ->
                    Box(modifier = Modifier.weight(1f)) {
                        BendCard(item = item, onClick = { onSelectKind(item.kind) })
                    }
                }
                if (rowItems.size == 1) {
                    Box(modifier = Modifier.weight(1f))
                }
            }
        }
    }
}

@Composable
private fun BendCard(
    item: HomeCardItem,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = 108.dp)
            .clip(RoundedCornerShape(16.dp))
            .background(BgPanel)
            .border(1.dp, LineSoft, RoundedCornerShape(16.dp))
            .clickable(onClick = onClick)
            .padding(14.dp)
    ) {
        Column(
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(34.dp)
                    .clip(RoundedCornerShape(9.dp))
                    .background(AccentWash),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    painter = painterResource(id = item.iconRes),
                    contentDescription = null,
                    tint = Accent,
                    modifier = Modifier.size(18.dp)
                )
            }

            Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                Text(
                    text = item.title,
                    fontFamily = PoppinsFontFamily,
                    fontWeight = FontWeight.Medium,
                    fontSize = 14.5.sp,
                    color = TextPrimary
                )
                Text(
                    text = item.sub,
                    fontFamily = PoppinsFontFamily,
                    fontSize = 11.sp,
                    lineHeight = 15.sp,
                    color = TextTertiary
                )
            }
        }
    }
}
