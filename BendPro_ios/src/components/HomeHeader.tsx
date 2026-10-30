export default function HomeHeader() {
  return (
    <header className="home-header hairline-bottom">
      <span className="home-header-mark">
        BEND<span>PRO</span>
      </span>
      <button type="button" className="icon-button" aria-label="Info">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
          <circle cx="12" cy="12" r="9" stroke="currentColor" strokeWidth="1.6" />
          <path d="M12 11v5.5" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" />
          <circle cx="12" cy="8" r="1" fill="currentColor" />
        </svg>
      </button>
    </header>
  )
}
