package com.bendpro.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
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
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bendpro.app.R
import com.bendpro.core.Feasibility
import com.bendpro.core.FeasibilityLevel
import com.bendpro.ui.theme.ColorDanger
import com.bendpro.ui.theme.ColorDangerWash
import com.bendpro.ui.theme.ColorOk
import com.bendpro.ui.theme.ColorOkWash
import com.bendpro.ui.theme.ColorWarn
import com.bendpro.ui.theme.ColorWarnWash
import com.bendpro.ui.theme.PoppinsFontFamily

@Composable
fun StatusPill(
    feasibility: Feasibility,
    modifier: Modifier = Modifier
) {
    val (bgColor, fgColor, text) = when (feasibility.level) {
        FeasibilityLevel.OK -> Triple(ColorOkWash, ColorOk, "VALID")
        FeasibilityLevel.WARN -> Triple(ColorWarnWash, ColorWarn, "CHECK CLOSELY")
        FeasibilityLevel.DANGER -> Triple(ColorDangerWash, ColorDanger, "NOT POSSIBLE")
    }

    Row(
        modifier = modifier
            .semantics { contentDescription = feasibility.message }
            .clip(RoundedCornerShape(999.dp))
            .background(bgColor)
            .padding(horizontal = 14.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        Icon(
            painter = painterResource(
                id = if (feasibility.level == FeasibilityLevel.OK) R.drawable.ic_check else R.drawable.ic_alert
            ),
            contentDescription = null,
            tint = fgColor,
            modifier = Modifier.size(14.dp)
        )

        Text(
            text = text,
            fontFamily = PoppinsFontFamily,
            fontWeight = FontWeight.Bold,
            fontSize = 12.sp,
            letterSpacing = 0.04.sp,
            color = fgColor
        )
    }
}
