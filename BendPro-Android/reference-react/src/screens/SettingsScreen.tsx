import type { Unit } from '../types'
import { UNIT_LABEL } from '../lib/units'

const UNITS: Unit[] = ['in', 'ft-in', 'mm']

export default function SettingsScreen({
  unit,
  onUnitChange,
  darkOptimized,
  onToggleDark,
}: {
  unit: Unit
  onUnitChange: (u: Unit) => void
  darkOptimized: boolean
  onToggleDark: (v: boolean) => void
}) {
  return (
    <div className="screen">
      <div className="settings-section">
        <span className="settings-section-title">Units</span>
        <div className="settings-option-row">
          {UNITS.map((u) => (
            <button
              key={u}
              type="button"
              className={`settings-pill ${u === unit ? 'active' : ''}`}
              onClick={() => onUnitChange(u)}
            >
              {UNIT_LABEL[u]}
            </button>
          ))}
        </div>
      </div>

      <div className="settings-section">
        <span className="settings-section-title">Display</span>
        <label className="settings-toggle-row">
          <div>
            <span className="settings-toggle-label">High-contrast dark mode</span>
            <span className="settings-toggle-hint">Optimized for bright job-site light and headlamps.</span>
          </div>
          <input type="checkbox" checked={darkOptimized} onChange={(e) => onToggleDark(e.target.checked)} />
        </label>
      </div>

      <div className="settings-section">
        <span className="settings-section-title">About</span>
        <p className="settings-about">
          BendPro runs the same centerline-radius engine for every calculation and diagram — offline, with no account
          and no data collection.
        </p>
      </div>
    </div>
  )
}
