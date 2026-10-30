export default function DetailHeader({
  title,
  onBack,
  saved,
  onToggleSave,
}: {
  title: string
  onBack: () => void
  saved?: boolean
  onToggleSave?: () => void
}) {
  return (
    <header className="detail-header hairline-bottom">
      <button type="button" className="icon-button" onClick={onBack} aria-label="Back">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
          <path d="M15 5 8 12l7 7" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      </button>
      <span className="detail-header-title">{title}</span>
      <button
        type="button"
        className="icon-button"
        aria-label="Save"
        onClick={onToggleSave}
        style={{ visibility: onToggleSave ? 'visible' : 'hidden' }}
      >
        <svg width="19" height="19" viewBox="0 0 24 24" fill={saved ? 'currentColor' : 'none'} style={{ color: saved ? 'var(--accent)' : undefined }}>
          <path d="M6 4h12a1 1 0 0 1 1 1v15l-7-4-7 4V5a1 1 0 0 1 1-1Z" stroke="currentColor" strokeWidth="1.6" strokeLinejoin="round" />
        </svg>
      </button>
    </header>
  )
}
