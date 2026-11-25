package com.bendpro.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.bendpro.core.AppUnit
import com.bendpro.core.HistoryEntry
import com.bendpro.data.DataStoreRepository
import com.bendpro.data.PersistedState
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class AppViewModel(
    private val repository: DataStoreRepository
) : ViewModel() {

    val state: StateFlow<PersistedState> = repository.stateFlow
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = PersistedState()
        )

    fun setUnit(unit: AppUnit) {
        viewModelScope.launch {
            repository.updateUnit(unit)
        }
    }

    fun setBenderId(benderId: String) {
        viewModelScope.launch {
            repository.updateBenderId(benderId)
        }
    }

    fun addHistory(entry: HistoryEntry) {
        viewModelScope.launch {
            repository.addHistoryEntry(entry)
        }
    }

    fun clearHistory() {
        viewModelScope.launch {
            repository.clearHistory()
        }
    }

    fun setDarkOptimized(enabled: Boolean) {
        viewModelScope.launch {
            repository.updateDarkOptimized(enabled)
        }
    }

    class Factory(private val repository: DataStoreRepository) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            return AppViewModel(repository) as T
        }
    }
}
