package com.bendpro.data

import com.bendpro.core.AppUnit
import com.bendpro.core.BENDERS
import com.bendpro.core.HistoryEntry
import kotlinx.serialization.Serializable

@Serializable
data class PersistedState(
    val unit: String = "in",
    val benderId: String = BENDERS.first().id,
    val history: List<HistoryEntry> = emptyList(),
    val darkOptimized: Boolean = true
) {
    val appUnit: AppUnit
        get() = AppUnit.fromId(unit)
}
