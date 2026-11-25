package com.bendpro.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val DarkColorScheme = darkColorScheme(
    primary = Accent,
    onPrimary = TextPrimary,
    primaryContainer = BgPanelRaised,
    onPrimaryContainer = TextPrimary,
    secondary = AccentDim,
    onSecondary = TextPrimary,
    background = BgVoid,
    onBackground = TextPrimary,
    surface = BgPanel,
    onSurface = TextPrimary,
    surfaceVariant = BgPanelRaised,
    onSurfaceVariant = TextSecondary,
    outline = Line,
    outlineVariant = LineSoft
)

@Composable
fun BendProTheme(
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = DarkColorScheme,
        typography = AppTypography,
        shapes = AppShapes,
        content = content
    )
}
