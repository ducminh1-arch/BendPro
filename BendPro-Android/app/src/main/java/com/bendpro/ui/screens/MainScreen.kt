package com.bendpro.ui.screens

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import com.bendpro.core.BENDERS
import com.bendpro.core.BendKind
import com.bendpro.ui.components.BottomNav
import com.bendpro.ui.components.DetailHeader
import com.bendpro.ui.components.HomeHeader
import com.bendpro.ui.components.ScreenTab
import com.bendpro.ui.components.SimpleHeader
import com.bendpro.ui.theme.BgVoid
import com.bendpro.ui.viewmodel.AppViewModel
import com.bendpro.ui.viewmodel.DetailViewModel

sealed interface BendsRoute {
    data object Home : BendsRoute
    data class Detail(val kind: BendKind) : BendsRoute
    data class BenderPicker(val returnTo: BendKind) : BendsRoute
}

@Composable
fun MainScreen(
    viewModel: AppViewModel,
    modifier: Modifier = Modifier,
    detailViewModel: DetailViewModel = viewModel()
) {
    val state by viewModel.state.collectAsState()
    var activeTab by remember { mutableStateOf(ScreenTab.BENDS) }
    var bendsRoute by remember { mutableStateOf<BendsRoute>(BendsRoute.Home) }

    // System Back Handler implementation
    when {
        activeTab == ScreenTab.BENDS && bendsRoute is BendsRoute.BenderPicker -> {
            BackHandler {
                val picker = bendsRoute as BendsRoute.BenderPicker
                bendsRoute = BendsRoute.Detail(picker.returnTo)
            }
        }
        activeTab == ScreenTab.BENDS && bendsRoute is BendsRoute.Detail -> {
            BackHandler {
                val current = (bendsRoute as BendsRoute.Detail).kind
                detailViewModel.resetToDefaults(current)
                bendsRoute = BendsRoute.Home
            }
        }
        activeTab != ScreenTab.BENDS -> {
            BackHandler {
                activeTab = ScreenTab.BENDS
            }
        }
    }

    Scaffold(
        modifier = modifier.fillMaxSize(),
        topBar = {
            when (activeTab) {
                ScreenTab.BENDS -> {
                    when (val route = bendsRoute) {
                        is BendsRoute.Home -> {
                            HomeHeader()
                        }
                        is BendsRoute.Detail -> {
                            val title = TITLE_MAP[route.kind] ?: "Bend Detail"
                            DetailHeader(
                                title = title,
                                onBack = {
                                    detailViewModel.resetToDefaults(route.kind)
                                    bendsRoute = BendsRoute.Home
                                }
                            )
                        }
                        is BendsRoute.BenderPicker -> {
                            DetailHeader(
                                title = "Select Bender",
                                onBack = { bendsRoute = BendsRoute.Detail(route.returnTo) }
                            )
                        }
                    }
                }
                ScreenTab.HISTORY -> {
                    SimpleHeader(title = "History")
                }
                ScreenTab.SETTINGS -> {
                    SimpleHeader(title = "Settings")
                }
            }
        },
        bottomBar = {
            BottomNav(
                activeTab = activeTab,
                onTabSelected = { newTab ->
                    activeTab = newTab
                }
            )
        },
        containerColor = BgVoid
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(BgVoid)
                .padding(innerPadding)
        ) {
            when (activeTab) {
                ScreenTab.BENDS -> {
                    val selectedBender = remember(state.benderId) {
                        BENDERS.find { it.id == state.benderId } ?: BENDERS.first()
                    }

                    when (val route = bendsRoute) {
                        is BendsRoute.Home -> {
                            HomeScreen(
                                onSelectKind = { kind ->
                                    detailViewModel.resetToDefaults(kind)
                                    bendsRoute = BendsRoute.Detail(kind)
                                }
                            )
                        }
                        is BendsRoute.Detail -> {
                            DetailScreen(
                                kind = route.kind,
                                unit = state.appUnit,
                                bender = selectedBender,
                                viewModel = detailViewModel,
                                onOpenBenderPicker = {
                                    bendsRoute = BendsRoute.BenderPicker(route.kind)
                                },
                                onSaveHistory = { entry ->
                                    viewModel.addHistory(entry)
                                }
                            )
                        }
                        is BendsRoute.BenderPicker -> {
                            BenderPickerScreen(
                                selectedId = state.benderId,
                                onSelectBender = { benderId ->
                                    viewModel.setBenderId(benderId)
                                    bendsRoute = BendsRoute.Detail(route.returnTo)
                                }
                            )
                        }
                    }
                }
                ScreenTab.HISTORY -> {
                    HistoryScreen(
                        entries = state.history,
                        onClearHistory = {
                            viewModel.clearHistory()
                        }
                    )
                }
                ScreenTab.SETTINGS -> {
                    SettingsScreen(
                        unit = state.appUnit,
                        onUnitChange = { newUnit ->
                            viewModel.setUnit(newUnit)
                        },
                        darkOptimized = state.darkOptimized,
                        onToggleDark = { enabled ->
                            viewModel.setDarkOptimized(enabled)
                        }
                    )
                }
            }
        }
    }
}
