import type { Bender } from '../types'
import { BENDERS, tradeSizeLabel } from '../data/benders'

export default function BendersScreen({
  selectedId,
  onSelect,
}: {
  selectedId: string
  onSelect: (id: string) => void
}) {
  return (
    <div className="screen">
      <p className="screen-intro">
        Select the bender you're working with. Centerline radius per shoe drives every calculation and QuickCheck result.
      </p>
      <div className="bender-list">
        {BENDERS.map((b: Bender) => (
          <button
            key={b.id}
            type="button"
            className={`bender-card ${b.id === selectedId ? 'active' : ''}`}
            onClick={() => onSelect(b.id)}
          >
            <div className="bender-card-top">
              <span className="bender-brand">{b.brand}</span>
              {b.id === selectedId && <span className="bender-selected-tag">SELECTED</span>}
            </div>
            <span className="bender-model">{b.model}</span>
            <div className="bender-sizes">
              {b.conduitSizesIn.map((s) => (
                <span key={s} className="bender-size-pill mono">
                  {tradeSizeLabel(s)}
                </span>
              ))}
            </div>
          </button>
        ))}
      </div>
    </div>
  )
}
