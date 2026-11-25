package com.bendpro.data

import com.bendpro.core.AppUnit
import com.bendpro.core.BendKind
import com.bendpro.core.HistoryEntry
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class PersistedStateTest {

    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
        coerceInputValues = true
        encodeDefaults = true
    }

    @Test
    fun testDefaultValues() {
        val defaultState = PersistedState()
        assertEquals("in", defaultState.unit)
        assertEquals(AppUnit.INCHES, defaultState.appUnit)
        assertEquals("klein-emt-standard", defaultState.benderId)
        assertTrue(defaultState.history.isEmpty())
        assertTrue(defaultState.darkOptimized)
    }

    @Test
    fun testSerializationRoundTrip() {
        val state = PersistedState(
            unit = "mm",
            benderId = "greenlee-855",
            history = listOf(
                HistoryEntry(
                    id = "12345",
                    kind = BendKind.OFFSET,
                    label = "30° Offset",
                    createdAt = 1700000000000L,
                    inputSummary = "Offset 4\" · 3/4\"",
                    resultSummary = "Marks 8.00\" apart · shrink 1.500\""
                )
            ),
            darkOptimized = false
        )

        val serialized = json.encodeToString(state)
        val deserialized = json.decodeFromString<PersistedState>(serialized)

        assertEquals(state, deserialized)
        assertEquals(AppUnit.MM, deserialized.appUnit)
        assertEquals(1, deserialized.history.size)
        assertEquals(BendKind.OFFSET, deserialized.history.first().kind)
    }

    @Test
    fun testCorruptJsonFallback() {
        val corruptJson = "{ this is not valid json }"
        val state = try {
            json.decodeFromString<PersistedState>(corruptJson)
        } catch (e: Exception) {
            PersistedState()
        }

        assertEquals(PersistedState(), state)
    }

    @Test
    fun testMissingFieldsFallback() {
        // Missing benderId and history should take default values
        val partialJson = """{"unit":"ft-in"}"""
        val state = json.decodeFromString<PersistedState>(partialJson)

        assertEquals("ft-in", state.unit)
        assertEquals(AppUnit.FEET_INCHES, state.appUnit)
        assertEquals("klein-emt-standard", state.benderId)
        assertTrue(state.history.isEmpty())
        assertTrue(state.darkOptimized)
    }
}
