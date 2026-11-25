import { useEffect, useState } from 'react'
import type { HistoryEntry, Unit } from './types'
import BottomNav, { type Screen } from './components/BottomNav'
import BendsTab from './screens/BendsTab'
import HistoryScreen from './screens/HistoryScreen'
import SettingsScreen from './screens/SettingsScreen'
import { BENDERS } from './data/benders'
import './App.css'

const STORAGE_KEY = 'bendpro:v1'

interface Persisted {
  unit: Unit
  benderId: string
  history: HistoryEntry[]
  darkOptimized: boolean
}

function loadPersisted(): Persisted {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (raw) return JSON.parse(raw)
  } catch {
    // ignore corrupt storage
  }
  return { unit: 'in', benderId: BENDERS[0].id, history: [], darkOptimized: true }
}

const SCREEN_TITLE: Record<Screen, string> = {
  bends: 'Bends',
  history: 'History',
  settings: 'Settings',
}

export default function App() {
  const [screen, setScreen] = useState<Screen>('bends')
  const [state, setState] = useState<Persisted>(loadPersisted)

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state))
  }, [state])

  return (
    <div className="app-shell">
      {screen === 'bends' && (
        <BendsTab
          unit={state.unit}
          benderId={state.benderId}
          onSelectBender={(benderId) => setState((s) => ({ ...s, benderId }))}
          onSaveHistory={(entry) => setState((s) => ({ ...s, history: [...s.history, entry] }))}
        />
      )}

      {screen === 'history' && (
        <>
          <header className="home-header hairline-bottom">
            <span className="home-header-mark">{SCREEN_TITLE.history}</span>
          </header>
          <div className="app-main">
            <HistoryScreen entries={state.history} onClear={() => setState((s) => ({ ...s, history: [] }))} />
          </div>
        </>
      )}

      {screen === 'settings' && (
        <>
          <header className="home-header hairline-bottom">
            <span className="home-header-mark">{SCREEN_TITLE.settings}</span>
          </header>
          <div className="app-main">
            <SettingsScreen
              unit={state.unit}
              onUnitChange={(unit) => setState((s) => ({ ...s, unit }))}
              darkOptimized={state.darkOptimized}
              onToggleDark={(darkOptimized) => setState((s) => ({ ...s, darkOptimized }))}
            />
          </div>
        </>
      )}

      <BottomNav active={screen} onChange={setScreen} />
    </div>
  )
}
