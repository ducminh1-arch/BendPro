import type { Bender } from '../types'
import { tradeSizeLabel } from '../data/benders'

export default function BenderSelectRow({
  bender,
  tradeSizeIn,
  onClick,
}: {
  bender: Bender
  tradeSizeIn: number
  onClick: () => void
}) {
  return (
    <button type="button" className="bender-select-row" onClick={onClick}>
      <span className="bender-select-icon">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
          <path d="M4 18c0-5 4-9 9-9h5" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" />
          <circle cx="18" cy="6" r="2.4" stroke="currentColor" strokeWidth="1.7" />
          <circle cx="4" cy="18" r="2.4" stroke="currentColor" strokeWidth="1.7" />
        </svg>
      </span>
      <span className="bender-select-label">
        {bender.brand} · {tradeSizeLabel(tradeSizeIn)}
      </span>
      <span className="bender-select-chevron">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
          <path d="m9 6 6 6-6 6" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      </span>
    </button>
  )
}
