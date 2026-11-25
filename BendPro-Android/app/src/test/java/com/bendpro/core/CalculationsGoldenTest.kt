package com.bendpro.core

import org.junit.Assert.assertEquals
import org.junit.Test

class CalculationsGoldenTest {

    private val klein = BENDERS.first { it.id == "klein-emt-standard" }
    private val greenlee = BENDERS.first { it.id == "greenlee-855" }
    private val eps = 1e-9

    @Test
    fun testOffsetGoldenRows() {
        // offset(30, 4, K, 0.75) -> distanceBetweenBends 8, travel 8, shrink 1.5, ok
        val res1 = calcOffset(30.0, 4.0, klein, 0.75)
        assertEquals(8.0, res1.distanceBetweenBendsIn, eps)
        assertEquals(8.0, res1.travelIn, eps)
        assertEquals(1.5, res1.shrinkIn, eps)
        assertEquals(FeasibilityLevel.OK, res1.feasibility.level)
        assertEquals("Marks 8.00\" apart · shrink 1.500\"", summarize(res1))

        // offset(10, 1, K, 1) -> distance 6, shrink 0.0625, ok
        val res2 = calcOffset(10.0, 1.0, klein, 1.0)
        assertEquals(6.0, res2.distanceBetweenBendsIn, eps)
        assertEquals(0.0625, res2.shrinkIn, eps)
        assertEquals(FeasibilityLevel.OK, res2.feasibility.level)

        // offset(45, 1, K, 0.75) -> distance 1.4, shrink 0.375, danger
        val res3 = calcOffset(45.0, 1.0, klein, 0.75)
        assertEquals(1.4, res3.distanceBetweenBendsIn, eps)
        assertEquals(0.375, res3.shrinkIn, eps)
        assertEquals(FeasibilityLevel.DANGER, res3.feasibility.level)

        // offset(22.5, 2, K, 0.75) -> distance 5.2, shrink 0.5, warn
        val res4 = calcOffset(22.5, 2.0, klein, 0.75)
        assertEquals(5.2, res4.distanceBetweenBendsIn, eps)
        assertEquals(0.5, res4.shrinkIn, eps)
        assertEquals(FeasibilityLevel.WARN, res4.feasibility.level)

        // offset(30, 2, K, 0.75) -> distance 4, shrink 0.75, danger
        val res5 = calcOffset(30.0, 2.0, klein, 0.75)
        assertEquals(4.0, res5.distanceBetweenBendsIn, eps)
        assertEquals(0.75, res5.shrinkIn, eps)
        assertEquals(FeasibilityLevel.DANGER, res5.feasibility.level)

        // offset(30, 3, K, 0.75) -> distance 6, shrink 1.125, warn
        val res6 = calcOffset(30.0, 3.0, klein, 0.75)
        assertEquals(6.0, res6.distanceBetweenBendsIn, eps)
        assertEquals(1.125, res6.shrinkIn, eps)
        assertEquals(FeasibilityLevel.WARN, res6.feasibility.level)
    }

    @Test
    fun testNinetyGoldenRows() {
        // ninety(0.75, 12) -> deduct 6, mark 6, ok
        val res1 = calcNinety(0.75, 12.0)
        assertEquals(6.0, res1.deductIn, eps)
        assertEquals(6.0, res1.markIn, eps)
        assertEquals(FeasibilityLevel.OK, res1.feasibility.level)
        assertEquals("Mark at 6.00\" · deduct 6\"", summarize(res1))

        // ninety(1, 9) -> deduct 8, mark 1, warn
        val res2 = calcNinety(1.0, 9.0)
        assertEquals(8.0, res2.deductIn, eps)
        assertEquals(1.0, res2.markIn, eps)
        assertEquals(FeasibilityLevel.WARN, res2.feasibility.level)

        // ninety(0.5, 4) -> deduct 5, mark −1, danger
        val res3 = calcNinety(0.5, 4.0)
        assertEquals(5.0, res3.deductIn, eps)
        assertEquals(-1.0, res3.markIn, eps)
        assertEquals(FeasibilityLevel.DANGER, res3.feasibility.level)
    }

    @Test
    fun testKickGoldenRows() {
        // kick(45, 6, K, 0.75) -> distanceToMark 8.4 (±1e-9), gain 2.25, ok
        val res1 = calcKick(45.0, 6.0, klein, 0.75)
        assertEquals(8.4, res1.distanceToMarkIn, eps)
        assertEquals(2.25, res1.gainIn, eps)
        assertEquals(FeasibilityLevel.OK, res1.feasibility.level)
        assertEquals("Mark at 8.40\" · gain 2.250\"", summarize(res1))

        // kick(45, 3, K, 0.75) -> distanceToMark 4.2, gain 1.125, warn
        val res2 = calcKick(45.0, 3.0, klein, 0.75)
        assertEquals(4.2, res2.distanceToMarkIn, eps)
        assertEquals(1.125, res2.gainIn, eps)
        assertEquals(FeasibilityLevel.WARN, res2.feasibility.level)

        // kick(60, 2, K, 0.75) -> distanceToMark 2.4, gain 0.5, danger
        val res3 = calcKick(60.0, 2.0, klein, 0.75)
        assertEquals(2.4, res3.distanceToMarkIn, eps)
        assertEquals(0.5, res3.gainIn, eps)
        assertEquals(FeasibilityLevel.DANGER, res3.feasibility.level)
    }

    @Test
    fun testSaddle3GoldenRows() {
        // saddle3(3, K, 0.75) -> centerToSide 7.5, totalGain 0.75, ok
        val res1 = calcSaddle3(3.0, klein, 0.75)
        assertEquals(7.5, res1.centerToSideIn, eps)
        assertEquals(0.75, res1.totalGainIn, eps)
        assertEquals(FeasibilityLevel.OK, res1.feasibility.level)
        assertEquals("Side bends 7.50\" from center · gain 0.750\"", summarize(res1))

        // saddle3(1, K, 0.75) -> centerToSide 2.5, totalGain 0.25, danger
        val res2 = calcSaddle3(1.0, klein, 0.75)
        assertEquals(2.5, res2.centerToSideIn, eps)
        assertEquals(0.25, res2.totalGainIn, eps)
        assertEquals(FeasibilityLevel.DANGER, res2.feasibility.level)
    }

    @Test
    fun testKick90GoldenRows() {
        // kick90(30, 4, 0.75, 18, K) -> kickMark 8, deduct 6, stubMark 12, ok
        val res1 = calcKick90(30.0, 4.0, 0.75, 18.0, klein)
        assertEquals(8.0, res1.kickMarkIn, eps)
        assertEquals(6.0, res1.deductIn, eps)
        assertEquals(12.0, res1.stubMarkIn, eps)
        assertEquals(FeasibilityLevel.OK, res1.feasibility.level)
        assertEquals("Kick mark 8.00\" from start · stub mark 12.00\" from end", summarize(res1))

        // kick90(45, 1, 0.75, 18, K) -> kickMark 1.4, stubMark 12, danger
        val res2 = calcKick90(45.0, 1.0, 0.75, 18.0, klein)
        assertEquals(1.4, res2.kickMarkIn, eps)
        assertEquals(12.0, res2.stubMarkIn, eps)
        assertEquals(FeasibilityLevel.DANGER, res2.feasibility.level)
    }

    @Test
    fun testSegmentedGoldenRows() {
        // segmented(90, 24, 6) -> anglePerShot 18, distanceBetweenShots 7.508854321931082, warn
        val res1 = calcSegmented(90.0, 24.0, 6)
        assertEquals(18.0, res1.anglePerShotDeg, eps)
        assertEquals(7.508854321931082, res1.distanceBetweenShotsIn, eps)
        assertEquals(FeasibilityLevel.WARN, res1.feasibility.level)
        assertEquals("6 shots at 18.0° · 7.51\" apart", summarize(res1))

        // segmented(90, 24, 8) -> anglePerShot 12.857142857142858, distance 5.374294852958777, ok
        val res2 = calcSegmented(90.0, 24.0, 8)
        assertEquals(12.857142857142858, res2.anglePerShotDeg, eps)
        assertEquals(5.374294852958777, res2.distanceBetweenShotsIn, eps)
        assertEquals(FeasibilityLevel.OK, res2.feasibility.level)

        // segmented(90, 24, 1) -> anglePerShot 90, danger
        val res3 = calcSegmented(90.0, 24.0, 1)
        assertEquals(90.0, res3.anglePerShotDeg, eps)
        assertEquals(FeasibilityLevel.DANGER, res3.feasibility.level)
    }

    @Test
    fun testSaddle4GoldenRows() {
        // saddle4(3, 8, G, 1) -> inner 8, outerFromInner 7.5, totalGain 0.75, ok
        val res1 = calcSaddle4(3.0, 8.0, greenlee, 1.0)
        assertEquals(8.0, res1.innerSpacingIn, eps)
        assertEquals(7.5, res1.outerFromInnerIn, eps)
        assertEquals(0.75, res1.totalGainIn, eps)
        assertEquals(FeasibilityLevel.OK, res1.feasibility.level)
        assertEquals("Inner 8.00\" apart · outer 7.50\" beyond each", summarize(res1))

        // saddle4(1, 8, K, 0.75) -> outerFromInner 2.5, totalGain 0.25, warn
        val res2 = calcSaddle4(1.0, 8.0, klein, 0.75)
        assertEquals(2.5, res2.outerFromInnerIn, eps)
        assertEquals(0.25, res2.totalGainIn, eps)
        assertEquals(FeasibilityLevel.WARN, res2.feasibility.level)
    }

    @Test
    fun testRollingGoldenRows() {
        // rolling(30, 6, 4, K, 0.75) -> trueOffset 7.211102550927978, rollAngle 33.690067525979785, distance 14.422205101855956, shrink 2.7041634565979917, ok
        val res1 = calcRollingOffset(30.0, 6.0, 4.0, klein, 0.75)
        assertEquals(7.211102550927978, res1.trueOffsetIn, eps)
        assertEquals(33.690067525979785, res1.rollAngleDeg, eps)
        assertEquals(14.422205101855956, res1.distanceBetweenBendsIn, eps)
        assertEquals(2.7041634565979917, res1.shrinkIn, eps)
        assertEquals(FeasibilityLevel.OK, res1.feasibility.level)
        assertEquals("True offset 7.21\" · roll 33.7° · marks 14.42\" apart", summarize(res1))

        // rolling(30, 0, 0, K, 0.75) -> all 0, danger
        val res2 = calcRollingOffset(30.0, 0.0, 0.0, klein, 0.75)
        assertEquals(0.0, res2.trueOffsetIn, eps)
        assertEquals(0.0, res2.distanceBetweenBendsIn, eps)
        assertEquals(0.0, res2.shrinkIn, eps)
        assertEquals(FeasibilityLevel.DANGER, res2.feasibility.level)
    }

    @Test
    fun testWirefillGoldenRows() {
        // wirefill(0.75, "12", 3) -> conduitArea 0.533, total 0.0399, max 40, fill 7.4859287054409, ok
        val res1 = calcWireFill(0.75, "12", 3)
        assertEquals(0.533, res1.conduitAreaSqIn, eps)
        assertEquals(0.0399, res1.totalConductorAreaSqIn, eps)
        assertEquals(40.0, res1.maxFillPct, eps)
        assertEquals(7.4859287054409, res1.fillPct, 1e-7)
        assertEquals(FeasibilityLevel.OK, res1.feasibility.level)
        assertEquals("3 × 12 AWG in 0.75\" EMT · 7.5% fill", summarize(res1))

        // wirefill(0.5, "12", 9) -> total 0.1197, fill 39.375, warn
        val res2 = calcWireFill(0.5, "12", 9)
        assertEquals(0.1197, res2.totalConductorAreaSqIn, eps)
        assertEquals(39.375, res2.fillPct, eps)
        assertEquals(FeasibilityLevel.WARN, res2.feasibility.level)

        // wirefill(0.5, "12", 10) -> total 0.133, fill 43.75, danger
        val res3 = calcWireFill(0.5, "12", 10)
        assertEquals(0.133, res3.totalConductorAreaSqIn, eps)
        assertEquals(43.75, res3.fillPct, eps)
        assertEquals(FeasibilityLevel.DANGER, res3.feasibility.level)

        // wirefill(0.5, "8", 2) -> max 31, fill 24.07894736842105, ok
        val res4 = calcWireFill(0.5, "8", 2)
        assertEquals(31.0, res4.maxFillPct, eps)
        assertEquals(24.07894736842105, res4.fillPct, eps)
        assertEquals(FeasibilityLevel.OK, res4.feasibility.level)

        // wirefill(1, "1", 5) -> fill 90.39351851851852, danger
        val res5 = calcWireFill(1.0, "1", 5)
        assertEquals(90.39351851851852, res5.fillPct, eps)
        assertEquals(FeasibilityLevel.DANGER, res5.feasibility.level)
    }
}
