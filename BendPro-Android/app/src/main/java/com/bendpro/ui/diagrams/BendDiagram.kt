package com.bendpro.ui.diagrams

import android.graphics.Paint
import android.graphics.Typeface
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.unit.dp
import com.bendpro.core.BendResult
import com.bendpro.core.Feasibility
import com.bendpro.core.FeasibilityLevel
import com.bendpro.core.Kick90Result
import com.bendpro.core.KickResult
import com.bendpro.core.NinetyResult
import com.bendpro.core.OffsetResult
import com.bendpro.core.RollingOffsetResult
import com.bendpro.core.Saddle3Result
import com.bendpro.core.Saddle4Result
import com.bendpro.core.SegmentedResult
import com.bendpro.core.WireFillResult
import com.bendpro.ui.theme.Accent
import com.bendpro.ui.theme.BgPanel
import com.bendpro.ui.theme.ColorDanger
import com.bendpro.ui.theme.ColorOk
import com.bendpro.ui.theme.ColorWarn
import com.bendpro.ui.theme.LineSoft
import com.bendpro.ui.theme.Metal200
import com.bendpro.ui.theme.TextSecondary
import com.bendpro.ui.theme.TextTertiary
import java.util.Locale
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin

fun feasibilityColor(feasibility: Feasibility): Color = when (feasibility.level) {
    FeasibilityLevel.OK -> ColorOk
    FeasibilityLevel.WARN -> ColorWarn
    FeasibilityLevel.DANGER -> ColorDanger
}

private fun formatNumber(value: Double, decimals: Int): String {
    return String.format(Locale.US, "%.${decimals}f", value)
}

private fun formatAngleNumber(angle: Double): String {
    return if (angle % 1.0 == 0.0) angle.toInt().toString() else angle.toString()
}

@Composable
fun BendDiagram(
    result: BendResult,
    modifier: Modifier = Modifier
) {
    val statusColor = feasibilityColor(result.feasibility)

    Box(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(BgPanel)
            .border(1.dp, LineSoft, RoundedCornerShape(16.dp))
            .padding(12.dp)
            .aspectRatio(16f / 10f)
    ) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            val scale = size.width / 320f
            val offsetY = (size.height - 200f * scale) / 2f

            drawDiagram(
                result = result,
                statusColor = statusColor,
                scale = scale,
                offsetY = offsetY
            )
        }
    }
}

private fun DrawScope.drawDimLine(
    x1: Float,
    y1: Float,
    x2: Float,
    y2: Float,
    label: String,
    scale: Float,
    offsetY: Float
) {
    val sx1 = x1 * scale
    val sy1 = y1 * scale + offsetY
    val sx2 = x2 * scale
    val sy2 = y2 * scale + offsetY

    val dashEffect = PathEffect.dashPathEffect(floatArrayOf(3f * scale, 3f * scale), 0f)

    // Dashed connecting line
    drawLine(
        color = TextTertiary,
        start = Offset(sx1, sy1),
        end = Offset(sx2, sy2),
        strokeWidth = 1f * scale,
        pathEffect = dashEffect
    )

    // Perpendicular ticks
    if (x1 == x2) {
        // Vertical dim line
        drawLine(
            color = TextTertiary,
            start = Offset(sx1 - 4f * scale, sy1),
            end = Offset(sx1 + 4f * scale, sy1),
            strokeWidth = 1f * scale
        )
        drawLine(
            color = TextTertiary,
            start = Offset(sx2 - 4f * scale, sy2),
            end = Offset(sx2 + 4f * scale, sy2),
            strokeWidth = 1f * scale
        )
    } else {
        // Horizontal or angled dim line
        drawLine(
            color = TextTertiary,
            start = Offset(sx1, sy1 - 4f * scale),
            end = Offset(sx1, sy1 + 4f * scale),
            strokeWidth = 1f * scale
        )
        drawLine(
            color = TextTertiary,
            start = Offset(sx2, sy2 - 4f * scale),
            end = Offset(sx2, sy2 + 4f * scale),
            strokeWidth = 1f * scale
        )
    }

    // Text label
    val midX = (sx1 + sx2) / 2f
    val midY = (sy1 + sy2) / 2f - 8f * scale

    val paint = Paint().apply {
        color = TextSecondary.toArgb()
        textSize = 11f * scale
        typeface = Typeface.MONOSPACE
        textAlign = Paint.Align.CENTER
        isAntiAlias = true
    }

    drawContext.canvas.nativeCanvas.drawText(label, midX, midY, paint)
}

private fun DrawScope.drawCanvasText(
    text: String,
    x: Float,
    y: Float,
    scale: Float,
    offsetY: Float,
    color: Color = TextTertiary,
    fontSize: Float = 10f,
    align: Paint.Align = Paint.Align.LEFT
) {
    val paint = Paint().apply {
        this.color = color.toArgb()
        this.textSize = fontSize * scale
        this.typeface = Typeface.MONOSPACE
        this.textAlign = align
        this.isAntiAlias = true
    }
    drawContext.canvas.nativeCanvas.drawText(text, x * scale, y * scale + offsetY, paint)
}

private fun DrawScope.drawPolyline(
    points: List<Pair<Float, Float>>,
    color: Color,
    strokeWidth: Float,
    scale: Float,
    offsetY: Float
) {
    if (points.size < 2) return
    val path = Path().apply {
        moveTo(points[0].first * scale, points[0].second * scale + offsetY)
        for (i in 1 until points.size) {
            lineTo(points[i].first * scale, points[i].second * scale + offsetY)
        }
    }
    drawPath(
        path = path,
        color = color,
        style = Stroke(
            width = strokeWidth * scale,
            cap = StrokeCap.Round,
            join = StrokeJoin.Round
        )
    )
}

private fun DrawScope.drawDiagram(
    result: BendResult,
    statusColor: Color,
    scale: Float,
    offsetY: Float
) {
    when (result) {
        is OffsetResult -> {
            val rise = 60f
            val runL = 60f
            val runR = 60f
            val midRun = 100f
            val x0 = 40f
            val y0 = 150f
            val x1 = x0 + runL
            val y1 = y0
            val x2 = x1 + midRun
            val y2 = y1 - rise
            val x3 = x2 + runR
            val y3 = y2

            val points = listOf(x0 to y0, x1 to y1, x2 to y2, x3 to y3)
            // Pipe stroke
            drawPolyline(points, Metal200, 6f, scale, offsetY)
            // Overlay stroke
            drawPolyline(points, statusColor, 2f, scale, offsetY)

            // Bend point circles
            drawCircle(statusColor, radius = 3.5f * scale, center = Offset(x1 * scale, y1 * scale + offsetY))
            drawCircle(statusColor, radius = 3.5f * scale, center = Offset(x2 * scale, y2 * scale + offsetY))

            // Dimension line
            drawDimLine(x1, y1 + 20f, x2, y2 + 20f + rise, "${formatNumber(result.distanceBetweenBendsIn, 2)}\"", scale, offsetY)

            // Angle labels
            drawCanvasText("${formatAngleNumber(result.angleDeg)}°", x1 - 6f, y0 + 36f, scale, offsetY)
            drawCanvasText("${formatAngleNumber(result.angleDeg)}°", x2 + 4f, y2 + 36f, scale, offsetY)
        }

        is NinetyResult -> {
            val x0 = 60f
            val y0 = 40f
            val stubLen = 90f
            val runLen = 140f
            val x1 = x0
            val y1 = y0 + stubLen
            val x2 = x1 + runLen
            val y2 = y1
            val markY = y1 - min(max(result.markIn.toFloat() * 5f, 10f), stubLen - 6f)

            val points = listOf(x0 to y0, x1 to y1, x2 to y2)
            drawPolyline(points, Metal200, 6f, scale, offsetY)
            drawPolyline(points, statusColor, 2f, scale, offsetY)

            drawCircle(statusColor, radius = 3.5f * scale, center = Offset(x1 * scale, y1 * scale + offsetY))

            // Accent mark tick
            drawLine(
                color = Accent,
                start = Offset((x0 - 14f) * scale, markY * scale + offsetY),
                end = Offset((x0 + 14f) * scale, markY * scale + offsetY),
                strokeWidth = 2f * scale
            )
            drawCanvasText("mark", x0 + 20f, markY + 4f, scale, offsetY, color = Accent)

            // Dimension line
            drawDimLine(x0 - 26f, y0, x0 - 26f, y1, "${formatNumber(result.stubHeightIn, 1)}\"", scale, offsetY)
        }

        is KickResult -> {
            val x0 = 40f
            val y0 = 150f
            val runL = 90f
            val x1 = x0 + runL
            val y1 = y0
            val angRad = (result.angleDeg * Math.PI) / 180.0
            val legLen = 110.0
            val x2 = (x1 + legLen * cos(angRad)).toFloat()
            val y2 = (y1 - legLen * sin(angRad)).toFloat()

            val points = listOf(x0 to y0, x1 to y1, x2 to y2)
            drawPolyline(points, Metal200, 6f, scale, offsetY)
            drawPolyline(points, statusColor, 2f, scale, offsetY)

            drawCircle(statusColor, radius = 3.5f * scale, center = Offset(x1 * scale, y1 * scale + offsetY))

            // Dashed baseline extension
            drawLine(
                color = TextTertiary,
                start = Offset(x1 * scale, y1 * scale + offsetY),
                end = Offset((x1 + 40f) * scale, y1 * scale + offsetY),
                strokeWidth = 1f * scale,
                pathEffect = PathEffect.dashPathEffect(floatArrayOf(2f * scale, 3f * scale), 0f)
            )

            drawCanvasText("${formatAngleNumber(result.angleDeg)}°", x1 + 6f, y1 - 6f, scale, offsetY)
            drawDimLine(x0, y0 + 20f, x1, y0 + 20f, "${formatNumber(result.distanceToMarkIn, 2)}\"", scale, offsetY)
        }

        is Saddle3Result -> {
            val x0 = 30f
            val y0 = 150f
            val runL = 60f
            val rise = 40f
            val x1 = x0 + runL
            val y1 = y0
            val x2 = x1 + 40f
            val y2 = y1 - rise
            val x3 = x2 + 40f
            val y3 = y2
            val x4 = x3 + 40f
            val y4 = y0
            val x5 = x4 + 40f
            val y5 = y0

            val points = listOf(x0 to y0, x1 to y1, x2 to y2, x3 to y3, x4 to y4, x5 to y5)
            drawPolyline(points, Metal200, 6f, scale, offsetY)
            drawPolyline(points, statusColor, 2f, scale, offsetY)

            drawCircle(statusColor, radius = 3f * scale, center = Offset(x1 * scale, y1 * scale + offsetY))
            drawCircle(statusColor, radius = 3f * scale, center = Offset(x2 * scale, y2 * scale + offsetY))
            drawCircle(statusColor, radius = 3f * scale, center = Offset(x4 * scale, y4 * scale + offsetY))

            drawDimLine(x1, y1 + 18f, x2, y1 + 18f, "${formatNumber(result.centerToSideIn, 1)}\"", scale, offsetY)
            drawCanvasText("${formatNumber(result.depthIn, 1)}\"", (x2 + x3) / 2f - 10f, y2 - 10f, scale, offsetY)
        }

        is Kick90Result -> {
            val x0 = 40f
            val y0 = 150f
            val angRad = (result.angleDeg * Math.PI) / 180.0
            val kickLeg = 70.0
            val x1 = (x0 + kickLeg * cos(angRad)).toFloat()
            val y1 = (y0 - kickLeg * sin(angRad)).toFloat()
            val runLen = 90f
            val x2 = x1 + runLen
            val y2 = y1
            val stubLen = 60f
            val x3 = x2
            val y3 = y2 - stubLen

            val points = listOf(x0 to y0, x1 to y1, x2 to y2, x3 to y3)
            drawPolyline(points, Metal200, 6f, scale, offsetY)
            drawPolyline(points, statusColor, 2f, scale, offsetY)

            drawCircle(statusColor, radius = 3.5f * scale, center = Offset(x0 * scale, y0 * scale + offsetY))
            drawCircle(statusColor, radius = 3.5f * scale, center = Offset(x2 * scale, y2 * scale + offsetY))

            drawCanvasText("${formatAngleNumber(result.angleDeg)}°", x0 + 4f, y0 - 10f, scale, offsetY)
            drawCanvasText("90°", x2 + 6f, y2 + 14f, scale, offsetY)
            drawDimLine(x0, y0 + 20f, x1, y0 + 20f, "${formatNumber(result.kickMarkIn, 2)}\"", scale, offsetY)
            drawCanvasText("${formatNumber(result.stubMarkIn, 2)}\"", x2 + 8f, (y2 + y3) / 2f, scale, offsetY, color = TextSecondary)
        }

        is SegmentedResult -> {
            val cx = 40f
            val cy = 165f
            val r = 100f
            val n = max(2, result.shots)
            val pts = mutableListOf<Pair<Float, Float>>()
            for (i in 0 until n) {
                val a = ((result.totalAngleDeg * i) / (n - 1)) * (Math.PI / 180.0)
                pts.add((cx + r * sin(a)).toFloat() to (cy - r * (1.0 - cos(a))).toFloat())
            }

            drawPolyline(pts, Metal200, 6f, scale, offsetY)
            drawPolyline(pts, statusColor, 2f, scale, offsetY)

            for (pt in pts) {
                drawCircle(statusColor, radius = 3f * scale, center = Offset(pt.first * scale, pt.second * scale + offsetY))
            }

            drawCanvasText("${formatAngleNumber(result.totalAngleDeg)}° sweep", 220f, 30f, scale, offsetY)
            drawCanvasText("$n shots", 220f, 44f, scale, offsetY)
        }

        is Saddle4Result -> {
            val x0 = 20f
            val y0 = 150f
            val runL = 45f
            val rise = 40f
            val flat = 40f
            val x1 = x0 + runL
            val y1 = y0
            val x2 = x1 + 35f
            val y2 = y1 - rise
            val x3 = x2 + flat
            val y3 = y2
            val x4 = x3 + 35f
            val y4 = y0
            val x5 = x4 + runL
            val y5 = y0

            val points = listOf(x0 to y0, x1 to y1, x2 to y2, x3 to y3, x4 to y4, x5 to y5)
            drawPolyline(points, Metal200, 6f, scale, offsetY)
            drawPolyline(points, statusColor, 2f, scale, offsetY)

            drawCircle(statusColor, radius = 3f * scale, center = Offset(x1 * scale, y1 * scale + offsetY))
            drawCircle(statusColor, radius = 3f * scale, center = Offset(x2 * scale, y2 * scale + offsetY))
            drawCircle(statusColor, radius = 3f * scale, center = Offset(x3 * scale, y3 * scale + offsetY))
            drawCircle(statusColor, radius = 3f * scale, center = Offset(x4 * scale, y4 * scale + offsetY))

            drawDimLine(x2, y2 - 16f, x3, y3 - 16f, "${formatNumber(result.innerSpacingIn, 1)}\"", scale, offsetY)
            drawDimLine(x1, y1 + 18f, x2, y1 + 18f, "${formatNumber(result.outerFromInnerIn, 1)}\"", scale, offsetY)
            drawCanvasText("${formatNumber(result.depthIn, 1)}\" deep", (x2 + x3) / 2f - 8f, y2 - 26f, scale, offsetY)
        }

        is RollingOffsetResult -> {
            val rise = 60f
            val runL = 55f
            val runR = 55f
            val midRun = 90f
            val x0 = 40f
            val y0 = 150f
            val x1 = x0 + runL
            val y1 = y0
            val x2 = x1 + midRun
            val y2 = y1 - rise
            val x3 = x2 + runR
            val y3 = y2

            val points = listOf(x0 to y0, x1 to y1, x2 to y2, x3 to y3)
            drawPolyline(points, Metal200, 6f, scale, offsetY)
            drawPolyline(points, statusColor, 2f, scale, offsetY)

            drawCircle(statusColor, radius = 3.5f * scale, center = Offset(x1 * scale, y1 * scale + offsetY))
            drawCircle(statusColor, radius = 3.5f * scale, center = Offset(x2 * scale, y2 * scale + offsetY))

            drawDimLine(x1, y1 + 20f, x2, y2 + 20f + rise, "${formatNumber(result.distanceBetweenBendsIn, 2)}\"", scale, offsetY)

            drawCanvasText("${formatAngleNumber(result.angleDeg)}°", x1 - 6f, y0 + 36f, scale, offsetY)
            drawCanvasText("roll ${formatNumber(result.rollAngleDeg, 0)}°", 220f, 30f, scale, offsetY, color = Accent)
            drawCanvasText("true ${formatNumber(result.trueOffsetIn, 1)}\"", 220f, 44f, scale, offsetY)
        }

        is WireFillResult -> {
            val barX = 30f
            val barY = 90f
            val barW = 260f
            val barH = 26f
            val fillW = min(barW, (max(0.0, result.fillPct) / 100.0 * barW).toFloat())
            val limitX = barX + (result.maxFillPct.toFloat() / 100f) * barW

            // Background bar
            drawRoundRect(
                color = Color(0xFF1C2128),
                topLeft = Offset(barX * scale, barY * scale + offsetY),
                size = androidx.compose.ui.geometry.Size(barW * scale, barH * scale),
                cornerRadius = androidx.compose.ui.geometry.CornerRadius(6f * scale, 6f * scale)
            )
            drawRoundRect(
                color = TextTertiary,
                topLeft = Offset(barX * scale, barY * scale + offsetY),
                size = androidx.compose.ui.geometry.Size(barW * scale, barH * scale),
                cornerRadius = androidx.compose.ui.geometry.CornerRadius(6f * scale, 6f * scale),
                style = Stroke(width = 1f * scale)
            )

            // Fill bar
            if (fillW > 0) {
                drawRoundRect(
                    color = statusColor.copy(alpha = 0.85f),
                    topLeft = Offset(barX * scale, barY * scale + offsetY),
                    size = androidx.compose.ui.geometry.Size(fillW * scale, barH * scale),
                    cornerRadius = androidx.compose.ui.geometry.CornerRadius(6f * scale, 6f * scale)
                )
            }

            // Limit line
            drawLine(
                color = TextSecondary,
                start = Offset(limitX * scale, (barY - 8f) * scale + offsetY),
                end = Offset(limitX * scale, (barY + barH + 8f) * scale + offsetY),
                strokeWidth = 1.5f * scale,
                pathEffect = PathEffect.dashPathEffect(floatArrayOf(3f * scale, 3f * scale), 0f)
            )

            drawCanvasText("max ${result.maxFillPct.toInt()}%", limitX - 16f, barY - 12f, scale, offsetY, color = TextSecondary)
            drawCanvasText("${formatNumber(result.fillPct, 1)}% conduit fill", barX + barW / 2f - 40f, barY + barH + 20f, scale, offsetY)
        }
    }
}
