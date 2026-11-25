package com.bendpro.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import com.bendpro.data.DataStoreRepository
import com.bendpro.data.dataStore
import com.bendpro.ui.screens.MainScreen
import com.bendpro.ui.theme.BendProTheme
import com.bendpro.ui.viewmodel.AppViewModel

class MainActivity : ComponentActivity() {

    private val viewModel: AppViewModel by viewModels {
        AppViewModel.Factory(DataStoreRepository(applicationContext.dataStore))
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen()
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            BendProTheme {
                MainScreen(viewModel = viewModel)
            }
        }
    }
}
