package com.bendpro.core

import java.math.BigDecimal
import java.math.RoundingMode

const val MM_PER_IN = 25.4

fun formatLength(valueIn: Double, unit: AppUnit, precision: Int = 2): String {
    if (!valueIn.isFinite()) return "—"
    val sign = if (valueIn < 0.0) "-" else ""
    val abs = Math.abs(valueIn)

    return when (unit) {
        AppUnit.MM -> {
            val mmVal = abs * MM_PER_IN
            val scale = if (precision == 2) 0 else precision
            // Use BigDecimal(Double) with HALF_UP to match JavaScript toFixed() round-half-up behavior on IEEE-754 doubles
            val formatted = BigDecimal(mmVal).setScale(scale, RoundingMode.HALF_UP).toPlainString()
            "$sign$formatted mm"
        }
        AppUnit.FEET_INCHES -> {
            var feet = Math.floor(abs / 12.0).toLong()
            val inches = abs - feet * 12.0
            var inchStr = toFraction(inches)
            // A9.3 ft-in carry fix: if inches part rounds up to 12, show {feet+1}' 0" instead of 12"
            if (inchStr == "12") {
                feet += 1
                inchStr = "0"
            }
            if (feet > 0) {
                "$sign$feet' $inchStr\""
            } else {
                "$sign$inchStr\""
            }
        }
        AppUnit.INCHES -> {
            "$sign${toFraction(abs)}\""
        }
    }
}

fun toFraction(value: Double): String {
    val whole = Math.floor(value).toLong()
    val frac = value - whole
    val sixteenths = Math.round(frac * 16.0).toInt()

    if (sixteenths == 0) return "$whole"
    if (sixteenths == 16) return "${whole + 1}"

    var num = sixteenths
    var den = 16
    while (num % 2 == 0 && den % 2 == 0) {
        num /= 2
        den /= 2
    }
    return if (whole > 0) "$whole $num/$den" else "$num/$den"
}

fun parseToInches(raw: String, unit: AppUnit): Double {
    val cleaned = raw.trim()
    if (cleaned.isEmpty()) return 0.0
    val n = cleaned.toDoubleOrNull() ?: return 0.0
    if (unit == AppUnit.MM) return n / MM_PER_IN
    return n
}
