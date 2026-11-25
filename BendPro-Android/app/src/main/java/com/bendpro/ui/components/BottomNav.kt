package com.bendpro.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bendpro.app.R
import com.bendpro.ui.theme.Accent
import com.bendpro.ui.theme.BgPanel
import com.bendpro.ui.theme.LineSoft
import com.bendpro.ui.theme.PoppinsFontFamily
import com.bendpro.ui.theme.TextTertiary

enum class ScreenTab(val label: String, val iconRes: Int) {
    BENDS("Bends", R.drawable.ic_nav_bends),
    HISTORY("History", R.drawable.ic_nav_history),
    SETTINGS("Settings", R.drawable.ic_nav_settings)
}

@Composable
fun BottomNav(
    activeTab: ScreenTab,
    onTabSelected: (ScreenTab) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(BgPanel)
            .navigationBarsPadding()
    ) {
        HorizontalDivider(thickness = 1.dp, color = LineSoft)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(64.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            ScreenTab.entries.forEach { tab ->
                val isActive = tab == activeTab
                val tint = if (isActive) Accent else TextTertiary
                val interactionSource = remember { MutableInteractionSource() }

                Box(
                    modifier = Modifier
                        .weight(1f)
                        .height(64.dp)
                        .clickable(
                            interactionSource = interactionSource,
                            indication = null,
                            role = Role.Tab,
                            onClickLabel = "Switch to ${tab.label} tab"
                        ) { onTabSelected(tab) },
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(3.dp)
                    ) {
                        Icon(
                            painter = painterResource(id = tab.iconRes),
                            contentDescription = null,
                            tint = tint,
                            modifier = Modifier.size(21.dp)
                        )
                        Text(
                            text = tab.label,
                            color = tint,
                            fontFamily = PoppinsFontFamily,
                            fontSize = 10.5.sp,
                            letterSpacing = 0.2.sp
                        )
                    }
                }
            }
        }
    }
}
