import { useRef, useState } from 'react'
import type { Unit } from '../types'
import { formatLength } from '../lib/units'

type InputStyle = 'pad' | 'slider'

interface Props {
  label: string
  valueIn: number
  onChangeIn: (v: number) => void
  unit: Unit
  min?: number
  max?: number
  step?: number
}

const PAD_KEYS = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', '⌫']

export default function ValueInput({ label, valueIn, onChangeIn, unit, min = 0, max = 96, step = 0.125 }: Props) {
  const [expanded, setExpanded] = useState(false)
  const [style, setStyle] = useState<InputStyle>('pad')
  const [raw, setRaw] = useState(String(valueIn))
  const dragRef = useRef<HTMLDivElement>(null)
  const [dragging, setDragging] = useState(false)

  function commit(next: string) {
    setRaw(next)
    const n = parseFloat(next)
    onChangeIn(isNaN(n) ? 0 : n)
  }

  function pressKey(k: string) {
    if (k === '⌫') {
      const next = raw.slice(0, -1) || '0'
      commit(next)
      return
    }
    if (k === '.' && raw.includes('.')) return
    const next = raw === '0' && k !== '.' ? k : raw + k
    commit(next)
  }

  function handlePointer(clientX: number) {
    const el = dragRef.current
    if (!el) return
    const rect = el.getBoundingClientRect()
    const pct = Math.min(1, Math.max(0, (clientX - rect.left) / rect.width))
    const value = min + pct * (max - min)
    const snapped = Math.round(value / step) * step
    setRaw(snapped.toFixed(3))
    onChangeIn(snapped)
  }

  const pct = Math.min(1, Math.max(0, (valueIn - min) / (max - min))) * 100

  if (!expanded) {
    return (
      <button type="button" className="simple-input-row" onClick={() => setExpanded(true)}>
        <div className="simple-input-head">
          <span className="simple-input-label">{label}</span>
          <span className="simple-input-value mono">{formatLength(valueIn, unit)}</span>
        </div>
      </button>
    )
  }

  return (
    <div className="value-input">
      <div className="value-input-head">
        <span className="value-input-label">{label}</span>
        <div className="value-input-style-toggle">
          <button
            type="button"
            className={style === 'pad' ? 'active' : ''}
            onClick={() => setStyle('pad')}
            aria-pressed={style === 'pad'}
          >
            KEYPAD
          </button>
          <button
            type="button"
            className={style === 'slider' ? 'active' : ''}
            onClick={() => setStyle('slider')}
            aria-pressed={style === 'slider'}
          >
            SLIDE
          </button>
          <button type="button" onClick={() => setExpanded(false)} aria-label="Collapse">
            DONE
          </button>
        </div>
      </div>

      <div className="value-input-readout mono">
        {valueIn.toFixed(3)} <span className="value-input-unit">in</span>
      </div>

      {style === 'pad' ? (
        <div className="pad-grid">
          {PAD_KEYS.map((k) => (
            <button key={k} type="button" className="pad-key" onClick={() => pressKey(k)}>
              {k}
            </button>
          ))}
        </div>
      ) : (
        <div
          ref={dragRef}
          className="slider-track"
          onPointerDown={(e) => {
            setDragging(true)
            ;(e.target as HTMLElement).setPointerCapture(e.pointerId)
            handlePointer(e.clientX)
          }}
          onPointerMove={(e) => {
            if (dragging) handlePointer(e.clientX)
          }}
          onPointerUp={() => setDragging(false)}
        >
          <div className="slider-fill" style={{ width: `${pct}%` }} />
          <div className="slider-thumb" style={{ left: `${pct}%` }} />
        </div>
      )}
    </div>
  )
}
