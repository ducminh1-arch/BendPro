import type { Feasibility } from '../types'

const LEVEL_LABEL: Record<Feasibility['level'], string> = {
  ok: 'VALID',
  warn: 'CHECK CLOSELY',
  danger: 'NOT POSSIBLE',
}

export default function StatusPill({ feasibility }: { feasibility: Feasibility }) {
  return (
    <span className={`status-pill status-pill-${feasibility.level}`} role="status" title={feasibility.message}>
      <svg className="status-pill-icon" viewBox="0 0 24 24" fill="none">
        {feasibility.level === 'ok' ? (
          <path d="M5 13l4 4L19 7" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" />
        ) : (
          <path d="M12 8v5M12 16.5h.01" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" />
        )}
      </svg>
      {LEVEL_LABEL[feasibility.level]}
    </span>
  )
}
