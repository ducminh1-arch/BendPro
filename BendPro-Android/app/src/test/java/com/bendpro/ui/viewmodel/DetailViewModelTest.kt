package com.bendpro.ui.viewmodel

import com.bendpro.core.AppUnit
import com.bendpro.core.BENDERS
import com.bendpro.core.BendKind
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

class DetailViewModelTest {

    private lateinit var viewModel: DetailViewModel
    private val kleinBender = BENDERS.first { it.id == "klein-emt-standard" }
    private val greenleeBender = BENDERS.first { it.id == "greenlee-855" }
    private val itoolcoBender = BENDERS.first { it.id == "itoolco-mega-1-1.5" }

    @Before
    fun setUp() {
        viewModel = DetailViewModel()
    }

    @Test
    fun testDefaultsMatchSpecA5() {
        // Offset
        val offset = viewModel.getState(BendKind.OFFSET)
        assertEquals(4.0, offset.offsetIn, 1e-9)
        assertEquals(30.0, offset.angleDeg, 1e-9)
        assertEquals(0.75, offset.tradeSizeIn, 1e-9)

        // Ninety
        val ninety = viewModel.getState(BendKind.NINETY)
        assertEquals(12.0, ninety.stubHeightIn, 1e-9)
        assertEquals(0.75, ninety.tradeSizeIn, 1e-9)

        // Kick
        val kick = viewModel.getState(BendKind.KICK)
        assertEquals(6.0, kick.riseIn, 1e-9)
        assertEquals(30.0, kick.angleDeg, 1e-9)
        assertEquals(0.75, kick.tradeSizeIn, 1e-9)

        // Saddle3
        val saddle3 = viewModel.getState(BendKind.SADDLE3)
        assertEquals(3.0, saddle3.depthIn, 1e-9)
        assertEquals(0.75, saddle3.tradeSizeIn, 1e-9)

        // Kick90
        val kick90 = viewModel.getState(BendKind.KICK90)
        assertEquals(4.0, kick90.kickOffsetIn, 1e-9)
        assertEquals(18.0, kick90.kick90StubIn, 1e-9)
        assertEquals(30.0, kick90.angleDeg, 1e-9)
        assertEquals(0.75, kick90.tradeSizeIn, 1e-9)

        // Segmented
        val segmented = viewModel.getState(BendKind.SEGMENTED)
        assertEquals(90.0, segmented.totalAngleDeg, 1e-9)
        assertEquals(24.0, segmented.radiusIn, 1e-9)
        assertEquals(6, segmented.shots)

        // Saddle4
        val saddle4 = viewModel.getState(BendKind.SADDLE4)
        assertEquals(3.0, saddle4.depthIn, 1e-9)
        assertEquals(8.0, saddle4.obstructionWidthIn, 1e-9)
        assertEquals(0.75, saddle4.tradeSizeIn, 1e-9)

        // Rolling
        val rolling = viewModel.getState(BendKind.ROLLING)
        assertEquals(6.0, rolling.rollingVerticalIn, 1e-9)
        assertEquals(4.0, rolling.rollingHorizontalIn, 1e-9)
        assertEquals(30.0, rolling.angleDeg, 1e-9)
        assertEquals(0.75, rolling.tradeSizeIn, 1e-9)

        // Wirefill
        val wirefill = viewModel.getState(BendKind.WIREFILL)
        assertEquals(0.75, wirefill.wireConduitSizeIn, 1e-9)
        assertEquals("12", wirefill.wireAwg)
        assertEquals(3, wirefill.wireCount)
    }

    @Test
    fun testLifecycleLeavingDetailResetsInputsAndRoundTripKeepsThem() {
        // User opens Offset and edits rise from 4 to 10
        assertEquals(4.0, viewModel.getState(BendKind.OFFSET).offsetIn, 1e-9)
        viewModel.setOffset(BendKind.OFFSET, 10.0)
        assertEquals(10.0, viewModel.getState(BendKind.OFFSET).offsetIn, 1e-9)

        // User goes to Bender Picker and returns (round trip): inputs are preserved
        viewModel.clampTradeSize(kleinBender, BendKind.OFFSET)
        assertEquals(10.0, viewModel.getState(BendKind.OFFSET).offsetIn, 1e-9)

        // User leaves Detail screen back to Home: inputs reset to A5 defaults
        viewModel.resetToDefaults(BendKind.OFFSET)
        assertEquals(4.0, viewModel.getState(BendKind.OFFSET).offsetIn, 1e-9)

        // Same for Kick (default rise is 6)
        assertEquals(6.0, viewModel.getState(BendKind.KICK).riseIn, 1e-9)
        viewModel.setRise(BendKind.KICK, 14.0)
        assertEquals(14.0, viewModel.getState(BendKind.KICK).riseIn, 1e-9)

        // Round trip to bender picker keeps inputs
        viewModel.clampTradeSize(kleinBender, BendKind.KICK)
        assertEquals(14.0, viewModel.getState(BendKind.KICK).riseIn, 1e-9)

        // Leaving Detail screen resets
        viewModel.resetToDefaults(BendKind.KICK)
        assertEquals(6.0, viewModel.getState(BendKind.KICK).riseIn, 1e-9)
    }

    @Test
    fun testOffsetSaveSummary() {
        viewModel.setAngle(BendKind.OFFSET, 30.0)
        viewModel.setOffset(BendKind.OFFSET, 4.0)
        viewModel.setTradeSize(BendKind.OFFSET, 0.75)

        val entry = viewModel.saveHistoryEntry(BendKind.OFFSET, AppUnit.INCHES, kleinBender)
        assertEquals("30° Offset", entry.label)
        assertEquals("Offset 4\" · 3/4\"", entry.inputSummary)
        assertEquals("Marks 8.00\" apart · shrink 1.500\"", entry.resultSummary)
    }

    @Test
    fun testNinetySaveSummary() {
        viewModel.setStubHeight(BendKind.NINETY, 12.0)
        viewModel.setTradeSize(BendKind.NINETY, 0.75)

        val entry = viewModel.saveHistoryEntry(BendKind.NINETY, AppUnit.INCHES, kleinBender)
        assertEquals("90° Bend", entry.label)
        assertEquals("Stub 12\" · 3/4\"", entry.inputSummary)
        assertEquals("Mark at 6.00\" · deduct 6\"", entry.resultSummary)
    }

    @Test
    fun testKickSaveSummary() {
        viewModel.setAngle(BendKind.KICK, 45.0)
        viewModel.setRise(BendKind.KICK, 6.0)
        viewModel.setTradeSize(BendKind.KICK, 0.75)

        val entry = viewModel.saveHistoryEntry(BendKind.KICK, AppUnit.INCHES, kleinBender)
        assertEquals("45° Kick", entry.label)
        assertEquals("Rise 6\" · 3/4\"", entry.inputSummary)
        assertEquals("Mark at 8.40\" · gain 2.250\"", entry.resultSummary)
    }

    @Test
    fun testSaddle3SaveSummary() {
        viewModel.setDepth(BendKind.SADDLE3, 3.0)
        viewModel.setTradeSize(BendKind.SADDLE3, 0.75)

        val entry = viewModel.saveHistoryEntry(BendKind.SADDLE3, AppUnit.INCHES, kleinBender)
        assertEquals("3-Point Saddle", entry.label)
        assertEquals("Depth 3\" · 3/4\"", entry.inputSummary)
        assertEquals("Side bends 7.50\" from center · gain 0.750\"", entry.resultSummary)
    }

    @Test
    fun testKick90SaveSummary() {
        // kick90(30, 4, 0.75, 18, K) -> kickMark 8, deduct 6, stubMark 12
        viewModel.setAngle(BendKind.KICK90, 30.0)
        viewModel.setKickOffset(BendKind.KICK90, 4.0)
        viewModel.setTradeSize(BendKind.KICK90, 0.75)
        viewModel.setKick90Stub(BendKind.KICK90, 18.0)

        val entry = viewModel.saveHistoryEntry(BendKind.KICK90, AppUnit.INCHES, kleinBender)
        assertEquals("30° Kick + 90°", entry.label)
        assertEquals("Kick offset 4\" · Stub 18\" · 3/4\"", entry.inputSummary)
        assertEquals("Kick mark 8.00\" from start · stub mark 12.00\" from end", entry.resultSummary)
    }

    @Test
    fun testSegmentedSaveSummary() {
        // segmented(90, 24, 6) -> 6 shots at 18.0° · 7.51" apart
        viewModel.setTotalAngle(BendKind.SEGMENTED, 90.0)
        viewModel.setRadius(BendKind.SEGMENTED, 24.0)
        viewModel.setShots(BendKind.SEGMENTED, 6)

        val entry = viewModel.saveHistoryEntry(BendKind.SEGMENTED, AppUnit.INCHES, kleinBender)
        assertEquals("Multi-Shot 90°", entry.label)
        assertEquals("Sweep 90° · Radius 24\" · 6 shots", entry.inputSummary)
        assertEquals("6 shots at 18.0° · 7.51\" apart", entry.resultSummary)
    }

    @Test
    fun testSaddle4SaveSummary() {
        // saddle4(3, 8, G, 1) -> Inner 8.00" apart · outer 7.50" beyond each
        viewModel.setDepth(BendKind.SADDLE4, 3.0)
        viewModel.setObstructionWidth(BendKind.SADDLE4, 8.0)
        viewModel.setTradeSize(BendKind.SADDLE4, 1.0)

        val entry = viewModel.saveHistoryEntry(BendKind.SADDLE4, AppUnit.INCHES, greenleeBender)
        assertEquals("4-Point Saddle", entry.label)
        assertEquals("Depth 3\" · Width 8\" · 1\"", entry.inputSummary)
        assertEquals("Inner 8.00\" apart · outer 7.50\" beyond each", entry.resultSummary)
    }

    @Test
    fun testRollingSaveSummary() {
        // rolling(30, 6, 4, K, 0.75) -> True offset 7.21" · roll 33.7° · marks 14.42" apart
        viewModel.setAngle(BendKind.ROLLING, 30.0)
        viewModel.setRollingVertical(BendKind.ROLLING, 6.0)
        viewModel.setRollingHorizontal(BendKind.ROLLING, 4.0)
        viewModel.setTradeSize(BendKind.ROLLING, 0.75)

        val entry = viewModel.saveHistoryEntry(BendKind.ROLLING, AppUnit.INCHES, kleinBender)
        assertEquals("30° Rolling Offset", entry.label)
        assertEquals("Vertical 6\" · Horizontal 4\" · 3/4\"", entry.inputSummary)
        assertEquals("True offset 7.21\" · roll 33.7° · marks 14.42\" apart", entry.resultSummary)
    }

    @Test
    fun testWireFillSaveSummary() {
        // wirefill(0.75, "12", 3) -> 3 × 12 AWG in 0.75" EMT · 7.5% fill
        viewModel.setWireConduitSize(BendKind.WIREFILL, 0.75)
        viewModel.setWireAwg(BendKind.WIREFILL, "12")
        viewModel.setWireCount(BendKind.WIREFILL, 3)

        val entry = viewModel.saveHistoryEntry(BendKind.WIREFILL, AppUnit.INCHES, kleinBender)
        assertEquals("Wire Fill", entry.label)
        assertEquals("3 × 12 AWG in 3/4\" EMT", entry.inputSummary)
        assertEquals("3 × 12 AWG in 0.75\" EMT · 7.5% fill", entry.resultSummary)
    }

    @Test
    fun testTradeSizeClampingOnBenderChange() {
        viewModel.setTradeSize(BendKind.OFFSET, 0.75)
        assertEquals(0.75, viewModel.getState(BendKind.OFFSET).tradeSizeIn, 1e-9)

        viewModel.clampTradeSize(itoolcoBender, BendKind.OFFSET)
        assertEquals(1.0, viewModel.getState(BendKind.OFFSET).tradeSizeIn, 1e-9)
    }

    @Test
    fun testResetSaved() {
        viewModel.setOffset(BendKind.OFFSET, 4.0)
        viewModel.saveHistoryEntry(BendKind.OFFSET, AppUnit.INCHES, kleinBender)
        assertTrue(viewModel.getState(BendKind.OFFSET).saved)

        viewModel.resetSaved(BendKind.OFFSET)
        assertFalse(viewModel.getState(BendKind.OFFSET).saved)
    }

    @Test
    fun testInputSummaryWithDifferentUnits() {
        viewModel.setOffset(BendKind.OFFSET, 4.0)
        viewModel.setTradeSize(BendKind.OFFSET, 0.75)

        val mmEntry = viewModel.saveHistoryEntry(BendKind.OFFSET, AppUnit.MM, kleinBender)
        assertEquals("Offset 102 mm · 3/4\"", mmEntry.inputSummary)

        val ftInEntry = viewModel.saveHistoryEntry(BendKind.OFFSET, AppUnit.FEET_INCHES, kleinBender)
        assertEquals("Offset 4\" · 3/4\"", ftInEntry.inputSummary)
    }
}
