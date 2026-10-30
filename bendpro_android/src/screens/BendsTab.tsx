import { useState } from 'react'
import type { Bender, BendKind, HistoryEntry, Unit } from '../types'
import HomeHeader from '../components/HomeHeader'
import DetailHeader from '../components/DetailHeader'
import HomeScreen from './HomeScreen'
import BendDetailScreen from './BendDetailScreen'
import BendersScreen from './BendersScreen'
import { BENDERS } from '../data/benders'

type Sub =
  | { mode: 'home' }
  | { mode: 'detail'; kind: BendKind }
  | { mode: 'benders'; returnTo: BendKind }

const TITLE: Record<BendKind, string> = {
  offset: 'Offset',
  ninety: '90° Bend',
  kick: 'Kick',
  saddle3: '3-Point Saddle',
  kick90: 'Kick + 90°',
  segmented: 'Multi-Shot',
  saddle4: '4-Point Saddle',
  rolling: 'Rolling Offset',
  wirefill: 'Wire Fill',
}

export default function BendsTab({
  unit,
  benderId,
  onSelectBender,
  onSaveHistory,
}: {
  unit: Unit
  benderId: string
  onSelectBender: (id: string) => void
  onSaveHistory: (entry: HistoryEntry) => void
}) {
  const [sub, setSub] = useState<Sub>({ mode: 'home' })
  const bender: Bender = BENDERS.find((b) => b.id === benderId) ?? BENDERS[0]

  if (sub.mode === 'home') {
    return (
      <>
        <HomeHeader />
        <div className="app-main">
          <HomeScreen onSelectCore={(kind) => setSub({ mode: 'detail', kind })} />
        </div>
      </>
    )
  }

  if (sub.mode === 'benders') {
    return (
      <>
        <DetailHeader title="Select Bender" onBack={() => setSub({ mode: 'detail', kind: sub.returnTo })} />
        <div className="app-main">
          <BendersScreen
            selectedId={benderId}
            onSelect={(id) => {
              onSelectBender(id)
              setSub({ mode: 'detail', kind: sub.returnTo })
            }}
          />
        </div>
      </>
    )
  }

  // detail
  return (
    <>
      <DetailHeader title={TITLE[sub.kind]} onBack={() => setSub({ mode: 'home' })} onToggleSave={() => {}} />
      <div className="app-main">
        <BendDetailScreen
          kind={sub.kind}
          unit={unit}
          bender={bender}
          onOpenBenderPicker={() => setSub({ mode: 'benders', returnTo: sub.kind })}
          onSaveHistory={onSaveHistory}
        />
      </div>
    </>
  )
}
