package com.bendpro.core

import org.junit.Assert.assertEquals
import org.junit.Test

class UnitsTest {

    @Test
    fun testFormatLengthGoldenCases() {
        // formatLength: 7.375 in → 7 3/8"
        assertEquals("7 3/8\"", formatLength(7.375, AppUnit.INCHES))

        // 30.5 ft-in → 2' 6 1/2"
        assertEquals("2' 6 1/2\"", formatLength(30.5, AppUnit.FEET_INCHES))

        // 12 ft-in → 1' 0"
        assertEquals("1' 0\"", formatLength(12.0, AppUnit.FEET_INCHES))

        // 7.375 mm → 187 mm
        assertEquals("187 mm", formatLength(7.375, AppUnit.MM))

        // 0.3125 in → 5/16"
        assertEquals("5/16\"", formatLength(0.3125, AppUnit.INCHES))

        // -2.5 in → -2 1/2"
        assertEquals("-2 1/2\"", formatLength(-2.5, AppUnit.INCHES))

        // 4.1875 mm, precision 3 → 106.362 mm
        assertEquals("106.362 mm", formatLength(4.1875, AppUnit.MM, 3))

        // NaN → —
        assertEquals("—", formatLength(Double.NaN, AppUnit.INCHES))
        assertEquals("—", formatLength(Double.POSITIVE_INFINITY, AppUnit.INCHES))

        // 11.99 ft-in → 1' 0" (deviation 3; the web app printed 12")
        assertEquals("1' 0\"", formatLength(11.99, AppUnit.FEET_INCHES))
    }

    @Test
    fun testMmRoundHalfUp() {
        // In JavaScript toFixed(0): (2.5).toFixed(0) === '3', (3.5).toFixed(0) === '4'
        // With banker's rounding 2.5 would round to 2 (even). Round-half-up rounds to 3.
        assertEquals("3 mm", formatLength(2.5 / 25.4, AppUnit.MM))
        assertEquals("4 mm", formatLength(3.5 / 25.4, AppUnit.MM))
    }

    @Test
    fun testToFraction() {
        assertEquals("7 3/8", toFraction(7.375))
        assertEquals("5/16", toFraction(0.3125))
        assertEquals("0", toFraction(0.03))
        assertEquals("3 1/2", toFraction(3.5))
    }

    @Test
    fun testParseToInches() {
        assertEquals(4.0, parseToInches("4", AppUnit.INCHES), 1e-9)
        assertEquals(4.5, parseToInches(" 4.5 ", AppUnit.FEET_INCHES), 1e-9)
        assertEquals(1.0, parseToInches("25.4", AppUnit.MM), 1e-9)
        assertEquals(0.0, parseToInches("", AppUnit.INCHES), 1e-9)
        assertEquals(0.0, parseToInches("abc", AppUnit.INCHES), 1e-9)
    }
}
