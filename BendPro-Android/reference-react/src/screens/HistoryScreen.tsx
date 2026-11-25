import type { HistoryEntry } from '../types'

export default function HistoryScreen({
  entries,
  onClear,
}: {
  entries: HistoryEntry[]
  onClear: () => void
}) {
  if (entries.length === 0) {
    return (
      <div className="screen">
        <div className="empty-state">
          <span className="empty-state-title">No saved bends yet</span>
          <span className="empty-state-body">Calculations you save from the Bends tab will show up here, newest first.</span>
        </div>
      </div>
    )
  }

  return (
    <div className="screen">
      <div className="history-head">
        <span className="screen-intro" style={{ margin: 0 }}>
          {entries.length} saved
        </span>
        <button type="button" className="text-button" onClick={onClear}>
          Clear all
        </button>
      </div>
      <ul className="history-list">
        {entries
          .slice()
          .reverse()
          .map((e) => (
            <li key={e.id} className="history-item">
              <div className="history-item-row">
                <span className="history-item-label">{e.label}</span>
                <span className="history-item-time mono">
                  {new Date(e.createdAt).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}
                </span>
              </div>
              <span className="history-item-input mono">{e.inputSummary}</span>
              <span className="history-item-result mono">{e.resultSummary}</span>
            </li>
          ))}
      </ul>
    </div>
  )
}
