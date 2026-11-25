package com.bendpro.data

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.emptyPreferences
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.bendpro.core.AppUnit
import com.bendpro.core.HistoryEntry
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.map
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.io.IOException

val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "bendpro_prefs")

class DataStoreRepository(
    private val dataStore: DataStore<Preferences>
) {
    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
        coerceInputValues = true
        encodeDefaults = true
    }

    companion object {
        val KEY_DATA = stringPreferencesKey("bendpro:v1")
    }

    val stateFlow: Flow<PersistedState> = dataStore.data
        .catch { exception ->
            if (exception is IOException) {
                emit(emptyPreferences())
            } else {
                throw exception
            }
        }
        .map { preferences ->
            val jsonString = preferences[KEY_DATA]
            if (jsonString.isNullOrEmpty()) {
                PersistedState()
            } else {
                try {
                    json.decodeFromString<PersistedState>(jsonString)
                } catch (e: Exception) {
                    PersistedState()
                }
            }
        }

    suspend fun updateUnit(unit: AppUnit) {
        updateState { it.copy(unit = unit.id) }
    }

    suspend fun updateBenderId(benderId: String) {
        updateState { it.copy(benderId = benderId) }
    }

    suspend fun addHistoryEntry(entry: HistoryEntry) {
        updateState { it.copy(history = it.history + entry) }
    }

    suspend fun clearHistory() {
        updateState { it.copy(history = emptyList()) }
    }

    suspend fun updateDarkOptimized(enabled: Boolean) {
        updateState { it.copy(darkOptimized = enabled) }
    }

    private suspend fun updateState(transform: (PersistedState) -> PersistedState) {
        dataStore.edit { preferences ->
            val currentJson = preferences[KEY_DATA]
            val currentState = if (currentJson.isNullOrEmpty()) {
                PersistedState()
            } else {
                try {
                    json.decodeFromString<PersistedState>(currentJson)
                } catch (e: Exception) {
                    PersistedState()
                }
            }
            val newState = transform(currentState)
            preferences[KEY_DATA] = json.encodeToString(newState)
        }
    }
}
