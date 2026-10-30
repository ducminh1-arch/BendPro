import { useMemo, useState } from 'react'
import type { Bender, BendKind, HistoryEntry, Unit } from '../types'
import BendDiagram from '../components/BendDiagram'
import StatusPill from '../components/StatusPill'
import BenderSelectRow from '../components/BenderSelectRow'
import ValueInput from '../components/ValueInput'
import {
  calcKick,
  calcKick90,
  calcNinety,
  calcOffset,
  calcRollingOffset,
  calcSaddle3,
  calcSaddle4,
  calcSegmented,
  calcWireFill,
  summarize,
  OFFSET_ANGLES,
  WIRE_AWG_OPTIONS,
} from '../lib/calculations'
import { TRADE_SIZES_IN, tradeSizeLabel } from '../data/benders'
import { formatLength } from '../lib/units'

const LEAD_IN = 3 // fixed starting mark from the reference end of conduit

/** Plain numeric field for non-length values (degrees, shot counts) that shouldn't run through unit/fraction formatting. */
function PlainField({
  label,
  suffix,
  value,
  onChange,
  min,
  max,
}: {
  label: string
  suffix: string
  value: number
  onChange: (v: number) => void
  min?: number
  max?: number
}) {
  return (
    <label className="simple-input-row" style={{ cursor: 'text' }}>
      <span className="simple-input-head">
        <span className="simple-input-label">{label}</span>
        <span className="simple-input-value">
          <input
            type="number"
            value={value}
            min={min}
            max={max}
            onChange={(e) => {
              const n = parseFloat(e.target.value)
              onChange(isNaN(n) ? 0 : n)
            }}
            style={{
              width: '64px',
              textAlign: 'right',
              background: 'transparent',
              border: 'none',
              outline: 'none',
              color: 'inherit',
              font: 'inherit',
            }}
          />{' '}
          {suffix}
        </span>
      </span>
    </label>
  )
}

interface Props {
  kind: BendKind
  unit: Unit
  bender: Bender
  onOpenBenderPicker: () => void
  onSaveHistory: (entry: HistoryEntry) => void
}

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

export default function BendDetailScreen({ kind, unit, bender, onOpenBenderPicker, onSaveHistory }: Props) {
  const [tradeSizeIn, setTradeSizeIn] = useState(0.75)
  const [angleDeg, setAngleDeg] = useState(30)
  const [offsetIn, setOffsetIn] = useState(4)
  const [stubHeightIn, setStubHeightIn] = useState(12)
  const [riseIn, setRiseIn] = useState(6)
  const [depthIn, setDepthIn] = useState(3)
  const [kickOffsetIn, setKickOffsetIn] = useState(4)
  const [kick90StubIn, setKick90StubIn] = useState(18)
  const [totalAngleDeg, setTotalAngleDeg] = useState(90)
  const [radiusIn, setRadiusIn] = useState(24)
  const [shots, setShots] = useState(6)
  const [obstructionWidthIn, setObstructionWidthIn] = useState(8)
  const [rollingVerticalIn, setRollingVerticalIn] = useState(6)
  const [rollingHorizontalIn, setRollingHorizontalIn] = useState(4)
  const [wireConduitSizeIn, setWireConduitSizeIn] = useState(0.75)
  const [wireAwg, setWireAwg] = useState('12')
  const [wireCount, setWireCount] = useState(3)
  const [saved, setSaved] = useState(false)

  const result = useMemo(() => {
    switch (kind) {
      case 'offset':
        return calcOffset(angleDeg, offsetIn, bender, tradeSizeIn)
      case 'ninety':
        return calcNinety(tradeSizeIn, stubHeightIn)
      case 'kick':
        return calcKick(angleDeg, riseIn, bender, tradeSizeIn)
      case 'saddle3':
        return calcSaddle3(depthIn, bender, tradeSizeIn)
      case 'kick90':
        return calcKick90(angleDeg, kickOffsetIn, tradeSizeIn, kick90StubIn, bender)
      case 'segmented':
        return calcSegmented(totalAngleDeg, radiusIn, shots)
      case 'saddle4':
        return calcSaddle4(depthIn, obstructionWidthIn, bender, tradeSizeIn)
      case 'rolling':
        return calcRollingOffset(angleDeg, rollingVerticalIn, rollingHorizontalIn, bender, tradeSizeIn)
      case 'wirefill':
        return calcWireFill(wireConduitSizeIn, wireAwg, wireCount)
    }
  }, [
    kind,
    angleDeg,
    offsetIn,
    stubHeightIn,
    riseIn,
    depthIn,
    kickOffsetIn,
    kick90StubIn,
    totalAngleDeg,
    radiusIn,
    shots,
    obstructionWidthIn,
    rollingVerticalIn,
    rollingHorizontalIn,
    wireConduitSizeIn,
    wireAwg,
    wireCount,
    bender,
    tradeSizeIn,
  ])

  function save() {
    const label =
      kind === 'offset'
        ? `${angleDeg}° Offset`
        : kind === 'ninety'
        ? '90° Bend'
        : kind === 'kick'
        ? `${angleDeg}° Kick`
        : kind === 'saddle3'
        ? '3-Point Saddle'
        : kind === 'kick90'
        ? `${angleDeg}° Kick + 90°`
        : kind === 'segmented'
        ? 'Multi-Shot 90°'
        : kind === 'saddle4'
        ? '4-Point Saddle'
        : kind === 'rolling'
        ? `${angleDeg}° Rolling Offset`
        : 'Wire Fill'

    const inputSummary =
      kind === 'offset'
        ? `Offset ${formatLength(offsetIn, unit)} · ${tradeSizeLabel(tradeSizeIn)}`
        : kind === 'ninety'
        ? `Stub ${formatLength(stubHeightIn, unit)} · ${tradeSizeLabel(tradeSizeIn)}`
        : kind === 'kick'
        ? `Rise ${formatLength(riseIn, unit)} · ${tradeSizeLabel(tradeSizeIn)}`
        : kind === 'saddle3'
        ? `Depth ${formatLength(depthIn, unit)} · ${tradeSizeLabel(tradeSizeIn)}`
        : kind === 'kick90'
        ? `Kick offset ${formatLength(kickOffsetIn, unit)} · Stub ${formatLength(kick90StubIn, unit)} · ${tradeSizeLabel(tradeSizeIn)}`
        : kind === 'segmented'
        ? `Sweep ${totalAngleDeg}° · Radius ${formatLength(radiusIn, unit)} · ${shots} shots`
        : kind === 'saddle4'
        ? `Depth ${formatLength(depthIn, unit)} · Width ${formatLength(obstructionWidthIn, unit)} · ${tradeSizeLabel(tradeSizeIn)}`
        : kind === 'rolling'
        ? `Vertical ${formatLength(rollingVerticalIn, unit)} · Horizontal ${formatLength(rollingHorizontalIn, unit)} · ${tradeSizeLabel(tradeSizeIn)}`
        : `${wireCount} × ${wireAwg} AWG in ${tradeSizeLabel(wireConduitSizeIn)} EMT`

    onSaveHistory({
      id: `${Date.now()}`,
      kind,
      label,
      createdAt: Date.now(),
      inputSummary,
      resultSummary: summarize(result),
    })
    setSaved(true)
  }

  return (
    <div className="screen">
      {kind !== 'wirefill' && (
        <>
          <BenderSelectRow bender={bender} tradeSizeIn={tradeSizeIn} onClick={onOpenBenderPicker} />

          <div className="trade-size-row">
            <span className="trade-size-label">CONDUIT</span>
            <div className="trade-size-chips">
              {TRADE_SIZES_IN.filter((s) => bender.conduitSizesIn.includes(s)).map((s) => (
                <button
                  key={s}
                  type="button"
                  className={`trade-size-chip ${s === tradeSizeIn ? 'active' : ''}`}
                  onClick={() => setTradeSizeIn(s)}
                >
                  {tradeSizeLabel(s)}
                </button>
              ))}
            </div>
          </div>
        </>
      )}

      <div className="info-section">
        <span className="info-section-title">Inputs</span>

        {kind === 'offset' && (
          <ValueInput label="RISE" valueIn={offsetIn} onChangeIn={setOffsetIn} unit={unit} max={24} />
        )}
        {kind === 'ninety' && (
          <ValueInput label="STUB LENGTH" valueIn={stubHeightIn} onChangeIn={setStubHeightIn} unit={unit} max={60} />
        )}
        {kind === 'kick' && (
          <ValueInput label="RISE" valueIn={riseIn} onChangeIn={setRiseIn} unit={unit} max={24} />
        )}
        {kind === 'saddle3' && (
          <ValueInput label="OBSTRUCTION DEPTH" valueIn={depthIn} onChangeIn={setDepthIn} unit={unit} max={12} />
        )}
        {kind === 'kick90' && (
          <>
            <ValueInput label="KICK OFFSET" valueIn={kickOffsetIn} onChangeIn={setKickOffsetIn} unit={unit} max={12} />
            <ValueInput label="STUB LENGTH (FROM FINISHED END)" valueIn={kick90StubIn} onChangeIn={setKick90StubIn} unit={unit} max={60} />
          </>
        )}
        {kind === 'segmented' && (
          <>
            <PlainField label="TOTAL SWEEP ANGLE" suffix="°" value={totalAngleDeg} onChange={setTotalAngleDeg} min={1} max={180} />
            <ValueInput label="BEND RADIUS" valueIn={radiusIn} onChangeIn={setRadiusIn} unit={unit} max={60} />
            <PlainField label="NUMBER OF SHOTS" suffix="shots" value={shots} onChange={(v) => setShots(Math.max(2, Math.round(v)))} min={2} max={20} />
          </>
        )}
        {kind === 'saddle4' && (
          <>
            <ValueInput label="OBSTRUCTION DEPTH" valueIn={depthIn} onChangeIn={setDepthIn} unit={unit} max={12} />
            <ValueInput label="OBSTRUCTION WIDTH (FLAT TOP)" valueIn={obstructionWidthIn} onChangeIn={setObstructionWidthIn} unit={unit} max={36} />
          </>
        )}
        {kind === 'rolling' && (
          <>
            <ValueInput label="VERTICAL OFFSET" valueIn={rollingVerticalIn} onChangeIn={setRollingVerticalIn} unit={unit} max={24} />
            <ValueInput label="HORIZONTAL OFFSET" valueIn={rollingHorizontalIn} onChangeIn={setRollingHorizontalIn} unit={unit} max={24} />
          </>
        )}
        {kind === 'wirefill' && (
          <>
            <div className="trade-size-row">
              <span className="trade-size-label">CONDUIT SIZE (EMT)</span>
              <div className="trade-size-chips">
                {TRADE_SIZES_IN.map((s) => (
                  <button
                    key={s}
                    type="button"
                    className={`trade-size-chip ${s === wireConduitSizeIn ? 'active' : ''}`}
                    onClick={() => setWireConduitSizeIn(s)}
                  >
                    {tradeSizeLabel(s)}
                  </button>
                ))}
              </div>
            </div>
            <div className="trade-size-row">
              <span className="trade-size-label">WIRE SIZE (AWG, THHN/THWN)</span>
              <div className="trade-size-chips">
                {WIRE_AWG_OPTIONS.map((a) => (
                  <button
                    key={a}
                    type="button"
                    className={`trade-size-chip ${a === wireAwg ? 'active' : ''}`}
                    onClick={() => setWireAwg(a)}
                  >
                    {a}
                  </button>
                ))}
              </div>
            </div>
            <PlainField label="NUMBER OF CONDUCTORS" suffix="ct" value={wireCount} onChange={(v) => setWireCount(Math.max(1, Math.round(v)))} min={1} max={40} />
          </>
        )}

        {(kind === 'offset' || kind === 'kick' || kind === 'kick90' || kind === 'rolling') && (
          <div className="angle-row">
            <span className="value-input-label">ANGLE</span>
            <div className="angle-chips">
              {OFFSET_ANGLES.map((a) => (
                <button
                  key={a}
                  type="button"
                  className={`angle-chip ${a === angleDeg ? 'active' : ''}`}
                  onClick={() => setAngleDeg(a)}
                >
                  {a}°
                </button>
              ))}
            </div>
          </div>
        )}
      </div>

      {result.kind === 'offset' && (
        <div className="info-section">
          <span className="info-section-title">Marks on Conduit</span>
          <div className="info-list">
            <div className="info-row">
              <span className="info-row-label"><span className="info-row-dot" />Mark 1</span>
              <span className="info-row-value mono">{formatLength(LEAD_IN, unit)}</span>
            </div>
            <div className="info-row">
              <span className="info-row-label"><span className="info-row-dot" />Mark 2</span>
              <span className="info-row-value mono">{formatLength(LEAD_IN + result.distanceBetweenBendsIn, unit)}</span>
            </div>
          </div>
          <span className="info-section-title">Calculations</span>
          <div className="info-list">
            <div className="info-row">
              <span className="info-row-label">Spacing</span>
              <span className="info-row-value plain mono">{formatLength(result.distanceBetweenBendsIn, unit)}</span>
            </div>
            <div className="info-row">
              <span className="info-row-label">Shrink</span>
              <span className="info-row-value plain mono">{formatLength(result.shrinkIn, unit, 3)}</span>
            </div>
          </div>
        </div>
      )}

      {result.kind === 'ninety' && (
        <div className="info-section">
          <span className="info-section-title">Marks on Conduit</span>
          <div className="info-list">
            <div className="info-row">
              <span className="info-row-label"><span className="info-row-dot" />Mark 1</span>
              <span className="info-row-value mono">{formatLength(result.markIn, unit)}</span>
            </div>
          </div>
          <span className="info-section-title">Calculations</span>
          <div className="info-list">
            <div className="info-row">
              <span className="info-row-label">Deduct</span>
              <span className="info-row-value plain mono">{formatLength(result.deductIn, unit)}</span>
            </div>
            <div className="info-row">
              <span className="info-row-label">Gain</span>
              <span className="info-row-value plain mono">{formatLength(Math.max(result.deductIn * 0.36, 0.1), unit, 2)}</span>
            </div>
            <div className="info-row">
              <span className="info-row-label">Mark</span>
              <span className="info-row-value plain mono">{formatLength(result.markIn, unit)}</span>
            </div>
          </div>
        </div>
      )}

      {result.kind === 'kick' && (
        <div className="info-section">
          <span className="info-section-title">Marks on Conduit</span>
          <div className="info-list">
            <div className="info-row">
              <span className="info-row-label"><span className="info-row-dot" />Mark</span>
              <span className="info-row-value mono">{formatLength(result.distanceToMarkIn, unit)}</span>
            </div>
          </div>
          <span className="info-section-title">Calculations</span>
          <div className="info-list">
            <div className="info-row">
              <span className="info-row-label">Gain</span>
              <span className="info-row-value plain mono">{formatLength(result.gainIn, unit, 3)}</span>
            </div>
          </div>
        </div>
      )}

      {result.kind === 'saddle3' && (
        <div className="info-section">
          <span className="info-section-title">Marks on Conduit</span>
          <div className="info-list">
            <div className="info-row">
              <span className="info-row-label"><span className="info-row-dot" />Center → Side</span>
              <span className="info-row-value mono">{formatLength(result.centerToSideIn, unit)}</span>
            </div>
          </div>
          <span className="info-section-title">Calculations</span>
          <div className="info-list">
            <div className="info-row">
              <span className="info-row-label">Total gain</span>
              <span className="info-row-value plain mono">{formatLength(result.totalGainIn, unit, 3)}</span>
            </div>
          </div>
        </div>
      )}

      {result.kind === 'kick90' && (
        <div className="info-section">
          <span className="info-section-title">Marks on Conduit</span>
          <div className="info-list">
            <div className="info-row">
              <span className="info-row-label"><span className="info-row-dot" />Mark 1 · from start</span>
              <span className="info-row-value mono">{formatLength(result.kickMarkIn, unit)}</span>
            </div>
            <div className="info-row">
              <span className="info-row-label"><span className="info-row-dot" />Mark 2 · from end</span>
              <span className="info-row-value mono">{formatLength(result.stubMarkIn, unit)}</span>
            </div>
          </div>
          <span className="info-section-title">Calculations</span>
          <div className="info-list">
            <div className="info-row">
              <span className="info-row-label">90° deduct</span>
              <span className="info-row-value plain mono">{formatLength(result.deductIn, unit)}</span>
            </div>
          </div>
        </div>
      )}

      {result.kind === 'segmented' && (
        <div className="info-section">
          <span className="info-section-title">Calculations</span>
          <div className="info-list">
            <div className="info-row">
              <span className="info-row-label">Angle per shot</span>
              <span className="info-row-value plain mono">{result.anglePerShotDeg.toFixed(1)}°</span>
            </div>
            <div className="info-row">
              <span className="info-row-label">Distance between shots</span>
              <span className="info-row-value plain mono">{formatLength(result.distanceBetweenShotsIn, unit)}</span>
            </div>
          </div>
        </div>
      )}

      {result.kind === 'saddle4' && (
        <div className="info-section">
          <span className="info-section-title">Marks on Conduit</span>
          <div className="info-list">
            <div className="info-row">
              <span className="info-row-label"><span className="info-row-dot" />Inner pair · spacing</span>
              <span className="info-row-value mono">{formatLength(result.innerSpacingIn, unit)}</span>
            </div>
            <div className="info-row">
              <span className="info-row-label"><span className="info-row-dot" />Outer · beyond each inner</span>
              <span className="info-row-value mono">{formatLength(result.outerFromInnerIn, unit)}</span>
            </div>
          </div>
          <span className="info-section-title">Calculations</span>
          <div className="info-list">
            <div className="info-row">
              <span className="info-row-label">All 4 bends</span>
              <span className="info-row-value plain mono">{result.sideAngleDeg}°</span>
            </div>
            <div className="info-row">
              <span className="info-row-label">Total gain</span>
              <span className="info-row-value plain mono">{formatLength(result.totalGainIn, unit, 3)}</span>
            </div>
          </div>
        </div>
      )}

      {result.kind === 'rolling' && (
        <div className="info-section">
          <span className="info-section-title">Marks on Conduit</span>
          <div className="info-list">
            <div className="info-row">
              <span className="info-row-label"><span className="info-row-dot" />Mark 1</span>
              <span className="info-row-value mono">{formatLength(LEAD_IN, unit)}</span>
            </div>
            <div className="info-row">
              <span className="info-row-label"><span className="info-row-dot" />Mark 2</span>
              <span className="info-row-value mono">{formatLength(LEAD_IN + result.distanceBetweenBendsIn, unit)}</span>
            </div>
          </div>
          <span className="info-section-title">Calculations</span>
          <div className="info-list">
            <div className="info-row">
              <span className="info-row-label">True offset</span>
              <span className="info-row-value plain mono">{formatLength(result.trueOffsetIn, unit)}</span>
            </div>
            <div className="info-row">
              <span className="info-row-label">Roll angle</span>
              <span className="info-row-value plain mono">{result.rollAngleDeg.toFixed(1)}°</span>
            </div>
            <div className="info-row">
              <span className="info-row-label">Shrink</span>
              <span className="info-row-value plain mono">{formatLength(result.shrinkIn, unit, 3)}</span>
            </div>
          </div>
        </div>
      )}

      {result.kind === 'wirefill' && (
        <div className="info-section">
          <span className="info-section-title">Calculations</span>
          <div className="info-list">
            <div className="info-row">
              <span className="info-row-label">Conduit area</span>
              <span className="info-row-value plain mono">{result.conduitAreaSqIn.toFixed(3)} sq in</span>
            </div>
            <div className="info-row">
              <span className="info-row-label">Conductor area</span>
              <span className="info-row-value plain mono">{result.totalConductorAreaSqIn.toFixed(4)} sq in</span>
            </div>
            <div className="info-row">
              <span className="info-row-label">Fill (max {result.maxFillPct}%)</span>
              <span className="info-row-value plain mono">{result.fillPct.toFixed(1)}%</span>
            </div>
          </div>
          <p style={{ fontSize: '11px', color: 'var(--text-tertiary)', lineHeight: 1.5, margin: '10px 2px 0' }}>
            EMT and THHN/THWN only, approximate NEC Chapter 9 subset — not verified against a specific code edition. Verify against the current NEC tables for other conduit or wire types.
          </p>
        </div>
      )}

      <div className="diagram-card">
        <BendDiagram result={result} />
      </div>

      <StatusPill feasibility={result.feasibility} />

      <button type="button" className="save-button" onClick={save}>
        {saved ? 'Saved ✓' : 'Save to history'}
      </button>
    </div>
  )
}
