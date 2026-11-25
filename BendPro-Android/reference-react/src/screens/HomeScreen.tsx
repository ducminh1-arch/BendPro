import type { ReactNode } from 'react'
import type { BendKind } from '../types'

const CORE: { id: BendKind; title: string; sub: string; icon: ReactNode }[] = [
  {
    id: 'offset',
    title: 'Offset',
    sub: 'Two bends to clear an obstacle vertically',
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
        <path d="M4 19h4l6-10h4l4-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    ),
  },
  {
    id: 'ninety',
    title: '90° Bend',
    sub: 'Stub-up from floor or wall',
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
        <path d="M6 4v10a4 4 0 0 0 4 4h9" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    ),
  },
  {
    id: 'saddle3',
    title: '3-Point Saddle',
    sub: 'Over a round or square obstruction',
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
        <path d="M3 17c2 0 2-9 5-9s2 6 4 6 1-6 4-6 3 9 5 9" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    ),
  },
  {
    id: 'kick',
    title: 'Kick',
    sub: 'Single angled bend',
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
        <path d="M4 19h6l10-14" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    ),
  },
]

const ADVANCED: { id: BendKind; title: string; sub: string; icon: ReactNode }[] = [
  {
    id: 'kick90',
    title: 'Kick + 90°',
    sub: 'Kick with a stub-up at the end',
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
        <path d="M4 19h5l6-9v0a4 4 0 0 1 4-4h1" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    ),
  },
  {
    id: 'segmented',
    title: 'Multi-Shot',
    sub: 'Segmented bend for large radius',
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
        <path d="M4 5h16M4 10.5h16M4 16h10M4 21h6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
      </svg>
    ),
  },
  {
    id: 'saddle4',
    title: '4-Point Saddle',
    sub: 'Flat-topped, wide obstruction',
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
        <path d="M3 17c2 0 2-8 4.5-8h9c2.5 0 2.5 8 4.5 8" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    ),
  },
  {
    id: 'rolling',
    title: 'Rolling Offset',
    sub: 'Offset across two planes',
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
        <path d="M4 20c4 0 3-16 8-16s3 12 8 12" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    ),
  },
]

const TOOLS: { id: BendKind; title: string; sub: string; icon: ReactNode }[] = [
  {
    id: 'wirefill',
    title: 'Wire Fill',
    sub: 'Conduit fill % vs NEC limit',
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
        <path d="M13 2 4 14h6l-1 8 9-12h-6l1-8z" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    ),
  },
]

function BendCard({ title, sub, icon, onClick }: { title: string; sub: string; icon: ReactNode; onClick: () => void }) {
  return (
    <button type="button" className="bend-card" onClick={onClick}>
      <span className="bend-card-icon">{icon}</span>
      <span className="bend-card-text">
        <span className="bend-card-title">{title}</span>
        <span className="bend-card-sub">{sub}</span>
      </span>
    </button>
  )
}

export default function HomeScreen({
  onSelectCore,
}: {
  onSelectCore: (kind: BendKind) => void
}) {
  return (
    <div className="screen">
      <span className="section-label">Core Bends</span>
      <div className="bend-grid">
        {CORE.map((c) => (
          <BendCard key={c.id} title={c.title} sub={c.sub} icon={c.icon} onClick={() => onSelectCore(c.id)} />
        ))}
      </div>

      <span className="section-label">Advanced Bends</span>
      <div className="bend-grid">
        {ADVANCED.map((a) => (
          <BendCard key={a.id} title={a.title} sub={a.sub} icon={a.icon} onClick={() => onSelectCore(a.id)} />
        ))}
      </div>

      <span className="section-label">Tools</span>
      <div className="bend-grid">
        {TOOLS.map((t) => (
          <BendCard key={t.id} title={t.title} sub={t.sub} icon={t.icon} onClick={() => onSelectCore(t.id)} />
        ))}
      </div>
    </div>
  )
}
